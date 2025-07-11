import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'kessel_gui.dart';
import 'kessel_helpers.dart';
import 'package:provider/provider.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(const SabaccApp());
}

class SabaccApp extends StatelessWidget {
  const SabaccApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => KesselGameUpdateProvider(KesselGame.example(), 1)
        )
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        theme: ThemeData.light(),
        title: "Pescado's Sabacc Client",
        home: KesselGamePage(),
      ),
    );
  }
}