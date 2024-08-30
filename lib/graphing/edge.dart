import 'snapshot_state.dart';
import 'graph_element.dart';

typedef EdgeId<V> = (V, V);
typedef IndexedEdgeId<V> = (V, V, int);

class Edge<V> implements GraphElement {
  const Edge(this.id);
  const Edge.endpoints(V endpoint1, V endpoint2) : id = (endpoint1, endpoint2);

  final EdgeId<V> id;

  V get endpoint1 => id.$1;
  V get endpoint2 => id.$2;

  @override
  bool operator ==(Object other) {
    if (other case Edge<V> edge) {
      return id == edge.id;
    } else if (other case (V, V) id) {
      return this.id == id;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => endpoint1.hashCode | endpoint2.hashCode;
}

class EdgeSnapshot<V> extends Edge<V> implements GraphElementSnapshot {
  EdgeSnapshot(this.edge, {this.state = SnapshotState.unmodified})
      : super(edge.id);

  final Edge<V> edge;

  @override
  final SnapshotState state;
}
