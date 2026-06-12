import 'package:PescadoClient/screens/credits.dart';
import 'package:PescadoClient/screens/login.dart';
import 'package:PescadoClient/screens/player_stats.dart';
import 'package:PescadoClient/screens/preferences.dart';
import 'package:PescadoClient/screens/register.dart';
import 'package:PescadoClient/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'screens/lobby.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(SabaccApp());
}

CustomTransitionPage pageTransition(Widget child, BuildContext context, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child2) => FadeTransition(
      opacity: animation,
      child: child2,
    )
  );
}

class SabaccApp extends StatelessWidget {
  final _router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        path: "/",
        pageBuilder: (context, state) => pageTransition(LobbyPage(), context, state)
      ),
      GoRoute(
        path: "/login",
        pageBuilder: (context, state) => pageTransition(LoginPage(), context, state)
      ),
      GoRoute(
        path: "/register",
        pageBuilder: (context, state) => pageTransition(RegisterPage(), context, state)
      ),
      GoRoute(
        path: "/preferences",
        pageBuilder: (context, state) => pageTransition(PreferencesPage(), context, state)
      ),
      GoRoute(
        path: "/credits",
        pageBuilder: (context, state) => pageTransition(CreditsPage(), context, state)
      ),
      GoRoute(
        path: "/player/:username",
        pageBuilder: (context, state) => pageTransition(PlayerStatsPage(player: Player(username: state.pathParameters["username"]!)), context, state)
      ),
    ]
  );

  SabaccApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool darkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppwideDataProvider(darkMode))
      ],
      child: Builder(
        builder: (context) {
          var appwideData = AppwideDataProvider.from(context);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            themeMode: appwideData.darkMode? ThemeMode.dark : ThemeMode.light,
            darkTheme: ThemeData.dark(),
            theme: ThemeData.light(),
            title: "Pescado's Sabacc Client",
            routerConfig: _router,
            checkerboardRasterCacheImages: true,
          );
        }
      )
    );
  }
}

class AppwideDataProvider extends ChangeNotifier {
  Player? _player;
  String _password = "";
  final String _backendUrl = "sabacc.paishofish49.net:5161";
  bool _darkMode = true;
  Player? get player => _player;
  bool get loggedIn => _player != null;
  String get username => player == null? "" : player!.username;
  String get password => _password;
  String get backendUrl => _backendUrl;
  bool get darkMode => _darkMode;
  AppwideDataProvider(bool darkMode) : _darkMode = darkMode;

  static AppwideDataProvider from(BuildContext context, {bool listen = true}) {
    return Provider.of(context, listen: listen);
  }

  void setDarkMode(bool dm) {
    _darkMode = dm;
    notifyListeners();
  }
  void logIn(Player player, String password) {
    _player = player;
    _password = password;
    notifyListeners();
  }
  void logOut() {
    _player = null;
    notifyListeners();
  }
}