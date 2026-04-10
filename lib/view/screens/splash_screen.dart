import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../data/services/app_storage_service.dart';
import '../../core/localization/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  final _storageService = AppStorageService();
  String _language = 'tr';
  String _randomTip = '';
  bool _hasNavigated = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animationController.forward();
    _rotationController.repeat();

    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(const Duration(seconds: 4), () async {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;

      try {
        final isProfileCreated = await _storageService.isProfileCreated();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            isProfileCreated ? '/' : '/profile',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    });
  }

  Future<void> _loadLanguage() async {
    final language = await _storageService.getLanguage();
    _selectRandomTip(language);
    if (mounted) {
      setState(() {
        _language = language;
      });
    }
  }

  void _selectRandomTip(String language) {
    const tips = [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
    ];
    final random = Random();
    final randomTipNumber = tips[random.nextInt(tips.length)];
    _randomTip = AppStrings.get('tip$randomTipNumber', language);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade200,
                Colors.purple.shade300,
                Colors.blue.shade300,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                ScaleTransition(
                  scale: Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Chat Bubble Logo
                      _buildChatBubbleLogo(),
                      const SizedBox(height: 32),
                      // FastGökdeniz Text
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Fast',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            TextSpan(
                              text: 'Gökdeniz',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tip of the Day
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _randomTip,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Rotating Loading Icon
                      RotationTransition(
                        turns: _rotationController,
                        child: Icon(
                          Icons.sync,
                          color: Colors.cyan.shade300,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.get('developer', _language),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.get('allRightsReserved', _language),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubbleLogo() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer bubble with gradient
          CustomPaint(size: const Size(150, 150), painter: ChatBubblePainter()),
          // Eyes (white dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          // Decorative dots on top right
          Positioned(
            top: 15,
            right: 20,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
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

class ChatBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.cyan.shade400,
          Colors.blue.shade600,
          Colors.blue.shade900,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw chat bubble shape
    final bubbleRadius = 45.0;

    // Top left arc
    path.addArc(
      Rect.fromLTWH(10, 10, bubbleRadius * 2, bubbleRadius * 2),
      3.14159,
      1.5708,
    );

    // Top right arc
    path.addArc(
      Rect.fromLTWH(
        size.width - 10 - bubbleRadius * 2,
        10,
        bubbleRadius * 2,
        bubbleRadius * 2,
      ),
      1.5708,
      1.5708,
    );

    // Right side line going down and then to pointer
    path.lineTo(size.width - 10, size.height - 35);

    // Pointer triangle
    path.lineTo(size.width - 5, size.height - 15);
    path.lineTo(size.width - 30, size.height - 35);

    // Bottom right arc
    path.addArc(
      Rect.fromLTWH(
        size.width - 10 - bubbleRadius * 2,
        size.height - 35 - bubbleRadius * 2,
        bubbleRadius * 2,
        bubbleRadius * 2,
      ),
      0,
      1.5708,
    );

    // Bottom left arc
    path.addArc(
      Rect.fromLTWH(
        10,
        size.height - 35 - bubbleRadius * 2,
        bubbleRadius * 2,
        bubbleRadius * 2,
      ),
      4.71239,
      1.5708,
    );

    // Left side back to top
    path.lineTo(10, 55);

    canvas.drawPath(path, paint);

    // Add glossy highlight effect
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.addArc(Rect.fromLTWH(20, 20, 50, 50), 3.14159, 3.14159);

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(ChatBubblePainter oldDelegate) => false;
}
