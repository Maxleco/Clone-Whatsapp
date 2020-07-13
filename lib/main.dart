import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/RouteGenerator.dart';

void main() {
  runApp(MyApp());
}

final ThemeData defaultTheme = ThemeData(
  primaryColor: Color(0xFF075E54),
  accentColor: Color(0xFF25D366),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

final ThemeData iosTheme = ThemeData(
  primaryColor: Colors.grey[200],
  accentColor: Color(0xFF25D366),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whatsapp',
      theme: Platform.isIOS ? iosTheme : defaultTheme,
      home: Login(),
      initialRoute: "/",
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
