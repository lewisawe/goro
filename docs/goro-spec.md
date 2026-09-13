# goro — Project Spec (RevenueCat Shipaton 2026, Next Gen Award)

> Author: [you] · Date: 2026-09-13 · Deadline: 2026-09-30 23:45 PDT (~17 days)
> Track: Next Gen Award (student, video + open-source repo, no store publish)
> Companion docs: `goro.md` (original concept), `idea-scorecard.md` (validation)

---

## 1. One sentence

goro is a physics tower-stacking game where your height is a narrated journey past real-world landmarks, and the only way to save a collapsing tower is a set of physical "site tools" you buy or unlock through RevenueCat.

## 2. Why this exists (the problem with every other stacker)

Every stacking game answers "how high can you go?" with a number and a leaderboard. The mechanic is saturated (see `idea-scorecard.md`: 5+ open-source clones, dozens of store apps). Two things are almost never done:

1. **Height as narrative.** No stacker turns altitude into a felt journey — passing the Statue of Liberty's torch, breaking the cloud layer, entering the stratosphere — with the world visibly transforming around the tower.
2. **Diegetic monetization.** Stackers bolt on generic "remove ads" or coin packs. None make the purchase *a physical action inside the game's fiction*.

goro does both, and the two twists are the same idea as the RevenueCat integration, so one feature serves multiple judging criteria.

## 3. Core design

### 3.1 The loop
- A crane swings a floor slab left↔right across the top of the screen.
- Tap / space to drop. The slab falls under real physics (Forge2D/Box2D).
- Off-center drops shift the tower's center of mass; it leans, sways, and can topple.
- Survive the drop → crane returns with the next slab, one floor higher.
- The camera rises with the tower; a live altitude readout climbs in meters + floors.

### 3.2 The narrative layer (unique #1)
- Altitude maps to a curated ladder of **real landmarks**. Crossing a threshold slides in a card: the landmark silhouette, its real height, one true fact, and your delta ("you just passed the Eiffel Tower's second floor — 115 m").
- The **world transforms by altitude band**: street level → city skyline → low clouds → high clouds → stratosphere (sky darkens, stars appear) → space. Background art + palette + ambient sound shift per band.
- This is the emotional spine and the thing the demo video opens on.

### 3.3 Site tools (unique #2 + the RevenueCat economy)
The fail state is not a dead end — it's a decision. When the tower is about to topple, or preemptively, the player can deploy a **site tool**. Each tool is a physical intervention in the simulation:

| Tool | Physics effect | RevenueCat product type |
|------|----------------|-------------------------|
| Steadying Cable | Damps crane sway for the next 3 drops | Consumable |
| Quick-Dry Cement | Fuses the last slab to the one below (welds a bad drop) | Consumable |
| Counterweight | One-time auto-correct of tower lean | Consumable |
| Safety Net (Revive) | Catch a collapsing tower once, resume from last stable floor | Consumable (the money beat) |
| Architect Pass | All tools discounted + exclusive slab/crane skins + landmark "expedition" sets | Subscription (entitlement) |
| Remove Ads | Removes interstitials (free tier shows them between runs) | Non-consumable |

Design rule: tools are **assistive, never pay-to-win in a competitive sense** — they change *your* run, not others' scores. This is what makes the monetization "an experience users don't hate" (a judged phrase).

### 3.4 Retention hooks (light, optional)
- Daily landmark challenge ("reach the Burj Khalifa today").
- Local best-height streak.
- Global leaderboard is a **stretch goal only** (needs backend). Not required for Next Gen.

## 4. Monetization strategy (maps to judging criterion #3)

**Primary: RevenueCat in-app purchases.** All tools and the Architect Pass are RevenueCat products behind entitlements/offerings. Consumables (tools) and a subscription (Architect Pass) show a *diverse* revenue mix, which the HAMM criteria explicitly reward.

**Secondary (optional, adds a story): RevenueCat Ads.** The free tier can show an interstitial between runs, and "Safety Net" can offer "watch a RevenueCat Ad to revive OR buy" — a clean, contextual placement that also opens the door to the Catvertising angle. Keep this optional; lead with IAP.

**Why it fits the genre:** the purchase is a physical tool you use mid-drop, not a paywall gate. It arrives at the exact moment of need (tower wobbling), which is the highest-intent moment in the loop.

**Judge-facing framing (for the submission text):** "goro monetizes the moment of tension. Site tools are RevenueCat consumables that intervene in the physics; the Architect Pass is a RevenueCat subscription entitlement. Monetization is diegetic — it lives inside the fiction of building — so it deepens the experience instead of interrupting it."

## 4b. Art direction (locked)

Reference: minimalist architectural / blueprint aesthetic. Off-white ground, thin line work, muted slate slabs, one teal accent for the "steady" state. Editorial and restrained, not cartoony. This look is cheaper to execute well (line work + flat fills + one accent) and directly serves the RevenueCat Design Award.

### Color tokens
```
--bg           #F7F8F9   off-white ground
--bg-alt       #FFFFFF   cards / slab face highlight
--line         #1F2933   near-black line work (crane, outlines, ticks)
--line-soft    #C7CDD4   faint rules, skyline, altitude ticks
--slab         #8A94A6   floor body (slate-blue-gray)
--slab-shade   #6B7280   slab top-face / side shading (isometric hint)
--slab-window  #E8EBEE   window rectangles on floors
--accent       #0F9D8A   teal — "STEADY" state, positive stability only
--warn         #E0A458   amber — stability drifting (pre-topple)
--danger       #D0555B   red — critical lean / collapse imminent
--text-strong  #1F2933   HEIGHT number, primary readouts
--text-muted   #8A94A6   labels (HEIGHT, FLOORS, STEADY)
```
Accent discipline: teal appears ONLY for stability-positive state and the one primary CTA. Amber/red are reserved for the stability meter degrading. Everything else is monochrome.

### Typography
- Labels + numerics: **JetBrains Mono** (technical, matches the reference's measured look). HEIGHT value is large/bold; labels are small caps, letter-spaced, muted.
- No serif display needed — keep it mono + clean for the mechanical feel.

### Line + shape rules
- `border-radius: 0` on slabs and HUD (sharp, drafting feel). Crane is pure 1–2px line.
- No shadows. Depth comes from the slab top-face shade only (subtle isometric), not drop shadows.
- Dotted vertical guide line shows the crane's drop path.
- Faint altitude ruler with tick marks + numeric markers up one edge.

### Altitude-band visual progression (monochrome-preserving)
The world transforms by band, but stays in the same restrained language — the skyline fades and the palette cools as you rise; teal stays constant as the one anchor.
| Band | Approx altitude | Background | Palette shift |
|------|-----------------|------------|---------------|
| Street | 0–50 m | faint city skyline (`--line-soft`) | base off-white |
| City | 50–300 m | skyline thins, drifts below | unchanged |
| Low cloud | 300–2000 m | soft horizontal cloud rules | bg lightens slightly |
| High cloud | 2–8 km | sparse clouds, horizon curve hint | cooler grays |
| Stratosphere | 8–100 km | bg darkens toward slate, first stars | inverted: dark bg, light line work |
| Space | 100 km+ | near-black, star field, Earth curve | dark mode, slabs glow faintly |

Note the stratosphere/space bands intentionally invert to a dark ground — a satisfying visual payoff for climbing, and an easy "wow" beat for the demo video.

### Portrait adaptation
The reference is a wide web layout; the Android target is portrait. Mockup: `goro-hud-mockup.html` (open in a browser). Composition: HUD readout top-left, stability meter top-right, crane in the upper third, tower rising through the vertical center, credit/footer omitted in-app.

## 5. Technical architecture

### 5.1 Stack (verified current, 2026)
- **Flutter** — single codebase, target Android (build/run in emulator + device; no store publish needed for Next Gen).
- **Flame** — 2D game engine (game loop, components, camera, input). `flutter.dev/games`, `docs.flame-engine.org`.
- **flame_forge2d** — Box2D v3 physics via Forge2D for slab dynamics, lean, collapse. `pub.dev/packages/flame_forge2d`.
- **purchases_flutter** — official RevenueCat Flutter SDK; wraps Play Billing + StoreKit + RevenueCat backend. `pub.dev/packages/purchases_flutter`. 2026 codelab: `revenuecat.github.io/codelabs/flutter.html`.

### 5.2 Module layout (target)
```
lib/
  main.dart                 # app entry, RevenueCat Purchases.configure()
  game/
    goro_game.dart          # FlameGame + Forge2D world
    crane.dart              # swinging crane + slab spawn/drop
    slab.dart               # physics body, welding logic
    tower.dart              # stack state, lean/collapse detection
    camera_rig.dart         # altitude-follow camera
    altitude.dart           # meters<->floors, band thresholds
  world/
    landmarks.dart          # landmark ladder data (height, fact, art key)
    bands.dart              # altitude-band backgrounds/palette/audio
  economy/
    products.dart           # RevenueCat product/entitlement IDs
    purchases_service.dart  # configure, getOfferings, purchase, restore
    tools.dart              # site-tool effects applied to the sim
  ui/
    hud.dart                # altitude readout, tool buttons
    landmark_card.dart      # slide-in landmark reveal
    paywall.dart            # tool store + Architect Pass
    game_over.dart          # revive decision screen
assets/
  art/ ...                  # slab/crane skins, band backgrounds, landmark silhouettes
  audio/ ...
```

### 5.3 RevenueCat integration points
- `Purchases.configure(PurchasesConfiguration(apiKey))` at startup.
- `Purchases.getOfferings()` to fetch tool packages + Architect Pass.
- `Purchases.purchase(package)` on tool buy / revive.
- `CustomerInfo.entitlements.active` to gate Architect Pass perks + Remove Ads.
- Sandbox / test purchases are sufficient for judging (no real charges, no publish).
- Progress also unlocks **Ship Kit** perks (registration → RC project created → first test purchase → first Store API call), so wiring RC early has a side benefit.

### 5.4 What is NOT reused
The open-source stack clones exist and are open source, but the repo is judged as original work. Reuse is limited to the engines (Flame, Forge2D) and standard patterns. All goro-specific code (narrative layer, tool economy, art) is written fresh.

## 6. Submission deliverables (Next Gen, verified against /rules)

- [ ] Working Android app using RevenueCat SDK for ≥1 IAP (or RevenueCat Ads).
- [ ] Public open-source repo with a detectable OSS license file (visible in the About section).
- [ ] Text description of features.
- [ ] Demo video < 2:00 on YouTube/Vimeo, shows the app running on device, no unlicensed music/marks.
- [ ] 1024×1024 app icon.
- [ ] ≥1 screenshot at 1179×2556, no device frame.
- [ ] For Best Game eligibility (optional secondary category): description of gameplay, art direction, monetization fit.
- Exemptions confirmed for Next Gen: no store URL, no promo code, no free-trial requirement, no store-download testing.

## 7. Judging-criteria map (Next Gen)

| Criterion | How goro answers it |
|-----------|---------------------|
| 1. Clear/original/interesting idea | Height-as-narrative + diegetic tool economy; neither found in clones |
| 2. Meaningful progress toward working app | Fully client-side; a real playable core is achievable in the time box |
| 3. Thoughtful RevenueCat use | Consumables (tools) + subscription (Architect Pass) + optional RC Ads; purchase at moment of highest intent |
| 4. Technical + product craft | Real Box2D physics, altitude-band art transformation (monochrome → dark-mode space payoff), polished slide-in landmark cards, disciplined blueprint art direction |

### Secondary target: RevenueCat Design Award
The locked art direction (§4b) is deliberately Design-Award-shaped: restrained blueprint aesthetic, sharp zero-radius slabs, a single teal accent used only for meaning (stability), and an altitude-band transformation that inverts to a dark starfield in space. For the submission's Design Award blurb, point judges at: the band inversion moment, the stability-meter color logic, and the slide-in landmark cards.

## 8. 17-day build plan

Dates from 2026-09-13 to 2026-09-30. Buffer built into the last two days. #BuildInPublic posts optional but free extra exposure — tag #Shipaton.

**Phase 0 — setup (Day 1, Sep 13–14)**
- Register on Devpost, create RevenueCat project (unlocks Ship Kit), init Flutter repo with OSS license (MIT) committed on day one.
- Add flame, flame_forge2d, purchases_flutter. Confirm a blank Flame + Forge2D scene runs on device.

**Phase 1 — core loop (Days 2–5)**
- Swinging crane, slab spawn, drop on tap.
- Forge2D bodies, stacking, lean + collapse detection, game-over trigger.
- Altitude-follow camera + live meter/floor readout.
- Exit criteria: you can stack a real, physics-driven tower until it falls.

**Phase 2 — narrative layer (Days 6–8)**
- Landmark ladder data + slide-in landmark card on threshold cross.
- Altitude bands: background + palette (+ simple ambient audio) shift by band.
- Exit criteria: climbing visibly changes the world and surfaces real landmarks.

**Phase 3 — RevenueCat economy (Days 9–12)**
- Configure Purchases, define offerings (tool consumables, Architect Pass subscription, Remove Ads).
- Wire each tool's physics effect to a successful purchase; entitlement gating for Architect Pass.
- Safety Net revive screen (buy / optional watch-RC-Ad).
- Test in sandbox; hit the "first test purchase" + "first Store API call" Ship Kit milestones.
- Exit criteria: a sandbox purchase changes the simulation live.

**Phase 4 — polish + art direction (Days 13–15)**
- Slab/crane skins, band art pass, landmark silhouettes, HUD, paywall UI, game-over UI.
- Sound, haptics on drop, screen-shake on collapse. Reduced-motion respect.
- Exit criteria: it looks and feels like a finished small game.

**Phase 5 — submission assets + buffer (Days 16–17, Sep 29–30)**
- Record + edit < 2:00 demo (open on landmark reveal, then the revive purchase beat).
- 1024×1024 icon, 1179×2556 screenshot (no frame).
- README with run instructions, license visible in About, text description, Best Game blurb.
- Submit on Devpost before 23:45 PDT Sep 30. Do not leave submission to the final hour.

## 9. Risks and mitigations

| Risk | Mitigation |
|------|------------|
| Reads as "just another stacker" in first 5s of video | Open video on landmark/cloud-break reveal, not the crane |
| Forge2D stacking instability eats time | Timebox tuning; fall back to simpler constrained physics if collapse detection is flaky |
| RevenueCat sandbox setup friction | Do it in Phase 0–3 early, not at the end; follow the 2026 Flutter codelab |
| Scope creep (leaderboard/backend) | Global leaderboard is explicitly stretch-only; cut first if time slips |
| Art takes longer than code | Use a tight, limited palette per band; silhouettes over detailed art |

## 10. Cut list (if time slips, drop in this order)

1. Global leaderboard / backend (already stretch)
2. RevenueCat Ads secondary integration (keep IAP)
3. Ambient audio per band (keep visual transform)
4. Number of landmarks / bands (keep ≥3 memorable ones)
Never cut: the physics core, one clean RevenueCat purchase that changes the sim, the landmark reveal, the demo video.

## 11. Open decisions before coding

1. Confirm Flutter + Flame + Forge2D as the stack (recommended). — pending your OK
2. License choice for the repo (MIT recommended, permissive + judge-friendly).
3. Landmark set for v1 (suggest a mixed ladder: Statue of Liberty → Eiffel → Burj Khalifa → cloud layer → Everest → Kármán line → orbit).

## 12. Tuning backlog (revisit)

- **Difficulty too easy** (noted 2026-09-13 after Phase 1). Options: narrower slabs, stricter lean/drift collapse thresholds, faster/wider crane swing, or slabs that must overlap the one below by a minimum. Revisit after visuals.
  - Update: difficulty pass applied (collapse at ~20° / 6m drift, earlier stability warnings, slabs 4.2). Awaiting play verdict.

## 13. Feature roadmap — "top tier & addictive"

Goal: take goro from a clean tech demo to something someone plays all day. The clean blueprint aesthetic stays (it's the Design Award angle); we add *feel*, a *compulsion loop*, *retention*, and *craft* — not visual clutter. Batches are ordered by impact so that if time slips, what's cut is least important. We build toward all of it.

Status legend: [ ] todo · [~] in progress · [x] done

### Batch A — Core feel (makes it addictive) [ ]
The backbone. Every other effect hangs off the perfect-drop mechanic.
- [ ] **Perfect-drop mechanic**: landing a slab near-perfectly aligned snaps it into place, flashes, and does NOT add lean. Turns random tapping into a skill to master.
- [ ] **Combo / streak scoring**: consecutive perfects build a multiplier; a streak straightens the tower and grants bonus height. Score is combo-driven, not just height.
- [ ] **Haptics**: buzz on every drop, stronger buzz on a perfect (Flutter built-in, no assets).
- [ ] **Screen shake**: small (2–4px) on heavy/off-center landings.
- [ ] **Sound**: clean thunk on landing, rising-pitch perfect chime, altitude-scaling ambient wind. (Needs licensed SFX files.)
- [ ] **Slab settle animation**: quick squash/settle instead of an abrupt stop.
- [ ] **Instant restart**: death → immediate retry, no menu. The "one more run" loop.
- [ ] **Personal-best line**: faint marker at your best height as a per-run target.

### Batch B — Polish (fixes "too simple") [ ]
More craft on what's there, not more stuff.
- [ ] **Line-art crane**: replace the plain triangle with a proper crane (hook, subtle idle sway, cable that reacts on release).
- [ ] **Parallax**: skyline and clouds scroll at different speeds as the tower rises → depth.
- [ ] **Varied slabs**: different window patterns, occasional rooftop detail (antenna, water tower) so the tower feels built, not cloned.
- [ ] **Landmark-for-scale moment**: when passing a landmark, briefly show its silhouette next to the tower for scale (the "wow" that sells the concept).
- [ ] **Particles**: dust puff on landing, sparkle on a perfect.
- [ ] **Landmark cards as achievements**: small celebration, not just an info card.

### Batch C — Retention (reasons to come back) [ ]
These double as the monetization surface (see Batch D).
- [ ] **Daily challenge**: one seeded tower per day (same crane rhythm for everyone), compare scores.
- [ ] **Streaks**: "N-day building streak" with loss-aversion nudge.
- [ ] **Cosmetic skins**: crane skins, slab materials (glass, concrete, gold), background themes.
- [ ] **Local leaderboard / share card**: auto-generated blueprint image of the final tower + highest landmark passed, built to post.

### Batch D — RevenueCat (Phase 3, rides on Batch C) [ ]
Monetization = the retention features behind entitlements. Requires the RevenueCat project + Android API key (into gitignored secrets.dart).
- [ ] **Site tools** (consumables): Steadying Cable, Quick-Dry Cement, Counterweight, Safety Net (revive).
- [ ] **Safety Net revive** on the COLLAPSE screen (the money beat: pay or watch a RevenueCat Ad to revive).
- [ ] **Architect Pass** (subscription): all skins + daily-challenge access + no ads + discounted tools.
- [ ] **Remove Ads** (non-consumable).
- [ ] Sandbox purchases wired and demoable (sufficient for Next Gen judging).

### Then — Submission [ ]
- [ ] < 2:00 demo video (open on landmark reveal + space inversion, then the revive paywall).
- [ ] 1024×1024 icon, 1179×2556 screenshot (no frame).
- [ ] README + run instructions, MIT license visible in About, text description, Best Game blurb.
- [ ] Submit on Devpost before 2026-09-30 23:45 PDT.

### Batch E — Nice to have (stretch, only if A–D + submission are done) [ ]
Time-sensitive extras. Build ONLY after the core game, retention, RevenueCat, and submission assets are complete. None of these are required to win; each is a bonus that could lift a specific award. Cut without hesitation if time is short.
- [ ] **Global leaderboard / shared persistent tower** (needs a backend, e.g. Firebase free tier). Biggest virality upside, biggest build cost. First to cut.
- [ ] **RevenueCat Ads integration** (rewarded ad to revive alongside the paid option) → could contend for the Catvertising Award. Optional on top of IAP.
- [ ] **OneSignal push** (e.g. "your daily tower is ready", streak reminder) → OneSignal "Keep Them Coming Back" award. Only if retention/daily is solid.
- [ ] **#BuildInPublic posts** during the window (tag #Shipaton) → separate award, low effort, can run in parallel any time.
- [ ] **Extra cosmetic packs / seasonal themes** beyond the base set.
- [ ] **Reduced-motion + dynamic-type accessibility polish** (accessibility criteria; do if time).
- [ ] **iOS build** (Next Gen doesn't need a store release; only if aiming beyond Next Gen).
- [ ] **Tutorial / first-run onboarding** (a single ghosted "tap to drop" hint; skip if the loop is self-evident).
- [ ] **Music track** (ambient, licensed) layered under the SFX.

### Judging-criteria mapping
- Batch A + B → Best Game ("fun, engaging, replayability") + Design Award (feel, animation)
- Batch B → Design Award (craft, aesthetics)
- Batch C + D → HAMM / monetization ("thoughtful RevenueCat use") + Next Gen criterion #3
- Batch E → bonus award surface (Catvertising, OneSignal, #BuildInPublic) — never at the expense of A–D
- All → Next Gen criteria #1 (compelling experience), #2 (working app), #4 (craft)
