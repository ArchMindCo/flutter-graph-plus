import 'package:graph_plus/diagraming/graph_view_orientation.dart';

typedef Increment = int Function(int value);
typedef Take = int Function(int value1, int value2);

int _next(v) => v + 1;
int _same(v) => v;

int _takeNext(_, v) => v;
int _takeSame(v, _) => v;

class GraphViewGridLayoutOrientation {
  const GraphViewGridLayoutOrientation(
      this.orientation,
      this.nextParentRow,
      this.nextParentColumn,
      this.nextChildRow,
      this.nextChildColumn,
      this.takeNextRow,
      this.takeNextColumn);

  factory GraphViewGridLayoutOrientation.orientation(
      GraphViewOrientation orientation) {
    return switch (orientation) {
      GraphViewOrientation.vertical =>
        const GraphViewGridLayoutOrientation.vertical(),
      GraphViewOrientation.horizontal =>
        const GraphViewGridLayoutOrientation.horizontal(),
    };
  }

  const GraphViewGridLayoutOrientation.vertical()
      : orientation = GraphViewOrientation.vertical,
        nextParentRow = _same,
        nextParentColumn = _next,
        nextChildRow = _next,
        nextChildColumn = _same,
        takeNextRow = _takeSame,
        takeNextColumn = _takeNext;

  const GraphViewGridLayoutOrientation.horizontal()
      : orientation = GraphViewOrientation.horizontal,
        nextParentRow = _next,
        nextParentColumn = _same,
        nextChildRow = _same,
        nextChildColumn = _next,
        takeNextRow = _takeNext,
        takeNextColumn = _takeSame;

  final GraphViewOrientation orientation;

  final Increment nextParentRow;
  final Increment nextParentColumn;
  final Increment nextChildRow;
  final Increment nextChildColumn;
  final Take takeNextRow;
  final Take takeNextColumn;

  Take get takeAssignedRow => takeNextRow;
  Take get takeAssignedColumn => takeNextColumn;
}
