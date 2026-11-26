import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/api_service.dart';

void main() {
  setUp(() {
    ApiService.baseUrl = 'http://127.0.0.1:8000/api';
  });

  test('ApiService pings Laravel backend successfully', () async {
    final ok = await ApiService.testConnection();
    expect(ok, isTrue);
  });

  test('ApiService searches real cities from backend SQLite', () async {
    final cities = await ApiService.searchCities('Shirpur', limit: 5);
    expect(cities, isNotEmpty);
    expect(cities.any((c) => c.name.toLowerCase().contains('shirpur')), isTrue);
  });

  test('ApiService calculates real Kundali from backend', () async {
    final kundali = await ApiService.calculateKundali(
      name: 'Aniket Joshi',
      date: '06-09-2000',
      time: '19:30:00',
      lat: 21.35,
      lng: 74.88,
      place: 'Shirpur, Dhule, Maharashtra',
      ayanamsha: 'lahiri',
    );

    expect(kundali.birthInfo.name, equals('Aniket Joshi'));
    expect(kundali.charts.containsKey('lagna'), isTrue);
    expect(kundali.charts.containsKey('navamsha'), isTrue);
    expect(kundali.charts.containsKey('chalit'), isTrue);
    expect(kundali.charts.containsKey('chandra'), isTrue);
    expect(kundali.planets, isNotEmpty);
    expect(kundali.mahadasha, isNotEmpty);
    expect(kundali.rawJson['success'], isTrue);
  });

  test('ApiService calculates real Gun Milan matchmaking', () async {
    final gm = await ApiService.calculateGunMilan(
      boy: {
        'name': 'Aniket',
        'date': '06-09-2000',
        'time': '19:30:00',
        'lat': 21.35,
        'lng': 74.88,
        'place': 'Shirpur',
      },
      girl: {
        'name': 'Pooja',
        'date': '15-08-2002',
        'time': '10:15:00',
        'lat': 18.52,
        'lng': 73.85,
        'place': 'Pune',
      },
      ayanamsha: 'lahiri',
    );

    expect(gm.totalMax, equals(36.0));
    expect(gm.totalObtained, greaterThan(0));
    expect(gm.gunas.length, equals(9));
    expect(gm.conclusion, isNotEmpty);
    expect(gm.boy.charts.containsKey('lagna'), isTrue);
    expect(gm.girl.charts.containsKey('lagna'), isTrue);
  });
}
