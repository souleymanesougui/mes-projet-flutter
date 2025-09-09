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
import 'package:path/path.dart' as path;

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
        scaffoldBackgroundColor: const Color(0xFF121215),
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
      home: const ChatScreen(),
    );
  }
}

// ======= Modèles de données =======
class ReceivedMessage {
  final String senderIP;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isFile;
  final String? fileName;
  final String? filePath;
  final bool isSystemMessage;
  bool isRead;

  ReceivedMessage({
    required this.senderIP,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isFile = false,
    this.fileName,
    this.filePath,
    this.isSystemMessage = false,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderIP': senderIP,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isFile': isFile,
      'fileName': fileName,
      'filePath': filePath,
      'isSystemMessage': isSystemMessage,
      'isRead': isRead,
    };
  }

  static ReceivedMessage fromMap(Map<String, dynamic> map) {
    return ReceivedMessage(
      senderIP: map['senderIP'],
      senderName: map['senderName'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      isFile: map['isFile'] ?? false,
      fileName: map['fileName'],
      filePath: map['filePath'],
      isSystemMessage: map['isSystemMessage'] ?? false,
      isRead: map['isRead'] ?? false,
    );
  }
}

class MediaItem {
  final String id;
  final String path;
  final String name;
  final int size;
  final DateTime modifiedDate;
  final bool isVideo;
  final bool isImage;
  final bool isFile;
  bool isSelected;

  MediaItem({
    required this.id,
    required this.path,
    required this.name,
    required this.size,
    required this.modifiedDate,
    this.isVideo = false,
    this.isImage = false,
    this.isFile = false,
    this.isSelected = false,
  });

  String get sizeFormatted {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1048576) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / 1048576).toStringAsFixed(1)} MB';
    }
  }
}

// ======= Gestionnaire des messages =======
class MessageManager {
  static const String _messagesKey = 'received_messages';
  static const String _deviceNameKey = 'device_name';
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
      final messagesJson = _messages
          .map((msg) => jsonEncode(msg.toMap()))
          .toList();
      await prefs.setStringList(_messagesKey, messagesJson);
    } catch (e) {
      print("Erreur sauvegarde messages: $e");
    }
  }

  static Future<String> getDeviceName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_deviceNameKey) ?? 'SOUSIMECK';
    } catch (e) {
      print("Erreur lecture nom d'appareil: $e");
      return 'SOUSIMECK';
    }
  }

  static Future<void> setDeviceName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceNameKey, name);
    } catch (e) {
      print("Erreur sauvegarde nom d'appareil: $e");
    }
  }

  static List<ReceivedMessage> get messages => _messages;

  static void addMessage(ReceivedMessage message) {
    _messages.add(message);
    saveMessages();
  }

  static void clearMessages() {
    _messages.clear();
    saveMessages();
  }
}

// ======= Gestionnaire des médias =======
class MediaManager {
  static Future<List<MediaItem>> getMediaItems() async {
    List<MediaItem> mediaItems = [];

    // Demander les permissions nécessaires
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (!status.isGranted) {
        return mediaItems;
      }
    }

    try {
      // Explorer les dossiers communs selon la plateforme
      List<String> directoriesToExplore = [];

      if (Platform.isAndroid) {
        // Dossiers Android communs
        directoriesToExplore.addAll([
          '/storage/emulated/0/DCIM',
          '/storage/emulated/0/Pictures',
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Movies',
          '/storage/emulated/0/Documents',
        ]);
      } else if (Platform.isIOS) {
        // iOS - on utilise les dossiers de l'application
        Directory? appDocDir = await getApplicationDocumentsDirectory();
        Directory? downloadsDir = await getDownloadsDirectory();

        if (appDocDir != null) directoriesToExplore.add(appDocDir.path);
        if (downloadsDir != null) directoriesToExplore.add(downloadsDir.path);
      } else if (Platform.isWindows) {
        // Dossiers Windows communs
        String userProfile = Platform.environment['USERPROFILE'] ?? '';
        if (userProfile.isNotEmpty) {
          directoriesToExplore.addAll([
            '$userProfile\\Pictures',
            '$userProfile\\Videos',
            '$userProfile\\Documents',
            '$userProfile\\Downloads',
            '$userProfile\\Desktop',
          ]);
        }
      } else if (Platform.isMacOS) {
        // Dossiers macOS communs
        String userHome = Platform.environment['HOME'] ?? '';
        if (userHome.isNotEmpty) {
          directoriesToExplore.addAll([
            '$userHome/Pictures',
            '$userHome/Movies',
            '$userHome/Documents',
            '$userHome/Downloads',
            '$userHome/Desktop',
          ]);
        }
      }

      // Explorer chaque dossier
      for (String directoryPath in directoriesToExplore) {
        try {
          Directory directory = Directory(directoryPath);
          if (await directory.exists()) {
            List<FileSystemEntity> entities = directory.listSync(
              recursive: true,
            );

            for (var entity in entities) {
              if (entity is File) {
                try {
                  final String filePath = entity.path;
                  final String extension = path
                      .extension(filePath)
                      .toLowerCase();

                  final bool isImage = [
                    '.jpg',
                    '.jpeg',
                    '.png',
                    '.gif',
                    '.bmp',
                    '.webp',
                  ].contains(extension);
                  final bool isVideo = [
                    '.mp4',
                    '.mov',
                    '.avi',
                    '.mkv',
                    '.flv',
                    '.wmv',
                    '.3gp',
                  ].contains(extension);
                  final bool isFile = !isImage && !isVideo;

                  final int size = await entity.length();
                  final DateTime modifiedDate = await entity.lastModified();

                  mediaItems.add(
                    MediaItem(
                      id: filePath,
                      path: filePath,
                      name: path.basename(filePath),
                      size: size,
                      modifiedDate: modifiedDate,
                      isImage: isImage,
                      isVideo: isVideo,
                      isFile: isFile,
                    ),
                  );
                } catch (e) {
                  print("Erreur avec le fichier ${entity.path}: $e");
                }
              }
            }
          }
        } catch (e) {
          print("Erreur exploration $directoryPath: $e");
        }
      }
    } catch (e) {
      print("Erreur accès fichiers: $e");
    }

    return mediaItems;
  }

  static Future<List<MediaItem>> getImages() async {
    final List<MediaItem> allMedia = await getMediaItems();
    return allMedia.where((item) => item.isImage).toList();
  }

  static Future<List<MediaItem>> getVideos() async {
    final List<MediaItem> allMedia = await getMediaItems();
    return allMedia.where((item) => item.isVideo).toList();
  }

  static Future<List<MediaItem>> getFiles() async {
    final List<MediaItem> allMedia = await getMediaItems();
    return allMedia.where((item) => item.isFile).toList();
  }
}

// ======= Écran de galerie multimédia =======
class MediaGalleryScreen extends StatefulWidget {
  const MediaGalleryScreen({super.key});

  @override
  _MediaGalleryScreenState createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MediaItem> images = [];
  List<MediaItem> videos = [];
  List<MediaItem> files = [];
  bool isLoading = true;
  int selectedCount = 0;
  String statusMessage = 'Chargement des médias...';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    setState(() {
      isLoading = true;
      statusMessage = 'Chargement des médias...';
    });

    try {
      final List<MediaItem> allImages = await MediaManager.getImages();
      final List<MediaItem> allVideos = await MediaManager.getVideos();
      final List<MediaItem> allFiles = await MediaManager.getFiles();

      setState(() {
        images = allImages;
        videos = allVideos;
        files = allFiles;
        isLoading = false;
        statusMessage =
            '${images.length} photos, ${videos.length} vidéos, ${files.length} fichiers';
      });
    } catch (e) {
      print("Erreur chargement médias: $e");
      setState(() {
        isLoading = false;
        statusMessage = 'Erreur lors du chargement des médias';
      });
      Fluttertoast.showToast(msg: "Erreur lors du chargement des médias");
    }
  }

  void _toggleSelection(MediaItem item) {
    setState(() {
      item.isSelected = !item.isSelected;
      selectedCount =
          images.where((i) => i.isSelected).length +
          videos.where((v) => v.isSelected).length +
          files.where((f) => f.isSelected).length;
    });
  }

  void _clearSelection() {
    setState(() {
      for (var item in images) {
        item.isSelected = false;
      }
      for (var item in videos) {
        item.isSelected = false;
      }
      for (var item in files) {
        item.isSelected = false;
      }
      selectedCount = 0;
    });
  }

  List<MediaItem> _getSelectedItems() {
    return [
      ...images.where((item) => item.isSelected),
      ...videos.where((item) => item.isSelected),
      ...files.where((item) => item.isSelected),
    ];
  }

  void _sendSelectedFiles() {
    final List<MediaItem> selectedItems = _getSelectedItems();
    if (selectedItems.isEmpty) {
      Fluttertoast.showToast(msg: "Aucun fichier sélectionné");
      return;
    }

    Fluttertoast.showToast(
      msg: "${selectedItems.length} fichier(s) sélectionné(s)",
    );

    // Retour à l'écran précédent avec les fichiers sélectionnés
    Navigator.pop(context, selectedItems);
  }

  Widget _buildImageThumbnail(MediaItem item) {
    return Image.file(
      File(item.path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[800],
          child: const Icon(Icons.image, color: Colors.white),
        );
      },
    );
  }

  Widget _buildVideoThumbnail(MediaItem item) {
    return Container(
      color: Colors.grey[800],
      child: const Icon(Icons.videocam, color: Colors.white, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Galerie Multimédia'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.photo_library), text: 'Photos'),
            Tab(icon: Icon(Icons.video_library), text: 'Vidéos'),
            Tab(icon: Icon(Icons.insert_drive_file), text: 'Fichiers'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMedia,
            tooltip: 'Actualiser',
          ),
          if (selectedCount > 0)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSelection,
              tooltip: 'Tout désélectionner',
            ),
          if (selectedCount > 0)
            Text('$selectedCount', style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: selectedCount > 0
          ? FloatingActionButton.extended(
              onPressed: _sendSelectedFiles,
              icon: const Icon(Icons.send),
              label: Text('Envoyer ($selectedCount)'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              statusMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMediaGrid(images, 'Aucune photo trouvée'),
                      _buildMediaGrid(videos, 'Aucune vidéo trouvée'),
                      _buildFileList(files, 'Aucun fichier trouvé'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(List<MediaItem> items, String emptyMessage) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final MediaItem item = items[index];
        return _buildMediaItem(item);
      },
    );
  }

  Widget _buildMediaItem(MediaItem item) {
    return GestureDetector(
      onTap: () => _toggleSelection(item),
      onLongPress: () => _toggleSelection(item),
      child: Stack(
        children: [
          item.isImage
              ? _buildImageThumbnail(item)
              : _buildVideoThumbnail(item),
          if (item.isSelected)
            Container(
              color: Colors.blue.withOpacity(0.5),
              child: const Center(
                child: Icon(Icons.check_circle, color: Colors.white, size: 40),
              ),
            ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.sizeFormatted,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(List<MediaItem> items, String emptyMessage) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final MediaItem item = items[index];
        return ListTile(
          leading: const Icon(Icons.insert_drive_file, color: Colors.white),
          title: Text(
            item.name,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${item.sizeFormatted} • ${_formatDate(item.modifiedDate)}',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: item.isSelected
              ? const Icon(Icons.check_circle, color: Colors.blue)
              : null,
          onTap: () => _toggleSelection(item),
          onLongPress: () => _toggleSelection(item),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ======= Écran de chat unifié =======
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final int udpPort = 4567;
  final int tcpPort = 4568;
  String? myIP;
  String deviceName = 'SOUSIMECK';
  late RawDatagramSocket udpSocket;
  Map<String, String> devices = {};
  Map<String, DateTime> lastSeen = {};
  ServerSocket? tcpServer;
  bool isScanning = false;
  final NetworkInfo _networkInfo = NetworkInfo();
  final Connectivity _connectivity = Connectivity();
  Timer? _broadcastTimer;
  Timer? _cleanupTimer;
  String connectedNetwork = '-';
  int onlineUsers = 0;
  TextEditingController messageController = TextEditingController();
  List<ReceivedMessage> messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadData();
    _initApp();
  }

  Future<void> _loadData() async {
    await MessageManager.loadMessages();
    deviceName = await MessageManager.getDeviceName();
    setState(() {
      messages = MessageManager.messages;
    });
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.storage.request();
      await Permission.accessMediaLocation.request();
      await Permission.manageExternalStorage.request();
    }
  }

  Future<void> _initApp() async {
    await getLocalIP();
    _initNetworkInfo();
  }

  @override
  void dispose() {
    udpSocket.close();
    tcpServer?.close();
    _broadcastTimer?.cancel();
    _cleanupTimer?.cancel();
    super.dispose();
  }

  Future<void> _initNetworkInfo() async {
    try {
      String? wifiName = await _networkInfo.getWifiName();
      setState(() {
        connectedNetwork = wifiName ?? '-';
      });
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
        onlineUsers = devices.length;
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

  void _addSystemMessage(String content) {
    ReceivedMessage systemMessage = ReceivedMessage(
      senderIP: 'system',
      senderName: 'Système',
      content: content,
      timestamp: DateTime.now(),
      isSystemMessage: true,
    );
    MessageManager.addMessage(systemMessage);

    setState(() {
      messages = MessageManager.messages;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> startUDP() async {
    try {
      udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        udpPort,
      );
      udpSocket.broadcastEnabled = true;

      udpSocket.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = udpSocket.receive();
          if (dg != null) {
            String msg = String.fromCharCodes(dg.data);
            String senderIP = dg.address.address;

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
                    setState(() {
                      devices[deviceIP] = deviceName;
                      lastSeen[deviceIP] = DateTime.now();
                      onlineUsers = devices.length;
                    });
                    _addSystemMessage("$deviceName s'est connecté");
                  } else {
                    lastSeen[deviceIP] = DateTime.now();
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
                    setState(() {
                      devices[deviceIP] = deviceName;
                      lastSeen[deviceIP] = DateTime.now();
                      onlineUsers = devices.length;
                    });
                    _addSystemMessage("$deviceName s'est connecté");
                  } else {
                    lastSeen[deviceIP] = DateTime.now();
                  }
                }
              }
            } else if (msg.startsWith("NAME_UPDATE:")) {
              List<String> parts = msg.substring(12).split(':');
              if (parts.length >= 2) {
                String deviceIP = parts[0];
                String newName = parts[1];

                if (deviceIP != myIP && devices.containsKey(deviceIP)) {
                  String oldName = devices[deviceIP]!;
                  setState(() {
                    devices[deviceIP] = newName;
                  });
                  _addSystemMessage("$oldName est maintenant $newName");
                }
              }
            } else if (msg.startsWith("GOODBYE:")) {
              List<String> parts = msg.substring(8).split(':');
              if (parts.length >= 2) {
                String deviceIP = parts[0];
                String deviceName = parts[1];

                if (devices.containsKey(deviceIP)) {
                  setState(() {
                    devices.remove(deviceIP);
                    lastSeen.remove(deviceIP);
                    onlineUsers = devices.length;
                  });
                  _addSystemMessage("$deviceName s'est déconnecté");
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

      _cleanupTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        DateTime now = DateTime.now();
        List<String> toRemove = [];

        lastSeen.forEach((ip, lastSeenTime) {
          if (now.difference(lastSeenTime) > const Duration(seconds: 15)) {
            toRemove.add(ip);
          }
        });

        if (toRemove.isNotEmpty) {
          setState(() {
            for (String ip in toRemove) {
              String deviceName = devices[ip]!;
              devices.remove(ip);
              lastSeen.remove(ip);
              _addSystemMessage("$deviceName s'est déconnecté (inactif)");
            }
            onlineUsers = devices.length;
          });
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

        client.listen(
          (data) {
            timeoutTimer?.cancel();
            timeoutTimer = Timer(const Duration(seconds: 30), () {
              client.close();
            });

            receivedData.addAll(data);
          },
          onDone: () async {
            timeoutTimer?.cancel();
            if (receivedData.isNotEmpty) {
              await processReceivedData(receivedData, senderIP);
            }
            client.close();
          },
          onError: (error) {
            timeoutTimer?.cancel();
            print("Erreur reception: $error");
            client.close();
          },
        );

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

      String header = String.fromCharCodes(
        data.sublist(0, min(50, data.length)),
      );
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

        setState(() {
          messages = MessageManager.messages;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        Fluttertoast.showToast(msg: "Message reçu de $senderName");
      } else if (header.startsWith('FILE:')) {
        int fileNameEnd = data.sublist(5).indexOf(10);
        if (fileNameEnd == -1) fileNameEnd = data.length - 5;

        String fileName = String.fromCharCodes(
          data.sublist(5, 5 + fileNameEnd),
        );
        List<int> fileData = data.sublist(5 + fileNameEnd + 1);

        Directory downloadDir;

        if (Platform.isAndroid || Platform.isIOS) {
          Directory? dir = await getExternalStorageDirectory();
          if (dir == null) {
            dir = await getApplicationDocumentsDirectory();
          }
          downloadDir = Directory('${dir.path}/GO');
        } else {
          downloadDir = Directory('${Directory.current.path}/GO_Downloads');
        }

        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        String finalFileName = fileName;
        int counter = 1;
        while (await File('${downloadDir.path}/$finalFileName').exists()) {
          finalFileName =
              '${fileName}_$counter${fileName.substring(fileName.lastIndexOf('.'))}';
          counter++;
        }

        File file = File('${downloadDir.path}/$finalFileName');
        await file.writeAsBytes(fileData);

        ReceivedMessage message = ReceivedMessage(
          senderIP: senderIP,
          senderName: senderName,
          content: "Fichier reçu: $finalFileName",
          timestamp: DateTime.now(),
          isFile: true,
          fileName: finalFileName,
          filePath: file.path,
        );
        MessageManager.addMessage(message);

        setState(() {
          messages = MessageManager.messages;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        Fluttertoast.showToast(msg: "Fichier reçu: $finalFileName");

        if (!Platform.isAndroid && !Platform.isIOS) {
          OpenFilex.open(downloadDir.path);
        }
      }
    } catch (e) {
      print("Erreur traitement données: $e");
      Fluttertoast.showToast(msg: "Erreur traitement données: $e");
    }
  }

  void sendText(String text) async {
    if (text.isEmpty) return;

    if (devices.isEmpty) {
      Fluttertoast.showToast(msg: "Aucun appareil disponible");
      return;
    }

    try {
      ReceivedMessage sentMessage = ReceivedMessage(
        senderIP: myIP!,
        senderName: deviceName,
        content: text,
        timestamp: DateTime.now(),
        isFile: false,
        isRead: true,
      );
      MessageManager.addMessage(sentMessage);

      setState(() {
        messages = MessageManager.messages;
        messageController.clear();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      for (String ip in devices.keys) {
        try {
          Socket socket = await Socket.connect(
            ip,
            tcpPort,
            timeout: const Duration(seconds: 10),
          );
          socket.add(utf8.encode('TEXT:$text'));
          await socket.flush();
          socket.close();
        } catch (e) {
          print("Erreur envoi à $ip: $e");
        }
      }

      Fluttertoast.showToast(msg: "Message envoyé");
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur: $e");
      print("Erreur envoi texte: $e");
    }
  }

  void sendFile() async {
    if (devices.isEmpty) {
      Fluttertoast.showToast(msg: "Aucun appareil disponible");
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      for (var platformFile in result.files) {
        if (platformFile.path != null) {
          File file = File(platformFile.path!);
          try {
            List<int> fileBytes = await file.readAsBytes();
            String fileName = platformFile.name;

            ReceivedMessage sentMessage = ReceivedMessage(
              senderIP: myIP!,
              senderName: deviceName,
              content: "Fichier envoyé: $fileName",
              timestamp: DateTime.now(),
              isFile: true,
              fileName: fileName,
              isRead: true,
            );
            MessageManager.addMessage(sentMessage);

            setState(() {
              messages = MessageManager.messages;
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            List<int> header = utf8.encode('FILE:$fileName\n');
            List<int> dataToSend = [...header, ...fileBytes];

            for (String ip in devices.keys) {
              try {
                Socket socket = await Socket.connect(
                  ip,
                  tcpPort,
                  timeout: const Duration(seconds: 30),
                );
                socket.add(dataToSend);
                await socket.flush();
                socket.close();
              } catch (e) {
                print("Erreur envoi fichier à $ip: $e");
              }
            }

            Fluttertoast.showToast(msg: "Fichier envoyé: $fileName");
          } catch (e) {
            Fluttertoast.showToast(msg: "Erreur: $e");
            print("Erreur envoi fichier: $e");
          }
        }
      }
    }
  }

  void _sendGoodbyeMessage() {
    if (myIP != null && myIP!.isNotEmpty) {
      udpSocket.send(
        "GOODBYE:$myIP:$deviceName".codeUnits,
        InternetAddress("255.255.255.255"),
        udpPort,
      );
    }
  }

  @override
  void deactivate() {
    _sendGoodbyeMessage();
    super.deactivate();
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
          title: const Text(
            'Effacer tous les messages',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir effacer tous les messages ?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                MessageManager.clearMessages();
                setState(() {
                  messages = [];
                });
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

  void _changeDeviceName() {
    TextEditingController nameController = TextEditingController(
      text: deviceName,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Changer le nom d\'appareil',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Entrez un nouveau nom",
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  String newName = nameController.text;
                  await MessageManager.setDeviceName(newName);

                  setState(() {
                    deviceName = newName;
                  });

                  if (myIP != null && myIP!.isNotEmpty) {
                    udpSocket.send(
                      "NAME_UPDATE:$myIP:$newName".codeUnits,
                      InternetAddress("255.255.255.255"),
                      udpPort,
                    );
                  }

                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: "Nom d'appareil mis à jour");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                'Enregistrer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openMediaGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MediaGalleryScreen()),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  Color _getAvatarColor(String name) {
    final int hash = name.hashCode;
    final int index = hash % _avatarColors.length;
    return _avatarColors[index];
  }

  final List<Color> _avatarColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.deepPurple,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('GO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: _openMediaGallery,
            tooltip: 'Ouvrir la galerie multimédia',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _changeDeviceName,
            tooltip: 'Change le nom',
          ),
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _clearMessages,
              tooltip: 'Effacer tous les messages',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              getLocalIP();
              scanDevices();
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E1E1E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      deviceName,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '$onlineUsers',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Zone des messages avec image de fond
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/background.jpeg',
                  ), // Ton image
                  fit: BoxFit.cover, // Couvre la zone des messages
                ),
              ),
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Envoyez votre message!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final bool isMe =
                            myIP != null && message.senderIP == myIP;
                        final bool isSystem = message.isSystemMessage;

                        Color bubbleColor;
                        Color textColor;

                        if (isSystem) {
                          bubbleColor = Colors.grey[800]!;
                          textColor = Colors.grey[400]!;
                        } else if (isMe) {
                          bubbleColor = const Color(0xFF0066CC);
                          textColor = Colors.white;
                        } else {
                          bubbleColor = const Color(0xFF2A2A2A);
                          textColor = Colors.white;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: isSystem
                                ? MainAxisAlignment.center
                                : (isMe
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start),
                            children: [
                              if (!isMe && !isSystem)
                                Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: _getAvatarColor(message.senderName),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getInitials(message.senderName),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              Flexible(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: isSystem
                                        ? MediaQuery.of(context).size.width *
                                              0.9
                                        : MediaQuery.of(context).size.width *
                                              0.7,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: bubbleColor,
                                    borderRadius: isSystem
                                        ? BorderRadius.circular(20)
                                        : BorderRadius.only(
                                            topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                            bottomLeft: Radius.circular(
                                              isMe ? 16 : 4,
                                            ),
                                            bottomRight: Radius.circular(
                                              isMe ? 4 : 16,
                                            ),
                                          ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isSystem
                                        ? CrossAxisAlignment.center
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe && !isSystem)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            message.senderName,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      if (message.isFile && !isSystem)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.insert_drive_file,
                                                  size: 18,
                                                  color: Colors.white70,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    message.fileName ??
                                                        'Fichier',
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            if (message.filePath != null)
                                              ElevatedButton.icon(
                                                onPressed: () => _openFile(
                                                  message.filePath!,
                                                ),
                                                icon: const Icon(
                                                  Icons.open_in_new,
                                                  size: 16,
                                                ),
                                                label: const Text('Ouvrir'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white
                                                      .withOpacity(0.1),
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        )
                                      else
                                        Text(
                                          message.content,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: isSystem ? 13 : 15,
                                            fontStyle: isSystem
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                          ),
                                          textAlign: isSystem
                                              ? TextAlign.center
                                              : TextAlign.left,
                                        ),
                                      if (!isSystem) const SizedBox(height: 8),
                                      if (!isSystem)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                color: textColor.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (isMe)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 4,
                                                ),
                                                child: Icon(
                                                  message.isRead
                                                      ? Icons.done_all
                                                      : Icons.done,
                                                  size: 14,
                                                  color: message.isRead
                                                      ? Colors.blue[100]
                                                      : Colors.white70,
                                                ),
                                              ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isMe && !isSystem)
                                Container(
                                  width: 40,
                                  height: 40,
                                  margin: const EdgeInsets.only(left: 12),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Écrivez un message...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (text) {
                      sendText(text);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.white),
                  onPressed: sendFile,
                  tooltip: 'Envoyer un fichier',
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => sendText(messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
