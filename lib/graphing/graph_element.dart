import 'package:graph_plus/graphing/g.dart';

abstract interface class GraphElement {}

abstract interface class GraphElementSnapshot extends GraphElement {
  SnapshotState get state;
}
