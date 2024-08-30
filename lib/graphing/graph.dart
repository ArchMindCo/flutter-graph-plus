import 'package:graph_plus/graphing/g.dart';

import 'queries.dart';

export 'vertex.dart';
export 'edge.dart';
export 'snapshot_state.dart';
export 'graph_element.dart';
export 'graph_metadata.dart';

class GraphMetadaProvider {
  const GraphMetadaProvider();
  GraphMetadata<V> provide<V>(Graph<V> graph) => GraphMetadata<V>(graph);

  //static GraphMetadata<V> provideOrDefault<V>(GraphMetadaProvider<V>? provider, Graph<V> graph) => (provider ?? GraphMetadaProvider<V>()).provide(graph);
}

class Graph<V> {
  Graph._(
      {required this.vertices,
      List<Edge<V>> edges = const [],
      this.metadataProvider = const GraphMetadaProvider()})
      : edges = edges.indexedValidFrom(vertices),
        uniqueEdges = edges.reducedValidFrom(vertices);

  Graph(
      {required List<Vertex<V>> vertices,
      List<Edge<V>> edges = const [],
      GraphMetadaProvider metadataProvider = const GraphMetadaProvider()})
      : this._(
            vertices: verticesFromList(vertices),
            edges: edges,
            metadataProvider: metadataProvider);

  Graph.empty({this.metadataProvider = const GraphMetadaProvider()})
      : vertices = const {},
        edges = const {},
        uniqueEdges = const {};

  Graph.copy(Graph<V> graph)
      : vertices = {...graph.vertices},
        edges = {...graph.edges},
        uniqueEdges = {...graph.uniqueEdges},
        metadataProvider = graph.metadataProvider;

  final Map<V, Vertex<V>> vertices;
  final Map<IndexedEdgeId, Edge<V>> edges;
  final Map<EdgeId<V>, List<Edge<V>>> uniqueEdges;
  final GraphMetadaProvider metadataProvider;

  /// Returns the number of vertices
  int get order => vertices.length;

  /// Returns the total number of unique edges
  int get size => edges.length;

  /// Returns the number of edges
  int get size2 => edges.length;

  GraphMetadata<V> get metadata => metadataProvider.provide(this);

  GraphSnapshot<V> addVertex(Vertex<V> vertex) {
    return GraphSnapshot<V>(vertexSnapshots: {
      ...vertices.map(VertexSnapshot.mapAsUnmodified),
      vertex.id: VertexSnapshot<V>(vertex, state: SnapshotState.added)
    });
  }

  GraphSnapshot<V> removeVertex(Vertex<V> vertex) =>
      removeVertexById(vertex.id);

  GraphSnapshot<V> removeVertexById(V id) {
    final vertex = vertices[id];
    if (vertex != null) {
      final unmodified = vertices.map(VertexSnapshot.mapAsUnmodified)
        ..remove(vertex);
      return GraphSnapshot<V>(vertexSnapshots: {
        ...unmodified,
        vertex.id: VertexSnapshot<V>(vertex, state: SnapshotState.removed)
      });
    } else {
      return GraphSnapshot(
          vertexSnapshots: {...vertices.map(VertexSnapshot.mapAsUnmodified)});
    }
  }

  GraphSnapshot<V> addGraph(Graph<V> graph) {
    // Use amru statuses (a=added,m=modified,r=removed,u=unmodified)
    // Start with ar, assume u for remaining
    // Use edges to check for m

    // Added: Get all vertices that's in the graph but not this
    final added = Map.fromEntries(graph.vertices.entries
            .where((entry) => !vertices.containsKey(entry.key)))
        .map(VertexSnapshot.mapAsAdded);

    // Removed: In addition, there are never any removals
    final removed = <V, VertexSnapshot<V>>{};

    // Remaining: Get all vertices that's in this graph but not in added
    // Additionally, we initially treat them as unmodified
    final tempRemaining = Map.fromEntries(
            vertices.entries.where((entry) => !added.containsKey(entry.key)))
        .map(VertexSnapshot.mapAsUnmodified);

    // Modified: Get all verticies from remaining that have amr edges
    final modified = <V, VertexSnapshot<V>>{};

    // Unmodified: Get all vertices from remaining that is not modified
    // Additionally, these are already mapped as u from the step that created the remaining
    final unmodified = Map.fromEntries(tempRemaining.entries
        .where((entry) => !modified.containsKey(entry.key)));

    return GraphSnapshot._fromOperation(
        added: added,
        modified: modified,
        removed: removed,
        unmodified: unmodified);
  }

  GraphSnapshot<V> diffGraph(Graph<V> graph) {
    // Use amru statuses (a=added,m=modified,r=removed,u=unmodified)
    // Start with ar, assume u for remaining
    // Use edges to check for m

    // Added: Get all vertices that's in the graph but not this
    final added = Map.fromEntries(graph.vertices.entries
            .where((entry) => !vertices.containsKey(entry.key)))
        .map(VertexSnapshot.mapAsAdded);

    // Removed: Get all vertices that's in this graph but not the graph
    final removed = Map.fromEntries(vertices.entries
            .where((entry) => !graph.vertices.containsKey(entry.key)))
        .map(VertexSnapshot.mapAsRemoved);

    // Remaining: Get all vertices that's in the graph but not in added
    // Additionally, we initially treat them as unmodified
    final tempRemaining = Map.fromEntries(graph.vertices.entries
            .where((entry) => !added.containsKey(entry.key)))
        .map(VertexSnapshot.mapAsUnmodified);

    // Modified: Get all verticies from remaining that have amr edges
    final modified = <V, VertexSnapshot<V>>{};

    // Unmodified: Get all vertices from remaining that is not modified
    // Additionally, these are already mapped as u from the step that created the remaining
    final unmodified = Map.fromEntries(tempRemaining.entries
        .where((entry) => !modified.containsKey(entry.key)));

    return GraphSnapshot._fromOperation(
        added: added,
        modified: modified,
        removed: removed,
        unmodified: unmodified);
  }

  Map<V, Vertex<V>> parentsOfById(V id) {
    final vertex = vertices[id];
    if (vertex == null) return {};
    return parentsOf(vertex);
  }

  Map<V, Vertex<V>> parentsOf(Vertex<V> vertex) {
    if (!vertices.containsValue(vertex)) return {};
    return vertices.entries.fold({}, (a, c) {
      final parentIds = uniqueEdges.keys
          .where((edgeId) => edgeId.$2 == c.key)
          .map((edgeId) => edgeId.$1);
      final parents = Map.fromEntries(vertices.entries
          .where((entry) => parentIds.any((childId) => entry.key == childId))
          .where((entry) => !a.containsKey(entry.key)));
      return {...a, ...parents};
    });
  }

  Map<V, Vertex<V>> childrenOfById(V id) {
    final vertex = vertices[id];
    if (vertex == null) return {};
    return childrenOf(vertex);
  }

  Map<V, Vertex<V>> childrenOf(Vertex<V> vertex) {
    if (!vertices.containsValue(vertex)) return {};

    final children = uniqueEdges.keys
        .where((edgeId) => edgeId.$1 == vertex.id)
        .map((edgeId) => edgeId.$2)
        .where((id) => vertices.containsKey(id))
        .map((id) => MapEntry(id, vertices[id]!));
    return Map.fromEntries(children);
    //.where((entry) => !a.containsKey(entry.key)));
  }

  GraphSnapshot<V> operator +(Object other) {
    if (other case Vertex<V> vertex) {
      return addVertex(vertex);
    } else if (other case Graph<V> graph) {
      return addGraph(graph);
    } else {
      throw Exception();
    }
  }

  GraphSnapshot<V> operator -(Object other) {
    if (other case Vertex<V> vertex) {
      return removeVertex(vertex);
    } else if (other case Graph<V> graph) {
      return diffGraph(graph);
    } else {
      throw Exception();
    }
  }
}

class GraphSnapshot<V> extends Graph<V> {
  GraphSnapshot({this.vertexSnapshots = const {}})
      : super._(vertices: activeVertices(vertexSnapshots));

  GraphSnapshot.graph(super.graph)
      : vertexSnapshots = graph.vertices.map(VertexSnapshot.mapAsUnmodified),
        super.copy();

  GraphSnapshot.empty()
      : vertexSnapshots = const {},
        super.empty();

  GraphSnapshot._fromOperation({
    required Map<V, VertexSnapshot<V>> added,
    required Map<V, VertexSnapshot<V>> modified,
    required Map<V, VertexSnapshot<V>> removed,
    required Map<V, VertexSnapshot<V>> unmodified,
  }) : this(vertexSnapshots: {
          ...added,
          ...modified,
          ...removed,
          ...unmodified
        });

  final Map<V, VertexSnapshot<V>> vertexSnapshots;

  Map<V, VertexSnapshot<V>> verticesByState(SnapshotState state) =>
      vertexSnapshots.entries.fold(
          {}, (a, c) => {...a, if (c.value.state == state) c.key: c.value});

  int getOrderByState(SnapshotState state) => verticesByState(state).length;
}

class StatefulGraph<V> implements Graph<V> {
  StatefulGraph() : _graphs = [GraphSnapshot.empty()];

  final List<GraphSnapshot<V>> _graphs;

  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value == _index) return;
    _index = value;
  }

  bool get isCurrent => _index + 1 == _graphs.length;

  GraphSnapshot<V> get current => _graphs[_index];

  @override
  Map<V, Vertex<V>> get vertices => current.vertices;

  @override
  Map<IndexedEdgeId, Edge<V>> get edges => current.edges;

  @override
  Map<EdgeId<V>, List<Edge<V>>> get uniqueEdges => current.uniqueEdges;

  /// Returns the number of vertices
  @override
  int get order => current.order;

  /// Returns the total number of unique edges
  @override
  int get size => current.size;

  /// Returns the number of edges
  @override
  int get size2 => current.size2;

  @override
  GraphSnapshot<V> operator +(Object other) => _execute(() => current + other);

  @override
  GraphSnapshot<V> operator -(Object other) => _execute(() => current - other);

  @override
  GraphSnapshot<V> addGraph(Graph<V> graph) =>
      _execute(() => current.addGraph(graph));

  @override
  GraphSnapshot<V> addVertex(Vertex<V> vertex) =>
      _execute(() => current.addVertex(vertex));

  @override
  GraphSnapshot<V> diffGraph(Graph<V> graph) =>
      _execute(() => current.diffGraph(graph));

  @override
  GraphMetadata<V> get metadata => current.metadata;

  @override
  GraphSnapshot<V> removeVertex(Vertex<V> vertex) =>
      _execute(() => current.removeVertex(vertex));

  @override
  GraphSnapshot<V> removeVertexById(V id) =>
      _execute(() => current.removeVertexById(id));

  @override
  GraphMetadaProvider get metadataProvider => current.metadataProvider;

  @override
  Map<V, Vertex<V>> parentsOfById(V id) => current.parentsOfById(id);

  @override
  Map<V, Vertex<V>> parentsOf(Vertex<V> vertex) => current.parentsOf(vertex);

  @override
  Map<V, Vertex<V>> childrenOfById(V id) => current.childrenOfById(id);

  @override
  Map<V, Vertex<V>> childrenOf(Vertex<V> vertex) => current.childrenOf(vertex);

  GraphSnapshot<V> toLast() {
    index = _graphs.length - 1;
    return current;
  }

  GraphSnapshot<V> toFirst() {
    index = _graphs.isEmpty ? -1 : 0;
    return current;
  }

  GraphSnapshot<V> _execute(GraphSnapshot<V> Function() action) {
    if (!isCurrent) {
      throw Exception(
          "Invoking an operation to a previous graph is not valid.");
    }
    final graph = action();
    _graphs.add(graph);
    return toLast();
  }
}
