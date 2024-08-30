import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graph_plus/diagraming/graph_view.dart';
import 'package:graph_plus/extensions/path_extension.dart';

import '../render_graph_view_widget_data.dart';

class RenderEdgeContainer<V> extends RenderBox with RenderObjectWithChildMixin {
  RenderEdgeContainer(this.edgeId,
      {required bool selected, required Color lineColor})
      : _selected = selected,
        _lineColor = lineColor {
    updateLinePaint();
  }

  final (V, V) edgeId;
  final debug = false;

  final Color debugVertexColor = Colors.green;
  late Paint debugVertexFillPaint = Paint()
    ..color = debugVertexColor.withAlpha(32)
    ..style = PaintingStyle.fill;
  late Paint debugVertexStrokePaint = Paint()
    ..color = debugVertexColor
    ..style = PaintingStyle.stroke;

  bool _selected = false;
  bool get selected => _selected;
  set selected(bool value) {
    if (value == _selected) return;
    _selected = value;
    markNeedsLayout();
  }

  late Paint linePaint;
  Color _lineColor;
  Color get lineColor => _lineColor;
  set lineColor(Color value) {
    if (value == _lineColor) return;
    _lineColor = value;
    updateLinePaint();
    markNeedsPaint();
  }

  late Path linePath;
  late Rect bounds;

  void updateLinePaint() {
    linePaint = Paint()
      ..color = _lineColor
      ..style = PaintingStyle.stroke;
  }

  @override
  RenderBox? get child => super.child as RenderBox?;

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData ??= RenderGraphViewWidgetData();
  }

  void layoutEdge(Constraints constraints, GraphViewOrientation orientation,
      List<Offset> path) {
    if (path.length > 1) {
      final temp = Path();
      Offset last = path.first;
      temp.moveTo(last.dx, last.dy);
      for (final offset in path.skip(1)) {
        if (orientation == GraphViewOrientation.vertical) {
          temp.vertialCubicLineTo(last, offset);
        } else {
          temp.horizontalCubicLineTo(last, offset);
        }
        last = offset;
      }
      linePath = temp;
    } else {
      linePath = Path();
    }
    bounds = linePath.getBounds();
    layout(constraints);
  }

  @override
  void performLayout() {
    final cellConstraints = constraints.loosen();
    child?.layout(cellConstraints, parentUsesSize: true);

    // final offset = alignment.align(constraints, child.size);
    // parentDataOf.offset = offset;
    // childBounds = offset & child.size;

    size = constraints.constrain(bounds.size);
  }

  RenderGraphViewWidgetData? get parentDataOf =>
      child?.parentData as RenderGraphViewWidgetData?;

  @override
  void paint(PaintingContext context, Offset offset) {
    // void paintDebugBorder() =>
    //     context.canvas.drawRect(offset & constraints.biggest, debugBorderPaint);

    if (hasSize) {
      if (debug) {
        final bounds = offset & size;
        // context.canvas.drawRect(bounds, borderPaint);
        context.canvas.drawRect(bounds, debugVertexFillPaint);
        context.canvas.drawRect(bounds, debugVertexStrokePaint);
      }

      if (child != null) {
        context.paintChild(child!, offset);
      }
      // if (settings.debugRenderVertexContainerBorder) {
      //   paintDebugBorder();
      // }
    }

    context.canvas.drawPath(linePath.shift(offset), linePaint);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return child?.hitTest(result, position: position) ?? false;
    // if (childBounds.contains(position)) {
    //   return child.hitTest(result, position: position - childBounds.topLeft);
    // }
    // return false;
  }
}
