import 'package:core_extras/core_extras.dart';
import 'package:graph_plus/graphing/graph.dart';

typedef VertexGroups<V, G> = Map<G, Set<V>>;
typedef AssignVertexGroups<V, G> = Set<G> Function(Vertex<V> vertex);

class GraphViewGrouping<V, G> {
  const GraphViewGrouping({required this.assignGroup});

  final AssignVertexGroups<V, G> assignGroup;

  VertexGroups<V, G> getGroups(Graph<V> graph) {
    VertexGroups<V, G> groups = {};
    for (final vertex in graph.vertices.values) {
      final g = assignGroup(vertex);

      for (final groupId in g) {
        final current = groups.valueOf(groupId, initialValue: {});
        current.add(vertex.id);
      }
    }
    return groups;
  }
}
