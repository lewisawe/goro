import 'dart:math' as math;

/// Altitude-band definitions and the real-world landmark ladder.
/// Height as narrative (see goro-spec.md §3.2).

/// A visual band the world passes through as the tower climbs.
enum Band { street, city, lowCloud, highCloud, stratosphere, space }

/// Returns the band for a given altitude in meters.
Band bandForMeters(double m) {
  if (m < 50) return Band.street;
  if (m < 300) return Band.city;
  if (m < 2000) return Band.lowCloud;
  if (m < 8000) return Band.highCloud;
  if (m < 100000) return Band.stratosphere;
  return Band.space;
}

/// True once the world should invert to the dark/space palette.
bool isDarkBand(Band b) => b == Band.stratosphere || b == Band.space;

/// A continuous 0..1 "sky darkness" ramp derived from altitude, used to
/// interpolate background color, star opacity, and skyline fade. Smooth
/// (not stepped) so the world transforms gradually. Tuned so a normal
/// session (compressed altitude scale) climbs from day to space.
double skyDarkness(double m) {
  const start = 200.0; // begin darkening just above the city
  const end = 4200.0; // full space by here (~30 floors at 140m/floor)
  if (m <= start) return 0;
  if (m >= end) return 1;
  final t = (math.log(m) - math.log(start)) / (math.log(end) - math.log(start));
  return t.clamp(0.0, 1.0);
}

/// A real landmark on the height ladder. [heightM] is its real-world height.
class Landmark {
  const Landmark(this.name, this.heightM, this.fact);
  final String name;
  final double heightM;
  final String fact;
}

/// v1 landmark ladder — spread across the compressed altitude range so cards
/// fire steadily through a climb (heights are the real landmark heights;
/// the game's altitude scale is compressed so they arrive at a good cadence).
const landmarkLadder = <Landmark>[
  Landmark('Statue of Liberty', 93,
      'From ground to torch, Lady Liberty stands about 93 meters.'),
  Landmark('Eiffel Tower', 330,
      'The Eiffel Tower reaches 330 m including its antennas.'),
  Landmark('Burj Khalifa', 828,
      "The world's tallest building tops out at 828 m."),
  Landmark('Cloud layer', 1500,
      'Low cumulus clouds typically form around 1.5 km up.'),
  Landmark('Mount Everest', 2800,
      "Earth's highest peak reaches 8,849 m — you're above the clouds now."),
  Landmark('Stratosphere', 3600,
      'The air thins and the sky darkens toward black.'),
  Landmark('Kármán line', 4200,
      'At the edge of space. Officially, you have left Earth.'),
  Landmark('Low orbit', 5200,
      'Among the stars. The ISS orbits here. You are in space.'),
];

/// The highest landmark strictly below [m], or null before the first one.
Landmark? lastPassed(double m) {
  Landmark? passed;
  for (final l in landmarkLadder) {
    if (m >= l.heightM) {
      passed = l;
    } else {
      break;
    }
  }
  return passed;
}

/// The next landmark at or above [m], or null once all are passed.
Landmark? nextTarget(double m) {
  for (final l in landmarkLadder) {
    if (m < l.heightM) return l;
  }
  return null;
}
