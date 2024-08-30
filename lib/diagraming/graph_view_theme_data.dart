import 'package:flutter/material.dart';

class GraphViewThemeData {
  const GraphViewThemeData(
      {this.borderColor,
      Color? vertexBorderColor,
      required this.edgeLineColor,
      this.groupBorderColor})
      : _vertexBorderColor = vertexBorderColor;

  GraphViewThemeData.theme(BuildContext context)
      : this(
            borderColor: Theme.of(context).colorScheme.outline,
            edgeLineColor: Theme.of(context).colorScheme.outline,
            groupBorderColor: Theme.of(context).colorScheme.outlineVariant);

  GraphViewThemeData.lightContrast()
      : this(
            borderColor: Colors.black,
            edgeLineColor: Colors.black,
            groupBorderColor: Colors.black);
  GraphViewThemeData.darkContrast()
      : this(
            borderColor: Colors.white,
            edgeLineColor: Colors.white,
            groupBorderColor: Colors.white);

  final Color? _vertexBorderColor;
  Color get vertexBorderColor {
    assert(_vertexBorderColor != null || borderColor != null);
    return _vertexBorderColor ?? borderColor!;
  }

  final Color? borderColor;
  final Color edgeLineColor;
  final Color? groupBorderColor;
}
