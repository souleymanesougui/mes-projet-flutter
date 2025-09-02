import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(TicTacToeApp());
  });
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sousi meck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.deepPurple[900],
      ),
      home: GameHomePage(),
    );
  }
}

class GameHomePage extends StatefulWidget {
  @override
  _GameHomePageState createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController playerXController = TextEditingController();
  final TextEditingController playerOController = TextEditingController();

  String playerXName = "";
  String playerOName = "";
  List<String?> boardState = List.filled(9, null);
  String currentPlayer = "X";
  bool gameOver = false;
  List<int>? winningLine;
  AudioPlayer audioPlayer = AudioPlayer();
  double volume = 0.2;
  bool musicPlaying = false;

  final List<List<int>> winningLines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];

  @override
  void initState() {
    super.initState();
    audioPlayer.setVolume(volume);
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void startMusic() async {
    await audioPlayer.play(AssetSource('musique.mp3'));
    musicPlaying = true;
    setState(() {});
  }

  void toggleMusic() async {
    if (musicPlaying) {
      await audioPlayer.pause();
      musicPlaying = false;
    } else {
      await audioPlayer.resume();
      musicPlaying = true;
    }
    setState(() {});
  }

  void resetGame() {
    setState(() {
      boardState = List.filled(9, null);
      currentPlayer = "X";
      gameOver = false;
      winningLine = null;
    });
  }

  void checkMove(int idx) {
    if (gameOver || boardState[idx] != null) return;

    setState(() {
      boardState[idx] = currentPlayer;

      for (var combo in winningLines) {
        final a = combo[0], b = combo[1], c = combo[2];
        if (boardState[a] != null &&
            boardState[a] == boardState[b] &&
            boardState[a] == boardState[c]) {
          gameOver = true;
          winningLine = combo;
          return;
        }
      }

      if (!boardState.contains(null)) {
        gameOver = true;
      }

      if (!gameOver) {
        currentPlayer = currentPlayer == "X" ? "O" : "X";
      }
    });
  }

  String get resultText {
    if (!gameOver) return "Au tour : ${currentPlayer == 'X' ? playerXName : playerOName}";
    if (winningLine != null) {
      return "🎉 Félicitations ${currentPlayer == 'X' ? playerXName : playerOName} ! 🎊";
    }
    return "Match nul 🤝";
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final gridSize = sw * 0.9;
    final fontLarge = sw * 0.15;
    final fontMedium = sw * 0.05;
    final isSmallScreen = sw < 400;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(sw * 0.05),
            margin: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[800]!, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: playerXName.isEmpty || playerOName.isEmpty
                ? Column(
              children: [
                Text(
                  'SOUSI MECK',
                  style: TextStyle(
                    fontSize: fontLarge * 0.8,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                SizedBox(height: sh * 0.03),
                _buildStyledTextField(playerXController, "Joueur X"),
                SizedBox(height: sh * 0.02),
                _buildStyledTextField(playerOController, "Joueur O"),
                SizedBox(height: sh * 0.04),
                _buildButton("Commencez", Colors.blueAccent, () {
                  if (playerXController.text.trim().isEmpty ||
                      playerOController.text.trim().isEmpty) return;
                  setState(() {
                    playerXName = playerXController.text.trim();
                    playerOName = playerOController.text.trim();
                  });
                  startMusic();
                }),
              ],
            )
                : Column(
              children: [
                Container(
                  width: gridSize,
                  height: gridSize,
                  child: Stack(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 9,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemBuilder: (context, idx) {
                          return GestureDetector(
                            onTap: () => checkMove(idx),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: boardState[idx] == 'X'
                                    ? LinearGradient(
                                    colors: [
                                      Colors.blue,
                                      Colors.lightBlueAccent
                                    ])
                                    : boardState[idx] == 'O'
                                    ? LinearGradient(
                                    colors: [
                                      Colors.red,
                                      Colors.orangeAccent
                                    ])
                                    : LinearGradient(
                                    colors: [
                                      Colors.white10,
                                      Colors.white12
                                    ]),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedScale(
                                  scale: boardState[idx] == null ? 0 : 1,
                                  duration: Duration(milliseconds: 300),
                                  child: Text(
                                    boardState[idx] ?? '',
                                    style: TextStyle(
                                      fontSize: fontLarge,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                            color: Colors.black,
                                            blurRadius: 3)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (winningLine != null)
                        CustomPaint(
                          size: Size(gridSize, gridSize),
                          painter: WinLinePainter(winningLine!, gridSize),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: sh * 0.03),
                Text(
                  resultText,
                  style: TextStyle(
                    fontSize: fontMedium,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: sh * 0.03),
                if (gameOver)
                  isSmallScreen
                      ? Column(
                    children: [
                      _buildButton("Recommencer", Colors.green, resetGame),
                      SizedBox(height: sh * 0.02),
                      _buildButton("Changer les noms", Colors.orange, () {
                        setState(() {
                          playerXName = "";
                          playerOName = "";
                          boardState = List.filled(9, null);
                          gameOver = false;
                        });
                      }),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton("Recommencer", Colors.green, resetGame),
                      SizedBox(width: sw * 0.03),
                      _buildButton("Changer les noms", Colors.orange, () {
                        setState(() {
                          playerXName = "";
                          playerOName = "";
                          boardState = List.filled(9, null);
                          gameOver = false;
                        });
                      }),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleMusic,
        backgroundColor: Colors.deepPurpleAccent,
        child: Icon(musicPlaying ? Icons.music_off : Icons.music_note),
      ),
    );
  }

  Widget _buildStyledTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.deepPurple.withOpacity(0.5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: Colors.black,
        elevation: 8,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class WinLinePainter extends CustomPainter {
  final List<int> winCombo;
  final double gridSize;

  WinLinePainter(this.winCombo, this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellowAccent
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cellSize = gridSize / 3;
    final margin = 6.0;
    final effectiveCellSize = cellSize - 2 * margin;

    // Calcul des positions de début et de fin de la ligne
    Offset start = _getPosition(winCombo[0], cellSize, margin, effectiveCellSize);
    Offset end = _getPosition(winCombo[2], cellSize, margin, effectiveCellSize);

    // Pour les lignes horizontales et verticales, on ajuste les points de début et fin
    if (winCombo[0] % 3 == winCombo[1] % 3 && winCombo[1] % 3 == winCombo[2] % 3) {
      // Ligne verticale
      start = Offset(start.dx, start.dy - effectiveCellSize / 2 + margin);
      end = Offset(end.dx, end.dy + effectiveCellSize / 2 - margin);
    } else if (winCombo[0] ~/ 3 == winCombo[1] ~/ 3 && winCombo[1] ~/ 3 == winCombo[2] ~/ 3) {
      // Ligne horizontale
      start = Offset(start.dx - effectiveCellSize / 2 + margin, start.dy);
      end = Offset(end.dx + effectiveCellSize / 2 - margin, end.dy);
    } else {
      // Ligne diagonale
      if (winCombo[0] == 0 || winCombo[0] == 2) {
        start = Offset(start.dx - effectiveCellSize / 2 + margin, start.dy - effectiveCellSize / 2 + margin);
        end = Offset(end.dx + effectiveCellSize / 2 - margin, end.dy + effectiveCellSize / 2 - margin);
      } else {
        start = Offset(start.dx + effectiveCellSize / 2 - margin, start.dy - effectiveCellSize / 2 + margin);
        end = Offset(end.dx - effectiveCellSize / 2 + margin, end.dy + effectiveCellSize / 2 - margin);
      }
    }

    canvas.drawLine(start, end, paint);
  }

  Offset _getPosition(int index, double cellSize, double margin, double effectiveCellSize) {
    int row = index ~/ 3;
    int col = index % 3;

    double x = col * cellSize + margin + effectiveCellSize / 2;
    double y = row * cellSize + margin + effectiveCellSize / 2;

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}