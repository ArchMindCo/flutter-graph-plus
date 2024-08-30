import 'package:flutter/material.dart';
import 'package:graph_plus/graphing/g.dart';

import '../graphing/graph.dart';
import 'graph_view_build_delegate.dart';
import 'graph_view_configuration.dart';
import 'graph_view_controller.dart';
import 'graph_view_grouping.dart';
import 'graph_view_layout_delegate.dart';
import 'graph_view_orientation.dart';
import 'graph_view_recorder.dart';
import 'graph_view_theme_data.dart';
import 'graph_view_widget.dart';

export 'graph_view_build_delegate.dart';
export 'graph_view_grouping.dart';
export 'graph_view_layout_delegate.dart';
export 'graph_view_orientation.dart';
export 'graph_view_recorder.dart';
export 'graph_view_theme_data.dart';

class GraphView<V, G> extends StatelessWidget {
  GraphView(
    this.graph, {
    super.key,
    required this.buildDelegate,
    required this.layoutDelegate,
    this.orientation = GraphViewOrientation.vertical,
    this.theme,
    this.darkTheme,
    GraphViewController? controller,
    this.recorder,
    this.grouping,
    this.useAppTheme = true,
  }) : controller = controller ?? GraphViewController();

  final Graph<V> graph;
  final GraphViewBuildDelegate<V, G> buildDelegate;
  final GraphViewLayoutDelegate<V> layoutDelegate;
  final GraphViewController controller;
  final GraphViewOrientation orientation;
  final GraphViewThemeData? theme;
  final GraphViewThemeData? darkTheme;
  final GraphViewRecorder? recorder;
  final GraphViewGrouping<V, G>? grouping;
  final bool useAppTheme;

  @override
  Widget build(BuildContext context) {
    Widget build() => GraphViewConfiguration(
          useAppTheme: useAppTheme,
          theme: theme,
          darkTheme: darkTheme,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, child) => GraphViewWidget<V>(graph,
                orientation: orientation,
                layoutDelegate: layoutDelegate,
                children: buildDelegate.build(context, graph, grouping)),
          ),
        );

    return recorder == null
        ? build()
        : RepaintBoundary(key: recorder!.boundaryKey, child: build());
  }

  void tbd(BuildContext context) {}
}
