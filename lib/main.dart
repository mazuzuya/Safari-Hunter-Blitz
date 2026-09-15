import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/safari_game.dart';
import 'game/hud.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xff17382f)),
      home: const GameRoot(),
    );
  }
}

class GameRoot extends StatefulWidget {
  const GameRoot({super.key});

  @override
  State<GameRoot> createState() => _GameRootState();
}

class _GameRootState extends State<GameRoot> {
  late final SafariController controller;
  late final SafariGame game;

  @override
  void initState() {
    super.initState();
    controller = SafariController();
    game = SafariGame(controller);
  }

  @override
  void dispose() {
    game.audio.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              final p = game.convertGlobalToLocalCoordinate(Vector2(event.position.dx, event.position.dy));
              game.handleTap(p.x, p.y);
            },
            child: GameWidget(
              game: game,
              loadingBuilder: (_) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/logo.png', width: 220, height: 220),
                    const SizedBox(height: 18),
                    const Text('Memuat...', style: TextStyle(color: Color(0xfffff9db), fontSize: 18)),
                  ],
                ),
              ),
              errorBuilder: (context, error) => Center(
                child: Text('Gagal memuat aset:\n$error', style: const TextStyle(color: Color(0xffff8e72)), textAlign: TextAlign.center),
              ),
            ),
          ),
          HudOverlay(game),
        ],
      ),
    );
  }
}
