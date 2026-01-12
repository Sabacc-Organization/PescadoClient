import 'package:PescadoClient/general_gui.dart';
import 'package:PescadoClient/screens/page_template.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplateW(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 150,
          children: [
            SimpleCardW(
              child: SelectableText.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Credits\n",
                      style: Theme.of(context).textTheme.displayLarge
                    ),
                    TextSpan(
                      children: [
                        WidgetSpan(child: Divider()),
                        TextSpan(text: "Sabacc Lodge Founder, Sabacc Developer - "),
                        TextSpan(
                          text: "Heinoushare",
                          recognizer: TapGestureRecognizer()..onTap = () {launchUrl(Uri.parse("https://samuelanes.com/"));},
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)
                        ),
                        TextSpan(text: ", "),
                      ]
                    ),
                    TextSpan(
                      children: [
                        WidgetSpan(child: Divider()),
                        TextSpan(text: "Pescado Client, Pescado Cards, Pescado Table, Sabacc Developer - "),
                        TextSpan(
                          text: "Sénior Pescado",
                          recognizer: TapGestureRecognizer()..onTap = () {launchUrl(Uri.parse("https://paishofish49.net"));},
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)
                        ),
                      ]
                    ),
                    TextSpan(
                      children: [
                        WidgetSpan(child: Divider()),
                        TextSpan(text: "Milky Way Background Image - "),
                        TextSpan(
                          text: "Serge Brunier",
                          recognizer: TapGestureRecognizer()..onTap = () {launchUrl(Uri.parse("mailto:serge.brunier@wanadoo.fr"));},
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)
                        ),
                        TextSpan(text: ", "),
                        TextSpan(
                          text: "Source",
                          recognizer: TapGestureRecognizer()..onTap = () {launchUrl(Uri.parse("https://www.eso.org/public/images/eso0932a/"));},
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)
                        )
                      ]
                    ),
                    TextSpan(
                      children: [
                        WidgetSpan(child: Divider()),
                        TextSpan(text: "Planet Background Image - "),
                        TextSpan(
                          text: "Adis Resic",
                          recognizer: TapGestureRecognizer()..onTap = () {launchUrl(Uri.parse("https://science-fiction-blender.eu/"));},
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)
                        ),
                      ]
                    )
                  ]
                )
              ),
            ),
            SimpleCardW(
              child: SelectableText.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Links\n",
                      style: Theme.of(context).textTheme.displayLarge
                    ),
                    TextSpan(
                      children: [
                        WidgetSpan(child: Divider()),
                        TextSpan(text: "Sabacc Lodge - "),
                        TextSpan(
                          text: "Discord",
                          recognizer: TapGestureRecognizer()..onTap = () {launchUrl(Uri.parse("https://discord.gg/cSYRyqufek"));},
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)
                        )
                      ]
                    ),
                  ]
                )
              ),
            )
          ],
        )
      )
    );
  }
}