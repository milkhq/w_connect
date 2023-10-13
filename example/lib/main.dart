import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:w_connect/w_connect.dart';

void main(List<String> args) {
  if (runWebViewTitleBarWidget(
    args,
    builder: (context) {
      return const SizedBox();
    },
  )) {
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();
  WConnect().init(args);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _wConnectPlugin = WConnect();

  ui.Image? _image;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _wConnectPlugin.loadVideo(
          url: './mittria_360.mp4',
          callback: (img) {
            setState(() {
              _image = img;
            });
          },
          onDone: () {
            var currentFrame = 0;
            Timer.periodic(Duration(milliseconds: 32), (timer) {
              currentFrame++;
              if (currentFrame > 238) {
                currentFrame = 0;
                return;
              }
              _wConnectPlugin.decodeFrameByIndex(index: currentFrame);
            });
            // _wConnectPlugin.decodeFrameByIndex(index: 0);
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: RawImage(
            filterQuality: FilterQuality.medium,
            fit: BoxFit.scaleDown,
            image: _image,
          ),
        ),
      ),
    );
  }
}
