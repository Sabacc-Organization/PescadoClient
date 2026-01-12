import 'dart:convert';
import 'package:PescadoClient/general_gui.dart';
import 'package:PescadoClient/main.dart';
import 'package:PescadoClient/network/connection.dart';
import 'package:PescadoClient/screens/page_template.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PreferencesPage extends StatefulWidget {

  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    var appwideData = AppwideDataProvider.from(context);
    return PageTemplateW(
      child: Center(
        child: SimpleCardW(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SelectableText("Dark Mode"),
                  Switch(
                    value: appwideData.darkMode,
                    onChanged: (dm) {
                      appwideData.setDarkMode(dm);
                    }
                  ),
                ],
              ),
              if (_errorMessage != null) SelectableText(
                _errorMessage?? "",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              SimpleTextButtonW(
                onClick: () {
                  SabaccConnectionManager.preferences(
                    context,
                    callback: (res) {
                      print(res.body);
                      if (200 <= res.statusCode && res.statusCode < 300) {
                        context.go("/");
                      } else {
                        var message = (json.decode(res.body) as Map<String, dynamic>)["message"];
                        setState(() {
                          _errorMessage = message?? "There was an error. Please try again.";
                        });
                      }
                    }
                  );
                },
                text: "Save"
              )
            ],
          ),
        ),
      )
    );
  }
}