class Cell {
  const Cell(this.row, this.col);

  final int row;
  final int col;

  /// this method is called operator == method, which overrides the ==operator to compare two Cell object for equality. Basically this method will check if the current cell and other cell are same object in memory
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // to check whether other is of type Cell
    if (other is! Cell) return false;
// if it returns true than new instance will not get created because each set ot map should consist of unique values.
    return other.row == row && other.col == col;
  }

  /// this method is hashcode getter method to provide a unique hash code for each cell. This ensures that two Cell objects with the same row and col values will have the same hash code, which is essential for using Cell objects in collections like Set or Map.
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}
