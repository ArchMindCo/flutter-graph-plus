import 'package:flutter/widgets.dart';
import 'package:graph_plus/diagraming/graph_view.dart';
import 'graph_view_configuration.dart';
import 'group_container/group_container.dart';
import 'vertex_container.dart';
import 'package:graph_plus/graphing/graph.dart';

import 'edge_container.dart';

typedef VertexBuilder<V> = Widget Function(
    BuildContext context, GraphViewThemeData theme, Vertex<V> vertex);
typedef EdgeBuilder<V> = Widget? Function(
    BuildContext context, GraphViewThemeData theme, Edge<V> edge);
typedef GroupBuilder<V, G> = Widget? Function(
    BuildContext context, GraphViewThemeData theme, MapEntry<G, Set<V>> group);

class GraphViewBuildDelegate<V, G> {
  const GraphViewBuildDelegate(
      {this.buildVertex = _buildVertex,
      this.buildEdge = _buildEdge,
      this.buildGroup = _buildGroup,
      this.groupBorderRadius = 0});

  final VertexBuilder<V> buildVertex;
  final EdgeBuilder<V> buildEdge;
  final GroupBuilder<V, G> buildGroup;
  final double groupBorderRadius;

  List<Widget> build(
      BuildContext context, Graph<V> graph, GraphViewGrouping<V, G>? grouping) {
    final theme = GraphViewConfiguration.themeOf(context);
    return [
      if (grouping != null)
        ...grouping.getGroups(graph).entries.map((entry) =>
            GroupContainer<V, G>(
                groupId: entry.key,
                vertexIds: entry.value,
                borderRadius: groupBorderRadius,
                child: buildGroup(context, theme, entry))),
      ...graph.edges.values.map((edge) =>
          EdgeContainer<V>(edge: edge, child: buildEdge(context, theme, edge))),
      ...graph.vertices.values.map((vertex) => VertexContainer<V>(
          vertex: vertex, child: buildVertex(context, theme, vertex))),
    ];
  }

  static Widget _buildVertex(_, __, Vertex vertex) => Text(vertex.name);
  static Widget? _buildEdge(_, __, ___) => null;
  static Widget? _buildGroup(_, __, ___) => null;
}
