import 'dart:ui';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'w_connect_method_channel.dart';

abstract class WConnectPlatform extends PlatformInterface {
  /// Constructs a WConnectPlatform.
  WConnectPlatform() : super(token: _token);

  static final Object _token = Object();

  static WConnectPlatform _instance = MethodChannelWConnect();

  /// The default instance of [WConnectPlatform] to use.
  ///
  /// Defaults to [MethodChannelWConnect].
  static WConnectPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WConnectPlatform] when
  /// they register themselves.
  static set instance(WConnectPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> connect() {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  void init(List<String> args) {
    throw UnimplementedError('init() has not been implemented.');
  }

  void decodeVideo(
      {required String url, required void Function(Image img) callback}) {
    throw UnimplementedError('decodeVideo() has not been implemented.');
  }

  Stream<String?> get onAccountChanged =>
      throw UnimplementedError('onAccountChanged() has not been implemented.');

  Future<void> loadVideo(
      {required String url,
      required void Function(Image img) callback,
      required void Function() onDone}) {
    throw UnimplementedError('loadVideo() has not been implemented.');
  }

  Future<void> decodeFrameByIndex({
    required int index,
  }) {
    throw UnimplementedError('loadVideoFrame() has not been implemented.');
  }

  Future<void> loadVideoChunks({required String url}) {
    throw UnimplementedError('loadVideoChunks() has not been implemented.');
  }

  Future<void> decodeFrames({
    required void Function(Image img) callback,
  }) {
    throw UnimplementedError('loadVideoFrame() has not been implemented.');
  }

  Future<dynamic> signIn() {
    throw UnimplementedError('signIn() has not been implemented.');
  }

  void playBackgroundTrack() {
    throw UnimplementedError('playBackgroundTrack() has not been implemented.');
  }

  void stopBackgroundTrack() {
    throw UnimplementedError('stopBackgroundTrack() has not been implemented.');
  }

  void toggleBackgroundTrack() {
    throw UnimplementedError('toggleBackgroundTrack() has not been implemented.');
  }
}
