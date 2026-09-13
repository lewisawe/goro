import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/goro_game.dart';
import 'theme/tokens.dart';
import 'world/landmarks.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — goro is a vertical game (disable auto-rotate).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure RevenueCat here in Phase 3 (key lives in gitignored secrets.dart).

  runApp(const GoroApp());
}

class GoroApp extends StatelessWidget {
  const GoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GoroScreen(),
    );
  }
}

class GoroScreen extends StatefulWidget {
  const GoroScreen({super.key});

  @override
  State<GoroScreen> createState() => _GoroScreenState();
}

class _GoroScreenState extends State<GoroScreen> {
  late GoroGame _game;

  /// Landmark banner is transient UI, kept in a notifier so it doesn't
  /// rebuild the GameWidget either.
  final ValueNotifier<Landmark?> _banner = ValueNotifier(null);

  /// A key change forces a fresh GameWidget only on explicit restart.
  Key _gameKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _game = _buildGame();
  }

  GoroGame _buildGame() {
    return GoroGame()..onLandmarkPassed = _showLandmark;
  }

  void _showLandmark(Landmark l) {
    _banner.value = l;
    Future.delayed(const Duration(seconds: 3), () {
      if (_banner.value == l) _banner.value = null;
    });
  }

  void _restart() {
    _banner.value = null;
    setState(() {
      _game = _buildGame();
      _gameKey = UniqueKey();
    });
  }

  @override
  void dispose() {
    _banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoroColors.bg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _game.dropSlab(),
        child: Stack(
          children: [
            // The game surface is built ONCE and never rebuilt by state
            // changes — HUD/overlays listen to notifiers instead. This is
            // what removes the whole-screen stutter.
            GameWidget(key: _gameKey, game: _game),

            // HUD listens only to the stats notifier.
            ValueListenableBuilder<GoroStats>(
              valueListenable: _game.stats,
              builder: (_, s, __) => _Hud(stats: s),
            ),

            // Landmark banner
            ValueListenableBuilder<Landmark?>(
              valueListenable: _banner,
              builder: (_, l, __) =>
                  l == null ? const SizedBox.shrink() : _LandmarkCard(landmark: l),
            ),

            // Game over overlay (from stats)
            ValueListenableBuilder<GoroStats>(
              valueListenable: _game.stats,
              builder: (_, s, __) => s.gameOver
                  ? _GameOver(stats: s, onRestart: _restart)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.stats});
  final GoroStats stats;

  @override
  Widget build(BuildContext context) {
    final stability = stats.stability;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HEIGHT',
                    style: TextStyle(
                        color: GoroColors.textMuted,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${stats.heightMeters.round()}',
                        style: const TextStyle(
                            color: GoroColors.textStrong,
                            fontSize: 44,
                            height: 1,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 3),
                    const Text('m',
                        style: TextStyle(
                            color: GoroColors.textMuted,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(children: [
                  Text('${stats.floors}',
                      style: const TextStyle(
                          color: GoroColors.textStrong,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  const Text('FLOORS',
                      style: TextStyle(
                          color: GoroColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500)),
                ]),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 96,
                  height: 6,
                  color: GoroColors.lineSoft,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: switch (stability) {
                      Stability.steady => 0.38,
                      Stability.wobbling => 0.7,
                      Stability.critical => 1.0,
                    },
                    child: Container(color: stability.color),
                  ),
                ),
                const SizedBox(height: 6),
                Text(stability.label,
                    style: TextStyle(
                        color: stability.color,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LandmarkCard extends StatelessWidget {
  const _LandmarkCard({required this.landmark});
  final Landmark landmark;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 96),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: GoroColors.bgAlt,
            border: Border.all(color: GoroColors.line, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(landmark.name.toUpperCase(),
                  style: const TextStyle(
                      color: GoroColors.textStrong,
                      fontSize: 15,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${landmark.heightM.round()} m',
                  style: const TextStyle(
                      color: GoroColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              SizedBox(
                width: 240,
                child: Text(landmark.fact,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: GoroColors.textMuted, fontSize: 12, height: 1.4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameOver extends StatelessWidget {
  const _GameOver({required this.stats, required this.onRestart});
  final GoroStats stats;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: GoroColors.bg.withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('COLLAPSE',
                  style: TextStyle(
                      color: GoroColors.danger,
                      fontSize: 14,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text('${stats.heightMeters.round()} m',
                  style: const TextStyle(
                      color: GoroColors.textStrong,
                      fontSize: 56,
                      fontWeight: FontWeight.w800)),
              Text('${stats.floors} FLOORS',
                  style: const TextStyle(
                      color: GoroColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 2)),
              const SizedBox(height: 28),
              // Phase 3: RevenueCat "Safety Net" revive goes here.
              GestureDetector(
                onTap: onRestart,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  color: GoroColors.line,
                  child: const Text('REBUILD',
                      style: TextStyle(
                          color: GoroColors.bg,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
