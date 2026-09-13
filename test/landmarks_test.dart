import 'package:flutter_test/flutter_test.dart';
import 'package:goro/world/landmarks.dart';

void main() {
  group('bandForMeters', () {
    test('maps altitude to the correct band', () {
      expect(bandForMeters(0), Band.street);
      expect(bandForMeters(49), Band.street);
      expect(bandForMeters(50), Band.city);
      expect(bandForMeters(299), Band.city);
      expect(bandForMeters(300), Band.lowCloud);
      expect(bandForMeters(1999), Band.lowCloud);
      expect(bandForMeters(2000), Band.highCloud);
      expect(bandForMeters(7999), Band.highCloud);
      expect(bandForMeters(8000), Band.stratosphere);
      expect(bandForMeters(99999), Band.stratosphere);
      expect(bandForMeters(100000), Band.space);
    });

    test('space and stratosphere are dark bands', () {
      expect(isDarkBand(Band.street), isFalse);
      expect(isDarkBand(Band.highCloud), isFalse);
      expect(isDarkBand(Band.stratosphere), isTrue);
      expect(isDarkBand(Band.space), isTrue);
    });
  });

  group('landmark ladder', () {
    test('lastPassed returns null below the first landmark', () {
      expect(lastPassed(0), isNull);
      expect(lastPassed(92), isNull);
    });

    test('lastPassed returns the highest landmark at or below height', () {
      expect(lastPassed(93)!.name, 'Statue of Liberty');
      expect(lastPassed(500)!.name, 'Eiffel Tower');
      expect(lastPassed(1000)!.name, 'Burj Khalifa');
      expect(lastPassed(9000)!.name, 'Low orbit');
    });

    test('nextTarget points to the upcoming landmark', () {
      expect(nextTarget(0)!.name, 'Statue of Liberty');
      expect(nextTarget(100)!.name, 'Eiffel Tower');
      expect(nextTarget(9000), isNull);
    });

    test('ladder is strictly ascending by height', () {
      for (var i = 1; i < landmarkLadder.length; i++) {
        expect(landmarkLadder[i].heightM,
            greaterThan(landmarkLadder[i - 1].heightM));
      }
    });
  });
}
