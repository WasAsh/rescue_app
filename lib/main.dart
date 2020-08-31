import 'package:flutter/material.dart';
import 'package:rescue_app/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title : 'Rescue' ,
      home: Home(),
    );
  }
}
