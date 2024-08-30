import 'dart:math';

import 'package:core_extras/core_extras.dart';
import 'package:flutter/material.dart';
import 'package:graph_plus/extensions/offset_extension.dart';

import '../../graphing/graph.dart';
import '../graph_view_layout_delegate.dart';
import '../graph_view_orientation.dart';
import 'graph_view_grid_layout_orientation.dart';

class GraphViewGridLayoutDelegate<V> implements GraphViewLayoutDelegate<V> {
  GraphViewGridLayoutDelegate();

  final snapToPixel = false;

  Map<V, Size> sizes = {};

  final Map<V, (int, int)> vertexCells = {};
  final Map<(int, int), int> rowSpans = {};
  final Map<(int, int), int> columnSpans = {};
  final Map<int, double> rowHeights = {};
  final Map<int, double> columnWidths = {};
  final Size padding = const Size.square(30);
  late double paddedCellWidth = padding.width * 2;
  late double paddedCellHeight = padding.height * 2;

  final Color debugCellColor = Colors.pink;
  late Paint debugCellFillPaint = Paint()
    ..color = debugCellColor.withAlpha(32)
    ..style = PaintingStyle.fill;
  late Paint debugCellStrokePaint = Paint()
    ..color = debugCellColor
    ..style = PaintingStyle.stroke;

  @override
  void layout(GraphMetadata<V> metadata, Map<V, Size> sizes,
      GraphViewOrientation orientation) {
    _reset(sizes: sizes);
    _layout2(metadata, metadata.sources.keys, sizes, 0, 0,
        GraphViewGridLayoutOrientation.orientation(orientation));
  }

  void _reset({Map<V, Size>? sizes}) {
    if (sizes != null) {
      this.sizes = sizes;
    }
    vertexCells.clear();
    rowSpans.clear();
    columnSpans.clear();
    rowHeights.clear();
    columnWidths.clear();
  }

  (int nextRowIndex, int nextColumnIndex) _layout2(
      GraphMetadata<V> metadata,
      Iterable<V> ids,
      Map<V, Size> sizes,
      int rowIndex,
      int columnIndex,
      GraphViewGridLayoutOrientation orientation) {
    if (ids.isEmpty) {
      return (
        orientation.nextParentRow(rowIndex),
        orientation.nextParentColumn(columnIndex)
      );
    }

    for (final id in ids) {
      final size = sizes[id];
      if (size != null) {
        final children = metadata.childrenOfById(id).keys;

        final (childNextRowIndex, chilNextColumnIndex) = _layout2(
            metadata,
            children,
            sizes,
            orientation.nextChildRow(rowIndex),
            orientation.nextChildColumn(columnIndex),
            orientation);
        final rowSpan = childNextRowIndex - rowIndex;
        final columnSpan = chilNextColumnIndex - columnIndex;

        final cell = (rowIndex, columnIndex);
        _assignCell(id, cell, orientation);
        _addSpan(columnSpans, cell, columnSpan);
        _addSpan(rowSpans, cell, rowSpan);

        _expandRow(rowIndex, size.height);
        _expandColumn(columnIndex, size.width, columnSpan: columnSpan);

        rowIndex = orientation.takeNextRow(rowIndex, childNextRowIndex);
        columnIndex =
            orientation.takeNextColumn(columnIndex, chilNextColumnIndex);
      }
    }

    return (rowIndex, columnIndex);
  }

  void _assignCell(
      V id, (int, int) cell, GraphViewGridLayoutOrientation orientation) {
    final current = vertexCells[id];
    if (current == null) {
      vertexCells[id] = cell;
    } else {
      final (currentRowIndex, currentColumnIndex) = current;
      final (updatedRowIndex, updatedColumnIndex) = cell;
      vertexCells[id] = (
        orientation.takeAssignedRow(currentRowIndex, updatedRowIndex),
        orientation.takeAssignedColumn(currentColumnIndex, updatedColumnIndex)
      );
    }
  }

  void _addSpan(Map<(int, int), int> spans, (int, int) cell, int span) {
    if (span < 2) return;
    spans[cell] = span;
  }

  void _expandRow(int rowIndex, double height, {int rowSpan = 1}) =>
      rowHeights[rowIndex] = _calculateExpansion(
        current: rowHeights[rowIndex] ?? 0,
        total: _getRowHeight(rowIndex, rowSpan: rowSpan),
        requested: height,
      );

  void _expandColumn(int columnIndex, double width, {int columnSpan = 1}) =>
      columnWidths[columnIndex] = _calculateExpansion(
          current: columnWidths[columnIndex] ?? 0,
          total: _getColumnWidth(columnIndex, columnSpan: columnSpan),
          requested: width);

  /// Returns the minimum value needed to satisfy the [requested] value. The [current] value indicates the current value and is a subset of the [total] value.
  /// A new requested value is calculated from the originally requested value and the other subsets
  double _calculateExpansion({
    required double current,
    required double requested,
    double? total,
  }) {
    final other = (total ?? current) - current;
    final requested2 = requested - other;
    return max(requested2, current);
  }

  double _getRowOffset(int rowIndex, {bool round = false}) {
    double offset = 0;
    for (var i = 0; i < rowIndex; i++) {
      offset += rowHeights[i] ?? 0;
    }
    return round ? offset.roundToDouble() : offset;
  }

  double _getColumnOffset(int columnIndex, {bool round = false}) {
    double offset = 0;
    for (var i = 0; i < columnIndex; i++) {
      offset += columnWidths[i] ?? 0;
    }
    return round ? offset.roundToDouble() : offset;
  }

  double _getRowHeight(int rowIndex, {int rowSpan = 1, bool round = false}) {
    final lastRowIndex = rowIndex + rowSpan;
    double paddingHeight = paddedCellHeight * (rowSpan - 1);
    double height = paddingHeight;

    for (var i = rowIndex; i < lastRowIndex; i++) {
      height += rowHeights[i] ?? 0;
    }
    return round ? height.roundToDouble() : height;
  }

  double _getColumnWidth(int columnIndex,
      {int columnSpan = 1, bool round = false}) {
    final lastColumnIndex = columnIndex + columnSpan;
    double paddingWidth = paddedCellWidth * (columnSpan - 1);
    double width = paddingWidth;

    for (var i = columnIndex; i < lastColumnIndex; i++) {
      width += columnWidths[i] ?? 0;
    }
    return round ? width.roundToDouble() : width;
  }

  Rect _getCellBounds((int, int) cell,
      {int? rowSpanOverride, int? columnSpanOverride}) {
    final (rowIndex, columnIndex) = cell;
    final rowSpan = rowSpanOverride ?? rowSpans[cell] ?? 1;
    final columnSpan = columnSpanOverride ?? columnSpans[cell] ?? 1;

    final outerWidth = _getColumnWidth(columnIndex,
        columnSpan: columnSpan, round: snapToPixel);
    final outerHeight =
        _getRowHeight(rowIndex, rowSpan: rowSpan, round: snapToPixel);
    final size = Size(outerWidth, outerHeight);

    final dx = _getColumnOffset(columnIndex, round: snapToPixel) +
        (paddedCellHeight * columnIndex);
    final dy = _getRowOffset(rowIndex, round: snapToPixel) +
        (paddedCellWidth * rowIndex);
    final offset = Offset(dx, dy);

    return (offset & size).expandBySize(padding);
  }

  Rect _getMinimumCellBounds((int, int) cell) {
    final (rowIndex, columnIndex) = cell;
    final rowSpan = rowSpans[cell] ?? 1;
    final columnSpan = columnSpans[cell] ?? 1;

    final initalRowIndex = rowIndex + (rowSpan / 2).floor();
    final initalColumnIndex = columnIndex + (columnSpan / 2).floor();

    late int effectiveRowIndex;
    late int effectiveRowSpan;
    if (rowSpan.isEven) {
      effectiveRowSpan = 2;
      effectiveRowIndex = initalRowIndex - 1;
    } else {
      effectiveRowSpan = 1;
      effectiveRowIndex = initalRowIndex;
    }

    late int effectiveColumnIndex;
    late int effectiveColumnSpan;
    if (columnSpan.isEven) {
      effectiveColumnSpan = 2;
      effectiveColumnIndex = initalColumnIndex - 1;
    } else {
      effectiveColumnSpan = 1;
      effectiveColumnIndex = initalColumnIndex;
    }

    return _getCellBounds((effectiveRowIndex, effectiveColumnIndex),
        rowSpanOverride: effectiveRowSpan,
        columnSpanOverride: effectiveColumnSpan);
  }

  @override
  (Offset, Rect) getOffset(V vertexId) {
    if (vertexCells.notContainsKey(vertexId)) {
      return (Offset(Random().nextDouble() * 50, 0), Rect.zero);
    }
    final vertexSize = sizes[vertexId];
    if (vertexSize == null)
      return (Offset(Random().nextDouble() * 50, 0), Rect.zero);

    final cell = vertexCells[vertexId]!;
    final rect = _getCellBounds(cell);
    final mrect = _getMinimumCellBounds(cell);

    final initialOffset = rect.topLeft;
    final outerWidth = rect.width;
    final outerHeight = rect.height;
    // final columnSpan = columnSpans[cell] ?? 1;
    // final rowSpan = rowSpans[cell] ?? 1;

    // final dx = _getColumnOffset(columnIndex, round: snapToPixel);
    // final dy = _getRowOffset(rowIndex, round: snapToPixel);
    // final initialOffset = Offset(dx, dy);

    // final outerWidth = _getColumnWidth(columnIndex,
    //     columnSpan: columnSpan, round: snapToPixel);
    // final outerHeight =
    //     _getRowHeight(rowIndex, rowSpan: rowSpan, round: snapToPixel);

    final o = initialOffset.translateCenter(
        (vertexSize.width, outerWidth), (vertexSize.height, outerHeight));
    shapeBounds[vertexId] = o & vertexSize;
    return (o, mrect);
  }

  Map<V, Rect> shapeBounds = {};

  @override
  List<Offset> getPath(EdgeId id, GraphViewOrientation orientation) {
    final cell1 = shapeBounds[id.$1]!;
    // final rect1 = _getCellBounds(cell1);

    final cell2 = shapeBounds[id.$2]!;
    //final rect2 = _getCellBounds(cell2);

    return [
      orientation.getStartEndpoint(cell1),
      orientation.getEndEndpoint(cell2)
    ];
  }

  @override
  Rect get boundary {
    var outer = Rect.zero;
    for (final cell in vertexCells.values) {
      final bounds = _getCellBounds(cell);
      outer = outer.expandToInclude(bounds);
    }
    return outer;
  }

  @override
  void debugPaint(PaintingContext context, Offset offset) {
    for (final cell in vertexCells.values) {
      final rect = _getMinimumCellBounds(cell);
      context.canvas.drawRect(rect, debugCellFillPaint);
      context.canvas.drawRect(rect, debugCellStrokePaint);
    }
  }
}
