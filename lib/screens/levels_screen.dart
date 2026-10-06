import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_theme.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../services/haptics.dart';
import '../services/sound_service.dart';
import '../widgets/floating_particles.dart';
import 'game_screen.dart';

class LevelsScreen extends ConsumerStatefulWidget {
  const LevelsScreen({super.key});

  @override
  ConsumerState<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends ConsumerState<LevelsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  static const totalLevels = 100;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highestLevel = ref.watch(highestLevelProvider);
    final appTheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: appTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: FloatingParticles(
              particleColor: appTheme.textPrimary.withValues(alpha: 0.1),
              count: 18,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: appTheme.appBarFg,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'LEVELS',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: 2.0,
                          color: appTheme.appBarFg,
                        ),
                      ),
                      const SizedBox(width: 48), // balance leading button
                    ],
                  ),
                ),
                // Progress Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appTheme.cardBg,
                          Color.lerp(appTheme.cardBg, appTheme.surfaceVariant, 0.4)!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: appTheme.border.withValues(alpha: 0.4),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFD152),
                                  size: 24,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'PROGRESS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 1.2,
                                    color: appTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$highestLevel / $totalLevels UNLOCKED',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: appTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (highestLevel / totalLevels).clamp(0.0, 1.0),
                            minHeight: 12,
                            backgroundColor: appTheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              appTheme.playBg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Levels Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: totalLevels,
                    itemBuilder: (context, index) {
                      final levelNum = index + 1;
                      final isUnlocked = levelNum <= highestLevel;
                      final isCurrent = levelNum == highestLevel;
                      final isCompleted = levelNum < highestLevel;

                      return _LevelNodeButton(
                        levelNum: levelNum,
                        isUnlocked: isUnlocked,
                        isCurrent: isCurrent,
                        isCompleted: isCompleted,
                        pulseController: _pulseController,
                        appTheme: appTheme,
                        onTap: isUnlocked
                            ? () {
                                Haptics.select();
                                ref.read(gameProvider.notifier).startLevel(levelNum);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const GameScreen(),
                                  ),
                                );
                              }
                            : null,
                      );
                    },
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

class _LevelNodeButton extends StatefulWidget {
  final int levelNum;
  final bool isUnlocked;
  final bool isCurrent;
  final bool isCompleted;
  final AnimationController pulseController;
  final AppThemeData appTheme;
  final VoidCallback? onTap;

  const _LevelNodeButton({
    required this.levelNum,
    required this.isUnlocked,
    required this.isCurrent,
    required this.isCompleted,
    required this.pulseController,
    required this.appTheme,
    required this.onTap,
  });

  @override
  State<_LevelNodeButton> createState() => _LevelNodeButtonState();
}

class _LevelNodeButtonState extends State<_LevelNodeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveDepth = _isPressed ? 1.0 : 4.0;
    final translateY = _isPressed ? 3.0 : 0.0;

    Color bgColor;
    Color borderColor;
    Color shadowColor;

    if (!widget.isUnlocked) {
      bgColor = widget.appTheme.levelLocked;
      borderColor = widget.appTheme.levelLockedBorder;
      shadowColor = widget.appTheme.levelLockedBorder;
    } else if (widget.isCurrent) {
      bgColor = widget.appTheme.levelCurrent;
      borderColor = const Color(0xFFFFD152);
      shadowColor = widget.appTheme.levelCurrentShadow;
    } else {
      bgColor = widget.appTheme.levelNormal;
      borderColor = widget.appTheme.levelNormalBorder;
      shadowColor = widget.appTheme.levelNormalShadow;
    }

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = true);
          SoundService.playTap();
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        transform: Matrix4.translationValues(0, translateY, 0),
        child: AnimatedBuilder(
          animation: widget.pulseController,
          builder: (context, child) {
            final haloSize = widget.isCurrent
                ? 4.0 + sin(widget.pulseController.value * pi) * 4.0
                : 0.0;

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
                  width: widget.isCurrent ? 3.0 : 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    offset: Offset(0, effectiveDepth),
                    blurRadius: 0,
                  ),
                  if (widget.isCurrent)
                    BoxShadow(
                      color: const Color(0xFFFFD152).withValues(alpha: 0.5),
                      blurRadius: haloSize * 2,
                      spreadRadius: haloSize * 0.5,
                    ),
                ],
                gradient: widget.isUnlocked
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.lerp(bgColor, Colors.white, 0.22)!,
                          bgColor,
                        ],
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Top glossy highlight for unlocked
                  if (widget.isUnlocked)
                    Positioned(
                      top: 2,
                      left: 6,
                      right: 6,
                      height: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
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
                  Center(
                    child: widget.isUnlocked
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.levelNum}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      offset: Offset(0, 1.5),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.isCompleted)
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFD152),
                                  size: 14,
                                ),
                              if (widget.isCurrent)
                                const Text(
                                  'PLAY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                            ],
                          )
                        : Icon(
                            Icons.lock_rounded,
                            color: widget.appTheme.levelLockedIcon,
                            size: 22,
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
