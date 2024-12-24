import 'package:flutter_2048/domain/domain.dart';

class GridTileMovement {
  const GridTileMovement(this.fromGridTile, this.toGridTile);

  final GridTile? fromGridTile;
  final GridTile toGridTile;

  // this method adds an additional grid tile to the grid
  static GridTileMovement add(GridTile gridTile) {
    return GridTileMovement(null, gridTile);
  }

  // this method shifts the grid tile to the new position
  static GridTileMovement shift(GridTile fromGridTile, GridTile toGridTile) {
    return GridTileMovement(fromGridTile, toGridTile);
  }

  // this method is a no operation method indicating that the grid tile has not moved.
  static GridTileMovement noop(GridTile gridTile) {
    return GridTileMovement(gridTile, gridTile);
  }
}
