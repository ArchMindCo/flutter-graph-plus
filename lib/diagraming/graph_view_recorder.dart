import 'package:flutter/material.dart';
import 'package:graph_plus_exporter/graph_view_exporter.dart';

class GraphViewRecorder {
  final boundaryKey = GlobalKey();
  Future exportToClipboard({double pixelRatio = 1}) async {
    final exporter = GraphViewExporter();
    exporter.exportWidgetToClipboard(boundaryKey, MediaType.png,
        pixelRatio: pixelRatio);
  }
}
