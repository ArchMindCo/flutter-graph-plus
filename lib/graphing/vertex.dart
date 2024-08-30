import 'snapshot_state.dart';
import 'graph_element.dart';

class Vertex<V> implements GraphElement {
  const Vertex(this.id, {this.source, String? name}) : _name = name;

  final V id;
  final String? _name;
  final dynamic source;

  String get name => _name ?? id.toString();

  @override
  bool operator ==(Object other) {
    if (other case Vertex<V> vertex) {
      return id == vertex.id;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => id.hashCode;
}

class VertexSnapshot<V> extends Vertex<V> implements GraphElementSnapshot {
  VertexSnapshot(this.vertex, {this.state = SnapshotState.unmodified})
      : super(vertex.id);

  final Vertex<V> vertex;
  @override
  final SnapshotState state;

  static MapEntry<V, VertexSnapshot<V>> mapAsAdded<V>(V id, Vertex<V> vertex) =>
      mapAs(id, vertex, SnapshotState.added);

  static MapEntry<V, VertexSnapshot<V>> mapAsModified<V>(
          V id, Vertex<V> vertex) =>
      mapAs(id, vertex, SnapshotState.modified);

  static MapEntry<V, VertexSnapshot<V>> mapAsRemoved<V>(
          V id, Vertex<V> vertex) =>
      mapAs(id, vertex, SnapshotState.removed);

  static MapEntry<V, VertexSnapshot<V>> mapAsUnmodified<V>(
          V id, Vertex<V> vertex) =>
      mapAs(id, vertex, SnapshotState.unmodified);

  static MapEntry<V, VertexSnapshot<V>> mapAs<V>(
          V id, Vertex<V> vertex, SnapshotState state) =>
      MapEntry(id, VertexSnapshot<V>(vertex, state: state));
}
