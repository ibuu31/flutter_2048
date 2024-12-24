import 'dart:math';

import 'package:flutter_2048/data/data.dart';
import 'package:flutter_2048/domain/domain.dart';

extension CellEx on Cell {
  /// this extension is used to initialize the grid tile. This extension is helping us to get 2 number on tile when a new tile is appeared on screen. 90 percent of time this will return 2 number and 10 percent of time it will return 4 number.
  GridTile toInitialGridTile() {
    return GridTile(
      this,
      Random().nextDouble() < 0.9 ? Tile(2) : Tile(4),
    );
  }
}
