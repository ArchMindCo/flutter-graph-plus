import 'dart:js_interop';
import 'dart:ui';

import 'package:flutter/foundation.dart';

@JS("Blob")
extension type JSBlob(JSObject _) implements JSAny {
  external JSBlob.data(JSAny blobParts, JSAny options);
}

@JS("navigator")
extension type JSNavigator(JSObject _) implements JSObject {
  external static JSClipboard get clipboard;
}

@JS("Clipboard")
extension type JSClipboard(JSObject _) implements JSObject {
  external JSPromise write(JSArray<JSClipboardItem> data);
}

@JS("ClipboardItem")
extension type JSClipboardItem(JSObject _) implements JSAny {
  external JSClipboardItem.data(JSAny data);
  external JSArray<JSString> get types;
}

abstract class ExtendedClipboard {
  static Future setData(List<ClipboardItem> items) async {
    if (kIsWeb) {
      final promise = JSNavigator.clipboard.write(items.toJS);
      final future = promise.toDart;
      return future;
    }
  }
}

class ClipboardItem {
  static Future<ClipboardItem> png(Image image) async {
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final buffer = byteData?.buffer.asUint8List();
    if (buffer == null) throw Exception();
    return ClipboardItem.pngData(data: buffer);
  }

  ClipboardItem.pngData({required Uint8List data})
      : key = "image/png",
        jsData = JSBlob.data([data.toJS].toJS, {"type": "image/png"}.jsify()!);

  final String key;
  final JSAny jsData;

  JSClipboardItem get toJS => JSClipboardItem.data({key: jsData}.jsify()!);
}

extension ClipboardItemList on List<ClipboardItem> {
  JSArray<JSClipboardItem> get toJS => map((item) => item.toJS).toList().toJS;
}
