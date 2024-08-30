import 'package:flutter/material.dart';

import '../graph_view_configuration.dart';
import 'render_group_container.dart';

class GroupContainer<V, G> extends SingleChildRenderObjectWidget {
  const GroupContainer(
      {super.key,
      required this.groupId,
      required this.vertexIds,
      this.borderRadius = 0,
      super.child,
      this.selected = false});

  final G groupId;
  final Set<V> vertexIds;
  final bool selected;
  final double borderRadius;

  @override
  RenderGroupContainer<V> createRenderObject(BuildContext context) {
    final theme = GraphViewConfiguration.themeOf(context);
    return RenderGroupContainer<V>(vertexIds,
        selected: selected,
        borderColor: theme.groupBorderColor,
        borderRadius: borderRadius);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderGroupContainer<V> renderObject) {
    final theme = GraphViewConfiguration.themeOf(context);
    renderObject.selected = selected;
    renderObject.borderRadius = borderRadius;
    renderObject.lineColor = theme.groupBorderColor;
  }
}
