import 'dart:ui';

typedef GetEndpoint = Offset Function(Rect bounds);

Offset getVerticalStartEndpoint(Rect bounds) => bounds.bottomCenter;
Offset getVerticalEndEndpoint(Rect bounds) => bounds.topCenter;
Offset getHorizontalStartEndpoint(Rect bounds) => bounds.centerRight;
Offset getHorizontalEndEndpoint(Rect bounds) => bounds.centerLeft;

enum GraphViewOrientation {
  vertical(getVerticalStartEndpoint, getVerticalEndEndpoint),
  horizontal(getHorizontalStartEndpoint, getHorizontalEndEndpoint);

  const GraphViewOrientation(this.getStartEndpoint, this.getEndEndpoint);
  final GetEndpoint getStartEndpoint;
  final GetEndpoint getEndEndpoint;
}
