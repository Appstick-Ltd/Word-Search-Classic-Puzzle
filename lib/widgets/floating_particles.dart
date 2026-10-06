import 'dart:math';
import 'package:flutter/material.dart';

class FloatingParticles extends StatefulWidget {
  final Color particleColor;
  final int count;

  const FloatingParticles({
    super.key,
    required this.particleColor,
    this.count = 20,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticle {
  double x; // 0..1
  double y; // 0..1
  double speed;
  double size;
  double opacity;
  double oscillationSpeed;
  double oscillationWidth;
  String? letter;

  _FloatingParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.oscillationSpeed,
    required this.oscillationWidth,
    this.letter,
  });
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_FloatingParticle> _particles = [];
  final Random _rnd = Random(42);
  static const _letters = ['W', 'O', 'R', 'D', 'S', 'E', 'A', 'C', 'H', '★', '◆'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < widget.count; i++) {
      _particles.add(
        _FloatingParticle(
          x: _rnd.nextDouble(),
          y: _rnd.nextDouble(),
          speed: 0.03 + _rnd.nextDouble() * 0.06,
          size: 10 + _rnd.nextDouble() * 18,
          opacity: 0.08 + _rnd.nextDouble() * 0.16,
          oscillationSpeed: 1.0 + _rnd.nextDouble() * 2.0,
          oscillationWidth: 0.02 + _rnd.nextDouble() * 0.03,
          letter: _rnd.nextBool() ? _letters[_rnd.nextInt(_letters.length)] : null,
        ),
      );
    }
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
        return CustomPaint(
          painter: _ParticlesPainter(
            particles: _particles,
            time: _controller.value,
            color: widget.particleColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_FloatingParticle> particles;
  final double time;
  final Color color;

  _ParticlesPainter({
    required this.particles,
    required this.time,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    for (final p in particles) {
      final curY = (p.y - time * p.speed * 4) % 1.0;
      final curX = (p.x + sin((time * 2 * pi * p.oscillationSpeed) + p.y * 10) * p.oscillationWidth) % 1.0;

      final realX = curX * size.width;
      final realY = curY * size.height;

      final paint = Paint()
        ..color = color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      if (p.letter != null) {
        final textSpan = TextSpan(
          text: p.letter,
          style: TextStyle(
            color: color.withValues(alpha: p.opacity * 1.2),
            fontSize: p.size,
            fontWeight: FontWeight.w900,
            fontFamily: 'Fredoka',
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(realX - textPainter.width / 2, realY - textPainter.height / 2),
        );
      } else {
        // Glowing bubble
        canvas.drawCircle(Offset(realX, realY), p.size * 0.45, paint);
        // Highlight in bubble
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: p.opacity * 0.7)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(realX - p.size * 0.12, realY - p.size * 0.12),
          p.size * 0.12,
          highlightPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
