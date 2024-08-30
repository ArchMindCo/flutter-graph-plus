import 'dart:ui';

extension DoubleTupleExtension on (double, double) {
  double center() => ($2 - $1) / 2;
}

extension OffsetExtension on Offset {
  Offset translateCenter((double, double) widths, (double, double) heights) =>
      Offset(dx + widths.center(), dy + heights.center());
}
