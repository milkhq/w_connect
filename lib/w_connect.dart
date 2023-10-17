import 'dart:ui';

import 'w_connect_platform_interface.dart';

export 'package:desktop_webview_window/desktop_webview_window.dart';

class WConnect {
  Future<String?> getPlatformVersion() {
    return WConnectPlatform.instance.getPlatformVersion();
  }

  Future<void> connect() async {
    WConnectPlatform.instance.connect();
  }

  Future<void> disconnect() async {
    WConnectPlatform.instance.disconnect();
  }

  void init(List<String> args) {
    return WConnectPlatform.instance.init(args);
  }

  Stream<String?> get onAccountChanged =>
      WConnectPlatform.instance.onAccountChanged;

  void decodeVideo(
      {required String url, required void Function(Image img) callback}) {
    return WConnectPlatform.instance.decodeVideo(url: url, callback: callback);
  }

  Future<void> loadVideo(
      {required String url,
      required void Function(Image img) callback,
      required void Function() onDone}) {
    return WConnectPlatform.instance
        .loadVideo(url: url, callback: callback, onDone: onDone);
  }

  Future<void> decodeFrameByIndex({
    required int index,
  }) {
    return WConnectPlatform.instance.decodeFrameByIndex(index: index);
  }

  Future<void> loadVideoChunks({required String url}) {
    return WConnectPlatform.instance.loadVideoChunks(url: url);
  }

  Future<void> decodeFrames({
    required void Function(Image img) callback,
  }) {
    return WConnectPlatform.instance.decodeFrames(callback: callback);
  }

  Future<dynamic> signIn() {
    return WConnectPlatform.instance.signIn();
  }
}
