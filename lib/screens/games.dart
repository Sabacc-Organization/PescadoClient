import 'dart:convert';
import 'package:PescadoClient/general_gui.dart';
import 'package:PescadoClient/main.dart';
import 'package:PescadoClient/network/connection.dart';
import 'package:PescadoClient/screens/page_template.dart';
import 'package:flutter/material.dart';
import 'package:PescadoClient/utils.dart';

String toStringForTable(dynamic x) {
  if (x == null) {
    return "N/A";
  }
  if (x is double) {
    return "${(x*1000.0).round()/1000}%";
  }
  return x.toString();
}

class MyGamesPage extends StatelessWidget {
  const MyGamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appwideData = AppwideDataProvider.from(context);
    return PageTemplateW(
      child: Center(
        child: FutureBuilder(
          future: SabaccConnectionManager.myGames(
            context,
            player: appwideData.username,
            password: appwideData.password
          ),
          builder: (context, asyncSnapshot) {
            if (!asyncSnapshot.hasData) {
              return SimpleCardW(child: CircularProgressIndicator());
            }
            Map<String, dynamic> games;
            try {
              games = jsonDecode(asyncSnapshot.data!.body) as Map<String, dynamic>;
            } on FormatException {
              return SimpleCardW(
                child: SelectableText(
                  "There was an error. Please try again later.",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }
            return ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height/3),
                    SimpleCardW(
                      maxWidth: MediaQuery.of(context).size.width*3/5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SelectableText("My Games", style: Theme.of(context).textTheme.displaySmall,),
                          SimpleGameTableW(games: games.cast<String, List<dynamic>>(), player: appwideData.player!, inputFormat: 1,)
                        ],
                      )
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height/3),
                  ],
                )
              ),
            );
          }
        ),
      )
    );
  }
}