class Tile {
  /// this class is taking a number and returning a new number by multiplying it with some operand. Here id is a unique integer which is incrementing every time a new tile is generated providing unique id to each tile.
  Tile(this.number) : id = _tileIdCounter++;

  final int number;
  final int id;

  static int _tileIdCounter = 0;

// this method overloads multiplication operator, it allows you to multiply a number of a tile by an operand and return a new Tile object with result.
  Tile operator *(int operand) {
    return Tile(number * operand);
  }

  factory Tile.fromJson(Map<String, dynamic> json) => Tile(json['number']);

  Map<String, dynamic> toJson() {
    return {
      'number': number,
    };
  }
}
