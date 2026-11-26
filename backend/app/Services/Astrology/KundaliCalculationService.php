<?php

namespace App\Services\Astrology;

use DateTime;
use DateTimeZone;
use InvalidArgumentException;

class KundaliCalculationService
{
    public function __construct(
        protected AstronomyEngine $astroEngine,
        protected PanchangCalculator $panchangCalculator,
        protected HinduCalendar $hinduCalendar,
        protected NavamshaCalculator $navamshaCalculator,
        protected ChalitCalculator $chalitCalculator,
        protected MahadashaCalculator $mahadashaCalculator,
        protected AvakhadaChakra $avakhadaChakra,
        protected KundaliChart $kundaliChart
    ) {}

    /**
     * Calculate complete Kundali based on birth details.
     *
     * @param array{
     *     date: string,
     *     time: string,
     *     lat: float|int|string,
     *     lng: float|int|string,
     *     name?: string|null,
     *     place?: string|null,
     *     state?: string|null,
     *     district?: string|null,
     *     tz_offset?: string|null,
     *     ayanamsha?: string|null,
     *     engine?: string|null
     * } $input
     * @return array<string, mixed>
     */
    public function calculate(array $input): array
    {
        $date = trim($input['date'] ?? '');
        $time = trim($input['time'] ?? '');
        $lat = (float) ($input['lat'] ?? 0);
        $lng = (float) ($input['lng'] ?? 0);
        $placeName = $input['place'] ?? '';
        $state = $input['state'] ?? '';
        $district = $input['district'] ?? '';
        $tzOffset = $input['tz_offset'] ?? '+05:30';
        $ayanamshaType = strtolower($input['ayanamsha'] ?? 'lahiri');

        $ayanamshaCode = 1;
        $ayanamshaName = 'Lahiri';
        if ($ayanamshaType === 'kp') {
            $ayanamshaCode = 5;
            $ayanamshaName = 'KP';
        }

        if (empty($date) || empty($time) || $lat == 0.0 || $lng == 0.0) {
            throw new InvalidArgumentException('Missing required fields: date, time, lat, lng');
        }

        $dateParts = preg_split('/[-\/.]/', $date);
        if (! $dateParts || count($dateParts) !== 3) {
            throw new InvalidArgumentException('Invalid date format. Use DD-MM-YYYY');
        }
        $day = (int) $dateParts[0];
        $month = (int) $dateParts[1];
        $year = (int) $dateParts[2];

        $timeParts = explode(':', $time);
        $hour = (int) ($timeParts[0] ?? 0);
        $minute = (int) ($timeParts[1] ?? 0);
        $second = (int) ($timeParts[2] ?? 0);

        $tz = new DateTimeZone('Asia/Kolkata');
        $localTime = new DateTime(sprintf(
            '%04d-%02d-%02d %02d:%02d:%02d',
            $year,
            $month,
            $day,
            $hour,
            $minute,
            $second
        ), $tz);

        $utcTime = clone $localTime;
        $utcTime->setTimezone(new DateTimeZone('UTC'));

        // Astronomical Data
        $activeEngine = 'Astronomy Engine (Don Cross, MIT)';
        $planets = $this->astroEngine->getPlanetPositions($utcTime, $ayanamshaCode, $lat, $lng);
        $houseData = $this->astroEngine->getHouseCusps($utcTime, $lat, $lng, $ayanamshaCode);
        $ayanamsha = $this->astroEngine->getAyanamsha($utcTime, $ayanamshaCode);

        $ascendantLng = $houseData['ascendant'];
        $ascRashi = AstrologyData::getRashiIndex($ascendantLng);

        // Panchang
        $panchangData = $this->panchangCalculator->calculate(
            $planets['sun']['longitude'],
            $planets['moon']['longitude']
        );

        // Hindu Calendar
        $calendarData = $this->hinduCalendar->calculate(
            $localTime,
            $planets['sun']['longitude'],
            $planets['moon']['longitude']
        );

        // Navamsha (D9)
        $navamshaRashis = $this->navamshaCalculator->calculateAll($planets);
        $ascNavamshaRashi = $this->navamshaCalculator->calculateNavamshaRashi($ascendantLng);

        // Chalit (Bhava Chalit)
        $chalitChart = $this->chalitCalculator->buildChalitChart($planets, $houseData['houses']);

        // Mahadasha
        $mahadashaData = $this->mahadashaCalculator->calculate($planets['moon']['longitude'], $localTime);

        // Avakahada Chakra
        $avakhadaData = $this->avakhadaChakra->calculate(
            $panchangData['rashi']['index'],
            $panchangData['nakshatra']['index']
        );
        $avakhadaData['yoga'] = $panchangData['yoga']['name'];
        $avakhadaData['karana'] = $panchangData['karana']['name'];

        // Charts
        $lagnaChart = $this->kundaliChart->getLagnaChart($planets, $ascendantLng);
        $chandraChart = $this->kundaliChart->getChandraChart($planets, $planets['moon']['longitude']);
        $navamshaChart = $this->kundaliChart->getNavamshaChart($navamshaRashis, $ascNavamshaRashi);
        $chalitChartData = $this->kundaliChart->getChalitChart($chalitChart, $ascRashi);

        // Planet details table
        $planetDetails = [];

        $lagnaRashi = AstrologyData::RASHI[$ascRashi];
        $lagnaNakIndex = AstrologyData::getNakshatraIndex($ascendantLng);
        $lagnaPada = AstrologyData::getNakshatraPada($ascendantLng);
        $lagnaDeg = AstrologyData::getDegreeDetails($ascendantLng);
        $planetDetails[] = [
            'id' => 'lagna',
            'name' => 'लग्न',
            'longitude' => $ascendantLng,
            'rashi' => $lagnaRashi['name'],
            'rashi_en' => $lagnaRashi['name_en'],
            'degree' => $lagnaDeg['display'],
            'degree_dms' => $lagnaDeg['display_dms'],
            'degree_raw' => $lagnaDeg['raw'],
            'rashi_degree' => $lagnaRashi['name'].' '.$lagnaDeg['display'],
            'deg' => $lagnaDeg['deg'],
            'min' => $lagnaDeg['min'],
            'sec' => $lagnaDeg['sec'],
            'nakshatra' => AstrologyData::NAKSHATRA[$lagnaNakIndex]['name_short'],
            'nakshatra_full' => AstrologyData::NAKSHATRA[$lagnaNakIndex]['name'],
            'pada' => $lagnaPada,
            'syllable' => AstrologyData::getNakshatraSyllable($lagnaNakIndex, $lagnaPada),
            'retrograde' => false,
            'retro_marker' => '',
            'speed' => 0,
        ];

        $planetOrder = ['sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu', 'uranus', 'neptune', 'pluto'];
        foreach ($planetOrder as $pid) {
            if (! isset($planets[$pid])) {
                continue;
            }
            $p = $planets[$pid];
            $rIndex = AstrologyData::getRashiIndex($p['longitude']);
            $nIndex = AstrologyData::getNakshatraIndex($p['longitude']);
            $pada = AstrologyData::getNakshatraPada($p['longitude']);
            $pInfo = AstrologyData::PLANETS[$pid];
            $rashiData = AstrologyData::RASHI[$rIndex];
            $deg = AstrologyData::getDegreeDetails($p['longitude']);

            $retroMarker = '';
            if ($pid === 'rahu' || $pid === 'ketu') {
                $retroMarker = '(व)';
            } elseif ($p['retrograde']) {
                $retroMarker = '↓';
            }

            $planetDetails[] = [
                'id' => $pid,
                'name' => $pInfo['name'],
                'longitude' => $p['longitude'],
                'rashi' => $rashiData['name'],
                'rashi_en' => $rashiData['name_en'],
                'degree' => $deg['display'],
                'degree_dms' => $deg['display_dms'],
                'degree_raw' => $deg['raw'],
                'rashi_degree' => $rashiData['name'].' '.$deg['display'],
                'deg' => $deg['deg'],
                'min' => $deg['min'],
                'sec' => $deg['sec'],
                'nakshatra' => AstrologyData::NAKSHATRA[$nIndex]['name_short'],
                'nakshatra_full' => AstrologyData::NAKSHATRA[$nIndex]['name'],
                'pada' => $pada,
                'syllable' => AstrologyData::getNakshatraSyllable($nIndex, $pada),
                'retrograde' => $p['retrograde'],
                'retro_marker' => $retroMarker,
                'speed' => $p['speed'],
            ];
        }

        // Coordinates display
        $latDeg = abs($lat);
        $latD = (int) floor($latDeg);
        $latM = (int) floor(($latDeg - $latD) * 60);
        $latDir = $lat >= 0 ? 'N' : 'S';

        $lngDeg = abs($lng);
        $lngD = (int) floor($lngDeg);
        $lngM = (int) floor(($lngDeg - $lngD) * 60);
        $lngDir = $lng >= 0 ? 'E' : 'W';

        $coordDisplay = sprintf('%03d:%02d:%s, %03d:%02d:%s', $latD, $latM, $latDir, $lngD, $lngM, $lngDir);

        $ayDeg = (int) floor($ayanamsha);
        $ayMin = (int) floor(($ayanamsha - $ayDeg) * 60);
        $aySec = (int) round((($ayanamsha - $ayDeg) * 60 - $ayMin) * 60);
        $ayanamshaDisplay = sprintf('%02d:%02d:%02d', $ayDeg, $ayMin, $aySec);

        $birthInfo = [
            'date' => sprintf('%02d/%02d/%04d', $day, $month, $year),
            'time' => sprintf('%02d:%02d:%02d', $hour, $minute, $second),
            'day' => $calendarData['day_name'],
            'place' => $placeName,
            'state' => $state,
            'district' => $district,
            'coordinates' => $coordDisplay,
            'lat' => $lat,
            'lng' => $lng,
            'timezone' => $tzOffset,
            'ishta_ghati' => $calendarData['ishta_ghati'],
        ];

        if (! empty($input['name'])) {
            $birthInfo['name'] = $input['name'];
        }

        return [
            'success' => true,
            'engine' => $activeEngine,
            'birth_info' => $birthInfo,
            'ayanamsha' => [
                'value' => round($ayanamsha, 6),
                'display' => $ayanamshaDisplay,
                'system' => $ayanamshaName,
            ],
            'panchang' => $panchangData,
            'hindu_calendar' => $calendarData,
            'planet_details' => $planetDetails,
            'charts' => [
                'lagna' => $lagnaChart,
                'navamsha' => $navamshaChart,
                'chalit' => $chalitChartData,
                'chandra' => $chandraChart,
            ],
            'mahadasha' => $mahadashaData,
            'avakhada' => $avakhadaData,
        ];
    }
}
