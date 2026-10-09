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

class PlayerStatsPage extends StatelessWidget {
  final Player _player;

  const PlayerStatsPage({super.key, required Player player}) : _player = player;

  @override
  Widget build(BuildContext context) {
    var appwideData = AppwideDataProvider.from(context);
    return PageTemplateW(
      child: Center(
        child: FutureBuilder(
          future: SabaccConnectionManager.playerStats(
            context,
            player: _player.username,
          ),
          builder: (context, asyncSnapshot) {
            if (!asyncSnapshot.hasData) {
              return SimpleCardW(child: CircularProgressIndicator());
            }
            Map<String, dynamic> stats;
            try {
              stats = jsonDecode(asyncSnapshot.data!.body) as Map<String, dynamic>;
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
                          SelectableText(_player.username, style: Theme.of(context).textTheme.displaySmall,),
                          Divider(),
                          SelectableText("Basic Information", style: Theme.of(context).textTheme.headlineSmall,),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SelectableText("Username"),
                                    SelectableText("Total Games Played"),
                                    SelectableText("Games Completed")
                                  ],
                                ),
                                VerticalDivider(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(_player.username),
                                    SelectableText(stats["totalGamesPlayed"].toString()),
                                    SelectableText(stats["gamesCompleted"].toString())
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(),
                          SelectableText("Performance Statistics", style: Theme.of(context).textTheme.headlineSmall,),
                          SimpleTableW(
                            filters: [],
                            enableSearchBar: false,
                            columns: [
                              SimpleTableColumn(
                                "Game Type",
                                children: []
                              ),
                              SimpleTableColumn(
                                "Games Played",
                                children: []
                              ),
                              SimpleTableColumn(
                                "Games Completed",
                                children: []
                              ),
                              SimpleTableColumn(
                                "Average Payout",
                                children: []
                              ),
                            ]
                          ).withRows(
                            [
                              [
                                AnnotatedWidget.text("Overall"),
                                AnnotatedWidget.text(toStringForTable(stats["totalGamesPlayed"])),
                                AnnotatedWidget.text(toStringForTable(stats["gamesCompleted"])),
                                AnnotatedWidget.text(toStringForTable(stats["overallAvgPayout"])),
                              ],
                              [
                                AnnotatedWidget.text("Traditional"),
                                AnnotatedWidget.text(toStringForTable(stats["traditionalGamesPlayed"])),
                                AnnotatedWidget.text(toStringForTable(stats["traditionalGamesCompleted"])),
                                AnnotatedWidget.text(toStringForTable(stats["traditionalAvgPayout"])),
                              ],
                              [
                                AnnotatedWidget.text("Corellian Spike"),
                                AnnotatedWidget.text(toStringForTable(stats["corellianSpikeGamesPlayed"])),
                                AnnotatedWidget.text(toStringForTable(stats["corellianSpikeGamesCompleted"])),
                                AnnotatedWidget.text(toStringForTable(stats["corellianSpikeAvgPayout"])),
                              ],
                              [
                                AnnotatedWidget.text("Kessel"),
                                AnnotatedWidget.text(toStringForTable(stats["kesselGamesPlayed"])),
                                AnnotatedWidget.text(toStringForTable(stats["kesselGamesCompleted"])),
                                AnnotatedWidget.text(toStringForTable(stats["kesselAvgPayout"])),
                              ]
                            ]
                          ),
                          Divider(),
                          SelectableText("Game History Timeline", style: Theme.of(context).textTheme.headlineSmall,),
                          SimpleTimelineW(
                            TimelineGameData.fromJson(stats["gameHistory"]["week"]),
                            TimelineGameData.fromJson(stats["gameHistory"]["month"]),
                            TimelineGameData.fromJson(stats["gameHistory"]["year"]),
                            TimelineGameData.fromJson(stats["gameHistory"]["lifetime"]),
                          ),
                          Divider(),
                          SelectableText("Game History", style: Theme.of(context).textTheme.headlineSmall,),
                          SimpleGameTableW(
                            player: _player,
                            inputFormat: 0,
                            games: cast<Map<String, dynamic>>(stats["games"])!.cast<String, List<dynamic>>(),
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