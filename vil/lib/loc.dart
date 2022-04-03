class Loc {
  final int x;
  final int y;

  const Loc(this.x, this.y);

  @override
  String toString() => '$y, $x';

  Loc get down => Loc(1, y + 1);

  Loc get next => Loc(x + 1, y);
}
