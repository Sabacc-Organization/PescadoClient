import 'dart:convert';
import 'package:PescadoClient/general_gui.dart';
import 'package:PescadoClient/main.dart';
import 'package:PescadoClient/network/connection.dart';
import 'package:PescadoClient/screens/page_template.dart';
import 'package:flutter/material.dart';

class PlayerStatsPage extends StatelessWidget {
  final String _player;

  const PlayerStatsPage({super.key, required String player}) : _player = player;

  @override
  Widget build(BuildContext context) {
    var appwideData = AppwideDataProvider.from(context);
    return PageTemplateW(
      child: Center(
        child: FutureBuilder(
          future: SabaccConnectionManager.playerStats(
            context,
            player: _player,
          ),
          builder: (context, asyncSnapshot) {
            if (!asyncSnapshot.hasData) {
              return SimpleCardW(child: CircularProgressIndicator());
            }
            var stats = jsonDecode(asyncSnapshot.data!.body) as Map<String, dynamic>;
            return ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height/3),
                    SimpleCardW(
                      // maxWidth: 900,
                      child: Column(
                        children: [
                          SelectableText(_player, style: Theme.of(context).textTheme.displaySmall,),
                          Divider(),
                          SelectableText("Basic Information", style: Theme.of(context).textTheme.headlineSmall,),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 350),
                            child: Table(
                              columnWidths: {1: FixedColumnWidth(10)},
                              border: TableBorder.all(color:Theme.of(context).colorScheme.outlineVariant),
                              children: [
                                TableRow(
                                  children: [
                                    SelectableText("Username", textAlign: TextAlign.end,),
                                    Container(),
                                    SelectableText(_player)
                                  ]
                                ),
                                TableRow(
                                  children: [
                                    SelectableText("Total Games Played", textAlign: TextAlign.end,),
                                    Container(),
                                    SelectableText(stats["totalGamesPlayed"].toString())
                                  ]
                                )
                              ],
                            ),
                          )
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