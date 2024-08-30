import 'package:flutter/rendering.dart';

mixin RenderObjectWithSelectionMixin implements RenderObject {
  bool _selected = false;
  bool get selected => _selected;
  set selected(bool value) {
    if (value == _selected) return;
    _selected = value;
    markNeedsLayout();
  }
}
