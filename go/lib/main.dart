import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const LocalShareApp());
}

class LocalShareApp extends StatelessWidget {
  const LocalShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GO',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

// ======= Home Screen =======
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    DevicesScreen(),
    ChatsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
    await Permission.accessMediaLocation.request();
    await Permission.manageExternalStorage.request();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'Découvrir'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_outlined), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ======= Chats Screen =======
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});
  static List<ChatMessage> messages = [];
  static ValueNotifier<List<ChatMessage>> messageNotifier = ValueNotifier([]);

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class ChatMessage {
  final String content;
  final String sender;
  final DateTime timestamp;
  final bool isFile;
  final String? filePath;

  ChatMessage({
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isFile = false,
    this.filePath,
  });
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialiser avec les messages existants
    ChatsScreen.messageNotifier.value = List.from(ChatsScreen.messages);
  }

  void _openFile(String filePath) async {
    try {
      await OpenFilex.open(filePath);
    } catch (e) {
      Fluttertoast.showToast(msg: "Impossible d'ouvrir le fichier: $e");
    }
  }

  String _formatTime(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: ValueListenableBuilder(
        valueListenable: ChatsScreen.messageNotifier,
        builder: (context, messages, child) {
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ListTile(
                title: Text(message.content),
                subtitle: Text("De ${message.sender} • ${_formatTime(message.timestamp)}"),
                trailing: message.isFile
                    ? IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _openFile(message.filePath!),
                )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

// ======= Devices Screen =======
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});
  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final int udpPort = 4567; // Port pour la découverte UDP
  final int tcpPort = 4568; // Port pour les transferts TCP
  String? myIP;
  String deviceName = 'Unknown';
  late RawDatagramSocket udpSocket;
  Map<String, String> devices = {}; // IP -> Device Name
  ServerSocket? tcpServer;
  bool isScanning = false;
  final NetworkInfo _networkInfo = NetworkInfo();
  final Connectivity _connectivity = Connectivity();
  Timer? _broadcastTimer;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _getDeviceName();
    await getLocalIP();
    _initNetworkInfo();
  }

  Future<void> _getDeviceName() async {
    try {
      const platform = MethodChannel('com.example.localshare/device');
      final name = await platform.invokeMethod('getDeviceName');
      setState(() {
        deviceName = name ?? 'Unknown';
      });
    } catch (e) {
      print("Erreur nom d'appareil: $e");
      // Utiliser un nom par défaut si la méthode échoue
      setState(() {
        deviceName = 'MyDevice';
      });
    }
  }

  @override
  void dispose() {
    udpSocket.close();
    tcpServer?.close();
    _broadcastTimer?.cancel();
    super.dispose();
  }

  Future<void> _initNetworkInfo() async {
    try {
      String? wifiName = await _networkInfo.getWifiName();
      String? wifiIP = await _networkInfo.getWifiIP();
      print('WiFi Name: $wifiName');
    } catch (e) {
      print("Erreur info réseau: $e");
    }
  }

  Future<void> getLocalIP() async {
    try {
      for (var iface in await NetworkInterface.list()) {
        for (var addr in iface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            setState(() {
              myIP = addr.address;
            });
            await startUDP();
            await startTCPServer();
            return;
          }
        }
      }
      Fluttertoast.showToast(msg: "Impossible de trouver l'adresse IP");
    } catch (e) {
      print("Erreur IP: $e");
      Fluttertoast.showToast(msg: "Erreur IP: $e");
    }
  }

  // ===== Ouvrir les paramètres Wi-Fi =====
  Future<void> openWifiSettings() async {
    try {
      const platform = MethodChannel('com.example.localshare/wifi');
      await platform.invokeMethod('openWifiSettings');
    } catch (e) {
      Fluttertoast.showToast(msg: "Impossible d'ouvrir les paramètres Wi-Fi");
      print("Erreur paramètres Wi-Fi: $e");
    }
  }

  // ===== Scanner les appareils disponibles =====
  Future<void> scanDevices() async {
    setState(() {
      isScanning = true;
      devices.clear();
    });

    try {
      // Vérifier la connectivité
      var connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        Fluttertoast.showToast(msg: "Aucune connexion réseau");
        setState(() => isScanning = false);
        return;
      }

      // Envoyer un broadcast UDP pour découvrir les appareils
      if (myIP != null) {
        for (int i = 0; i < 3; i++) {
          udpSocket.send(
            "DISCOVER:$myIP:$deviceName".codeUnits,
            InternetAddress("255.255.255.255"),
            udpPort,
          );
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // Attendre un peu pour les réponses
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        isScanning = false;
      });

      if (devices.isEmpty) {
        Fluttertoast.showToast(msg: "Aucun appareil trouvé");
      } else {
        Fluttertoast.showToast(msg: "${devices.length} appareil(s) trouvé(s)");
      }
    } catch (e) {
      setState(() {
        isScanning = false;
      });
      Fluttertoast.showToast(msg: "Erreur scan: $e");
      print("Erreur scan: $e");
    }
  }

  // ===== UDP pour détecter les appareils sur le même réseau =====
  Future<void> startUDP() async {
    try {
      udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, udpPort);
      udpSocket.broadcastEnabled = true;

      // Recevoir broadcast des autres appareils
      udpSocket.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = udpSocket.receive();
          if (dg != null) {
            String msg = String.fromCharCodes(dg.data);

            if (msg.startsWith("DISCOVER:")) {
              List<String> parts = msg.substring(9).split(':');
              if (parts.length >= 2) {
                String deviceIP = parts[0];
                String deviceName = parts[1];

                // Ne pas ajouter soi-même
                if (deviceIP != myIP) {
                  // Répondre à la découverte
                  udpSocket.send(
                    "RESPONSE:$myIP:${this.deviceName}".codeUnits,
                    dg.address,
                    dg.port,
                  );

                  if (!devices.containsKey(deviceIP)) {
                    setState(() => devices[deviceIP] = deviceName);
                  }
                }
              }
            }
            else if (msg.startsWith("RESPONSE:")) {
              List<String> parts = msg.substring(9).split(':');
              if (parts.length >= 2) {
                String deviceIP = parts[0];
                String deviceName = parts[1];

                // Ne pas ajouter soi-même
                if (deviceIP != myIP) {
                  if (!devices.containsKey(deviceIP)) {
                    setState(() => devices[deviceIP] = deviceName);
                  }
                }
              }
            }
          }
        }
      });

      // Envoyer broadcast périodiquement
      _broadcastTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (myIP != null) {
          udpSocket.send(
            "DISCOVER:$myIP:$deviceName".codeUnits,
            InternetAddress("255.255.255.255"),
            udpPort,
          );
        }
      });
    } catch (e) {
      print("Erreur UDP: $e");
      Fluttertoast.showToast(msg: "Erreur UDP: $e");
    }
  }

  // ===== TCP Server pour recevoir fichiers et textes =====
  Future<void> startTCPServer() async {
    try {
      tcpServer = await ServerSocket.bind(InternetAddress.anyIPv4, tcpPort);
      tcpServer!.listen((client) {
        List<int> receivedData = [];
        String? senderIP = client.remoteAddress.address;
        Timer? timeoutTimer;

        client.listen((data) {
          // Réinitialiser le timer à chaque réception de données
          timeoutTimer?.cancel();
          timeoutTimer = Timer(const Duration(seconds: 30), () {
            client.close();
          });

          receivedData.addAll(data);
        }, onDone: () async {
          timeoutTimer?.cancel();
          if (receivedData.isNotEmpty) {
            await processReceivedData(receivedData, senderIP);
          }
          client.close();
        }, onError: (error) {
          timeoutTimer?.cancel();
          print("Erreur reception: $error");
          client.close();
        });

        // Démarrer le timer de timeout
        timeoutTimer = Timer(const Duration(seconds: 30), () {
          client.close();
        });
      });
    } catch (e) {
      print("Erreur serveur TCP: $e");
      Fluttertoast.showToast(msg: "Erreur serveur TCP: $e");
    }
  }

  Future<void> processReceivedData(List<int> data, String? senderIP) async {
    try {
      if (senderIP == null) return;

      // Convertir les premiers bytes en string pour vérifier le type de message
      String header = String.fromCharCodes(data.sublist(0, min(50, data.length)));

      if (header.startsWith('TEXT:')) {
        // Extraire le texte (après "TEXT:")
        String text = String.fromCharCodes(data.sublist(5));
        ChatMessage message = ChatMessage(
          content: text,
          sender: devices[senderIP] ?? senderIP,
          timestamp: DateTime.now(),
        );

        // Mettre à jour les messages
        ChatsScreen.messages.add(message);
        ChatsScreen.messageNotifier.value = List.from(ChatsScreen.messages);

        Fluttertoast.showToast(msg: "Message reçu de ${devices[senderIP] ?? senderIP}");
      }
      else if (header.startsWith('FILE:')) {
        // Trouver la fin du nom de fichier (recherche du premier saut de ligne)
        int fileNameEnd = data.sublist(5).indexOf(10); // 10 = code pour \n
        if (fileNameEnd == -1) fileNameEnd = data.length - 5;

        String fileName = String.fromCharCodes(data.sublist(5, 5 + fileNameEnd));
        List<int> fileData = data.sublist(5 + fileNameEnd + 1);

        // Sauvegarder le fichier
        Directory? dir = await getExternalStorageDirectory();
        if (dir == null) {
          dir = await getApplicationDocumentsDirectory();
        }

        // Créer le dossier de téléchargement s'il n'existe pas
        Directory downloadDir = Directory('${dir.path}/GO');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        File file = File('${downloadDir.path}/$fileName');
        await file.writeAsBytes(fileData);

        Fluttertoast.showToast(msg: "Fichier reçu: $fileName");

        // Ajouter un message dans le chat
        ChatMessage message = ChatMessage(
          content: "Fichier: $fileName",
          sender: devices[senderIP] ?? senderIP,
          timestamp: DateTime.now(),
          isFile: true,
          filePath: file.path,
        );

        ChatsScreen.messages.add(message);
        ChatsScreen.messageNotifier.value = List.from(ChatsScreen.messages);
      }
    } catch (e) {
      print("Erreur traitement données: $e");
      Fluttertoast.showToast(msg: "Erreur traitement données: $e");
    }
  }

  // ===== Envoyer texte =====
  void sendText(String ip, String text) async {
    try {
      Socket socket = await Socket.connect(ip, tcpPort, timeout: const Duration(seconds: 10));
      socket.add(utf8.encode('TEXT:$text'));
      await socket.flush();
      socket.close();

      // Ajouter le message localement aussi
      ChatMessage message = ChatMessage(
        content: text,
        sender: "Moi",
        timestamp: DateTime.now(),
      );

      ChatsScreen.messages.add(message);
      ChatsScreen.messageNotifier.value = List.from(ChatsScreen.messages);

      Fluttertoast.showToast(msg: "Message envoyé à ${devices[ip] ?? ip}");
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur: $e");
      print("Erreur envoi texte: $e");
    }
  }

  // ===== Envoyer fichier =====
  void sendFile(String ip) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      try {
        List<int> fileBytes = await file.readAsBytes();
        String fileName = file.path.split('/').last;

        // Préparer les données: FILE:[nomfichier]\n[donnéesfichier]
        List<int> header = utf8.encode('FILE:$fileName\n');
        List<int> dataToSend = [...header, ...fileBytes];

        Socket socket = await Socket.connect(ip, tcpPort, timeout: const Duration(seconds: 30));
        socket.add(dataToSend);
        await socket.flush();
        socket.close();

        Fluttertoast.showToast(msg: "Fichier envoyé à ${devices[ip] ?? ip}");

        // Ajouter un message dans le chat
        ChatMessage message = ChatMessage(
          content: "Fichier envoyé: $fileName",
          sender: "Moi",
          timestamp: DateTime.now(),
        );

        ChatsScreen.messages.add(message);
        ChatsScreen.messageNotifier.value = List.from(ChatsScreen.messages);
      } catch (e) {
        Fluttertoast.showToast(msg: "Erreur: $e");
        print("Erreur envoi fichier: $e");
      }
    }
  }

  // Dialogue pour envoyer un message texte
  void _showTextDialog(String ip, String deviceName) {
    TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Envoyer un message à $deviceName'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Entrez votre message"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  sendText(ip, textController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appareils Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: getLocalIP,
          ),
        ],
      ),
      body: Column(
        children: [
          // Boutons pour Wi-Fi et scan
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.wifi),
                  label: const Text('Paramètres Wi-Fi'),
                  onPressed: openWifiSettings,
                ),
                ElevatedButton.icon(
                  icon: Icon(isScanning ? Icons.refresh : Icons.search),
                  label: Text(isScanning ? 'Scan en cours...' : 'Scanner'),
                  onPressed: isScanning ? null : scanDevices,
                ),
              ],
            ),
          ),

          if (myIP != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Votre appareil: $deviceName'),
            ),
          Expanded(
            child: devices.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_other, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun appareil trouvé sur le réseau'),
                  SizedBox(height: 8),
                  Text('Connectez-vous au même réseau Wi-Fi', style: TextStyle(fontSize: 12)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final ip = devices.keys.elementAt(index);
                final name = devices[ip] ?? 'Inconnu';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_android, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(ip, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.message_outlined),
                          onPressed: () => _showTextDialog(ip, name),
                          tooltip: 'Envoyer message',
                        ),
                        IconButton(
                          icon: const Icon(Icons.file_copy_outlined),
                          onPressed: () => sendFile(ip),
                          tooltip: 'Envoyer fichier',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======= Settings Screen =======
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String deviceName = 'MyPhone';
  bool autoAcceptFiles = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paramètres de l\'appareil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nom de l\'appareil',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: deviceName),
              onChanged: (val) => setState(() => deviceName = val),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Fluttertoast.showToast(msg: "Nom d'appareil sauvegardé");
              },
              child: const Text('Sauvegarder'),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Accepter fichiers automatiquement'),
              value: autoAcceptFiles,
              onChanged: (val) => setState(() => autoAcceptFiles = val),
            ),
            SwitchListTile(
              title: const Text('Mode sombre'),
              value: darkMode,
              onChanged: (val) => setState(() => darkMode = val),
            ),
            const SizedBox(height: 24),
            const Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pour partager des fichiers:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('1. Connectez tous les appareils au même réseau Wi-Fi'),
                    Text('2. Cliquez sur "Scanner" pour trouver les appareils'),
                    Text('3. Sélectionnez un appareil et partagez!'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('À propos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Local Share v1.0\n'
                'Une application pour partager fichiers et messages\n'
                'sur le réseau local.'),
          ],
        ),
      ),
    );
  }
}