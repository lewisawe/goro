# goro

A physics tower-stacking game where your height is a narrated journey past real-world landmarks, and the only way to save a collapsing tower is a set of physical "site tools" you buy or unlock through RevenueCat.

Built for the [RevenueCat Shipaton 2026](https://revenuecat-shipaton-2026.devpost.com) — Next Gen Award (student track).

## What makes it different

Most stacking games answer "how high can you go?" with a number and a leaderboard. goro does two things almost no stacker does:

1. **Height as narrative.** Altitude maps to a ladder of real landmarks. Cross a threshold and a card reveals it (Statue of Liberty, Eiffel Tower, Burj Khalifa, the cloud layer, Everest, the Kármán line, orbit), with the world visibly transforming — the city skyline fades, clouds pass, and the sky inverts to a starfield in space.
2. **Diegetic monetization.** The fail state is a decision, not a dead end. "Site tools" are physical interventions in the physics simulation (steady the crane, weld a bad drop, catch a collapse) sold as RevenueCat consumables, plus an Architect Pass subscription. The purchase arrives at the moment of highest tension and deepens the game instead of interrupting it.

## Tech stack

- **Flutter** (Android target)
- **Flame** — 2D game engine
- **flame_forge2d** — Box2D physics
- **purchases_flutter** — RevenueCat SDK (in-app purchases + entitlements)

## Getting started

See [SETUP.md](SETUP.md) for installing Flutter and the Android SDK on Linux, then:

```bash
flutter pub get
flutter run
```

## Project docs

- `../goro-spec.md` — full project specification
- `../goro-hud-mockup.html` — visual/HUD reference
- `../idea-scorecard.md` — idea validation

## License

MIT — see [LICENSE](LICENSE).
