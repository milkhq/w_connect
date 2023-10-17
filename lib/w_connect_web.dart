// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html show window;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:js/js.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:rxdart/subjects.dart';
import 'package:w_connect/frame.dart';
import 'dart:ui' as ui;
import 'w_connect_platform_interface.dart';
import 'package:image/image.dart' as imglib;

@JS('accountChangedCallback')
external set _accountChangedCallback(void Function(String?) f);

/// Allows calling the assigned function from Dart as well.
@JS()
external void accountChangedCallback(String? bytes);

/// A web implementation of the WConnectPlatform of the WConnect plugin.
class WConnectWeb extends WConnectPlatform {
  /// Constructs a WConnectWeb
  WConnectWeb() {
    debugPrint('WConnectWeb constructor');
    _accountChangedCallback = allowInterop(_accountChangedHandler);
  }

  void _accountChangedHandler(String? account) {
    debugPrint('accountChangedHandler: $account');
    _accountChangedController.add(account);
  }

  final _accountChangedController = BehaviorSubject<String?>();

  static void registerWith(Registrar registrar) {
    WConnectPlatform.instance = WConnectWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }

  @override
  Future<void> connect() async {
    context.callMethod('connect', []);
  }

  @override
  Future<void> disconnect() async {
    context.callMethod('disconnect', []);
  }

  @override
  Stream<String?> get onAccountChanged => _accountChangedController.stream;

  @override
  void init(List<String> args) {
    context.callMethod('init', []);
  }

  @override
  void decodeVideo(
      {required String url, required void Function(ui.Image img) callback}) {
    void cb(Uint8ClampedList pixels, int width, int height) {
      // ui.decodeImageFromList(pixels, (result) {
      //   callback(result);
      // });
      // final rgba = YuvConverter.yuv420NV12ToRgba8888(pixels, 1080, 1920);
      // final w = 720;
      // final h = 1280;

      // final rgba = i420ToRgba(pixels, w, h);

      // final imagePixels = YuvConverter.yuv420NV12ToRgba8888(pixels, w, h);
      debugPrint('decodeVideo: $width $height, length: ${pixels.length}');

      ui.decodeImageFromPixels(
          pixels.buffer.asUint8List(), width, height, ui.PixelFormat.rgba8888,
          (result) {
        callback(result);
      });
    }

    context.callMethod('decodeVideo', [url, cb]);
  }

  @override
  Future<void> loadVideo(
      {required String url,
      required void Function(ui.Image img) callback,
      required void Function() onDone}) async {
    void cb(Uint8ClampedList pixels, int width, int height) {
      ui.decodeImageFromPixels(
          pixels.buffer.asUint8List(), width, height, ui.PixelFormat.rgba8888,
          (result) {
        callback(result);
      });
    }

    context.callMethod('loadVideo', [url, cb, onDone]);
  }

  @override
  Future<void> decodeFrameByIndex({
    required int index,
  }) {
    return context.callMethod('decodeFrameByIndex', [index]);
  }

  @override
  Future<void> loadVideoChunks({required String url}) {
    final completer = Completer<void>();

    cb() {
      completer.complete();
    }

    context.callMethod('loadVideoChunks', [url, cb]);

    return completer.future;
  }

  @override
  Future<void> decodeFrames({
    required void Function(ui.Image img) callback,
  }) async {
    cb(Uint8ClampedList pixels, int width, int height) {
      ui.decodeImageFromPixels(
          pixels.buffer.asUint8List(), width, height, ui.PixelFormat.rgba8888,
          (result) {
        callback(result);
      });
    }

    context.callMethod('decodeFrames', [cb]);
  }

  @override
  Future<dynamic> signIn() {
    final completer = Completer<dynamic>();
    cb(dynamic data) {
      completer.complete(data);
    }

    context.callMethod('signInWithEthereum', [cb]);
    return completer.future;
  }

  @override
  void playBackgroundTrack() {
    context.callMethod('playBgMusic', []);
  }

  @override
  void stopBackgroundTrack() {
    context.callMethod('pauseBgMusic', []);
  }

  @override
  void toggleBackgroundTrack() {
    context.callMethod('toggleMusic', []);
  }
}

Uint8List decodeYUV420SP(Uint8List bytes, int width, int height) {
  Uint8List yuv420sp = bytes;
  //int total = width * height;
  //Uint8List rgb = Uint8List(total);
  final outImg = imglib.Image(width: width, height: height);

  final int frameSize = width * height;

  for (int j = 0, yp = 0; j < height; j++) {
    int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
    for (int i = 0; i < width; i++, yp++) {
      int y = (0xff & yuv420sp[yp]) - 16;
      if (y < 0) y = 0;
      if ((i & 1) == 0) {
        v = (0xff & yuv420sp[uvp++]) - 128;
        u = (0xff & yuv420sp[uvp++]) - 128;
      }
      int y1192 = 1192 * y;
      int r = (y1192 + 1634 * v);
      int g = (y1192 - 833 * v - 400 * u);
      int b = (y1192 + 2066 * u);

      if (r < 0)
        r = 0;
      else if (r > 262143) r = 262143;
      if (g < 0)
        g = 0;
      else if (g > 262143) g = 262143;
      if (b < 0)
        b = 0;
      else if (b > 262143) b = 262143;

      // I don't know how these r, g, b values are defined, I'm just copying what you had bellow and
      // getting their 8-bit values.
      outImg.setPixelRgb(i, j, ((r << 6) & 0xff0000) >> 16,
          ((g >> 2) & 0xff00) >> 8, b & 0xff);

      /*rgb[yp] = 0xff000000 |
            ((r << 6) & 0xff0000) |
            ((g >> 2) & 0xff00) |
            ((b >> 10) & 0xff);*/
    }
  }
  return outImg.toUint8List();
}

Uint8List yuva420pToRgba8888(Uint8List data, int width, int height) {
  int planeSize = width * height;
  int uvPlaneSize = planeSize ~/ 4;

  Uint8List rgbaData = Uint8List(planeSize * 4);

  int uvPlaneOffset = planeSize;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int index = y * width + x;

      int yValue = data[index];
      int uIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);
      int vIndex = uvPlaneSize + uIndex;

      int uValue = data[uvPlaneOffset + uIndex];
      int vValue = data[uvPlaneOffset + vIndex];

      // YUV to RGB conversion
      int c = yValue - 16;
      int d = uValue - 128;
      int e = vValue - 128;

      int r = (298 * c + 409 * e + 128) >> 8;
      int g = (298 * c - 100 * d - 208 * e + 128) >> 8;
      int b = (298 * c + 516 * d + 128) >> 8;

      // Clip RGB values
      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      // Assign RGB values to the output buffer (RGBA8888 format)
      int rgbaIndex = index * 4;
      rgbaData[rgbaIndex] = r; // Red
      rgbaData[rgbaIndex + 1] = g; // Green
      rgbaData[rgbaIndex + 2] = b; // Blue
      rgbaData[rgbaIndex + 3] = 255; // Alpha (fully opaque)
    }
  }

  return rgbaData;
}

Uint8List i420ToRgba(Uint8List i420Data, int width, int height) {
  int planeSize = width * height;
  int uvPlaneSize = planeSize ~/ 4;

  Uint8List rgbaData = Uint8List(planeSize * 4);

  int uvPlaneOffset = planeSize;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int index = y * width + x;

      int yValue = i420Data[index];
      int uIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);
      int vIndex = uvPlaneSize + uIndex;

      int uValue = i420Data[uvPlaneOffset + uIndex];
      int vValue = i420Data[uvPlaneOffset + vIndex];

      // YUV to RGB conversion
      int c = yValue - 16;
      int d = uValue - 128;
      int e = vValue - 128;

      int r = (298 * c + 409 * e + 128) >> 8;
      int g = (298 * c - 100 * d - 208 * e + 128) >> 8;
      int b = (298 * c + 516 * d + 128) >> 8;

      // Clip RGB values
      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      // Assign RGB values to the output buffer (RGBA8888 format)
      int rgbaIndex = index * 4;
      rgbaData[rgbaIndex] = r; // Red
      rgbaData[rgbaIndex + 1] = g; // Green
      rgbaData[rgbaIndex + 2] = b; // Blue
      rgbaData[rgbaIndex + 3] = 255; // Alpha (fully opaque)
    }
  }

  return rgbaData;
}
