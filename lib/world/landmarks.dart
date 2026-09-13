/// Altitude-band definitions and the real-world landmark ladder.
/// Height as narrative (see goro-spec.md §3.2).
library;

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

/// A real landmark on the height ladder. [heightM] is its real-world height.
class Landmark {
  const Landmark(this.name, this.heightM, this.fact);
  final String name;
  final double heightM;
  final String fact;
}

/// v1 landmark ladder — mixed, memorable, spans the whole climb.
const landmarkLadder = <Landmark>[
  Landmark('Statue of Liberty', 93,
      'From ground to torch, Lady Liberty stands about 93 meters.'),
  Landmark('Eiffel Tower', 330,
      'The Eiffel Tower reaches 330 m including its antennas.'),
  Landmark('Burj Khalifa', 828,
      "The world's tallest building tops out at 828 m."),
  Landmark('Cloud layer', 2000,
      'Low cumulus clouds typically form around 2 km up.'),
  Landmark('Mount Everest', 8849,
      "Earth's highest peak reaches 8,849 m above sea level."),
  Landmark('Kármán line', 100000,
      'At 100 km, you have officially reached the edge of space.'),
  Landmark('Low orbit', 400000,
      'The ISS orbits at roughly 400 km. You are in space.'),
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
