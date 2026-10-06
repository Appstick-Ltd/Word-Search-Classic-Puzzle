import 'dart:math';
import 'package:flutter/material.dart';

class GameLogo extends StatefulWidget {
  const GameLogo({super.key});

  @override
  State<GameLogo> createState() => _GameLogoState();
}

class _GameLogoState extends State<GameLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final floatOffset = sin(_controller.value * 2 * pi) * 6.0;
        final scale = 1.0 + sin(_controller.value * 2 * pi) * 0.018;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background game badge container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2575FC),
                  Color(0xFF1B2A75),
                  Color(0xFF10194E),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFFFD152),
                width: 3.5,
              ),
              boxShadow: [
                const BoxShadow(
                  color: Color(0xFFC78C06),
                  offset: Offset(0, 7),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF2575FC).withValues(alpha: 0.4),
                  offset: const Offset(0, 14),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row with mini grid icon + sparkling stars
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMiniTile('W', const Color(0xFFFF4757)),
                    const SizedBox(width: 4),
                    _buildMiniTile('O', const Color(0xFFFFA502)),
                    const SizedBox(width: 4),
                    _buildMiniTile('R', const Color(0xFF2ED573)),
                    const SizedBox(width: 4),
                    _buildMiniTile('D', const Color(0xFF1E90FF)),
                  ],
                ),
                const SizedBox(height: 6),
                // "WORD" text with extruded 3D golden effect
                _build3dText(
                  'WORD',
                  fontSize: 44,
                  textColor: const Color(0xFFFFE600),
                  shadowColor: const Color(0xFFD48B00),
                  strokeColor: Colors.white,
                ),
                // "SEARCH" text with glossy 3D white-blue effect
                _build3dText(
                  'SEARCH',
                  fontSize: 40,
                  textColor: Colors.white,
                  shadowColor: const Color(0xFF0F3B8C),
                  strokeColor: const Color(0xFF70A1FF),
                ),
                const SizedBox(height: 6),
                // Ribbon subtitle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3838),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFB31212),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF8B0000),
                        offset: Offset(0, 2.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    'CLASSIC PUZZLE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Twinkling decorative stars
          Positioned(
            top: -12,
            right: -10,
            child: _TwinkleStar(size: 26, color: const Color(0xFFFFD152)),
          ),
          Positioned(
            bottom: -6,
            left: -10,
            child: _TwinkleStar(size: 22, color: const Color(0xFFFF4757), delay: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTile(String char, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            offset: const Offset(0, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _build3dText(
    String text, {
    required double fontSize,
    required Color textColor,
    required Color shadowColor,
    required Color strokeColor,
  }) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 4.0,
        height: 1.0,
        color: textColor,
        shadows: [
          // 3D Extrusion stack
          Shadow(offset: const Offset(0, 1), blurRadius: 0, color: shadowColor),
          Shadow(offset: const Offset(0, 2), blurRadius: 0, color: shadowColor),
          Shadow(offset: const Offset(0, 3), blurRadius: 0, color: shadowColor),
          Shadow(offset: const Offset(0, 4), blurRadius: 0, color: shadowColor),
          Shadow(offset: const Offset(0, 5), blurRadius: 0, color: shadowColor),
          const Shadow(offset: Offset(0, 7), blurRadius: 6, color: Colors.black45),
        ],
      ),
    );
  }
}

class _TwinkleStar extends StatefulWidget {
  final double size;
  final Color color;
  final double delay;

  const _TwinkleStar({
    required this.size,
    required this.color,
    this.delay = 0.0,
  });

  @override
  State<_TwinkleStar> createState() => _TwinkleStarState();
}

class _TwinkleStarState extends State<_TwinkleStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final scale = 0.8 + 0.35 * sin((_controller.value + widget.delay) * 2 * pi);
        final rot = _controller.value * pi * 0.25;

        return Transform.rotate(
          angle: rot,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              Icons.star_rounded,
              size: widget.size,
              color: widget.color,
              shadows: [
                Shadow(
                  color: widget.color.withValues(alpha: 0.6),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
