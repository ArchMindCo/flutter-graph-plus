import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../render_graph_view_widget_data.dart';

class RenderGroupContainer<V> extends RenderBox
    with RenderObjectWithChildMixin {
  RenderGroupContainer(this.group,
      {required bool selected,
      Color? borderColor,
      Color? backgroundColor,
      double borderRadius = 0})
      : _selected = selected,
        _borderColor = borderColor,
        _borderRadius = borderRadius {
    updateLinePaint();
  }

  final Set<V> group;
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

  double _borderRadius = 0.0;
  double get borderRadius => _borderRadius;
  set borderRadius(double value) {
    if (value == _borderRadius) return;
    _borderRadius = value;
    markNeedsLayout();
  }

  Paint? borderPaint;
  Color? _borderColor;
  Color? get lineColor => _borderColor;
  set lineColor(Color? value) {
    if (value == _borderColor) return;
    _borderColor = value;
    updateLinePaint();
    markNeedsPaint();
  }

  late Rect bounds;
  late void Function(Canvas canvas, Offset offset) paintGroup;

  void updateLinePaint() {
    if (_borderColor != null) {
      borderPaint = Paint()
        ..color = _borderColor!
        ..style = PaintingStyle.stroke;
    }
  }

  @override
  RenderBox? get child => super.child as RenderBox?;

  @override
  void setupParentData(RenderObject child) {
    child.parentData ??= RenderGraphViewWidgetData();
  }

  Rect layoutGroup(Constraints constraints, Map<V, Rect> b) {
    final groupBounds =
        Map.fromEntries(b.entries.where((entry) => group.contains(entry.key)));
    if (groupBounds.length == 1) {
      bounds = groupBounds.values.first;
    } else {
      bounds = groupBounds.values
          .skip(1)
          .fold(groupBounds.values.first, (a, c) => a.expandToInclude(c));
    }

    final RRect? rBounds = borderRadius == 0
        ? null
        : RRect.fromRectAndRadius(bounds, Radius.circular(borderRadius));
    paintGroup = rBounds == null
        ? (canvas, offset) {
            canvas.drawRect(bounds, borderPaint!);
          }
        : (canvas, offset) {
            canvas.drawRRect(rBounds, borderPaint!);
          };

    layout(constraints);
    return bounds;
  }

  @override
  void performLayout() {
    if (child case RenderBox child) {
      final cellConstraints = constraints.loosen();
      child.layout(cellConstraints);
      getParentDataOf(child).offset = bounds.topLeft;
    }

    // final offset = alignment.align(constraints, child.size);
    // parentDataOf.offset = offset;
    // childBounds = offset & child.size;

    size = constraints.constrain(bounds.size);
  }

  RenderGraphViewWidgetData getParentDataOf(RenderBox child) =>
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

      if (child != null) {
        final childOffset = getParentDataOf(child!).offset;
        context.paintChild(child!, offset + childOffset);
      }
      // if (settings.debugRenderVertexContainerBorder) {
      //   paintDebugBorder();
      // }
    }

    if (borderPaint != null) {
      paintGroup(context.canvas, offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child case RenderBox child) {
      final childOffset = getParentDataOf(child).offset;
      final hit = child.hitTest(result, position: position - childOffset);
      debugPrint("hit=$hit");
      return hit;
    }
    return false;
  }

  // @override
  // bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
  //   if (child case RenderBox child) {
  //     //final childOffset = getParentDataOf(child).offset;
  //     final hit = child.hitTest(result, position: position);
  //     //debugPrint("hit=$hit");
  //     return hit;
  //   }
  //   return false;
  // }
}
