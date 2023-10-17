import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:w_connect/w_connect.dart';
import 'package:w_connect/w_connect_platform_interface.dart';
import 'package:w_connect/w_connect_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWConnectPlatform
    with MockPlatformInterfaceMixin
    implements WConnectPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String> connect() {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  // TODO: implement onAccountChanged
  Stream<String?> get onAccountChanged => throw UnimplementedError();

  @override
  void init(List<String> args) {
    // TODO: implement init
  }

  @override
  void decodeVideo(
      {required String url, required void Function(Image p1) callback}) {
    // TODO: implement decodeVideo
  }

  @override
  Future<void> decodeFrameByIndex({required int index}) {
    // TODO: implement decodeFrameByIndex
    throw UnimplementedError();
  }

  @override
  Future<void> loadVideo(
      {required String url,
      required void Function(Image img) callback,
      required void Function() onDone}) {
    // TODO: implement loadVideo
    throw UnimplementedError();
  }
  
  @override
  Future<void> decodeFrames({required void Function(Image img) callback}) {
    // TODO: implement decodeFrames
    throw UnimplementedError();
  }
  
  @override
  Future<void> loadVideoChunks({required String url}) {
    // TODO: implement loadVideoChunks
    throw UnimplementedError();
  }
  
  @override
  Future<Map<String, dynamic>> signIn() {
    // TODO: implement signIn
    throw UnimplementedError();
  }
}

void main() {
  final WConnectPlatform initialPlatform = WConnectPlatform.instance;

  test('$MethodChannelWConnect is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWConnect>());
  });

  test('getPlatformVersion', () async {
    WConnect wConnectPlugin = WConnect();
    MockWConnectPlatform fakePlatform = MockWConnectPlatform();
    WConnectPlatform.instance = fakePlatform;

    expect(await wConnectPlugin.getPlatformVersion(), '42');
  });
}
