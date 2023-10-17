import 'dart:async';
import 'dart:convert';

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

    _wConnectPlugin.onAccountChanged.listen((event) {
      print(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                TextButton(
                    onPressed: () {
                      _wConnectPlugin.connect();
                    },
                    child: Text('connect')),
                TextButton(
                    onPressed: () {
                      _wConnectPlugin
                          .signIn()
                          .then((value) => print(jsonDecode(value)));
                    },
                    child: Text('connect')),
              ],
            )),
      ),
    );
  }
}
