import 'graph.dart';

export 'graph.dart';

typedef G<V> = Graph<V>;
typedef V<V> = Vertex<V>;
typedef E<V> = Edge<V>;

typedef GS<V> = GraphSnapshot<V>;
typedef VS<V> = VertexSnapshot<V>;
typedef ES<V> = EdgeSnapshot<V>;

typedef SS = SnapshotState;

typedef SG<V> = StatefulGraph<V>;
