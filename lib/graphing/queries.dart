import 'graph.dart';

Map<V, VertexSnapshot<V>> activeVertices<V>(
        Map<V, VertexSnapshot<V>> vertices) =>
    vertices.entries.fold(
        {},
        (a, c) =>
            {...a, if (c.value.state != SnapshotState.removed) c.key: c.value});

Map<V, Vertex<V>> verticesFromList<V>(List<Vertex<V>> vertices) =>
    Map<V, Vertex<V>>.fromEntries(
        vertices.map((vertex) => MapEntry<V, Vertex<V>>(vertex.id, vertex)));

extension EdgeQueries<V> on Iterable<Edge<V>> {
  bool isParent(Vertex<V> vertex) => isParentById(vertex.id);

  bool isParentById(V id) => any((edge) => id == edge.endpoint1);

  bool isSource(Vertex<V> vertex) => isSourceById(vertex.id);

  bool isSourceById(V id) => !any((edge) => id == edge.endpoint2);

  bool isSink(Vertex<V> vertex) => isSinkById(vertex.id);

  bool isSinkById(V id) => !any((edge) => id == edge.endpoint1);

  Map<EdgeId<V>, List<Edge<V>>> reducedValidFrom(Map<V, Vertex<V>> vertices) {
    final validEdges = where((edge) =>
        vertices.containsKey(edge.endpoint1) &&
        vertices.containsKey(edge.endpoint2)).toList();

    final edges = <EdgeId, List<Edge<V>>>{};

    return validEdges.fold({}, (a, c) {
      final id = c.id;
      final list = edges[id];
      if (list != null) {
        list.add(c);
        return a;
      } else {
        return {
          ...a,
          id: [c]
        };
      }
    });
  }

  Map<IndexedEdgeId<V>, Edge<V>> indexedValidFrom(Map<V, Vertex<V>> vertices) {
    final validEdges = where((edge) =>
        vertices.containsKey(edge.endpoint1) &&
        vertices.containsKey(edge.endpoint2)).toList();
    final edgeIndeces = <EdgeId, int>{};
    return validEdges.fold({}, (a, c) {
      final id = c.id;
      final index = (edgeIndeces[id] ?? -1) + 1;
      edgeIndeces.addAll({id: index});

      final (ep1, ep2) = id;
      return {...a, (ep1, ep2, index): c};
    });
  }
}

extension VertexQueries<V> on Map<V, Vertex<V>> {
  Map<V, Vertex<V>> sourcesFromMap(Map<IndexedEdgeId, Edge<V>> edges) =>
      sources(edges.values);
  Map<V, Vertex<V>> sinksFromMap(Map<IndexedEdgeId, Edge<V>> edges) =>
      sinks(edges.values);

  Map<V, Vertex<V>> sources(Iterable<Edge<V>> edges) => entries.fold(
      {}, (a, c) => {...a, if (edges.isSourceById(c.key)) c.key: c.value});

  Map<V, Vertex<V>> sinks(Iterable<Edge<V>> edges) => entries
      .fold({}, (a, c) => {...a, if (edges.isSinkById(c.key)) c.key: c.value});
}

extension GraphQueries<V> on Graph<V> {
  Map<V, Vertex<V>> get sources => vertices.sourcesFromMap(edges);
  Map<V, Vertex<V>> get sinks => vertices.sinksFromMap(edges);
}
