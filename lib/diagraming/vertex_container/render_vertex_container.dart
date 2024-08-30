import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../render_graph_view_widget_data.dart';

class RenderVertexContainer<V> extends RenderBox
    with RenderObjectWithChildMixin {
  RenderVertexContainer(this.vertexId,
      {required bool selected, required Color borderColor})
      : _selected = selected,
        _borderColor = borderColor {
    updateBorderPaint();
  }

  final V vertexId;
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

  late Paint borderPaint;
  Color _borderColor;
  Color get borderColor => _borderColor;
  set borderColor(Color value) {
    if (value == _borderColor) return;
    _borderColor = value;
    updateBorderPaint();
    markNeedsPaint();
  }

  void updateBorderPaint() {
    borderPaint = Paint()
      ..color = _borderColor
      ..style = PaintingStyle.stroke;
  }

  @override
  RenderBox get child => super.child as RenderBox;

  @override
  void setupParentData(covariant RenderObject child) {
    child.parentData ??= RenderGraphViewWidgetData();
  }

  @override
  void performLayout() {
    final cellConstraints = constraints.loosen();
    child.layout(cellConstraints, parentUsesSize: true);

    // final offset = alignment.align(constraints, child.size);
    // parentDataOf.offset = offset;
    // childBounds = offset & child.size;
    size = constraints.constrain(child.size);
  }

  RenderGraphViewWidgetData get parentDataOf =>
      child.parentData as RenderGraphViewWidgetData;

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

      context.paintChild(child, offset);
      // if (settings.debugRenderVertexContainerBorder) {
      //   paintDebugBorder();
      // }
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return child.hitTest(result, position: position);
    // if (childBounds.contains(position)) {
    //   return child.hitTest(result, position: position - childBounds.topLeft);
    // }
    // return false;
  }
}
