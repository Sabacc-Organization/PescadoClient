import 'dart:math';

import 'package:flutter/material.dart';
import 'general_gui.dart';
import 'kessel_helpers.dart';

class KesselGamePage extends StatelessWidget {
  const KesselGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SabaccAppBarW(),
      body: Container(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: SabaccGameBoardW()
            ),
            Expanded(
              flex: 3,
              child: SabaccGameInfoPanelW()
            ),
          ],
        ),
      ),
    );
  }
}

class KesselPlayerW extends StatefulWidget {
  const KesselPlayerW({super.key, required this.player});
  final KesselPlayer player;

  @override
  State<KesselPlayerW> createState() => _KesselPlayerWState();
}

class _KesselPlayerWState extends State<KesselPlayerW> {
  @override
  Widget build(BuildContext context) {
    int numOfCards = widget.player.extraCard == null? 2 : 3;
    Widget pfp = widget.player.getPfp();
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.shrink(
            child: OverflowBox(
              minHeight: 0,
              minWidth: 0,
              maxHeight: double.infinity,
              maxWidth: double.infinity,
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: [
                  ...List.generate(numOfCards, (i) {
                    KesselCard card = [widget.player.bloodCard, ?widget.player.extraCard, widget.player.sandCard][i];
                    return Transform.translate(
                      offset: Offset(0, 70),
                      child: Transform.rotate(
                        angle: ((40 * i - ((40 * (numOfCards - 1)) / 2)) * pi / 180),
                        child: Transform.translate(
                          offset: Offset(0, -80),
                          child:  SizedBox(
                            width: 60,
                            child: KesselCardW(card: card)
                          ),
                        ),
                      ),
                    );
                  }),
                ]
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: ColorScheme.of(context).surfaceContainerLow,),
            padding: EdgeInsets.all(15),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(child: SizedBox(width: 25, height: 25, child: pfp)),
                  SizedBox(width: 10),
                  SelectableText(widget.player.username, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14))
                ]
              ),
            ),
          )
        ],
      ),
    );
  }
}

class KesselCardW extends StatefulWidget {
  const KesselCardW({super.key, required this.card});
  final KesselCard card;

  @override
  State<KesselCardW> createState() => _KesselCardWState();
}

class _KesselCardWState extends State<KesselCardW> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("hello");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
          print("hi");
        },
      child: Container(
        height: 50,
        width: 50,
        color: Colors.blue,
        child: Image.asset("lib/static/img/cards/kessel/pescado/cards/${widget.card.getCardId()}"),
      ),
    );
  }
}