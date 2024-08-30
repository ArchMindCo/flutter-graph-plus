import 'package:flutter/material.dart';

import '../../graphing/graph.dart';
import '../graph_view_configuration.dart';
import 'render_vertex_container.dart';

class VertexContainer<V> extends SingleChildRenderObjectWidget {
  const VertexContainer(
      {super.key,
      required this.vertex,
      required super.child,
      this.selected = false});

  final Vertex<V> vertex;
  final bool selected;

  @override
  RenderVertexContainer<V> createRenderObject(BuildContext context) {
    final theme = GraphViewConfiguration.themeOf(context);
    return RenderVertexContainer<V>(vertex.id,
        selected: selected, borderColor: theme.vertexBorderColor);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderVertexContainer<V> renderObject) {
    final theme = GraphViewConfiguration.themeOf(context);
    renderObject.selected = selected;
    renderObject.borderColor = theme.vertexBorderColor;
  }
}
