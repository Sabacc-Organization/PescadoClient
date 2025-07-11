import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sabacc_client_1/kessel_gui.dart';
import 'package:sabacc_client_1/kessel_helpers.dart';

class SabaccAppBarW extends StatelessWidget implements PreferredSizeWidget {
  const SabaccAppBarW({super.key});

  static const inversionMatrix = <double>[
    -1, 0, 0, 0, 255,
    0, -1, 0, 0, 255,
    0, 0, -1, 0, 255,
    0, 0, 0, 1, 0,
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorScheme.of(context).surfaceContainerLow,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SvgPicture.asset("lib/static/img/sabaccMono.svg", colorFilter: ColorFilter.matrix(inversionMatrix))
        ),
      title: SelectableText("Sabacc", style: TextStyle(fontSize: 40)),
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
                Tab(child: Text("Info")),
                Tab(child: Text("Game")),
                Tab(child: Text("Players"))
              ]
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Expanded(child: Container(
                    child: SelectableText("Info Stuff"),
                  )),
                  Expanded(child: GameTab()),
                  Expanded(child: Container(
                    child: SelectableText("Player Stuff"),
                  ))
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
