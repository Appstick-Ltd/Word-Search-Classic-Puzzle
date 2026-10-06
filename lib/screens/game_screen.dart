import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_theme.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../services/haptics.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/praise_toast.dart';
import '../widgets/victory_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _gridKey = GlobalKey();
  late final AnimationController _pulseController;

  // Praise toast state
  String? _currentPraise;
  Color _praiseColor = const Color(0xFF10B981);
  int _lastFoundWordCount = 0;

  static const _praiseList = [
    'AWESOME!',
    'GREAT!',
    'NICE!',
    'PERFECT!',
    'SUPERB!',
    'BRILLIANT!',
    'EXCELLENT!',
    'GENIUS!',
  ];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    final state = ref.read(gameProvider);
    _lastFoundWordCount = state.words.where((w) => w.isFound).length;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onPointerDown(
    PointerDownEvent event,
    GameState gameState,
    GameNotifier notifier,
  ) {
    final coord = _coordinateFromOffset(
      event.localPosition,
      gameState.gridSize,
    );
    if (coord != null) {
      notifier.startSelection(coord);
    }
  }

  void _onPointerMove(
    PointerMoveEvent event,
    GameState gameState,
    GameNotifier notifier,
  ) {
    final coord = _coordinateFromOffset(
      event.localPosition,
      gameState.gridSize,
    );
    if (coord != null) {
      notifier.updateSelection(coord);
    }
  }

  void _onPointerUp(PointerUpEvent event, GameNotifier notifier) {
    notifier.commitSelection();
  }

  GridCoordinate? _coordinateFromOffset(Offset localPos, int gridSize) {
    final renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final size = renderBox.size;
    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;

    final col = (localPos.dx / cellWidth).floor();
    final row = (localPos.dy / cellHeight).floor();

    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      return GridCoordinate(row, col);
    }
    return null;
  }

  void _checkForWordFound(GameState gameState) {
    final currentFound = gameState.words.where((w) => w.isFound).length;
    if (currentFound > _lastFoundWordCount) {
      final newlyFound = gameState.words.lastWhere((w) => w.isFound);
      _triggerPraise(newlyFound.color);
      _lastFoundWordCount = currentFound;

      if (gameState.status == GameStatus.won) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showVictoryOverlay(gameState);
          }
        });
      }
    } else if (currentFound < _lastFoundWordCount) {
      _lastFoundWordCount = currentFound;
    }
  }

  void _triggerPraise(Color color) {
    setState(() {
      _currentPraise = _praiseList[_rnd.nextInt(_praiseList.length)];
      _praiseColor = color;
    });
  }

  void _showVictoryOverlay(GameState gameState) {
    final appTheme = ref.read(themeProvider);
    final notifier = ref.read(gameProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return VictoryDialog(
          level: gameState.level,
          isRandom: gameState.isRandom,
          wordCount: gameState.words.length,
          appTheme: appTheme,
          onNextLevel: () {
            Navigator.of(ctx).pop();
            notifier.nextLevel();
          },
          onRestart: () {
            Navigator.of(ctx).pop();
            notifier.restartCurrentLevel();
          },
          onHome: () {
            Navigator.of(ctx).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final appTheme = ref.watch(themeProvider);

    // Watch for word discoveries
    _checkForWordFound(gameState);

    final currentWordText = gameState.currentSelection
        .map((c) => gameState.grid[c.row][c.col])
        .join();

    return ConfettiOverlay(
      isPlaying: gameState.status == GameStatus.won,
      child: Scaffold(
        backgroundColor: appTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: appTheme.appBarFg,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: appTheme.appBarFg,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gameState.isRandom
                      ? (gameState.difficulty?.color ?? appTheme.playBg)
                      : appTheme.playBg,
                  Color.lerp(
                    gameState.isRandom
                        ? (gameState.difficulty?.color ?? appTheme.playBg)
                        : appTheme.playBg,
                    Colors.black,
                    0.18,
                  )!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              gameState.isRandom
                  ? 'RANDOM • ${gameState.difficulty?.label.toUpperCase() ?? "PUZZLE"}'
                  : 'LEVEL ${gameState.level}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.replay_rounded,
                color: appTheme.textMuted,
                size: 26,
              ),
              onPressed: () {
                Haptics.select();
                notifier.restartCurrentLevel();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Live Selection Floating Indicator
              SizedBox(
                height: 38,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: currentWordText.isNotEmpty
                        ? Container(
                            key: const ValueKey('active_pill'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  appTheme.playBg,
                                  Color.lerp(appTheme.playBg, Colors.white, 0.2)!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: appTheme.playBg.withValues(alpha: 0.5),
                                  offset: const Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              currentWordText.split('').join(' • '),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 2.0,
                              ),
                            ),
                          )
                        : Text(
                            'SWIPE TO CONNECT LETTERS',
                            key: const ValueKey('hint_text'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: appTheme.textMuted.withValues(alpha: 0.6),
                            ),
                          ),
                  ),
                ),
              ),
              // Game Grid Area with Praise Toast Stack
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        _buildGridArea(gameState, notifier, appTheme),
                        if (_currentPraise != null)
                          Positioned(
                            top: 20,
                            child: PraiseToast(
                              text: _currentPraise!,
                              color: _praiseColor,
                              onComplete: () {
                                if (mounted) {
                                  setState(() => _currentPraise = null);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Word Target Chips
              _buildWordChips(gameState, appTheme),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordChips(GameState state, AppThemeData appTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: state.words.map((placement) {
          final isFound = placement.isFound;
          return AnimatedScale(
            scale: isFound ? 1.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isFound
                    ? LinearGradient(
                        colors: [
                          placement.color,
                          Color.lerp(placement.color, Colors.black, 0.15)!,
                        ],
                      )
                    : null,
                color: isFound ? null : appTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isFound
                      ? Colors.white
                      : appTheme.border.withValues(alpha: 0.4),
                  width: 2.0,
                ),
                boxShadow: isFound
                    ? [
                        BoxShadow(
                          color: placement.color.withValues(alpha: 0.5),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFound) ...[
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    placement.word,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      decoration: isFound
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationThickness: 2.5,
                      decorationColor: Colors.white,
                      color: isFound ? Colors.white : appTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridArea(
    GameState gameState,
    GameNotifier notifier,
    AppThemeData appTheme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = min(constraints.maxWidth, constraints.maxHeight);

        return Container(
          width: maxSide,
          height: maxSide,
          decoration: BoxDecoration(
            color: appTheme.cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFFFD152).withValues(alpha: 0.7),
              width: 3.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC78C06).withValues(alpha: 0.35),
                offset: const Offset(0, 6),
                blurRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                offset: const Offset(0, 12),
                blurRadius: 20,
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Listener(
            key: _gridKey,
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) => _onPointerDown(e, gameState, notifier),
            onPointerMove: (e) => _onPointerMove(e, gameState, notifier),
            onPointerUp: (e) => _onPointerUp(e, notifier),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: WordPillPainter(
                          gridSize: gameState.gridSize,
                          foundWords: gameState.words
                              .where((w) => w.isFound)
                              .toList(),
                          currentSelection: gameState.currentSelection,
                          selectionColor: appTheme.playBg,
                          pulseValue: _pulseController.value,
                        ),
                      );
                    },
                  ),
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gameState.gridSize,
                    crossAxisSpacing: gameState.gridSize >= 10 ? 2 : 4,
                    mainAxisSpacing: gameState.gridSize >= 10 ? 2 : 4,
                  ),
                  itemCount: gameState.gridSize * gameState.gridSize,
                  itemBuilder: (context, index) {
                    final r = index ~/ gameState.gridSize;
                    final c = index % gameState.gridSize;
                    final letter = gameState.grid[r][c];
                    final isSelected = gameState.currentSelection.contains(
                      GridCoordinate(r, c),
                    );

                    return AnimatedScale(
                      scale: isSelected ? 1.25 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutBack,
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: _fontSizeForGrid(gameState.gridSize),
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : appTheme.textPrimary,
                            shadows: isSelected
                                ? const [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _fontSizeForGrid(int size) {
    if (size <= 5) return 26;
    if (size <= 6) return 24;
    if (size <= 7) return 22;
    if (size <= 8) return 20;
    if (size <= 9) return 18;
    if (size <= 10) return 16;
    if (size <= 11) return 14;
    return 13;
  }
}

class WordPillPainter extends CustomPainter {
  final int gridSize;
  final List<WordPlacement> foundWords;
  final List<GridCoordinate> currentSelection;
  final Color selectionColor;
  final double pulseValue;

  WordPillPainter({
    required this.gridSize,
    required this.foundWords,
    required this.currentSelection,
    required this.selectionColor,
    this.pulseValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (gridSize <= 0) return;

    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;
    final strokeWidth = min(cellWidth, cellHeight) * 0.82;

    // Found words (solid vibrant capsule with border)
    for (final placement in foundWords) {
      if (placement.coordinates.isEmpty) continue;
      _drawCapsule(
        canvas,
        placement.coordinates.first,
        placement.coordinates.last,
        cellWidth,
        cellHeight,
        placement.color.withValues(alpha: 0.55),
        strokeWidth,
        hasBorder: true,
        borderColor: placement.color,
      );
    }

    // Current drag selection with pulsing glow
    if (currentSelection.isNotEmpty) {
      final currentAlpha = 0.65 + pulseValue * 0.2;
      _drawCapsule(
        canvas,
        currentSelection.first,
        currentSelection.last,
        cellWidth,
        cellHeight,
        selectionColor.withValues(alpha: currentAlpha),
        strokeWidth,
        hasBorder: true,
        borderColor: Colors.white,
      );
    }
  }

  void _drawCapsule(
    Canvas canvas,
    GridCoordinate start,
    GridCoordinate end,
    double cellWidth,
    double cellHeight,
    Color color,
    double strokeWidth, {
    bool hasBorder = false,
    Color? borderColor,
  }) {
    final startCenter = Offset(
      (start.col + 0.5) * cellWidth,
      (start.row + 0.5) * cellHeight,
    );
    final endCenter = Offset(
      (end.col + 0.5) * cellWidth,
      (end.row + 0.5) * cellHeight,
    );

    // Fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawLine(startCenter, endCenter, fillPaint);

    // Glowing border outline
    if (hasBorder && borderColor != null) {
      final borderPaint = Paint()
        ..color = borderColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth * 0.98;

      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth * 0.25;

      canvas.drawLine(startCenter, endCenter, borderPaint);
      canvas.drawLine(startCenter, endCenter, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WordPillPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.foundWords != foundWords ||
        oldDelegate.currentSelection != currentSelection ||
        oldDelegate.selectionColor != selectionColor ||
        oldDelegate.pulseValue != pulseValue;
  }
}
