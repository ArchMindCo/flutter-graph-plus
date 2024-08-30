import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graph_plus/diagraming/edge_container/render_edge_container.dart';
import 'package:graph_plus/diagraming/graph_view_layout_delegate.dart';
import 'package:graph_plus/diagraming/group_container/render_group_container.dart';
import 'package:graph_plus/diagraming/render_graph_view_widget_data.dart';
import 'package:graph_plus/diagraming/vertex_container/render_vertex_container.dart';

import '../../graphing/graph.dart';
import '../graph_view_orientation.dart';

class RenderGraphViewWidget<V> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RenderGraphViewWidgetData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RenderGraphViewWidgetData> {
  RenderGraphViewWidget(this.graph, this.orientation, this.layoutDelegate);

  final GraphViewOrientation orientation;
  final GraphViewLayoutDelegate<V> layoutDelegate;
  final Graph<V> graph;
  final debug = false;

  late Rect bounds;

  final Color debugCellColor = Colors.lightBlue;
  late Paint debugBoundsFillPaint = Paint()
    ..color = debugCellColor.withAlpha(32)
    ..style = PaintingStyle.fill;
  late Paint debugBoundsStrokePaint = Paint()
    ..color = debugCellColor
    ..style = PaintingStyle.stroke;

  RenderGraphViewWidgetData parentDataOf(RenderBox child) =>
      child.parentData as RenderGraphViewWidgetData;

  @override
  void setupParentData(covariant RenderObject child) =>
      child.parentData ??= RenderGraphViewWidgetData();

  @override
  void performLayout() {
    (Map<V, Rect>, Map<V, Rect>) performVertexLayout() {
      final childrenSizes = <RenderVertexContainer<V>>{};
      final childrenSizes2 = <V, Size>{};
      final Map<V, Rect> outerBounds = {};
      final Map<V, Rect> innerBounds = {};

      visitVertices((vertex) {
        vertex.layout(constraints, parentUsesSize: true);
        childrenSizes.add(vertex);
        childrenSizes2[vertex.vertexId] = vertex.size;
      });

      layoutDelegate.layout(graph.metadata, childrenSizes2, orientation);
      bounds = layoutDelegate.boundary;
      size = bounds.size;

      for (final child in childrenSizes) {
        final (offset, cellBounds) = layoutDelegate.getOffset(child.vertexId);
        parentDataOf(child).offset = offset;

        outerBounds[child.vertexId] = cellBounds;
        innerBounds[child.vertexId] = offset & childrenSizes2[child.vertexId]!;
      }

      return (innerBounds, outerBounds);
    }

    void performGroupLayout(Map<V, Rect> cellBounds) {
      visitGroups((group) {
        //final path = layoutDelegate.getPath(group.edgeId, orientation);
        group.layoutGroup(constraints, cellBounds);
        //parentDataOf(group).offset = bounds.topLeft;
      });
    }

    void performEdgeLayout(Map<V, Rect> innerBounds) {
      visitEdges((edge) {
        final path = layoutDelegate.getPath(edge.edgeId, orientation);
        edge.layoutEdge(constraints, orientation, path);
      });
    }

    final (innerBounds, cellBounds) = performVertexLayout();
    performEdgeLayout(innerBounds);
    performGroupLayout(cellBounds);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (debug) {
      context.canvas.drawRect(bounds, debugBoundsFillPaint);
      context.canvas.drawRect(bounds, debugBoundsStrokePaint);
      final r = offset & size;
      context.canvas.drawRect(r, debugBoundsFillPaint);
      layoutDelegate.debugPaint(context, offset);
    }
    defaultPaint(context, offset);
  }

  bool onChildren = false;
  @override
  void handleEvent(
      PointerEvent event, covariant HitTestEntry<HitTestTarget> entry) {
    if (!onChildren) {
      if (event is PointerUpEvent) {
        // onSurfaceTap();
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    onChildren = false;
    return true;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final hit = defaultHitTestChildren(result, position: position);
    onChildren = hit;
    return hit;
  }

  void visitVertices(Function(RenderVertexContainer<V> vertex) visitor) =>
      _visitChildrenByType(visitor);

  void visitEdges(Function(RenderEdgeContainer<V> edge) visitor) =>
      _visitChildrenByType(visitor);

  void visitGroups(Function(RenderGroupContainer<V> group) visitor) =>
      _visitChildrenByType(visitor);

  void _visitChildrenByType<T extends RenderBox>(Function(T child) visitor) {
    visitChildren((child) {
      if (child case T child) {
        visitor(child);
      }
    });
  }
}
