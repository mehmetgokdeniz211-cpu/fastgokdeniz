import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class FlappyBirdScreen extends StatefulWidget {
  const FlappyBirdScreen({super.key});

  @override
  State<FlappyBirdScreen> createState() => _FlappyBirdScreenState();
}

class _FlappyBirdScreenState extends State<FlappyBirdScreen> with TickerProviderStateMixin {
  double screenHeight = 0;
  double screenWidth = 0;
  double birdY = 0;
  double birdX = 0;
  double birdSize = 30;
  double gravity = 0.6;
  double velocity = 0;
  List<PipeSet> pipes = [];
  int score = 0;
  bool gameOver = false;
  bool gamePaused = false;
  Timer? gameTimer;
  Timer? pipeTimer;
  double pipeGap = 160;
  double pipeWidth = 60;
  double pipeSpeed = 5.5;
  List<int> highScores = [];
  int _updateCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
    // Build çağrılana kadar bekle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startGame();
    });
  }

  Future<void> _loadHighScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresString = prefs.getStringList('high_scores') ?? [];
      setState(() {
        highScores = scoresString.map((s) => int.parse(s)).toList();
        highScores.sort((a, b) => b.compareTo(a));
        if (highScores.length > 10) {
          highScores = highScores.sublist(0, 10);
        }
      });
    } catch (e) {
      print('Error loading high scores: $e');
    }
  }

  Future<void> _saveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      highScores.add(score);
      highScores.sort((a, b) => b.compareTo(a));
      if (highScores.length > 10) {
        highScores = highScores.sublist(0, 10);
      }
      await prefs.setStringList('high_scores', highScores.map((s) => s.toString()).toList());
    } catch (e) {
      print('Error saving high score: $e');
    }
  }

  void startGame() {
    if (screenHeight == 0 || screenWidth == 0) return;
    
    birdY = screenHeight / 2;
    birdX = screenWidth / 4;
    velocity = 0;
    score = 0;
    gameOver = false;
    gamePaused = false;
    pipes.clear();
    
    pipeTimer?.cancel();
    gameTimer?.cancel();
    
    gameTimer = Timer.periodic(Duration(milliseconds: 40), (timer) {
      if (!gameOver && !gamePaused) {
        updateGame();
      }
    });

    // Borular ekle
    pipeTimer = Timer.periodic(Duration(milliseconds: 1800), (timer) {
      if (!gameOver && !gamePaused && pipes.length < 3) {
        addPipe();
      }
      if (gameOver) timer.cancel();
    });
  }

  void updateGame() {
    // Hızlı update - minimal state change
    velocity += gravity;
    birdY += velocity;

    // Boruları hareket ettir
    for (var pipe in pipes) {
      pipe.x -= pipeSpeed;
    }

    // Geçmiş boruları kaldır
    pipes.removeWhere((pipe) => pipe.x + pipeWidth < 0);

    // Puan kontrol et - her geçilen boru için 1 puan
    for (var pipe in pipes) {
      if (pipe.x + pipeWidth < birdX && !pipe.scored) {
        pipe.scored = true;
        score++;
      }
    }

    // Çarpışma kontrol et
    if (checkCollision()) {
      gameOver = true;
      gameTimer?.cancel();
      _saveHighScore();
    }

    // Alt sınır kontrol et
    if (birdY > screenHeight) {
      gameOver = true;
      gameTimer?.cancel();
      _saveHighScore();
    }

    // Render güncelleme - her 2. frame'de render yap (performans optimizasyonu)
    _updateCount++;
    if (_updateCount % 2 == 0 && mounted) {
      setState(() {});
    }
  }

  bool checkCollision() {
    for (var pipe in pipes) {
      // Kuşun x konumunun boruyla çakışması
      if (birdX + birdSize > pipe.x && birdX < pipe.x + pipeWidth) {
        // Kuşun y konumunun boş alanın dışında olması
        if (birdY < pipe.topHeight || birdY + birdSize > pipe.topHeight + pipeGap) {
          return true;
        }
      }
    }
    // Üst sınır
    if (birdY < 0) {
      return true;
    }
    return false;
  }

  void addPipe() {
    if (screenHeight == 0 || screenWidth == 0) return;
    double topHeight = (Random().nextDouble() * (screenHeight - pipeGap - 100)) + 50;
    pipes.add(PipeSet(x: screenWidth, topHeight: topHeight));
  }

  void jump() {
    if (!gameOver && !gamePaused) {
      setState(() {
        velocity = -11;
      });
    }
  }

  void togglePause() {
    setState(() {
      gamePaused = !gamePaused;
    });
  }

  void resetGame() {
    gameTimer?.cancel();
    pipeTimer?.cancel();
    setState(() {
      gameOver = false;
      gamePaused = false;
      score = 0;
      pipes.clear();
    });
    _loadHighScores();
    startGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    pipeTimer?.cancel();
    super.dispose();
  }

  // Basit uçak icon'u - sağa bakacak şekilde
  Widget _buildAirplane(double size) {
    return Transform.translate(
      offset: Offset(-size * 0.5, -size * 0.3),
      child: Text(
        '✈️',
        style: TextStyle(fontSize: size * 1.8),
      ),
    );
  }

  // Engel olarak binalar - basit siyah çubuklar
  Widget _buildBuildingObstacle(double height, double width, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black87,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: GestureDetector(
          onTap: jump,
          child: Container(
            color: Colors.cyan.shade100,
            child: Stack(
              children: [
                // Oyun alanı
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  color: Colors.cyanAccent.shade100,
                  child: Stack(
                    children: [
                      // Uçak
                      Positioned(
                        left: birdX,
                        top: birdY,
                        child: _buildAirplane(birdSize),
                      ),
                      // Çubuk engelleri
                      ...pipes.map((pipe) {
                        return Positioned(
                          left: pipe.x,
                          top: 0,
                          child: Column(
                            children: [
                              // Üst çubuk
                              _buildBuildingObstacle(
                                pipe.topHeight,
                                pipeWidth,
                                Colors.black87,
                              ),
                              // Boş alan
                              SizedBox(height: pipeGap),
                              // Alt çubuk
                              _buildBuildingObstacle(
                                screenHeight - pipe.topHeight - pipeGap,
                                pipeWidth,
                                Colors.black87,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                // Puan
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                // Oyun Bitti Ekranı
                if (gameOver)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Oyun Bitti!',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Final Puanı: $score',
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Puan Tablosu
                            if (highScores.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'En Yüksek Puanlar',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ...List.generate(
                                      highScores.length,
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${index + 1}. 🏅',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              '${highScores[index]} puan',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 40),
                            ElevatedButton.icon(
                              onPressed: resetGame,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Yeniden Başla'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.home),
                              label: const Text('Ana Menüye Dön'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                backgroundColor: Colors.grey.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Duraklat Butonu
                if (!gameOver)
                  Positioned(
                    top: 40,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: togglePause,
                      backgroundColor: Colors.blue.shade600,
                      child: Icon(
                        gamePaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                      ),
                    ),
                  ),
                // Duraklatıldı Mesajı
                if (gamePaused && !gameOver)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Oyun Duraklatıldı',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: togglePause,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Devam Et'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PipeSet {
  double x;
  double topHeight;
  bool scored = false; // Her boru için sadece bir kez puan ver

  PipeSet({required this.x, required this.topHeight});
}
