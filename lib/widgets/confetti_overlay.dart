import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rot;
  double vrot;
  double width;
  double height;
  Color color;
  bool isStar;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rot,
    required this.vrot,
    required this.width,
    required this.height,
    required this.color,
    this.isStar = false,
  });
}

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.isPlaying,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _rnd = Random();

  static const _palette = [
    Color(0xFFFF4757),
    Color(0xFF2ED573),
    Color(0xFF1E90FF),
    Color(0xFFFFA502),
    Color(0xFFFF6B81),
    Color(0xFF70A1FF),
    Color(0xFFFFD152),
    Color(0xFF9B59B6),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..addListener(_updatePhysics);

    if (widget.isPlaying) {
      _spawnParticles();
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _spawnParticles();
      _controller.forward(from: 0.0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    const count = 75;
    for (int i = 0; i < count; i++) {
      final angle = -pi / 2 + (_rnd.nextDouble() - 0.5) * pi * 0.9;
      final speed = 8.0 + _rnd.nextDouble() * 16.0;
      _particles.add(
        ConfettiParticle(
          x: 0.5,
          y: 0.35,
          vx: cos(angle) * speed * 0.003,
          vy: sin(angle) * speed * 0.003,
          rot: _rnd.nextDouble() * 2 * pi,
          vrot: (_rnd.nextDouble() - 0.5) * 0.3,
          width: 8 + _rnd.nextDouble() * 8,
          height: 12 + _rnd.nextDouble() * 10,
          color: _palette[_rnd.nextInt(_palette.length)],
          isStar: _rnd.nextDouble() < 0.25,
        ),
      );
    }
  }

  void _updatePhysics() {
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.00035; // gravity
      p.vx *= 0.985; // air drag
      p.rot += p.vrot;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isPlaying || _controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final fadeOut = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final px = p.x * size.width;
      final py = p.y * size.height;

      if (py > size.height + 20) continue;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rot);

      final paint = Paint()
        ..color = p.color.withValues(alpha: fadeOut)
        ..style = PaintingStyle.fill;

      if (p.isStar) {
        _drawStar(canvas, p.width * 0.7, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.width, height: p.height),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    const points = 5;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = i * pi / points;
      final x = cos(angle) * r;
      final y = sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
