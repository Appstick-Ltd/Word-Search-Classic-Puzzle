import 'package:flutter/material.dart';
import '../services/haptics.dart';
import '../services/sound_service.dart';

class GameButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final Color textColor;
  final double height;
  final double? width;
  final double fontSize;
  final double borderRadius;
  final double depth;

  const GameButton({
    super.key,
    required this.onTap,
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.shadowColor,
    this.textColor = Colors.white,
    this.height = 64,
    this.width,
    this.fontSize = 20,
    this.borderRadius = 20,
    this.depth = 6,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    Haptics.light();
    SoundService.playTap();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDepth = _isPressed ? 1.5 : widget.depth;
    final translateY = _isPressed ? (widget.depth - 1.5) : 0.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOutQuad,
        width: widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(0, translateY, 0),
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.borderColor,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                offset: Offset(0, effectiveDepth),
                blurRadius: 0,
              ),
              if (!_isPressed)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  offset: Offset(0, widget.depth + 3),
                  blurRadius: 6,
                ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(widget.backgroundColor, Colors.white, 0.22)!,
                widget.backgroundColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Subtle top glossy reflection highlight
              Positioned(
                top: 2,
                left: widget.borderRadius * 0.5,
                right: widget.borderRadius * 0.5,
                height: (widget.height - 10) * 0.42,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius * 0.6),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
              // Button content (icon + label)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.textColor,
                        size: widget.fontSize * 1.15,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1.5),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: const [
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
