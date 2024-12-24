import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_2048/core/core.dart';
import 'package:flutter_2048/domain/domain.dart';
import 'package:flutter_2048/presentation/game/game.dart';
import 'package:flutter_2048/presentation/game/viewmodel/game_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  final FocusNode _focusNode = FocusNode();
  LogicalKeyboardKey? activeKeyDown;
  final gridSpacing = 4.0;
  final margin = 20;
  double swipeAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => ref.read(gameVMProvider).initialize());
  }

  void _handleStartGame() {
    ref.read(gameVMProvider).startNewGame();
    setState(() {
      activeKeyDown = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameVMProvider);
    if (state.isGameOver) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => GameOverDialog.show(
          context,
          onOkPressed: _handleStartGame,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => StartNewGameDialog.show(
              context,
              onOkPressed: _handleStartGame,
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: (node, event) => _handleKeyEvent(event),
        child: GestureDetector(
          onPanUpdate: (details) {
            final dragOffset = details.delta;
            // print(dragOffset);
            // atan2 returns angle based on how much is the drag happened on x and y axis respectively, then 180 into pi converts the angle into degree and summed up with 360 to handle if negative degree occurs and if positive degree occurs then it gets handled by %360 to ensure the degree stays in the range of 0 to 360.
            // 0 degree indicates right side
            // 90 degree indicates up side
            // 180 degree indicates left side
            // 270 degree indicates down side
            swipeAngle =
                (atan2(-dragOffset.dy, dragOffset.dx) * 180 / pi + 360) % 360;
            // print(swipeAngle);
            setState(() {});
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: margin / 2, vertical: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isPortrait = constraints.maxHeight > constraints.maxWidth;
                // min method is selecting minimum value between provided constraints, clamp is ensuring that the value does not exceed the range of 0-600 and then subtracting it twice the gridSpacing which is already provided.
                final gridSize =
                    min(constraints.maxWidth, constraints.maxHeight)
                            .clamp(0, 600) -
                        gridSpacing * 2;
                if (isPortrait) {
                  return Column(
                    children: [
                      GameGrid(
                        gridSpacing: gridSpacing,
                        gridTileMovements: state.gridTileMovements,
                        gridSize: gridSize,
                      ),
                      const SizedBox(height: 16),
                      ScoresTile(
                        bestScore: state.bestScore.toString(),
                        currentScore: state.currentScore.toString(),
                        isPortrait: isPortrait,
                      )
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GameGrid(
                        gridTileMovements: state.gridTileMovements,
                        gridSpacing: gridSpacing,
                        gridSize: gridSize,
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: gridSize,
                        child: ScoresTile(
                          bestScore: state.bestScore.toString(),
                          currentScore: state.currentScore.toString(),
                          isPortrait: isPortrait,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final direction = event.direction;
      if (activeKeyDown == null && direction != null) {
        setState(() {
          activeKeyDown = event.logicalKey;
        });
        ref.read(gameVMProvider.notifier).move(direction);
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == activeKeyDown) {
        setState(() {
          activeKeyDown = null;
        });
      }
    }
    return KeyEventResult.handled;
  }
}

class _GridViewStack extends StatelessWidget {
  const _GridViewStack(
      {required this.tileSize,
      required this.gridSpacing,
      required this.gridTileMovements});
  final double tileSize;
  final double gridSpacing;
  final List<GridTileMovement> gridTileMovements;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GridViewWidget(
            gridSize: AppConstants.maxGridSize,
            tileSize: tileSize,
            gridSpacing: gridSpacing,
          ),
        ),
        for (var gridTileMovement in gridTileMovements)
          AnimatedGridChild(
            gridTileMovement: gridTileMovement,
            offset: tileSize + gridSpacing,
            key: ValueKey(gridTileMovement.toGridTile.tile.id),
            child: GridTileWidget(
              gridTileMovement: gridTileMovement,
              tileSize: tileSize,
            ),
          ),
      ],
    );
  }
}

class GameGrid extends StatelessWidget {
  const GameGrid({
    super.key,
    required this.gridTileMovements,
    required this.gridSpacing,
    this.gridSize = 320,
  });
  final List<GridTileMovement> gridTileMovements;
  final double gridSize;
  final double gridSpacing;
  @override
  Widget build(BuildContext context) {
    final tileSize =
        ((gridSize - gridSpacing * (AppConstants.maxGridSize - 1)) /
                    AppConstants.maxGridSize) <
                0
            ? 0.0
            : ((gridSize - gridSpacing * (AppConstants.maxGridSize - 1)) /
                AppConstants.maxGridSize);
    return SizedBox(
      height: gridSize,
      width: gridSize,
      child: _GridViewStack(
        tileSize: tileSize,
        gridSpacing: gridSpacing,
        gridTileMovements: gridTileMovements,
      ),
    );
  }
}

class AnimatedGridChild extends StatefulWidget {
  const AnimatedGridChild(
      {super.key,
      required this.child,
      required this.gridTileMovement,
      required this.offset});
  final Widget child;
  final GridTileMovement gridTileMovement;
  final double offset;

  @override
  State<AnimatedGridChild> createState() => _AnimatedGridChildState();
}

class _AnimatedGridChildState extends State<AnimatedGridChild>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  late final Cell _initialCell = widget.gridTileMovement.fromGridTile?.cell ??
      widget.gridTileMovement.toGridTile.cell;
  late final _currentOffset = Offset(
      _initialCell.col * widget.offset, _initialCell.row * widget.offset);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));

    _offsetAnimation = Tween(begin: _currentOffset, end: _currentOffset)
        .animate(_animationController);
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedGridChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cell = oldWidget.gridTileMovement.toGridTile.cell;
    final newcell = widget.gridTileMovement.toGridTile.cell;
    final currentOffset =
        Offset(cell.col * oldWidget.offset, cell.row * oldWidget.offset);
    final newOffset =
        Offset(newcell.col * widget.offset, newcell.row * widget.offset);
    if (currentOffset != newOffset) {
      _offsetAnimation = Tween(begin: currentOffset, end: newOffset).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.ease));
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
        transform: Matrix4.identity()
          ..translate(_offsetAnimation.value.dx, _offsetAnimation.value.dy),
        child: widget.child);
  }
}
