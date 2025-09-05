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
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LocalShareApp());
}

class LocalShareApp extends StatelessWidget {
  const LocalShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

// ======= Modèle de message =======
class ReceivedMessage {
  final String senderIP;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isFile;
  final String? fileName;
  final String? filePath;
  bool isRead;

  ReceivedMessage({
    required this.senderIP,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isFile = false,
    this.fileName,
    this.filePath,
    this.isRead = false,
  });

  // Convertir en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'senderIP': senderIP,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isFile': isFile,
      'fileName': fileName,
      'filePath': filePath,
      'isRead': isRead,
    };
  }

  // Créer à partir d'une Map
  static ReceivedMessage fromMap(Map<String, dynamic> map) {
    return ReceivedMessage(
      senderIP: map['senderIP'],
      senderName: map['senderName'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      isFile: map['isFile'] ?? false,
      fileName: map['fileName'],
      filePath: map['filePath'],
      isRead: map['isRead'] ?? false,
    );
  }
}

// ======= Gestionnaire des messages =======
class MessageManager {
  static const String _messagesKey = 'received_messages';
  static List<ReceivedMessage> _messages = [];

  static Future<void> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getStringList(_messagesKey) ?? [];
      _messages = messagesJson.map((json) {
        final map = jsonDecode(json);
        return ReceivedMessage.fromMap(map);
      }).toList();
    } catch (e) {
      print("Erreur chargement messages: $e");
      _messages = [];
    }
  }

  static Future<void> saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages.map((msg) => jsonEncode(msg.toMap())).toList();
      await prefs.setStringList(_messagesKey, messagesJson);
    } catch (e) {
      print("Erreur sauvegarde messages: $e");
    }
  }

  static List<ReceivedMessage> get messages => _messages;

  static void addMessage(ReceivedMessage message) {
    _messages.insert(0, message);
    saveMessages();
  }

  static void clearMessages() {
    _messages.clear();
    saveMessages();
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
    ReceivedMessagesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    MessageManager.loadMessages();
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
      backgroundColor: const Color(0xFF121212),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.public, size: 24),
              activeIcon: Icon(Icons.public, size: 24, color: Colors.blue),
              label: 'Découvrir',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline, size: 24),
              activeIcon: Icon(Icons.chat_bubble, size: 24, color: Colors.blue),
              label: 'Messages',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          onTap: _onItemTapped,
        ),
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
  final int udpPort = 4567;
  final int tcpPort = 4568;
  String? myIP;
  String deviceName = 'Unknown';
  late RawDatagramSocket udpSocket;
  Map<String, String> devices = {};
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

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    getLocalIP();
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

  Future<void> openWifiSettings() async {
    try {
      const platform = MethodChannel('com.example.localshare/wifi');
      await platform.invokeMethod('openWifiSettings');
    } catch (e) {
      Fluttertoast.showToast(msg: "Impossible d'ouvrir les paramètres Wi-Fi");
      print("Erreur paramètres Wi-Fi: $e");
    }
  }

  Future<void> scanDevices() async {
    setState(() {
      isScanning = true;
      devices.clear();
    });

    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        Fluttertoast.showToast(msg: "Aucune connexion réseau");
        setState(() => isScanning = false);
        return;
      }

      if (myIP != null && myIP!.isNotEmpty) {
        for (int i = 0; i < 3; i++) {
          udpSocket.send(
            "DISCOVER:$myIP:$deviceName".codeUnits,
            InternetAddress("255.255.255.255"),
            udpPort,
          );
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

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

  Future<void> startUDP() async {
    try {
      udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, udpPort);
      udpSocket.broadcastEnabled = true;

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

                if (deviceIP != myIP) {
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
            } else if (msg.startsWith("RESPONSE:")) {
              List<String> parts = msg.substring(9).split(':');
              if (parts.length >= 2) {
                String deviceIP = parts[0];
                String deviceName = parts[1];

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

      _broadcastTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (myIP != null && myIP!.isNotEmpty) {
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

  Future<void> startTCPServer() async {
    try {
      tcpServer = await ServerSocket.bind(InternetAddress.anyIPv4, tcpPort);
      tcpServer!.listen((client) {
        List<int> receivedData = [];
        String? senderIP = client.remoteAddress.address;
        Timer? timeoutTimer;

        client.listen((data) {
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

      String header = String.fromCharCodes(data.sublist(0, min(50, data.length)));
      String senderName = devices[senderIP] ?? senderIP;

      if (header.startsWith('TEXT:')) {
        String text = String.fromCharCodes(data.sublist(5));

        ReceivedMessage message = ReceivedMessage(
          senderIP: senderIP,
          senderName: senderName,
          content: text,
          timestamp: DateTime.now(),
          isFile: false,
        );
        MessageManager.addMessage(message);

        Fluttertoast.showToast(msg: "Message reçu de $senderName");
      } else if (header.startsWith('FILE:')) {
        int fileNameEnd = data.sublist(5).indexOf(10);
        if (fileNameEnd == -1) fileNameEnd = data.length - 5;

        String fileName = String.fromCharCodes(data.sublist(5, 5 + fileNameEnd));
        List<int> fileData = data.sublist(5 + fileNameEnd + 1);

        Directory? dir = await getExternalStorageDirectory();
        if (dir == null) {
          dir = await getApplicationDocumentsDirectory();
        }

        Directory downloadDir = Directory('${dir.path}/GO');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        File file = File('${downloadDir.path}/$fileName');
        await file.writeAsBytes(fileData);

        ReceivedMessage message = ReceivedMessage(
          senderIP: senderIP,
          senderName: senderName,
          content: "Fichier reçu: $fileName",
          timestamp: DateTime.now(),
          isFile: true,
          fileName: fileName,
          filePath: file.path,
        );
        MessageManager.addMessage(message);

        Fluttertoast.showToast(msg: "Fichier reçu: $fileName");
      }
    } catch (e) {
      print("Erreur traitement données: $e");
      Fluttertoast.showToast(msg: "Erreur traitement données: $e");
    }
  }

  void sendText(String ip, String text) async {
    try {
      Socket socket = await Socket.connect(ip, tcpPort, timeout: const Duration(seconds: 10));
      socket.add(utf8.encode('TEXT:$text'));
      await socket.flush();
      socket.close();

      Fluttertoast.showToast(msg: "Message envoyé à ${devices[ip] ?? ip}");
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur: $e");
      print("Erreur envoi texte: $e");
    }
  }

  void sendFile(String ip) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      try {
        List<int> fileBytes = await file.readAsBytes();
        String fileName = file.path.split('/').last;

        List<int> header = utf8.encode('FILE:$fileName\n');
        List<int> dataToSend = [...header, ...fileBytes];

        Socket socket = await Socket.connect(ip, tcpPort, timeout: const Duration(seconds: 30));
        socket.add(dataToSend);
        await socket.flush();
        socket.close();

        Fluttertoast.showToast(msg: "Fichier envoyé à ${devices[ip] ?? ip}");
      } catch (e) {
        Fluttertoast.showToast(msg: "Erreur: $e");
        print("Erreur envoi fichier: $e");
      }
    }
  }

  void _showTextDialog(String ip, String deviceName) {
    TextEditingController textController = TextEditingController();
    final FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.message_outlined,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Envoyer à $deviceName',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: textController,
                    focusNode: focusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Écrivez votre message...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[700]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 4,
                    minLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        sendText(ip, text);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ANNULER',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (textController.text.isNotEmpty) {
                            sendText(ip, textController.text);
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.send, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'ENVOYER',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        focusNode.requestFocus();
      });
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }

  void _showDeviceOptions(String ip, String deviceName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_iphone, color: Colors.blue),
                  ),
                  title: Text(
                    deviceName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(ip, style: const TextStyle(color: Colors.grey)),
                ),
                const Divider(color: Colors.grey),
                _buildOptionTile(
                  icon: Icons.message_rounded,
                  title: 'Envoyer un message',
                  onTap: () {
                    Navigator.pop(context);
                    _showTextDialog(ip, deviceName);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.attach_file_rounded,
                  title: 'Envoyer un fichier',
                  onTap: () {
                    Navigator.pop(context);
                    sendFile(ip);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.content_copy_rounded,
                  title: 'Copier l\'adresse IP',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: ip));
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: 'IP copiée: $ip');
                  },
                ),
                const Divider(color: Colors.grey),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('FERMER', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Appareils Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: getLocalIP,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: const Text('Paramètres', style: TextStyle(color: Colors.white)),
                  onPressed: openWifiSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(isScanning ? Icons.refresh : Icons.search, color: Colors.white),
                  label: Text(
                    isScanning ? 'Scan en cours...' : 'Scanner',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: isScanning ? null : scanDevices,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (myIP != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Votre appareil: $deviceName',
                  style: const TextStyle(color: Colors.grey)),
            ),
          Expanded(
            child: devices.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_other, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text('Aucun appareil trouvé sur le réseau',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Connectez-vous au même réseau Wi-Fi',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final ip = devices.keys.elementAt(index);
                final name = devices[ip] ?? 'Inconnu';
                final int colorSeed = ip.hashCode;
                final Color avatarColor =
                Colors.primaries[colorSeed % Colors.primaries.length];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Material(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: InkWell(
                      onTap: () {
                        _showDeviceOptions(ip, name);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: avatarColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: avatarColor.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.phone_iphone,
                                color: avatarColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'En ligne',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildActionButton(
                                  icon: Icons.message_rounded,
                                  color: Colors.blue,
                                  tooltip: 'Envoyer message',
                                  onPressed: () => _showTextDialog(ip, name),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.attach_file_rounded,
                                  color: Colors.green,
                                  tooltip: 'Envoyer fichier',
                                  onPressed: () => sendFile(ip),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.more_vert_rounded,
                                  color: Colors.grey,
                                  tooltip: 'Plus d\'options',
                                  onPressed: () => _showDeviceOptions(ip, name),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

// ======= Écran des messages reçus =======
class ReceivedMessagesScreen extends StatefulWidget {
  const ReceivedMessagesScreen({super.key});

  @override
  _ReceivedMessagesScreenState createState() => _ReceivedMessagesScreenState();
}

class _ReceivedMessagesScreenState extends State<ReceivedMessagesScreen> {
  String? $deviceName;
  String? myIP;
  @override
  void initState() {
    super.initState();
    MessageManager.loadMessages();
  }

  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        Fluttertoast.showToast(msg: "Impossible d'ouvrir le fichier");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur: $e");
    }
  }

  void _clearMessages() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Effacer tous les messages', style: TextStyle(color: Colors.white)),
          content: const Text('Êtes-vous sûr de vouloir effacer tous les messages ?',
              style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                MessageManager.clearMessages();
                setState(() {});
                Navigator.of(context).pop();
                Fluttertoast.showToast(msg: "Messages effacés");
              },
              child: const Text('Effacer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = MessageManager.messages;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Messages Reçus'),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _clearMessages,
              tooltip: 'Effacer tous les messages',
            ),
        ],
      ),
      body: messages.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text('Aucun message reçu', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Les messages et fichiers apparaîtront ici',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      )
      :ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];

          // Marquer le message comme lu si ce n'est pas le mien
          if (!message.isRead && message.senderIP != myIP) {
            setState(() {
              message.isRead = true;
              // Sauvegarde si tu as une fonction pour ça
              MessageManager.saveMessages();
            });
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: message.senderIP == myIP
                  ? const BorderRadius.only( // message envoyé à droite
                topLeft: Radius.circular(16),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
                  : const BorderRadius.only( // message reçu à gauche
                topLeft: Radius.circular(0),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              color: message.senderIP == myIP ? Colors.green[400] : Colors.blue[300],
            ),
            child: ListTile(
              leading: message.isFile
                  ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.file_copy, size: 24, color: Colors.yellow[700]),
              )
                  : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_circle_outlined, size: 24, color: Colors.green),
              ),
              title: Text(
                message.senderName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')} - ${message.timestamp.day}/${message.timestamp.month}/${message.timestamp.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: message.isFile
                  ? IconButton(
                icon: const Icon(Icons.open_in_new, color: Colors.blue),
                onPressed: () => _openFile(message.filePath!),
                tooltip: 'Ouvrir le fichier',
              )
                  : Icon(
                message.isRead ? Icons.done_all : Icons.done,
                color: message.isRead ? Colors.red : Colors.black,
                size: 16,
              ),
              onTap: message.isFile ? () => _openFile(message.filePath!) : null,
            ),
          );
        },
      ),


    );
  }
}
