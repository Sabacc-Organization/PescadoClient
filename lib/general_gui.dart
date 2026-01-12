import 'dart:math';

import 'package:PescadoClient/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:PescadoClient/kessel_gui.dart';
import 'package:PescadoClient/kessel_helpers.dart';

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

class SimpleTextButtonW extends StatelessWidget {
  final void Function() _onClick;
  final String _text;

  const SimpleTextButtonW({
    required void Function() onClick,
    required String text,
    super.key
  })
  : _onClick = onClick, _text = text;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: _onClick, child: Text(_text));
  }
}

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
          child: Text("My Games")
        ),
        PopupMenuItem(
          onTap: () {
            context.go("/player/${appwideData.username}");
          },
          child: Text("Statistics")
        ),
      ],
      text: appwideData.username,
    );
  }
}

class HostGameDropdownW extends StatelessWidget {
  const HostGameDropdownW({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleTextDropdownW(
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Text("Traditional")
        ),
        PopupMenuItem(
          child: Text("Corellian Spike")
        ),
        PopupMenuItem(
          child: Text("Kessel")
        ),
        PopupMenuItem(
          child: Text("Coruscant Shift")
        ),
      ],
      text: "Host Game",
    );
  }
}

class SimpleTextDropdownW extends StatelessWidget {
  final List<PopupMenuEntry<dynamic>> Function(BuildContext) _itemBuilder;
  final String _text;
  const SimpleTextDropdownW({
    required List<PopupMenuEntry<dynamic>> Function(BuildContext) itemBuilder,
    required String text,
    super.key
  })
  : _itemBuilder = itemBuilder, _text = text;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: _itemBuilder,
      style: TextButton(onPressed: (){}, child: Text("")).defaultStyleOf(context),
      icon: Row(
        children: [
          Text(_text),
          Icon(Icons.arrow_drop_down)
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
  const SimpleTextFieldW({
    String? hint,
    TextEditingController? controller,
    bool obscureText = false,
    super.key
  })
  : _hint = hint, _controller = controller, _obscureText = obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
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
                HostGameDropdownW(),
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
