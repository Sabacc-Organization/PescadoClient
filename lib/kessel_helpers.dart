import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'utils.dart';

class KesselGameUpdateProvider extends ChangeNotifier {
  KesselGameUpdateProvider(this.game, this.myId);
  KesselGame game;
  int myId;
}

enum KesselSuit {
  blood,
  sand;
}

enum KesselShiftToken {
  freeDraw,
  refund,
  extraRefund,
  embezzlement,
  majorFraud,
  generalTariff,
  targetTariff,
  generalAudit,
  targetAudit,
  immunity,
  exhaustion,
  directTransaction,
  embargo,
  markdown,
  cookTheBooks,
  primeSabacc;

  String getCardId(){
    return "$name.png";
  }
}

class KesselSettings {
  KesselSettings({
    this.startingChips = 8,
    this.playersChooseShiftTokens = false
  });

  int startingChips;
  bool playersChooseShiftTokens;
}

class KesselCard {
  const KesselCard({required this.suit, required this.value}) : assert(-1 <= value && value <= 7);

  final KesselSuit suit;
  final int value;

  String getCardId(){
    String num = value.toString();
    if (value == -1){
      num = "back";
    } else if (value == 0){
      num = "sylop";
    } else if (value == 7){
      num = "imposter";
    }

    return "${num}_${suit.name}.png";
  }
}

class KesselPlayer {
  KesselPlayer({
    required this.id,
    required this.username,
    pfp,
    required this.lastAction,
    required this.chips,
    required this.usedChips,
    required this.shiftTokens,
    required this.outOfGame,
    required this.bloodCard,
    required this.sandCard,
    this.extraCard
  });

  int id;
  String username;
  Widget? pfp;

  String lastAction;
  int chips;
  int usedChips;
  List<KesselShiftToken> shiftTokens;
  bool outOfGame;

  KesselCard bloodCard;
  KesselCard sandCard;
  KesselCard? extraCard;

  Widget getPfp(){
    return pfp?? SvgPicture.asset("lib/static/img/sabacc.svg");
  }
}

class KesselGame {
  KesselGame({
    required this.id,
    required this.players,
    required this.playerTurn,
    required this.lastAction,
    required this.phase,
    required this.dice,
    required this.bloodDeck,
    required this.sandDeck,
    required this.activeShiftTokens,
    required this.cycleCount,
    required this.completed,
    required this.settings,
    required this.createdAt
  });

  int id;
  List<KesselPlayer> players;
  int playerTurn; // their id
  String lastAction;
  String phase;
  Pair<int, int> dice;
  KesselCard bloodDeck;
  KesselCard sandDeck;
  List<KesselShiftToken> activeShiftTokens;
  int cycleCount;
  bool completed;
  KesselSettings settings;
  DateTime createdAt;

  static KesselGame example(){
    return KesselGame(
      id: 1,
      players: [
        KesselPlayer(
          id: 1,
          username: "PaiShoFish49",
          lastAction: "Draws from sand discard and keeps new card.",
          chips: 7,
          usedChips: 1,
          shiftTokens: [KesselShiftToken.embargo, KesselShiftToken.immunity],
          outOfGame: false,
          bloodCard: KesselCard(suit: KesselSuit.blood, value: 1),
          sandCard: KesselCard(suit: KesselSuit.sand, value: 7)
        ),
        KesselPlayer(
          id: 2,
          username: "Heinoushare",
          lastAction: "Stands",
          chips: 8,
          usedChips: 0,
          shiftTokens: [KesselShiftToken.cookTheBooks, KesselShiftToken.refund],
          outOfGame: false,
          bloodCard: KesselCard(suit: KesselSuit.blood, value: -1),
          sandCard: KesselCard(suit: KesselSuit.sand, value: -1)
        ),
        KesselPlayer(
          id: 3,
          username: "bob",
          lastAction: "Draws from blood discard and keeps new card.",
          chips: 7,
          usedChips: 1,
          shiftTokens: [KesselShiftToken.embargo, KesselShiftToken.immunity],
          outOfGame: false,
          bloodCard: KesselCard(suit: KesselSuit.blood, value: -1),
          sandCard: KesselCard(suit: KesselSuit.sand, value: -1)
        )
      ],
      playerTurn: 2,
      lastAction: "Draws from sand discard and keeps new card.",
      phase: "draw",
      dice: Pair(2, 4),
      bloodDeck: KesselCard(suit: KesselSuit.blood, value: 4),
      sandDeck: KesselCard(suit: KesselSuit.sand, value: 5),
      activeShiftTokens: [KesselShiftToken.cookTheBooks],
      cycleCount: 1,
      completed: false,
      settings: KesselSettings(),
      createdAt: DateTime(2025, 7, 7, 19, 28)
    );
  }
}