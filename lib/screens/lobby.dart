import 'package:PescadoClient/general_gui.dart';
import 'package:PescadoClient/screens/page_template.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplateW(
      child: Container(
        alignment: AlignmentGeometry.xy(-0.7, 0),
        child: SimpleCardW(
          maxWidth: 550,
          child: SelectableText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Sabacc\n",
                  style: Theme.of(context).textTheme.displayLarge
                ),
                TextSpan(
                  text: "Pescado Client\n",
                  style: Theme.of(context).textTheme.displaySmall
                ),
                WidgetSpan(child: Divider()),
                TextSpan(
                  text: "New web client for interacting with ",
                  style: Theme.of(context).textTheme.headlineSmall
                ),
                TextSpan(
                  text: "Sabacc",
                  recognizer: TapGestureRecognizer()..onTap = () {launchUrl(Uri.parse("https://sabacc.samuelanes.com/"));},
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)
                ),
                TextSpan(
                  text: ", a card game from Star Wars.",
                  style: Theme.of(context).textTheme.headlineSmall
                ),
              ]
            )
          )
        ),
      )
    );
  }
}