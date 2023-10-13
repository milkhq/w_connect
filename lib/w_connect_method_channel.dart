import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/subjects.dart';
import 'dart:ui' as ui;

import 'w_connect_platform_interface.dart';

/// An implementation of [WConnectPlatform] that uses method channels.
class MethodChannelWConnect extends WConnectPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('w_connect');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Webview? webview;

  final _accountChangedController = BehaviorSubject<String?>();

  _init() async {
    if (webview == null) {
      webview = await WebviewWindow.create(
        configuration: const CreateConfiguration(
          windowHeight: 1280,
          windowWidth: 720,
          titleBarHeight: 0,
          titleBarTopPadding: 0,
          title: "",
        ),
      );
      webview!.registerJavaScriptMessageHandler("onAccountChanged",
          (name, body) {
        debugPrint('on javaScipt message: $name $body');
      });
      webview!.launch('http://127.0.0.1:5500/js/index.html');
    } else {
      webview!.reload();
    }
  }

  @override
  void init(List<String> args) {
    debugPrint('WConnectWeb init');
  }

  @override
  Future<void> connect() async {
    debugPrint('WConnectWeb connect');
    await _init();
  }

  @override
  Stream<String?> get onAccountChanged => _accountChangedController.stream;

  @override
  Future<void> disconnect() async {}

  @override
  void decodeVideo(
      {required String url, required void Function(ui.Image img) callback}) {
    // TODO: implement decodeVideo
  }
}
