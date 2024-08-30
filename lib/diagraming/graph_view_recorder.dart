import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graph_plus/tools/extended_clipboard.dart';

class GraphViewRecorder {
  final GlobalKey rbk = GlobalKey();
  Future capture({double pixelRatio = 1}) async {
    final o = rbk.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await o.toImage(pixelRatio: pixelRatio);
    final item = await ClipboardItem.png(image);

    ExtendedClipboard.setData([item]);
  }
}
