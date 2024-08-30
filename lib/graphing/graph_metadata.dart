import 'package:graph_plus/graphing/g.dart';
import 'package:graph_plus/graphing/graph.dart';
import 'package:graph_plus/graphing/queries.dart';

final class GraphMetadata<V> {
  GraphMetadata(this.graph)
      : sources = graph.sources,
        sinks = graph.sinks;

  final Graph<V> graph;

  final Map<V, Vertex<V>> sources;
  final Map<V, Vertex<V>> sinks;

  Map<V, Vertex<V>> childrenOfById(V id) => graph.childrenOfById(id);

  Map<V, Vertex<V>> childrenOf(Map<V, Vertex<V>> vertices) {
    return vertices.entries.fold({}, (a, c) {
      final children = Map.fromEntries(graph
          .childrenOf(c.value)
          .entries
          .where((entry) => !a.containsKey(entry.key)));
      return {...a, ...children};
    });
  }
}
