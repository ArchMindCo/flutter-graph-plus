import 'package:flutter/widgets.dart';

import '../../graphing/graph.dart';
import '../graph_view_layout_delegate.dart';
import '../graph_view_orientation.dart';
import '../graph_view_widget_element.dart';
import 'render_graph_view_widget.dart';

class GraphViewWidget<V> extends MultiChildRenderObjectWidget {
  const GraphViewWidget(this.graph,
      {super.key,
      super.children,
      required this.orientation,
      required this.layoutDelegate});

  final Graph<V> graph;
  final GraphViewOrientation orientation;
  final GraphViewLayoutDelegate<V> layoutDelegate;

  @override
  MultiChildRenderObjectElement createElement() => GraphViewWidgetElement(this);

  @override
  RenderGraphViewWidget createRenderObject(BuildContext context) {
    return RenderGraphViewWidget<V>(graph, orientation, layoutDelegate);
  }
}
