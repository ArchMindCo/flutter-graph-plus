import 'package:flutter/material.dart';
import 'package:graph_plus/diagraming/graph_view.dart';
import 'package:graph_plus/diagraming/graph_view_theme_data.dart';

class GraphViewConfiguration extends InheritedWidget {
  const GraphViewConfiguration({
    super.key,
    this.theme,
    this.darkTheme,
    this.useAppTheme = true,
    required super.child,
  });

  final GraphViewThemeData? theme;
  final GraphViewThemeData? darkTheme;
  final bool useAppTheme;

  static GraphViewThemeData themeOf(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    GraphViewThemeData getDefaultTheme(bool useAppTheme) => useAppTheme
        ? GraphViewThemeData.theme(context)
        : switch (brightness) {
            Brightness.light => GraphViewThemeData.lightContrast(),
            Brightness.dark => GraphViewThemeData.darkContrast()
          };

    final configuration =
        context.dependOnInheritedWidgetOfExactType<GraphViewConfiguration>();

    late GraphViewThemeData theme;
    if (configuration != null) {
      theme = switch (brightness) {
        Brightness.light =>
          configuration.theme ?? getDefaultTheme(configuration.useAppTheme),
        Brightness.dark => configuration.darkTheme ??
            configuration.theme ??
            getDefaultTheme(configuration.useAppTheme)
      };
    } else {
      theme = getDefaultTheme(true);
    }
    return theme;
  }

  @override
  bool updateShouldNotify(GraphViewConfiguration oldWidget) =>
      oldWidget.theme != theme;
}
