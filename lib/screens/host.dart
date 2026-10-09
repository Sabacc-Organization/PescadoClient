import 'dart:convert';
import 'package:PescadoClient/general_gui.dart';
import 'package:PescadoClient/main.dart';
import 'package:PescadoClient/network/connection.dart';
import 'package:PescadoClient/screens/page_template.dart';
import 'package:PescadoClient/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class SettingsWInterface extends Widget {
  const SettingsWInterface({super.key});

  Map<String, dynamic> asJsonable() {
    return {};
  }
}

class TraditionalSettingsW extends StatefulWidget implements SettingsWInterface {
  const TraditionalSettingsW({super.key});

  @override
  Map<String, dynamic> asJsonable() {
    return {};
  }

  @override
  State<TraditionalSettingsW> createState() => _TraditionalSettingsWState();
}

class _TraditionalSettingsWState extends State<TraditionalSettingsW> {
  final _startingCredits = TextEditingController();
  final _handPotAnte = TextEditingController();
  final _sabaccPotAnte = TextEditingController();
  final _smallBlind = TextEditingController();
  final _bigBlind = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleCardW(
      child: Column(
        children: [
          
        ],
      )
    );
  }
}

class HostPage extends StatefulWidget {

  const HostPage({super.key});

  @override
  State<HostPage> createState() => _HostPageState();
}

// esther is at the Johnson's doing a sale
class _HostPageState extends State<HostPage> {
  List<TextEditingController> _players = [TextEditingController()];
  final TextEditingController _variantController = TextEditingController();
  GameVariant _variant = GameVariant.traditional;

  String? _errorMessage;

  void playerUpdateCallback() {
    int i = 0;
    while (i < _players.length) {
      if (_players[i].text.isEmpty && i + 1 < _players.length) {
        _players.removeAt(i);
      } else {
        if (i + 1 >= _players.length && _players.length < 8 && _players[i].text.isNotEmpty) {
          _players.add(TextEditingController());
          _players[_players.length - 1].addListener(playerUpdateCallback);
        }
        i++;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _players[0].addListener(playerUpdateCallback);
  }

  @override
  Widget build(BuildContext context) {
    SettingsWInterface settings;

    var appwideData = AppwideDataProvider.from(context);
    return PageTemplateW(
      child: Center(
        child: SimpleCardW(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              DropdownMenu(
                selectOnly: true,
                controller: _variantController,
                initialSelection: GameVariant.traditional,
                onSelected: (value) {
                  setState(() {
                    _variant = value!;
                  });
                },
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  constraints: BoxConstraints.tight(const Size.fromHeight(40)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: GameVariant.traditional, label: "Traditional"),
                  DropdownMenuEntry(value: GameVariant.corellianSpike, label: "Corellian Spike"),
                  DropdownMenuEntry(value: GameVariant.kessel, label: "Kessel"),
                ]
              ),
              ...List.generate(_players.length, (index) =>
                SimpleTextFieldW(hint: "username", controller: _players[index],)
              ),
              if (_errorMessage != null) SelectableText(
                _errorMessage?? "",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              SelectableText("", style: Theme.of(context).textTheme.headlineSmall,),

              SimpleTextButtonW(
                onClick: () {
                  SabaccConnectionManager.host(
                    context,
                    username: appwideData.username,
                    password: appwideData.password,
                    players: _players.map((player) =>
                      player.text
                    ).toList(),
                    variant: _variant,
                    callback: (res) {
                      if (200 <= res.statusCode && res.statusCode < 300) {
                        try {
                          Map<String, String> resJson = cast<Map<String, dynamic>>(jsonDecode(res.body))!.cast<String, String>();
                          context.go(resJson["redirect"]!);
                        } on FormatException {
                          _errorMessage = "There was an error. Please try again later.";
                        }
                      } else {
                        var message = "There was an error. Please try again later.";
                        try {
                          message = (json.decode(res.body) as Map<String, dynamic>)["message"];
                        } on FormatException {
                          message += " The server may be down currently.";
                        }
                        setState(() {
                          _errorMessage = message;
                        });
                      }
                    }
                  );
                },
                text: "Host!"
              ),
            ],
          ),
        ),
      )
    );
  }
}