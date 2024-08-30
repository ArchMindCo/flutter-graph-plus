import 'package:flutter/material.dart';
import '../graph_view_configuration.dart';
import '../../graphing/graph.dart';
import 'render_edge_container.dart';

class EdgeContainer<V> extends SingleChildRenderObjectWidget {
  const EdgeContainer(
      {super.key, required this.edge, super.child, this.selected = false});

  final Edge<V> edge;
  final bool selected;

  @override
  RenderEdgeContainer<V> createRenderObject(BuildContext context) {
    final theme = GraphViewConfiguration.themeOf(context);
    return RenderEdgeContainer<V>(edge.id,
        selected: selected, lineColor: theme.edgeLineColor);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderEdgeContainer<V> renderObject) {
    final theme = GraphViewConfiguration.themeOf(context);
    renderObject.selected = selected;
    renderObject.lineColor = theme.edgeLineColor;
  }
}
