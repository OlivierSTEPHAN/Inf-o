import 'package:flutter/material.dart';

import 'package:qrcode_flutter/custom_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'qrcode in Flutter',
      debugShowCheckedModeBanner: false,
      home: Drawer3D(),
    );
  }
}
