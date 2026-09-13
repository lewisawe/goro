import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/goro_game.dart';
import 'theme/tokens.dart';
import 'world/landmarks.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure RevenueCat. The key lives in an untracked secrets file.
  // For now this is guarded so the app runs before secrets.dart exists.
  try {
    // import 'economy/secrets.dart' show revenueCatAndroidKey; (gitignored)
    // await PurchasesService.instance.configure(revenueCatAndroidKey);
  } catch (_) {
    // RevenueCat not yet configured — game still runs (Phase 0/1).
  }

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
  late final GoroGame _game;

  @override
  void initState() {
    super.initState();
    _game = GoroGame()
      ..onLandmarkPassed = _showLandmark
      ..onCollapse = _onCollapse;
  }

  void _showLandmark(Landmark l) {
    // Phase 2: replace with the slide-in landmark card.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l.name} — ${l.fact}')),
    );
  }

  void _onCollapse() {
    // Phase 3: replace with the revive decision screen (RevenueCat).
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoroColors.bg,
      body: Stack(
        children: [
          GameWidget(game: _game),
          // Phase 1: HUD overlay (height / floors / stability meter).
          const _HudPlaceholder(),
        ],
      ),
    );
  }
}

/// Placeholder HUD matching the locked tokens; real HUD lands in Phase 1.
class _HudPlaceholder extends StatelessWidget {
  const _HudPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HEIGHT',
                    style: TextStyle(
                        color: GoroColors.textMuted,
                        fontSize: 10,
                        letterSpacing: 2)),
                Text('0m',
                    style: TextStyle(
                        color: GoroColors.textStrong,
                        fontSize: 40,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            Text('STEADY',
                style: TextStyle(
                    color: GoroColors.accent,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
