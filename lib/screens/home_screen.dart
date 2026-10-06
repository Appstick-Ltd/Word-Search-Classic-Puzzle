import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_theme.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../services/sound_service.dart';
import '../widgets/floating_particles.dart';
import '../widgets/game_button.dart';
import '../widgets/game_logo.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'levels_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
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
          // Ambient floating particles & gaming atmosphere
          Positioned.fill(
            child: FloatingParticles(
              particleColor: appTheme.textPrimary.withValues(alpha: 0.12),
              count: 22,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Game Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Star / GitHub button
                      _buildTopIconButton(
                        icon: Icons.star_rounded,
                        color: const Color(0xFFFFA502),
                        onTap: () => launchUrl(
                          Uri.parse('https://github.com/sidhant947/FindWords'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      // Level Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              appTheme.playBg,
                              Color.lerp(appTheme.playBg, Colors.black, 0.15)!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: appTheme.playBg.withValues(alpha: 0.4),
                              offset: const Offset(0, 3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: Color(0xFFFFD152),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'LEVEL $highestLevel',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Support / Heart button
                      _buildTopIconButton(
                        icon: Icons.favorite_rounded,
                        color: const Color(0xFFFF4757),
                        onTap: () => launchUrl(
                          Uri.parse('https://ko-fi.com/sidhant947'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              // 3D Animated Game Logo
                              const Center(child: GameLogo()),
                              const SizedBox(height: 16),
                              // Animated Action Buttons
                              _buildStaggeredButton(
                                index: 0,
                                child: GameButton(
                                  onTap: () {
                                    ref.read(gameProvider.notifier).startLevel(highestLevel);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const GameScreen()),
                                    );
                                  },
                                  label: 'PLAY',
                                  icon: Icons.play_arrow_rounded,
                                  backgroundColor: appTheme.playBg,
                                  borderColor: appTheme.playBorder,
                                  shadowColor: appTheme.playShadow,
                                  height: 62,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildStaggeredButton(
                                index: 1,
                                child: GameButton(
                                  onTap: () {
                                    _showRandomDifficultyDialog(context, ref, appTheme);
                                  },
                                  label: 'RANDOM PUZZLE',
                                  icon: Icons.shuffle_rounded,
                                  backgroundColor: appTheme.randomBg,
                                  borderColor: appTheme.randomBorder,
                                  shadowColor: appTheme.randomShadow,
                                  height: 60,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildStaggeredButton(
                                index: 2,
                                child: GameButton(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const LevelsScreen()),
                                    );
                                  },
                                  label: 'LEVELS',
                                  icon: Icons.grid_view_rounded,
                                  backgroundColor: appTheme.levelsBg,
                                  borderColor: appTheme.levelsBorder,
                                  shadowColor: appTheme.levelsShadow,
                                  height: 60,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildStaggeredButton(
                                index: 3,
                                child: GameButton(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const HowToPlayScreen(),
                                      ),
                                    );
                                  },
                                  label: 'HOW TO PLAY',
                                  icon: Icons.help_outline_rounded,
                                  backgroundColor: const Color(0xFF00CEC9),
                                  borderColor: const Color(0xFF009688),
                                  shadowColor: const Color(0xFF00796B),
                                  height: 58,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildStaggeredButton(
                                index: 4,
                                child: GameButton(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                    );
                                  },
                                  label: 'SETTINGS',
                                  icon: Icons.settings_rounded,
                                  backgroundColor: appTheme.settingsBg,
                                  borderColor: appTheme.settingsBorder,
                                  shadowColor: appTheme.settingsShadow,
                                  height: 58,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
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

  Widget _buildTopIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SoundService.playTap();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _buildStaggeredButton({
    required int index,
    required Widget child,
  }) {
    final start = (index * 0.1).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final translateY = (1.0 - animation.value) * 35;
        final opacity = animation.value.clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
    );
  }

  void _showRandomDifficultyDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeData appTheme,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  appTheme.dialogBg,
                  Color.lerp(appTheme.dialogBg, appTheme.surfaceVariant, 0.3)!,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFFFD152),
                width: 2.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.casino_rounded,
                      color: Color(0xFFFFA502),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RANDOM PUZZLE',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: appTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Select puzzle difficulty',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                ...PuzzleDifficulty.values.map((diff) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GameButton(
                      onTap: () {
                        ref.read(gameProvider.notifier).startRandomPuzzle(diff);
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GameScreen()),
                        );
                      },
                      label: '${diff.label.toUpperCase()} (${diff.gridSize}x${diff.gridSize})',
                      backgroundColor: diff.color,
                      borderColor: diff.darkColor,
                      shadowColor: diff.darkColor,
                      height: 52,
                      fontSize: 16,
                      depth: 4,
                    ),
                  );
                }),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: appTheme.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
