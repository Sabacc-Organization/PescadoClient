import 'package:PescadoClient/network/connection.dart';
import 'package:flutter/material.dart';

class Pair<T, U> {
  Pair(this.left, this.right);
  T left;
  U right;
}

enum GameVariant {
  traditional,
  corellianSpike,
  kessel;

  @override
  String toString() {
    if (this == traditional) {
      return "Traditional";
    } else if (this == corellianSpike) {
      return "Corellian Spike";
    } else {
      return "Kessel";
    }
  }

  String slug() {
    if (this == traditional) {
      return "traditional";
    } else if (this == corellianSpike) {
      return "corellianSpike";
    } else {
      return "kessel";
    }
  }
}

class Player {
  final String username;
  final int? id;
  final DateTime? createdAt;
  const Player({required this.username, this.id, this.createdAt});

  Player copy() {
    return Player(username: username, id: id, createdAt: createdAt);
  }

  Future<Player> complete(BuildContext context) async {
    if (id != null && createdAt != null) {
      return copy();
    }
    return SabaccConnectionManager.playerLookup(context, id: id, username: username).then((player) {
      if (player == null) {
        return copy();
      }
      return player;
    });
  }

  bool equals(Player other) {
    return username == other.username;
  }
}

T? cast<T>(dynamic x) => x is T ? x : null;