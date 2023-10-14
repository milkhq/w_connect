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
      _wConnectPlugin
          .loadVideoChunks(
        url: './mittria_360.mp4',
      )
          .then((value) {
        _wConnectPlugin.decodeFrame(
            index: 0,
            callback: (img) {
              setState(() {
                _image = img;
              });
            });
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
