# Idea Scorecard — goro (RevenueCat Shipaton 2026, Next Gen Award)

> Validated: 2026-09-13 · Brief: https://revenuecat-shipaton-2026.devpost.com · Rules: /rules (fetched) · Deadline: 2026-09-30 23:45 PDT (~17 days)
> Track: Next Gen Award (student). Distribution risk removed — video + open-source repo, no store publish.

## Context that changes scoring

Next Gen judging rewards: (1) clear/original idea, (2) meaningful progress toward a working app, (3) thoughtful RevenueCat use, (4) technical + product craft. It does NOT require downloads, revenue, or store traction. This caps the damage from a saturated genre — judges score craft and RevenueCat integration, not market novelty alone. But criterion #1 (original/interesting) still penalizes a bare stack clone.

## Candidate scorecard

| Idea | One-liner | Prior art (repos/apps) | Clone verdict | Closest competitor | Friction / hook | RevenueCat fit | Demo | Build risk | Idea (crit1) | Working core (crit2) | RC use (crit3) | Craft (crit4) | Verdict |
|------|-----------|------------------------|---------------|--------------------|-----------------|----------------|------|------------|--------------|----------------------|----------------|---------------|---------|
| goro (bare stack clone) | Crane drops slabs, stack high | Very high (5+ FOSS + dozens of store apps) | **saturated** | Stack-tower (Flutter+Flame, polished) | none unique | core (IAP) | strong | low | 2 | 4 | 4 | 3 | **CAP: weak on idea** |
| goro + landmark-scale + revive economy | Stack a tower, height mapped live to real-world landmarks; fail→revive via RevenueCat | Same base genre, but landmark+revive combo not found in FOSS | contested | Stack Tower Builder (Eiffel theme) uses landmarks cosmetically, not as core progression | "how tall did I actually build" is a real curiosity hook; revive ties monetization to fail state | core (consumable revive + cosmetic) | strong | low-medium | 4 | 4 | 5 | 4 | **BUILD** |

## Evidence log

- Bare stack clone prior art (FOSS, Flutter+Flame, directly comparable):
  - https://github.com/mdusaama0/tower_bloxx — "Tower Bloxx-style crane drop game built with Flutter and Flame"
  - https://github.com/LouweS/Stack-tower — "polished cross-platform tower-stacking game built with Flutter and Flame"
  - https://github.com/forthtemple/stacktower — Stack Tower game, Dart/Flutter
  - https://github.com/liukun2634/stack-tower-game — HTML5 canvas crane-drop, adaptive AI, procedural skins
  - https://github.com/marat50coder/TowerSurge — Flutter Android crane-drop tower
- Store saturation (published stack games, several with leaderboards/themes already):
  - https://play.google.com/store/apps/details?id=com.miranky.eiffel_tower — "Stack Tower Builder", global leaderboard + themes + landmark (Eiffel) theming
  - https://play.google.com/store/apps/details?id=com.ocakoglu.stacktower — "STACK TOWER", 100 levels + leaderboard
  - https://skystack.fun/ — SKYSTACK, global leaderboard
  - https://towerstackgame.com/ — daily challenge + worldwide leaderboard
- Next Gen rules/criteria (no store publish, video+repo, RC required): https://revenuecat-shipaton-2026.devpost.com/rules (Section 3, Submission Requirements, Next Gen Award Criteria)

## Key findings

1. The stacking mechanic is **saturated** — 5+ near-identical FOSS repos (some Flutter+Flame, the exact stack you'd use) and dozens of store apps. Copying the base loop scores low on criterion #1 and risks "I've seen this."
2. Leaderboards + themes + even landmark theming **already exist** in shipped apps. Those alone are not differentiators.
3. The defensible angle is the **combination**: real-time landmark-scale progression as the *core* feedback loop (not a cosmetic theme) + a **RevenueCat-native revive/continue economy** wired to the fail state. That combo was not found in the FOSS results and directly serves criterion #3 (thoughtful RevenueCat use).
4. Because FOSS clones exist and are open source, do **not** copy one — the repo is judged and must be original work. Reuse is limited to the engine (Flame) and standard patterns.

## Recommendation

**BUILD**, but only the differentiated version: goro where the tower's height maps live to real-world landmarks as the central progression, and the fail state opens a RevenueCat-powered choice (pay to revive / watch RevenueCat Ad to revive / cosmetic pass). Lead the 2-minute video with the landmark reveal and the revive paywall — those are the two beats that separate it from every stack clone and hit criteria #1 and #3.

**Risk to watch:** it can still read as "another stacker" in the first 5 seconds of video. Mitigation: open the video on the landmark-comparison moment, not the crane. Make the RevenueCat revive flow a visible, deliberate beat.
