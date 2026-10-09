import 'dart:math';

import 'package:PescadoClient/main.dart';
import 'package:PescadoClient/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:PescadoClient/kessel_gui.dart';
import 'package:PescadoClient/kessel_helpers.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';

const inversionMatrix = <double>[
  -1, 0, 0, 0, 255,
  0, -1, 0, 0, 255,
  0, 0, -1, 0, 255,
  0, 0, 0, 1, 0,
];

const identityMatrix = <double>[
  1, 0, 0, 0, 0,
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0,
];

class UserDropdownW extends StatelessWidget {
  const UserDropdownW({super.key});

  @override
  Widget build(BuildContext context) {
    var appwideData = AppwideDataProvider.from(context);

    return SimpleTextDropdownW(
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            appwideData.logOut();
            context.go("/");
          },
          child: Text("Log Out")
        ),
        PopupMenuItem(
          onTap: () {
            context.go("/preferences");
          },
          child: Text("Preferences")
        ),
        PopupMenuItem(
          onTap: () {
            context.go("/myGames");
          },
          child: Text("My Games")
        ),
        PopupMenuItem(
          onTap: () {
            context.go("/player/${appwideData.username}");
          },
          child: Text("Statistics")
        ),
        PopupMenuItem(
          onTap: () {
            context.go("/host");
          },
          child: Text("Host A Game")
        ),
      ],
      text: appwideData.username,
    );
  }
}

class SimpleTextDropdownW extends StatefulWidget {
  final List<PopupMenuEntry<dynamic>> Function(BuildContext) _itemBuilder;
  final String _text;
  const SimpleTextDropdownW({
    required List<PopupMenuEntry<dynamic>> Function(BuildContext) itemBuilder,
    required String text,
    super.key
  })
  : _itemBuilder = itemBuilder, _text = text;

  @override
  State<SimpleTextDropdownW> createState() => _SimpleTextDropdownWState();
}

class _SimpleTextDropdownWState extends State<SimpleTextDropdownW> {
  bool _opened = false;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: widget._itemBuilder,
      style: TextButton(onPressed: (){}, child: Text("")).defaultStyleOf(context),
      onOpened: () {
        setState(() {
          _opened = true;
        });
      },
      onCanceled: () {
        setState(() {
          _opened = false;
        });
      },
      icon: Row(
        children: [
          Text(widget._text),
          Icon(_opened? Icons.arrow_drop_up : Icons.arrow_drop_down)
        ]
      ),
      offset: Offset(0, 40),
    );
  }
}

class SimpleTextFieldW extends StatelessWidget {
  final String? _hint;
  final TextEditingController? _controller;
  final bool _obscureText;
  final Widget? _icon;
  final double? _fontSize;
  const SimpleTextFieldW({
    String? hint,
    TextEditingController? controller,
    bool obscureText = false,
    Widget? icon,
    double? fontSize,
    super.key
  })
  : _hint = hint,
  _controller = controller,
  _obscureText = obscureText,
  _icon = icon,
  _fontSize = fontSize;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: TextStyle(fontSize: _fontSize),
      decoration: InputDecoration(
        // icon: _icon,
        prefixIcon: _icon,
        hintText: _hint,
        border: OutlineInputBorder(),
      ),
      textAlign: TextAlign.center,
      obscureText: _obscureText,
    );
  }
}

class SimpleCardW extends StatelessWidget {
  final double _maxWidth;
  final Widget _child;

  const SimpleCardW(
    {super.key,
    double maxWidth = 300,
    required Widget child}
  )
  : _maxWidth = maxWidth,
  _child = child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        color: Theme.of(context).colorScheme.outline,
        child: Card(
          margin: EdgeInsets.all(2),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: _child
          ),
        ),
      ),
    );
  }
}

class AnnotatedWidget {
  final Widget widget;
  final String description;
  final dynamic additional;
  const AnnotatedWidget(this.widget, this.description, {this.additional});
  static AnnotatedWidget text(String message) {
    return AnnotatedWidget(SelectableText(message), message);
  }
}

class SimpleTableColumn {
  final String title;
  final List<AnnotatedWidget> children;
  final int Function(AnnotatedWidget, AnnotatedWidget)? comparator;
  final bool Function(String, AnnotatedWidget)? searcher;
  final bool Function(List<bool>, AnnotatedWidget)? filterer;
  final bool sortable;
  final int fractionalSize;
  const SimpleTableColumn(this.title, {required this.children, this.comparator, this.searcher, this.filterer, this.sortable = true, this.fractionalSize = 1});

  @Deprecated("was for default sorting behavior, keeping it around cause it could come in handy.")
  static String getWidgetText(Widget x) {
    if (x is Text) {
      return x.data ?? "";
    } else if (x is SelectableText) {
      return x.data ?? "";
    } else if (x is RichText) {
      return x.text.toPlainText();
    } else if (x is Container) {
      return getWidgetText(x.child?? Text(""));
    } else if (x is Padding) {
      return getWidgetText(x.child?? Text(""));
    } else if (x is SizedBox) {
      return getWidgetText(x.child?? Text(""));
    } else if (x is GestureDetector) {
      return getWidgetText(x.child?? Text(""));
    }
    return "";
  }

  List<int> sort() {
    List<int> temp = List.generate(children.length, (index) => index);
    if (comparator == null) {
      temp.sort((a, b) => compareNatural(children[a].description, children[b].description));
      return temp;
    }
    temp.sort((a, b) => comparator!(children[a], children[b]));
    return temp;
  }

  List<bool> filter(List<bool> filters) {
    if (filterer == null) {
      return List.filled(children.length, true);
    }
    return children.map((widget) =>
      filterer!(filters, widget)
    ).toList();
  }

  List<bool> search(String query) {
    if (searcher == null) {
      return children.map((widget) {
        var a = widget.description;
        return (a.toLowerCase().contains(query.toLowerCase()) || a.isEmpty);
      }).toList();
    }
    if (query.isEmpty) {
      return List.filled(children.length, true);
    }
    return children.map((widget) =>
      searcher!(query, widget)
    ).toList();
  }

  List<bool> allowedRows(List<bool> filters, String query) {
    var matchFilters = filter(filters);
    var matchSearch = search(query);
    return List.generate(children.length, (index) => matchFilters[index] && matchSearch[index]);
  }

  SimpleTableColumn withRows(List<AnnotatedWidget> rows) {
    return SimpleTableColumn(title, children: children + rows, comparator: comparator, filterer: filterer, searcher: searcher, sortable: sortable, fractionalSize: fractionalSize);
  }
}

class SimpleTableW extends StatefulWidget {
  final List<SimpleTableColumn> columns;
  final List<(String, bool)> filters;
  final bool enableSearchBar;
  const SimpleTableW({
    super.key,
    required this.filters,
    required this.columns,
    this.enableSearchBar = false,
  });

  @override
  State<StatefulWidget> createState() => _SimpleTableWState();

  SimpleTableW withRows(List<List<AnnotatedWidget>> rows) {
    return SimpleTableW(filters: filters, enableSearchBar: enableSearchBar, columns: columns.mapIndexed((index, oldColumn) =>
      oldColumn.withRows(List.generate(rows.length, (index2) => rows[index2][index]))
    ).toList());
  }
}

class _SimpleTableWState extends State<SimpleTableW> {
  List<int> _rows = [];
  List<bool> _filters = [];
  int? _sortedBy;
  bool _descending = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.filters.map((filter) => filter.$2).toList();
    _searchController.addListener(() {
      setState(() {
        evaluateRows();
      });
    });
    evaluateRows();
  }

  @override
  void didUpdateWidget(covariant SimpleTableW oldWidget) {
    super.didUpdateWidget(oldWidget);
    evaluateRows();
  }

  int numOfRows() {
    return widget.columns.first.children.length;
  }

  void evaluateRows() {
    List<int> temp;
    if (_sortedBy == null) {
      temp = List.generate(numOfRows(), (index) => index);
    } else {
      temp = widget.columns[_sortedBy!].sort();
    }
    if (_descending) {
      temp.reverseRange(0, numOfRows());
    }
    List<bool> matchSearch = List.filled(numOfRows(), false);
    List<bool> matchFilters = List.filled(numOfRows(), true);

    widget.columns.forEachIndexed((index, column) {
      if (_searchController.text.isEmpty) {
        matchSearch = List.filled(numOfRows(), true);
      } else {
        column.search(_searchController.text).forEachIndexed((index, matches) {
          matchSearch[index] = matchSearch[index] || matches;
        });
      }
      column.filter(_filters).forEachIndexed((index, matches) {
        matchFilters[index] = matchFilters[index] && matches;
      });
    });

    _rows = temp.where((row) => matchFilters[row] && matchSearch[row]).toList();
  }

  @override
  Widget build(BuildContext context) {
    Column col = Column(
      spacing: 10,
      children: [
        if (widget.enableSearchBar) SimpleTextFieldW(
          controller: _searchController,
          hint: "Search",
          icon: Icon(Icons.search),
        ),
        Wrap(
          spacing: 40,
          children: [
            ...widget.filters.mapIndexed((index, filter) =>
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: _filters[index],
                    onChanged: (value) {
                      setState(() {
                        _filters[index] = value;
                        evaluateRows();
                      });
                    }
                  ),
                  SelectableText(filter.$1),
                ],
              )
            ),
          ],
        ),
        Table(
          columnWidths: { for (var element in List.generate(widget.columns.length, (index) =>
            (index, FlexColumnWidth(widget.columns[index].fractionalSize.toDouble()))
          )) element.$1 : element.$2 },
          border: TableBorder.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 2,
            borderRadius: BorderRadius.all(Radius.circular(5))
          ),
          children: [
            TableRow(
              children: [
                ...widget.columns.mapIndexed((index, column) =>
                  TableCell(
                    child: SelectionArea(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (column.sortable) {
                            setState(() {
                              if (_sortedBy == index) {
                                if (_descending) {
                                  _descending = false;
                                  _sortedBy = null;
                                } else {
                                  _descending = true;
                                }
                              } else {
                                _descending = false;
                                _sortedBy = index;
                              }
                              evaluateRows();
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                column.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900
                                ),
                              ),
                              Icon(_sortedBy == index? _descending? Icons.arrow_drop_down : Icons.arrow_drop_up : null)
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                )
              ]
            ),
            ..._rows.mapIndexed((index, row) =>
              TableRow(
                decoration: index.isEven? BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest) : null,
                children: [
                  ...widget.columns.map((column) {
                    return TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: column.children[row].widget,
                      )
                    );
                  })
                ]
              )
            ),
          ],
        ),
      ],
    );
    if (widget.enableSearchBar || widget.filters.isNotEmpty) {
      return SimpleCardW(
        maxWidth: double.infinity,
        child: col
      );
    }
    return col;
  }
}

class SimpleGameTableW extends StatelessWidget {
  final Map<String, List<dynamic>> games;
  final Player player;
  /// 0-User Stats Format, 1-Index Format
  final int inputFormat;
  const SimpleGameTableW({super.key, required this.games, required this.player, required this.inputFormat});

  List<AnnotatedWidget> gameToRow(GameVariant variant, Map<String, dynamic> game, int index, BuildContext context) {
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
    String playerTurnKeyString = """${variant.snakeSlug()}_player_turn_usernames""";
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
      AnnotatedWidget.text(inputFormat == 0? game["player_turn"].toString() : games[playerTurnKeyString]![index]),
      AnnotatedWidget(SelectableText(createdAtString), game["created_at"].toString(), additional: createdAt),
      AnnotatedWidget.text(cast<String>(game["p_act"]).toString()),
      AnnotatedWidget(SimpleGameCardW(cast<int>(game["id"])!, variant, playerInGame), "")
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SimpleTableW(
      enableSearchBar: true,
      filters: [
        ("Traditional", false),
        ("Corellian Spike", false),
        ("Kessel", false),
        ("Only show active games", false),
        ("Only show games where its ${player.username}'s turn", false),
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
            bool isPlayersTurn = widget.description == player.username;
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
        ...games[inputFormat == 0? "traditional" : "traditional_games"]!.cast<Map<String, dynamic>>().mapIndexed((index, game) =>
          gameToRow(GameVariant.traditional, game, index, context)
        ),
        ...games[inputFormat == 0? "corellianSpike" : "corellian_spike_games"]!.cast<Map<String, dynamic>>().mapIndexed((index, game) =>
          gameToRow(GameVariant.corellianSpike, game, index, context)
        ),
        ...games[inputFormat == 0? "kessel" : "kessel_games"]!.cast<Map<String, dynamic>>().mapIndexed((index, game) =>
          gameToRow(GameVariant.kessel, game, index, context)
        ),
      ]
    );
  }
}

class SimplePlayerCardW extends StatelessWidget {
  final Player player;
  const SimplePlayerCardW(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go("/player/${player.username}");
      },
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Text(player.username),
        )
      ),
    );
  }
}

class SimpleGameCardW extends StatelessWidget {
  final int id;
  final GameVariant variant;
  final bool inGame;
  const SimpleGameCardW(this.id, this.variant, this.inGame, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go("/game/${variant.slug()}/$id");
      },
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: Text(inGame? "Play" : "View"),
        )
      ),
    );
  }
}

class TimelineGameData {
  final List<String> dates;
  final List<int> traditional;
  final List<int> corellianSpike;
  final List<int> kessel;
  final List<int> total;
  const TimelineGameData(this.dates, this.traditional, this.corellianSpike, this.kessel, this.total);
  static TimelineGameData fromJson(Map<String, dynamic> data) {
    return TimelineGameData(
      cast<List<dynamic>>(data["dates"])!.cast<String>(),
      cast<List<dynamic>>((data["traditional"]))!.cast<int>(),
      cast<List<dynamic>>(data["corellianSpike"])!.cast<int>(),
      cast<List<dynamic>>(data["kessel"])!.cast<int>(),
      cast<List<dynamic>>(data["total"])!.cast<int>()
    );
  }
}

class SimpleTimelineW extends StatefulWidget {
  final TimelineGameData days7;
  final TimelineGameData days30;
  final TimelineGameData months12;
  final TimelineGameData lifetime;
  const SimpleTimelineW(this.days7, this.days30, this.months12, this.lifetime, {super.key});

  @override
  State<SimpleTimelineW> createState() => _SimpleTimelineWState();
}

class _SimpleTimelineWState extends State<SimpleTimelineW> {
  final TextEditingController _timespan = TextEditingController();

  TimelineGameData getData() {
    if (_timespan.text == "Last 7 Days") {
      return widget.days7;
    } else if (_timespan.text == "Last 30 Days") {
      return widget.days30;
    } else if (_timespan.text == "Last 12 Months") {
      return widget.months12;
    } else {
      return widget.lifetime;
    }
  }

  List<FlSpot> getPoints(GameVariant? variant) {
    TimelineGameData data = getData();
    int dataNum = data.dates.length;
    List<int> variantData;
    switch (variant) {
      case GameVariant.traditional: variantData = data.traditional; break;
      case GameVariant.corellianSpike: variantData = data.corellianSpike; break;
      case GameVariant.kessel: variantData = data.kessel; break;
      case null: variantData = data.total; break;
    }
    return List.generate(dataNum, (index) =>
      FlSpot(index.toDouble(), variantData[index].toDouble())
    );
  }

  Widget getDates(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    String text = getData().dates[value.toInt()];

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Transform.rotate(
        alignment: AlignmentGeometry.center,
        angle: -pi / 3,
        child: FractionalTranslation(
          translation: Offset(-0.5, 0),
          child: Text(text, style: style)
        )
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        value.toInt().toString(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _timespan.value = TextEditingValue(text: "Last 7 Days");
    _timespan.addListener(() {
      setState(() { /* timespan value changed */ });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCardW(
      maxWidth: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ...[
                    ("Total", Colors.amber),
                    ("Traditional", Colors.green),
                    ("Corellian Spike", Colors.red),
                    ("Kessel", Colors.blue),
                  ].map((element) =>
                    Card(
                      color: element.$2,
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(3),
                        child: SelectableText(element.$1)
                      ),
                    )
                  ),
                ],
              ),
              DropdownMenu(
                selectOnly: true,
                controller: _timespan,
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  constraints: BoxConstraints.tight(const Size.fromHeight(40)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: "Last 7 Days", label: "Last 7 Days"),
                  DropdownMenuEntry(value: "Last 30 Days", label: "Last 30 Days"),
                  DropdownMenuEntry(value: "Last 12 Months", label: "Last 12 Months"),
                  DropdownMenuEntry(value: "Lifetime", label: "Lifetime")
                ]
              ),
            ]
          ),
          SizedBox(height: 25,),
          SizedBox(
            height: 400,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideVertically: true,
                    fitInsideHorizontally: true,
                    maxContentWidth: 150,
                    getTooltipItems: (spots) {
                      List<LineTooltipItem?> ret = [null, null, null, null];
                      for (var spot in spots) {
                        (int, String) line;
                        if (spot.bar.color == Colors.amber) {
                          line = (0, "Total: ");
                        } else if (spot.bar.color == Colors.green) {
                          line = (1, "Traditional: ");
                        } else if (spot.bar.color == Colors.red) {
                          line = (2, "Corellian Spike: ");
                        } else {
                          line = (3, "Kessel: ");
                        }
                        ret[line.$1] = LineTooltipItem(
                          line.$2 + spot.y.toInt().toString(),
                          TextStyle(
                            color: spot.bar.gradient?.colors.first ??
                              spot.bar.color ??
                              Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          )
                        );
                      }
                      return ret;
                    }
                  )
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: getPoints(null),
                    isCurved: false,
                    barWidth: 2,
                    color: Colors.amber,
                    dotData: const FlDotData(
                      show: true,
                    ),
                  ),
                  LineChartBarData(
                    spots: getPoints(GameVariant.traditional),
                    isCurved: false,
                    barWidth: 2,
                    color: Colors.green,
                    dotData: const FlDotData(
                      show: true,
                    ),
                  ),
                  LineChartBarData(
                    spots: getPoints(GameVariant.corellianSpike),
                    isCurved: false,
                    barWidth: 2,
                    color: Colors.red,
                    dotData: const FlDotData(
                      show: true,
                    ),
                  ),
                  LineChartBarData(
                    spots: getPoints(GameVariant.kessel),
                    isCurved: false,
                    barWidth: 2,
                    color: Colors.blue,
                    dotData: const FlDotData(
                      show: true,
                    ),
                  ),
                ],
                minY: 0,
                maxY: max(getData().total.max + 1, 3),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey, width: 0.4)
                  )
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitleAlignment: SideTitleAlignment.outside,
                    drawBelowEverything: true,
                    sideTitles: SideTitles(
                      reservedSize: 60,
                      maxIncluded: true,
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: getDates,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: SelectableText("Number of Games"),
                    sideTitles: SideTitles(
                      showTitles: true,
                      minIncluded: false,
                      getTitlesWidget: leftTitleWidgets,
                      interval: 1,
                      reservedSize: 36,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SabaccAppBarW extends StatelessWidget implements PreferredSizeWidget {
  const SabaccAppBarW({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    var appwideData = AppwideDataProvider.from(context);
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: ColorScheme.of(context).surfaceContainerLow,
      title: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: kToolbarHeight),
        child: GestureDetector(
          onTap: () {
            context.go("/");
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: LayoutBuilder(
                  builder: (context, constraints) => SvgPicture.asset(
                    "lib/static/img/sabaccMono.svg",
                    colorFilter: Theme.of(context).brightness == Brightness.dark? ColorFilter.matrix(inversionMatrix) : ColorFilter.matrix(identityMatrix),
                    width: constraints.biggest.shortestSide,
                    height: constraints.biggest.shortestSide,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Text("Sabacc", style: TextStyle(fontSize: 40)),
            ]
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
          child: Row(
            children: [
              if (appwideData.loggedIn) ...[
                UserDropdownW()
              ],
              if (!appwideData.loggedIn) ...[
                SimpleTextButtonW(
                  onClick: () {
                    context.go("/login");
                  },
                  text: "Log In"
                ),
                SimpleTextButtonW(
                  onClick: () {
                    context.go("/register");
                  },
                  text: "Register"
                )
              ],
              SimpleTextButtonW(
                onClick: () {
                  context.go("/credits");
                },
                text: "Credits"
              ),
            ],
          )
        )
      ],
      bottom: PreferredSize(preferredSize: Size.fromHeight(2), child: Container(height: 2, color: Theme.of(context).colorScheme.outline,)),
    );
  }
}

class GameTab extends StatefulWidget {
  const GameTab({super.key});

  @override
  State<GameTab> createState() => _GameTabState();
}

class _GameTabState extends State<GameTab> {
  @override
  Widget build(BuildContext context) {
    KesselGame game = context.watch<KesselGameUpdateProvider>().game;
    String playerTurn = "undefined";
    for (var player in game.players) {
      if (player.id == game.playerTurn) {
        playerTurn = player.username;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SelectableText("Number of Players: ${game.players.length}", style: TextStyle(fontSize: 20)),
          SelectableText("Player Turn: $playerTurn", style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

class SabaccGameInfoPanelW extends StatefulWidget {
  const SabaccGameInfoPanelW({super.key});

  @override
  State<StatefulWidget> createState() => _SabaccGameInfoPanelWState();
}

class _SabaccGameInfoPanelWState extends State<SabaccGameInfoPanelW>{
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: ColorScheme.of(context).surfaceContainerLow),
      margin: EdgeInsets.symmetric(vertical: 100, horizontal: 100),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              indicator: BoxDecoration(
                color: ColorScheme.of(context).surfaceContainerHighest,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              splashBorderRadius: BorderRadius.circular(25),
              tabs: [
                InkWell(
                  onTap: () {
                    print("hello, world!");
                  },
                  child: Tab(child: Text("Info"))
                ),
                Tab(child: Text("Game")),
                Tab(child: Text("Players"))
              ]
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Container(
                    child: SelectableText("Info Stuff"),
                  ),
                  GameTab(),
                  Container(
                    child: SelectableText("Player Stuff"),
                  )
                ]
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SabaccGameBoardW extends StatefulWidget {
  const SabaccGameBoardW({super.key});

  @override
  State<StatefulWidget> createState() => _SabaccGameBoardWState();
}

class _SabaccGameBoardWState extends State<SabaccGameBoardW> {
  @override
  Widget build(BuildContext context) {
    int numOfPlayers = context.watch<KesselGameUpdateProvider>().game.players.length;
    return Container(
      padding: EdgeInsets.all(175),
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            SvgPicture.asset("lib/static/img/table.svg", fit: BoxFit.contain, height: double.infinity,),
            ...List.generate(numOfPlayers, (i) {
              return Center(child: Transform.translate(
                offset: Offset.fromDirection((pi / 2) + (pi * i * 2 / numOfPlayers), constraints.biggest.shortestSide/2),
                child: KesselPlayerW(player: context.watch<KesselGameUpdateProvider>().game.players[i]),
              ));
            })
          ],
        );
      })
    );
  }
}
