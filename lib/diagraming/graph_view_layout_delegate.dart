import 'dart:math';

import 'package:flutter/material.dart';

import '../graphing/graph.dart';
import 'graph_view_orientation.dart';

class GraphViewLayoutDelegate<V> {
  const GraphViewLayoutDelegate();

  void layout(GraphMetadata<V> metadata, Map<V, Size> sizes,
      GraphViewOrientation orientation) {}

  (Offset, Rect) getOffset(V vertexId) {
    return (Offset(Random().nextDouble() * 50, 0), Rect.zero);
  }

  List<Offset> getPath(EdgeId id, GraphViewOrientation orientation) => [];

  Rect get boundary => Rect.zero;

  void debugPaint(PaintingContext context, Offset offset) {}
}
