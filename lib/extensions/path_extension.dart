import 'dart:ui';

extension PathExtension on Path {
  void lineToOffset(Offset offset) => lineTo(offset.dx, offset.dy);
  void vertialCubicLineTo(Offset start, Offset offset,
          {double breakpoint = .3}) =>
      _cubicLineTo(start, offset, 0, 1);

  void horizontalCubicLineTo(Offset start, Offset offset,
          {double breakpoint = .3}) =>
      _cubicLineTo(start, offset, 1, 0);

  void _cubicLineTo(Offset start, Offset offset, int mx, int my,
      {double breakpoint = .3}) {
    final x3 = offset.dx;
    final y3 = offset.dy;

    final distance = (x3 - start.dx) * mx + (y3 - start.dy) * my;
    final intialBreakpoint = distance * breakpoint;
    final finalBreakpoint = distance - intialBreakpoint;

    final x1 = start.dx + intialBreakpoint * mx;
    final y1 = start.dy + intialBreakpoint * my;

    final x2 = x3 - finalBreakpoint * mx;
    final y2 = y3 - finalBreakpoint * my;
    cubicTo(x1, y1, x2, y2, x3, y3);
  }
}
