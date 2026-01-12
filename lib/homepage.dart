import 'package:flutter/material.dart';
import 'general_gui.dart';

class LoggedOutHomepage extends StatelessWidget {
  const LoggedOutHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SabaccAppBarW(),
      body: Container(
        alignment: Alignment.topCenter,
        child: SelectableText("Welcome to the Sabacc Lounge!", style: TextStyle(fontSize: 40.0)),
      )
    );
  }
}