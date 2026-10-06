import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../services/haptics.dart';
import 'game_button.dart';

class VictoryDialog extends StatefulWidget {
  final int level;
  final bool isRandom;
  final int wordCount;
  final VoidCallback onNextLevel;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final AppThemeData appTheme;

  const VictoryDialog({
    super.key,
    required this.level,
    required this.isRandom,
    required this.wordCount,
    required this.onNextLevel,
    required this.onRestart,
    required this.onHome,
    required this.appTheme,
  });

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog>
    with TickerProviderStateMixin {
  late final AnimationController _cardController;
  late final AnimationController _raysController;
  late final AnimationController _star1Controller;
  late final AnimationController _star2Controller;
  late final AnimationController _star3Controller;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _raysController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _star1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _star2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _star3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Stagger star entrance
    _cardController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Haptics.heavy();
          _star1Controller.forward();
        }
      });
      Future.delayed(const Duration(milliseconds: 320), () {
        if (mounted) {
          Haptics.heavy();
          _star2Controller.forward();
        }
      });
      Future.delayed(const Duration(milliseconds: 540), () {
        if (mounted) {
          Haptics.heavy();
          _star3Controller.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _raysController.dispose();
    _star1Controller.dispose();
    _star2Controller.dispose();
    _star3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOutBack,
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Background Rotating Sunburst Rays
            Positioned(
              top: -80,
              child: AnimatedBuilder(
                animation: _raysController,
                builder: (context, _) {
                  return Transform.rotate(
                    angle: _raysController.value * 2 * pi,
                    child: CustomPaint(
                      painter: _SunburstPainter(
                        color: const Color(0xFFFFD152).withValues(alpha: 0.18),
                      ),
                      size: const Size(260, 260),
                    ),
                  );
                },
              ),
            ),
            // Main card
            Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.appTheme.cardBg,
                    Color.lerp(widget.appTheme.cardBg, widget.appTheme.surfaceVariant, 0.4)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFFFD152),
                  width: 3.5,
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0xFFC78C06),
                    offset: Offset(0, 8),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    offset: const Offset(0, 16),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isRandom ? 'PUZZLE SOLVED!' : 'LEVEL COMPLETE!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: widget.appTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.isRandom
                        ? 'Found all ${widget.wordCount} words!'
                        : 'Level ${widget.level} Mastered!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: widget.appTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 3 Stars Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedStar(_star1Controller, 42, -0.15),
                      const SizedBox(width: 8),
                      _buildAnimatedStar(_star2Controller, 54, 0.0),
                      const SizedBox(width: 8),
                      _buildAnimatedStar(_star3Controller, 42, 0.15),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Next Level Button
                  GameButton(
                    onTap: widget.onNextLevel,
                    label: widget.isRandom ? 'NEXT PUZZLE' : 'NEXT LEVEL',
                    icon: Icons.play_arrow_rounded,
                    backgroundColor: const Color(0xFF10B981),
                    borderColor: const Color(0xFF047857),
                    shadowColor: const Color(0xFF064E3B),
                    height: 58,
                    fontSize: 18,
                  ),
                  const SizedBox(height: 12),
                  // Secondary actions (Replay & Home)
                  Row(
                    children: [
                      Expanded(
                        child: GameButton(
                          onTap: widget.onRestart,
                          label: 'REPLAY',
                          icon: Icons.replay_rounded,
                          backgroundColor: const Color(0xFF3897F0),
                          borderColor: const Color(0xFF1E6BB8),
                          shadowColor: const Color(0xFF1E3A8A),
                          height: 48,
                          fontSize: 14,
                          depth: 4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GameButton(
                          onTap: widget.onHome,
                          label: 'HOME',
                          icon: Icons.home_rounded,
                          backgroundColor: widget.appTheme.surfaceVariant,
                          borderColor: widget.appTheme.border,
                          shadowColor: Color.lerp(widget.appTheme.border, Colors.black, 0.3)!,
                          textColor: widget.appTheme.textPrimary,
                          height: 48,
                          fontSize: 14,
                          depth: 4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Floating Crown / Trophy Badge on top
            Positioned(
              top: 8,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFEA79),
                      Color(0xFFFFA502),
                      Color(0xFFCC8400),
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: [
                    const BoxShadow(
                      color: Color(0xFF8B5A00),
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFA502).withValues(alpha: 0.5),
                      offset: const Offset(0, 8),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 38,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStar(
    AnimationController controller,
    double size,
    double tilt,
  ) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
      child: Transform.rotate(
        angle: tilt,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD152).withValues(alpha: 0.5),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            Icons.star_rounded,
            size: size,
            color: const Color(0xFFFFD152),
            shadows: const [
              Shadow(
                color: Color(0xFFC78C06),
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  final Color color;

  _SunburstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const count = 12;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = i * 2 * pi / count;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          angle,
          pi / count,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) => false;
}
