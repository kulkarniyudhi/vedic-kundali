class BirthInfo {
  final String name;
  final String date;
  final String time;
  final String day;
  final String place;
  final String state;
  final String district;
  final String coordinates;
  final double lat;
  final double lng;
  final String timezone;
  final String ishtaGhati;

  const BirthInfo({
    required this.name,
    required this.date,
    required this.time,
    required this.day,
    required this.place,
    required this.state,
    required this.district,
    required this.coordinates,
    required this.lat,
    required this.lng,
    required this.timezone,
    required this.ishtaGhati,
  });

  factory BirthInfo.fromJson(Map<String, dynamic> json) {
    return BirthInfo(
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      day: json['day'] ?? '',
      place: json['place'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      coordinates: json['coordinates'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      timezone: json['timezone'] ?? '+05:30',
      ishtaGhati: json['ishta_ghati'] is Map
          ? (json['ishta_ghati']['display'] ?? '')
          : (json['ishta_ghati'] ?? ''),
    );
  }
}

class PlanetDetail {
  final String id;
  final String name;
  final double longitude;
  final String rashi;
  final String rashiEn;
  final String degree;
  final String degreeDms;
  final String nakshatra;
  final int pada;
  final String syllable;
  final bool retrograde;
  final String retroMarker;
  final double speed;

  const PlanetDetail({
    required this.id,
    required this.name,
    required this.longitude,
    required this.rashi,
    required this.rashiEn,
    required this.degree,
    required this.degreeDms,
    required this.nakshatra,
    required this.pada,
    required this.syllable,
    required this.retrograde,
    required this.retroMarker,
    required this.speed,
  });

  factory PlanetDetail.fromJson(Map<String, dynamic> json) {
    return PlanetDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      rashi: json['rashi'] ?? '',
      rashiEn: json['rashi_en'] ?? '',
      degree: json['degree'] ?? '',
      degreeDms: json['degree_dms'] ?? json['degree'] ?? '',
      nakshatra: json['nakshatra'] ?? '',
      pada: json['pada'] ?? 1,
      syllable: json['syllable'] ?? '',
      retrograde: json['retrograde'] ?? false,
      retroMarker: json['retro_marker'] ?? '',
      speed: (json['speed'] ?? 0.0).toDouble(),
    );
  }
}

class ChartHouseData {
  final int ascendantRashi;
  final String title;
  final Map<int, List<String>> houses;

  const ChartHouseData({
    required this.ascendantRashi,
    required this.title,
    required this.houses,
  });

  factory ChartHouseData.fromJson(Map<String, dynamic> json) {
    final Map<int, List<String>> housesMap = {};
    if (json['houses'] is Map) {
      json['houses'].forEach((key, val) {
        final houseNum = int.tryParse(key.toString()) ?? 1;
        if (val is List) {
          housesMap[houseNum] = val.map((e) => e.toString()).toList();
        } else {
          housesMap[houseNum] = [];
        }
      });
    }

    return ChartHouseData(
      ascendantRashi: json['ascendant_rashi'] ?? 0,
      title: json['title'] ?? '',
      houses: housesMap,
    );
  }
}

class MahadashaPeriod {
  final String planetKey;
  final String planetName;
  final int totalYears;
  final double actualYears;
  final String startDate;
  final String endDate;

  const MahadashaPeriod({
    required this.planetKey,
    required this.planetName,
    required this.totalYears,
    required this.actualYears,
    required this.startDate,
    required this.endDate,
  });

  factory MahadashaPeriod.fromJson(Map<String, dynamic> json) {
    return MahadashaPeriod(
      planetKey: json['planet_key'] ?? '',
      planetName: json['planet_name'] ?? '',
      totalYears: json['total_years'] ?? 0,
      actualYears: (json['actual_years'] ?? 0.0).toDouble(),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }
}

class PanchangInfo {
  final String tithi;
  final String paksha;
  final String nakshatra;
  final int pada;
  final String syllable;
  final String yoga;
  final String karana;
  final String moonRashi;

  const PanchangInfo({
    required this.tithi,
    required this.paksha,
    required this.nakshatra,
    required this.pada,
    required this.syllable,
    required this.yoga,
    required this.karana,
    required this.moonRashi,
  });

  factory PanchangInfo.fromJson(Map<String, dynamic> json) {
    final tithiMap = json['tithi'] as Map<String, dynamic>? ?? {};
    final nakMap = json['nakshatra'] as Map<String, dynamic>? ?? {};
    final yogaMap = json['yoga'] as Map<String, dynamic>? ?? {};
    final karMap = json['karana'] as Map<String, dynamic>? ?? {};
    final rashiMap = json['rashi'] as Map<String, dynamic>? ?? {};

    return PanchangInfo(
      tithi: tithiMap['name'] ?? '',
      paksha: tithiMap['paksha'] ?? '',
      nakshatra: nakMap['name'] ?? '',
      pada: nakMap['pada'] ?? 1,
      syllable: nakMap['syllable'] ?? '',
      yoga: yogaMap['name'] ?? '',
      karana: karMap['name'] ?? '',
      moonRashi: rashiMap['display'] ?? rashiMap['name'] ?? '',
    );
  }
}

class HinduCalendarInfo {
  final String dayName;
  final String hinduMonth;
  final int shakaSamvat;
  final int vikramKartik;
  final int vikramChaitra;
  final String ishtaGhati;

  const HinduCalendarInfo({
    required this.dayName,
    required this.hinduMonth,
    required this.shakaSamvat,
    required this.vikramKartik,
    required this.vikramChaitra,
    required this.ishtaGhati,
  });

  factory HinduCalendarInfo.fromJson(Map<String, dynamic> json) {
    return HinduCalendarInfo(
      dayName: json['day_name'] ?? '',
      hinduMonth: json['hindu_month'] ?? '',
      shakaSamvat: json['shaka_samvat'] ?? 0,
      vikramKartik: json['vikram_kartik'] ?? 0,
      vikramChaitra: json['vikram_chaitra'] ?? 0,
      ishtaGhati: json['ishta_ghati'] is Map
          ? (json['ishta_ghati']['display'] ?? '')
          : (json['ishta_ghati'] ?? ''),
    );
  }
}

class AvakhadaInfo {
  final String varna;
  final String tattva;
  final String vashya;
  final String yoni;
  final String gana;
  final String nadi;
  final String varga;
  final String yunja;
  final String yoga;
  final String karana;

  const AvakhadaInfo({
    required this.varna,
    required this.tattva,
    required this.vashya,
    required this.yoni,
    required this.gana,
    required this.nadi,
    required this.varga,
    required this.yunja,
    required this.yoga,
    required this.karana,
  });

  factory AvakhadaInfo.fromJson(Map<String, dynamic> json) {
    return AvakhadaInfo(
      varna: json['varna'] ?? '',
      tattva: json['tattva'] ?? '',
      vashya: json['vashya'] ?? '',
      yoni: json['yoni'] ?? '',
      gana: json['gana'] ?? '',
      nadi: json['nadi'] ?? '',
      varga: json['varga'] ?? '',
      yunja: json['yunja'] ?? '',
      yoga: json['yoga'] ?? '',
      karana: json['karana'] ?? '',
    );
  }
}

class KundaliData {
  final BirthInfo birthInfo;
  final String ayanamshaSystem;
  final String ayanamshaDisplay;
  final PanchangInfo panchang;
  final HinduCalendarInfo calendar;
  final List<PlanetDetail> planets;
  final Map<String, ChartHouseData> charts;
  final List<MahadashaPeriod> mahadasha;
  final AvakhadaInfo avakhada;
  final Map<String, dynamic> rawJson;

  const KundaliData({
    required this.birthInfo,
    required this.ayanamshaSystem,
    required this.ayanamshaDisplay,
    required this.panchang,
    required this.calendar,
    required this.planets,
    required this.charts,
    required this.mahadasha,
    required this.avakhada,
    this.rawJson = const {},
  });

  factory KundaliData.fromJson(Map<String, dynamic> json) {
    final planetsList = (json['planet_details'] as List? ?? [])
        .map((p) => PlanetDetail.fromJson(p))
        .toList();

    final chartsMap = <String, ChartHouseData>{};
    if (json['charts'] is Map) {
      json['charts'].forEach((k, v) {
        chartsMap[k.toString()] = ChartHouseData.fromJson(v);
      });
    }

    final dashaList = (json['mahadasha'] as List? ?? [])
        .map((d) => MahadashaPeriod.fromJson(d))
        .toList();

    return KundaliData(
      birthInfo: BirthInfo.fromJson(json['birth_info'] ?? {}),
      ayanamshaSystem: json['ayanamsha']?['system'] ?? 'Lahiri',
      ayanamshaDisplay: json['ayanamsha']?['display'] ?? '23:59:10',
      panchang: PanchangInfo.fromJson(json['panchang'] ?? {}),
      calendar: HinduCalendarInfo.fromJson(json['hindu_calendar'] ?? {}),
      planets: planetsList,
      charts: chartsMap,
      mahadasha: dashaList,
      avakhada: AvakhadaInfo.fromJson(json['avakhada'] ?? {}),
      rawJson: json,
    );
  }
}

class GunaItem {
  final String name;
  final String nameEn;
  final String description;
  final String boyValue;
  final String girlValue;
  final dynamic maxPoints;
  final dynamic obtained;
  final bool hasNote;

  const GunaItem({
    required this.name,
    required this.nameEn,
    required this.description,
    required this.boyValue,
    required this.girlValue,
    required this.maxPoints,
    required this.obtained,
    this.hasNote = false,
  });

  factory GunaItem.fromJson(Map<String, dynamic> json) {
    return GunaItem(
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      description: json['description'] ?? '',
      boyValue: json['boy_value']?.toString() ?? '',
      girlValue: json['girl_value']?.toString() ?? '',
      maxPoints: json['max_points'],
      obtained: json['obtained'],
      hasNote: json['note'] ?? false,
    );
  }
}

class MangalDoshaItem {
  final bool hasMangal;
  final int chalitHouse;
  final int lagnaHouse;
  final bool shifted;
  final String description;

  const MangalDoshaItem({
    required this.hasMangal,
    required this.chalitHouse,
    required this.lagnaHouse,
    required this.shifted,
    required this.description,
  });

  factory MangalDoshaItem.fromJson(Map<String, dynamic> json) {
    return MangalDoshaItem(
      hasMangal: json['has_mangal'] ?? false,
      chalitHouse: json['chalit_house'] ?? 1,
      lagnaHouse: json['lagna_house'] ?? 1,
      shifted: json['shifted'] ?? false,
      description: json['description'] ?? '',
    );
  }
}

class GunMilanData {
  final KundaliData boy;
  final KundaliData girl;
  final List<GunaItem> gunas;
  final double totalMax;
  final double totalObtained;
  final double percentage;
  final String conclusion;
  final String mangalStatus;
  final String mangalSummary;
  final MangalDoshaItem boyMangal;
  final MangalDoshaItem girlMangal;
  final Map<String, dynamic> rawJson;

  const GunMilanData({
    required this.boy,
    required this.girl,
    required this.gunas,
    required this.totalMax,
    required this.totalObtained,
    required this.percentage,
    required this.conclusion,
    required this.mangalStatus,
    required this.mangalSummary,
    required this.boyMangal,
    required this.girlMangal,
    this.rawJson = const {},
  });

  factory GunMilanData.fromJson(Map<String, dynamic> json) {
    final gm = json['gun_milan'] ?? {};
    final md = json['mangal_dosha'] ?? {};

    final gunaList = (gm['gunas'] as List? ?? [])
        .map((g) => GunaItem.fromJson(g))
        .toList();

    return GunMilanData(
      boy: KundaliData.fromJson(json['boy'] ?? {}),
      girl: KundaliData.fromJson(json['girl'] ?? {}),
      gunas: gunaList,
      totalMax: (gm['total_max'] ?? 36).toDouble(),
      totalObtained: (gm['total_obtained'] ?? 0.0).toDouble(),
      percentage: (gm['percentage'] ?? 0.0).toDouble(),
      conclusion: gm['conclusion'] ?? '',
      mangalStatus: md['status'] ?? '',
      mangalSummary: md['summary'] ?? '',
      boyMangal: MangalDoshaItem.fromJson(md['boy'] ?? {}),
      girlMangal: MangalDoshaItem.fromJson(md['girl'] ?? {}),
      rawJson: json,
    );
  }
}

class CityItem {
  final String name;
  final String? marathiName;
  final String state;
  final String district;
  final double lat;
  final double lng;
  final String display;

  const CityItem({
    required this.name,
    this.marathiName,
    required this.state,
    required this.district,
    required this.lat,
    required this.lng,
    required this.display,
  });

  factory CityItem.fromJson(Map<String, dynamic> json) {
    return CityItem(
      name: json['name'] ?? '',
      marathiName: json['marathi_name'],
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      display: json['display'] ?? '',
    );
  }
}

// ──────────────────────────────────────────
// RICH MOCK DATA FOR INSTANT OFFLINE/PREVIEW
// ──────────────────────────────────────────
final sampleKundaliData = KundaliData(
  birthInfo: const BirthInfo(
    name: 'अनिकेत जोशी',
    date: '06/09/2000',
    time: '19:30:00',
    day: 'बुधवार',
    place: 'Shirpur',
    state: 'Maharashtra',
    district: 'Dhule',
    coordinates: '021:21:N, 074:52:E',
    lat: 21.35,
    lng: 74.88,
    timezone: '+05:30',
    ishtaGhati: '33:45:00',
  ),
  ayanamshaSystem: 'Lahiri',
  ayanamshaDisplay: '23:51:42',
  panchang: const PanchangInfo(
    tithi: 'शुक्ल अष्टमी',
    paksha: 'शुक्ल',
    nakshatra: 'ज्येष्ठा',
    pada: 3,
    syllable: 'यी',
    yoga: 'विष्कम्भ',
    karana: 'बव',
    moonRashi: 'वृश्चिक ( ना नी नू ने )',
  ),
  calendar: const HinduCalendarInfo(
    dayName: 'बुधवार',
    hinduMonth: 'भाद्रपद',
    shakaSamvat: 1922,
    vikramKartik: 2056,
    vikramChaitra: 2057,
    ishtaGhati: '33:45:00',
  ),
  planets: const [
    PlanetDetail(
      id: 'lagna',
      name: 'लग्न',
      longitude: 345.5,
      rashi: 'मीन',
      rashiEn: 'Pisces',
      degree: "15°30'",
      degreeDms: "15° 30' 12\"",
      nakshatra: 'उ.भाद्र',
      pada: 4,
      syllable: 'ञ',
      retrograde: false,
      retroMarker: '',
      speed: 0,
    ),
    PlanetDetail(
      id: 'sun',
      name: 'रवि',
      longitude: 140.2,
      rashi: 'सिंह',
      rashiEn: 'Leo',
      degree: "20°12'",
      degreeDms: "20° 12' 05\"",
      nakshatra: 'पूर्वा-फा.',
      pada: 3,
      syllable: 'टी',
      retrograde: false,
      retroMarker: '',
      speed: 0.98,
    ),
    PlanetDetail(
      id: 'moon',
      name: 'चंद्र',
      longitude: 236.4,
      rashi: 'वृश्चिक',
      rashiEn: 'Scorpio',
      degree: "26°24'",
      degreeDms: "26° 24' 18\"",
      nakshatra: 'ज्ये.',
      pada: 3,
      syllable: 'यी',
      retrograde: false,
      retroMarker: '',
      speed: 12.4,
    ),
    PlanetDetail(
      id: 'mars',
      name: 'मंगळ',
      longitude: 124.8,
      rashi: 'सिंह',
      rashiEn: 'Leo',
      degree: "4°48'",
      degreeDms: "04° 48' 22\"",
      nakshatra: 'मघा',
      pada: 2,
      syllable: 'मी',
      retrograde: false,
      retroMarker: '',
      speed: 0.62,
    ),
    PlanetDetail(
      id: 'mercury',
      name: 'बुध',
      longitude: 165.1,
      rashi: 'कन्या',
      rashiEn: 'Virgo',
      degree: "15°06'",
      degreeDms: "15° 06' 40\"",
      nakshatra: 'हस्त',
      pada: 2,
      syllable: 'ष',
      retrograde: false,
      retroMarker: '',
      speed: 1.4,
    ),
    PlanetDetail(
      id: 'jupiter',
      name: 'गुरु',
      longitude: 69.8,
      rashi: 'मिथुन',
      rashiEn: 'Gemini',
      degree: "9°48'",
      degreeDms: "09° 48' 11\"",
      nakshatra: 'आर्द्रा',
      pada: 1,
      syllable: 'कू',
      retrograde: false,
      retroMarker: '',
      speed: 0.12,
    ),
    PlanetDetail(
      id: 'venus',
      name: 'शुक्र',
      longitude: 172.3,
      rashi: 'कन्या',
      rashiEn: 'Virgo',
      degree: "22°18'",
      degreeDms: "22° 18' 33\"",
      nakshatra: 'हस्त',
      pada: 4,
      syllable: 'ठ',
      retrograde: false,
      retroMarker: '',
      speed: 1.15,
    ),
    PlanetDetail(
      id: 'saturn',
      name: 'शनि',
      longitude: 37.6,
      rashi: 'वृषभ',
      rashiEn: 'Taurus',
      degree: "7°36'",
      degreeDms: "07° 36' 50\"",
      nakshatra: 'कृत्ति.',
      pada: 4,
      syllable: 'ए',
      retrograde: true,
      retroMarker: '↓',
      speed: -0.04,
    ),
    PlanetDetail(
      id: 'rahu',
      name: 'राहू',
      longitude: 95.2,
      rashi: 'कर्क',
      rashiEn: 'Cancer',
      degree: "5°12'",
      degreeDms: "05° 12' 00\"",
      nakshatra: 'पुष्य',
      pada: 1,
      syllable: 'हू',
      retrograde: true,
      retroMarker: '(व)',
      speed: -0.05,
    ),
    PlanetDetail(
      id: 'ketu',
      name: 'केतु',
      longitude: 275.2,
      rashi: 'मकर',
      rashiEn: 'Capricorn',
      degree: "5°12'",
      degreeDms: "05° 12' 00\"",
      nakshatra: 'उ.षा.',
      pada: 3,
      syllable: 'जा',
      retrograde: true,
      retroMarker: '(व)',
      speed: -0.05,
    ),
  ],
  charts: {
    'lagna': ChartHouseData(
      ascendantRashi: 11, // Pisces
      title: 'लग्न कुंडली',
      houses: {
        1: [],
        2: [],
        3: ['saturn'],
        4: ['jupiter'],
        5: ['rahu'],
        6: ['sun', 'mars'],
        7: ['mercury', 'venus'],
        8: [],
        9: ['moon'],
        10: [],
        11: ['ketu'],
        12: [],
      },
    ),
    'navamsha': ChartHouseData(
      ascendantRashi: 3, // Cancer
      title: 'नवमांश कुंडली',
      houses: {
        1: ['saturn'],
        2: [],
        3: ['jupiter'],
        4: ['rahu'],
        5: ['moon'],
        6: ['sun'],
        7: ['mars'],
        8: [],
        9: ['mercury'],
        10: ['ketu'],
        11: ['venus'],
        12: [],
      },
    ),
    'chalit': ChartHouseData(
      ascendantRashi: 11,
      title: 'चलित कुंडली',
      houses: {
        1: [],
        2: [],
        3: ['saturn'],
        4: ['jupiter'],
        5: ['rahu'],
        6: ['sun', 'mars'],
        7: ['mercury', 'venus'],
        8: [],
        9: ['moon'],
        10: [],
        11: ['ketu'],
        12: [],
      },
    ),
    'chandra': ChartHouseData(
      ascendantRashi: 7, // Scorpio
      title: 'चंद्र राशी कुंडली',
      houses: {
        1: ['moon'],
        2: [],
        3: ['ketu'],
        4: [],
        5: [],
        6: [],
        7: ['saturn'],
        8: ['jupiter'],
        9: ['rahu'],
        10: ['sun', 'mars'],
        11: ['mercury', 'venus'],
        12: [],
      },
    ),
  },
  mahadasha: const [
    MahadashaPeriod(
      planetKey: 'mercury',
      planetName: 'बुध',
      totalYears: 17,
      actualYears: 4.85,
      startDate: '06/09/2000',
      endDate: '15/07/2005',
    ),
    MahadashaPeriod(
      planetKey: 'ketu',
      planetName: 'केतु',
      totalYears: 7,
      actualYears: 7.0,
      startDate: '15/07/2005',
      endDate: '15/07/2012',
    ),
    MahadashaPeriod(
      planetKey: 'venus',
      planetName: 'शुक्र',
      totalYears: 20,
      actualYears: 20.0,
      startDate: '15/07/2012',
      endDate: '15/07/2032',
    ),
    MahadashaPeriod(
      planetKey: 'sun',
      planetName: 'रवि',
      totalYears: 6,
      actualYears: 6.0,
      startDate: '15/07/2032',
      endDate: '15/07/2038',
    ),
    MahadashaPeriod(
      planetKey: 'moon',
      planetName: 'चंद्र',
      totalYears: 10,
      actualYears: 10.0,
      startDate: '15/07/2038',
      endDate: '15/07/2048',
    ),
    MahadashaPeriod(
      planetKey: 'mars',
      planetName: 'मंगळ',
      totalYears: 7,
      actualYears: 7.0,
      startDate: '15/07/2048',
      endDate: '15/07/2055',
    ),
    MahadashaPeriod(
      planetKey: 'rahu',
      planetName: 'राहू',
      totalYears: 18,
      actualYears: 18.0,
      startDate: '15/07/2055',
      endDate: '15/07/2073',
    ),
    MahadashaPeriod(
      planetKey: 'jupiter',
      planetName: 'गुरु',
      totalYears: 16,
      actualYears: 16.0,
      startDate: '15/07/2073',
      endDate: '15/07/2089',
    ),
    MahadashaPeriod(
      planetKey: 'saturn',
      planetName: 'शनि',
      totalYears: 19,
      actualYears: 19.0,
      startDate: '15/07/2089',
      endDate: '15/07/2108',
    ),
  ],
  avakhada: const AvakhadaInfo(
    varna: 'ब्राह्मण',
    tattva: 'जल',
    vashya: 'कीट',
    yoni: 'मृग',
    gana: 'राक्षस',
    nadi: 'अंत्य',
    varga: 'मृग',
    yunja: 'मध्य',
    yoga: 'विष्कम्भ',
    karana: 'बव',
  ),
);

final sampleGunMilanData = GunMilanData(
  boy: sampleKundaliData,
  girl: KundaliData(
    birthInfo: const BirthInfo(
      name: 'प्रिया कुलकर्णी',
      date: '12/10/2001',
      time: '10:15:00',
      day: 'शुक्रवार',
      place: 'Pune',
      state: 'Maharashtra',
      district: 'Pune',
      coordinates: '018:31:N, 073:51:E',
      lat: 18.52,
      lng: 73.85,
      timezone: '+05:30',
      ishtaGhati: '10:37:00',
    ),
    ayanamshaSystem: 'Lahiri',
    ayanamshaDisplay: '23:52:30',
    panchang: const PanchangInfo(
      tithi: 'कृष्ण एकादशी',
      paksha: 'कृष्ण',
      nakshatra: 'आश्लेषा',
      pada: 2,
      syllable: 'डू',
      yoga: 'शुभ',
      karana: 'बालव',
      moonRashi: 'कर्क ( हा ही हू हे )',
    ),
    calendar: const HinduCalendarInfo(
      dayName: 'शुक्रवार',
      hinduMonth: 'आश्विन',
      shakaSamvat: 1923,
      vikramKartik: 2057,
      vikramChaitra: 2058,
      ishtaGhati: '10:37:00',
    ),
    planets: sampleKundaliData.planets,
    charts: sampleKundaliData.charts,
    mahadasha: sampleKundaliData.mahadasha,
    avakhada: const AvakhadaInfo(
      varna: 'ब्राह्मण',
      tattva: 'जल',
      vashya: 'जलचर',
      yoni: 'मार्जार',
      gana: 'राक्षस',
      nadi: 'अंत्य',
      varga: 'मार्जार',
      yunja: 'आदि',
      yoga: 'शुभ',
      karana: 'बालव',
    ),
  ),
  gunas: const [
    GunaItem(
      name: 'वर्ण',
      nameEn: 'Varna',
      description: 'जातीय सुसंगतता (Social compatibility)',
      boyValue: 'ब्राह्मण',
      girlValue: 'ब्राह्मण',
      maxPoints: 1,
      obtained: 1,
    ),
    GunaItem(
      name: 'वश्य',
      nameEn: 'Vashya',
      description: 'आकर्षण व वर्चस्व (Dominance & attraction)',
      boyValue: 'कीट',
      girlValue: 'जलचर',
      maxPoints: 2,
      obtained: 1,
    ),
    GunaItem(
      name: 'तारा',
      nameEn: 'Tara',
      description: 'नक्षत्र सुसंगतता (Birth star compatibility)',
      boyValue: 'ज्येष्ठा',
      girlValue: 'आश्लेषा',
      maxPoints: 3,
      obtained: 3,
    ),
    GunaItem(
      name: 'योनि',
      nameEn: 'Yoni',
      description: 'शारीरिक सुसंगतता (Physical/sexual compatibility)',
      boyValue: 'मृग',
      girlValue: 'मार्जार',
      maxPoints: 4,
      obtained: 2,
    ),
    GunaItem(
      name: 'ग्रह मैत्री',
      nameEn: 'Graha Maitri',
      description: 'मानसिक सुसंगतता (Mental compatibility)',
      boyValue: 'मंगळ',
      girlValue: 'चंद्र',
      maxPoints: 5,
      obtained: 4,
    ),
    GunaItem(
      name: 'गण',
      nameEn: 'Gana',
      description: 'स्वभाव सुसंगतता (Temperament compatibility)',
      boyValue: 'राक्षस',
      girlValue: 'राक्षस',
      maxPoints: 6,
      obtained: 6,
    ),
    GunaItem(
      name: 'भकूट',
      nameEn: 'Bhakut',
      description: 'प्रेम व कुटुंब सुसंगतता (Love & family)',
      boyValue: 'वृश्चिक',
      girlValue: 'कर्क',
      maxPoints: 7,
      obtained: 7,
      hasNote: true,
    ),
    GunaItem(
      name: 'नाडी',
      nameEn: 'Nadi',
      description: 'आरोग्य व वंश सुसंगतता (Health & progeny)',
      boyValue: 'आद्य',
      girlValue: 'अंत्य',
      maxPoints: 8,
      obtained: 8,
    ),
    GunaItem(
      name: 'नक्षत्र',
      nameEn: 'Nakshatra',
      description: 'जन्म नक्षत्र (Birth star)',
      boyValue: 'ज्येष्ठा',
      girlValue: 'आश्लेषा',
      maxPoints: '-',
      obtained: '-',
    ),
  ],
  totalMax: 36,
  totalObtained: 32,
  percentage: 88.9,
  conclusion:
      'युवक आणि युवती या दोघांच्याही भाव चलित कुंडलीनुसार मंगळ १, ४, ७, ८, १२ या स्थानांत नसल्याने मंगळ दोष मानला जात नाही. आपले गुण ३२.०० आहेत म्हणून हे गुण मिलन वैवाहिक जीवना करीता अतिशय उत्तम आहे.',
  mangalStatus: 'निर्दोष',
  mangalSummary: 'दोन्ही कुंडली भाव चलितनुसार मंगळ दोषमुक्त (निर्दोष) आहेत.',
  boyMangal: const MangalDoshaItem(
    hasMangal: false,
    chalitHouse: 6,
    lagnaHouse: 6,
    shifted: false,
    description: 'युवकाच्या भाव चलित कुंडलीनुसार मंगळ ६ व्या भावात असून मंगळ दोष नाही.',
  ),
  girlMangal: const MangalDoshaItem(
    hasMangal: false,
    chalitHouse: 9,
    lagnaHouse: 9,
    shifted: false,
    description: 'युवतीच्या भाव चलित कुंडलीनुसार मंगळ ९ व्या भावात असून मंगळ दोष नाही.',
  ),
);

final sampleIndianCities = [
  const CityItem(name: 'Shirpur', marathiName: 'शिरपूर', state: 'Maharashtra', district: 'Dhule', lat: 21.3500, lng: 74.8800, display: 'Shirpur, Dhule, Maharashtra'),
  const CityItem(name: 'Pune', marathiName: 'पुणे', state: 'Maharashtra', district: 'Pune', lat: 18.5204, lng: 73.8567, display: 'Pune, Pune, Maharashtra'),
  const CityItem(name: 'Mumbai', marathiName: 'मुंबई', state: 'Maharashtra', district: 'Mumbai', lat: 19.0760, lng: 72.8777, display: 'Mumbai, Maharashtra'),
  const CityItem(name: 'Nashik', marathiName: 'नाशिक', state: 'Maharashtra', district: 'Nashik', lat: 19.9975, lng: 73.7898, display: 'Nashik, Maharashtra'),
  const CityItem(name: 'Nagpur', marathiName: 'नागपूर', state: 'Maharashtra', district: 'Nagpur', lat: 21.1458, lng: 79.0882, display: 'Nagpur, Maharashtra'),
  const CityItem(name: 'Chhatrapati Sambhajinagar', marathiName: 'छत्रपती संभाजीनगर (औरंगाबाद)', state: 'Maharashtra', district: 'Aurangabad', lat: 19.8762, lng: 75.3433, display: 'Chhatrapati Sambhajinagar, Maharashtra'),
  const CityItem(name: 'Dhule', marathiName: 'धुळे', state: 'Maharashtra', district: 'Dhule', lat: 20.9042, lng: 74.7749, display: 'Dhule, Maharashtra'),
  const CityItem(name: 'Jalgaon', marathiName: 'जळगाव', state: 'Maharashtra', district: 'Jalgaon', lat: 21.0077, lng: 75.5626, display: 'Jalgaon, Maharashtra'),
  const CityItem(name: 'Thane', marathiName: 'ठाणे', state: 'Maharashtra', district: 'Thane', lat: 19.2183, lng: 72.9781, display: 'Thane, Maharashtra'),
  const CityItem(name: 'Kolhapur', marathiName: 'कोल्हापूर', state: 'Maharashtra', district: 'Kolhapur', lat: 16.7050, lng: 74.2433, display: 'Kolhapur, Maharashtra'),
  const CityItem(name: 'Solapur', marathiName: 'सोलापूर', state: 'Maharashtra', district: 'Solapur', lat: 17.6599, lng: 75.9064, display: 'Solapur, Maharashtra'),
  const CityItem(name: 'Satara', marathiName: 'सातारा', state: 'Maharashtra', district: 'Satara', lat: 17.6805, lng: 73.9997, display: 'Satara, Maharashtra'),
  const CityItem(name: 'Sangli', marathiName: 'सांगली', state: 'Maharashtra', district: 'Sangli', lat: 16.8524, lng: 74.5815, display: 'Sangli, Maharashtra'),
  const CityItem(name: 'Ratnagiri', marathiName: 'रत्नागिरी', state: 'Maharashtra', district: 'Ratnagiri', lat: 16.9902, lng: 73.3120, display: 'Ratnagiri, Maharashtra'),
  const CityItem(name: 'Ahilyanagar (Ahmednagar)', marathiName: 'अहिल्यानगर (अहमदनगर)', state: 'Maharashtra', district: 'Ahmednagar', lat: 19.0948, lng: 74.7480, display: 'Ahilyanagar, Maharashtra'),
  const CityItem(name: 'Nandurbar', marathiName: 'नंदुरबार', state: 'Maharashtra', district: 'Nandurbar', lat: 21.3697, lng: 74.2403, display: 'Nandurbar, Maharashtra'),
  const CityItem(name: 'Amravati', marathiName: 'अमरावती', state: 'Maharashtra', district: 'Amravati', lat: 20.9374, lng: 77.7796, display: 'Amravati, Maharashtra'),
  const CityItem(name: 'Nanded', marathiName: 'नांदेड', state: 'Maharashtra', district: 'Nanded', lat: 19.1383, lng: 77.3210, display: 'Nanded, Maharashtra'),
  const CityItem(name: 'Akola', marathiName: 'अकोला', state: 'Maharashtra', district: 'Akola', lat: 20.7002, lng: 77.0082, display: 'Akola, Maharashtra'),
  const CityItem(name: 'Latur', marathiName: 'लातूर', state: 'Maharashtra', district: 'Latur', lat: 18.4088, lng: 76.5604, display: 'Latur, Maharashtra'),
  const CityItem(name: 'New Delhi', marathiName: 'नवी दिल्ली', state: 'Delhi', district: 'New Delhi', lat: 28.6139, lng: 77.2090, display: 'New Delhi, Delhi'),
  const CityItem(name: 'Bengaluru', marathiName: 'बंगळुरू', state: 'Karnataka', district: 'Bengaluru', lat: 12.9716, lng: 77.5946, display: 'Bengaluru, Karnataka'),
  const CityItem(name: 'Hyderabad', marathiName: 'हैद्राबाद', state: 'Telangana', district: 'Hyderabad', lat: 17.3850, lng: 78.4867, display: 'Hyderabad, Telangana'),
  const CityItem(name: 'Ahmedabad', marathiName: 'अहमदाबाद', state: 'Gujarat', district: 'Ahmedabad', lat: 23.0225, lng: 72.5714, display: 'Ahmedabad, Gujarat'),
  const CityItem(name: 'Surat', marathiName: 'सुरत', state: 'Gujarat', district: 'Surat', lat: 21.1702, lng: 72.8311, display: 'Surat, Gujarat'),
  const CityItem(name: 'Indore', marathiName: 'इंदूर', state: 'Madhya Pradesh', district: 'Indore', lat: 22.7196, lng: 75.8577, display: 'Indore, Madhya Pradesh'),
  const CityItem(name: 'Bhopal', marathiName: 'भोपाळ', state: 'Madhya Pradesh', district: 'Bhopal', lat: 23.2599, lng: 77.4126, display: 'Bhopal, Madhya Pradesh'),
  const CityItem(name: 'Jaipur', marathiName: 'जयपूर', state: 'Rajasthan', district: 'Jaipur', lat: 26.9124, lng: 75.7873, display: 'Jaipur, Rajasthan'),
  const CityItem(name: 'Varanasi', marathiName: 'वाराणसी (काशी)', state: 'Uttar Pradesh', district: 'Varanasi', lat: 25.3176, lng: 82.9739, display: 'Varanasi, Uttar Pradesh'),
  const CityItem(name: 'Kolkata', marathiName: 'कोलकाता', state: 'West Bengal', district: 'Kolkata', lat: 22.5726, lng: 88.3639, display: 'Kolkata, West Bengal'),
];
