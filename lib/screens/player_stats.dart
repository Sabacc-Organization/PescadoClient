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

  List<AnnotatedWidget> gameToRow(GameVariant variant, Map<String, dynamic> game, BuildContext context) {
    AppwideDataProvider appwideData = AppwideDataProvider.from(context);
    List<Player> players = cast<List<dynamic>>(game["players"])!.cast<Map<String, dynamic>>().map((player) =>
      Player(id: player["id"], username: player["username"])
    ).toList();
    DateTime? createdAt = DateTime.tryParse(game["created_at"].toString());
    String createdAtString = (createdAt == null)? "N/A" :
      "${["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][createdAt.weekday]}, "
      "${["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][createdAt.month]} ${createdAt.day}, "
      "${createdAt.year}";
    bool playerInGame = appwideData.loggedIn && players.any((player) => player.equals(appwideData.player!));
    return [
      AnnotatedWidget.text(variant.toString()),
      AnnotatedWidget.text(cast<int>(game["id"]).toString()),
      AnnotatedWidget(
        Wrap(
          children: [
            ...players.map((player) => SimplePlayerCardW(player))
          ],
        ),
        players.map((player) => player.username).join(", "),
        additional: players
      ),
      AnnotatedWidget.text(game["player_turn"].toString()),
      AnnotatedWidget(SelectableText(createdAtString), game["created_at"].toString(), additional: createdAt),
      AnnotatedWidget.text(cast<String>(game["p_act"]).toString()),
      AnnotatedWidget(SimpleGameCardW(cast<int>(game["id"])!, variant, playerInGame), "")
    ];
  }

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
                          SimpleTableW(
                            enableSearchBar: true,
                            filters: [
                              ("Traditional", false),
                              ("Corellian Spike", false),
                              ("Kessel", false),
                              ("Only show active games", false),
                              ("Only show games where its ${_player.username}'s turn", false),
                              ("Show completed games", true)
                            ],
                            columns: [
                              SimpleTableColumn(
                                "Variant",
                                fractionalSize: 3,
                                filterer: (filters, widget)  {
                                  if (filters[0] && filters[1] && filters[2]) {
                                    return true;
                                  }
                                  if (!(filters[0] || filters[1] || filters[2])) {
                                    return true;
                                  }
                                  if (widget.description == "Traditional" && !filters[0]) {
                                    return false;
                                  }
                                  if (widget.description == "Corellian Spike" && !filters[1]) {
                                    return false;
                                  }
                                  if (widget.description == "Kessel" && !filters[2]) {
                                    return false;
                                  }
                                  return true;
                                },
                                children: []
                              ),
                              SimpleTableColumn(
                                "ID",
                                fractionalSize: 2,
                                children: []
                              ),
                              SimpleTableColumn(
                                "Players",
                                fractionalSize: 6,
                                children: []
                              ),
                              SimpleTableColumn(
                                "Player Turn",
                                fractionalSize: 3,
                                filterer: (filters, widget) {
                                  if (!filters[5] && widget.description == "Completed") {
                                    return false;
                                  }
                                  bool isPlayersTurn = widget.description == _player.username;
                                  if (filters[4] && !isPlayersTurn) {
                                    return false;
                                  }
                                  return true;
                                },
                                children: []
                              ),
                              SimpleTableColumn(
                                "Date Created",
                                fractionalSize: 4,
                                comparator: (first, second) {
                                  if (first.additional == null && second.additional == null) {
                                    return 0;
                                  }
                                  if (first.additional == null) {
                                    return -1;
                                  }
                                  if (second.additional == null) {
                                    return 1;
                                  }
                                  return cast<DateTime>(first.additional)!.compareTo(cast<DateTime>(second.additional)!);
                                },
                                filterer: (filters, widget) {
                                  if (filters[3]
                                    && (DateTime.now().difference(cast<DateTime>(widget.additional)!)) > Duration(days: 2)) {
                                    return false;
                                  }
                                  return true;
                                },
                                children: []
                              ),
                              SimpleTableColumn(
                                "Last Move",
                                fractionalSize: 5,
                                children: []
                              ),
                              SimpleTableColumn(
                                "Link",
                                fractionalSize: 2,
                                sortable: false,
                                children: []
                              ),
                            ]
                          ).withRows(
                            [
                              ...cast<List<dynamic>>(stats["games"]["traditional"])!.cast<Map<String, dynamic>>().map((game) =>
                                gameToRow(GameVariant.traditional, game, context)
                              ),
                              ...cast<List<dynamic>>(stats["games"]["corellianSpike"])!.cast<Map<String, dynamic>>().map((game) =>
                                gameToRow(GameVariant.corellianSpike, game, context)
                              ),
                              ...cast<List<dynamic>>(stats["games"]["kessel"])!.cast<Map<String, dynamic>>().map((game) =>
                                gameToRow(GameVariant.kessel, game, context)
                              ),
                            ]
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