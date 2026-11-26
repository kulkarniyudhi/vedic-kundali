<?php

namespace App\Services\Astrology;

class AstrologyData
{
    // ──────────────────────────────────────────
    // RASHI (Zodiac Signs) — index 0–11
    // ──────────────────────────────────────────
    public const RASHI = [
        ['name' => 'मेष',   'name_en' => 'Aries',       'lord' => 'Mars',    'element' => 'अग्नि', 'type' => 'movable', 'varna' => 'क्षत्रिय', 'vashya' => 'चतुष्पद'],
        ['name' => 'वृषभ',  'name_en' => 'Taurus',      'lord' => 'Venus',   'element' => 'पृथ्वी', 'type' => 'fixed',   'varna' => 'वैश्य',   'vashya' => 'चतुष्पद'],
        ['name' => 'मिथुन', 'name_en' => 'Gemini',      'lord' => 'Mercury', 'element' => 'वायु',  'type' => 'dual',    'varna' => 'शूद्र',   'vashya' => 'नर'],
        ['name' => 'कर्क',  'name_en' => 'Cancer',      'lord' => 'Moon',    'element' => 'जल',    'type' => 'movable', 'varna' => 'ब्राह्मण', 'vashya' => 'जलचर'],
        ['name' => 'सिंह',  'name_en' => 'Leo',         'lord' => 'Sun',     'element' => 'अग्नि', 'type' => 'fixed',   'varna' => 'क्षत्रिय', 'vashya' => 'वनचर'],
        ['name' => 'कन्या', 'name_en' => 'Virgo',       'lord' => 'Mercury', 'element' => 'पृथ्वी', 'type' => 'dual',    'varna' => 'वैश्य',   'vashya' => 'नर'],
        ['name' => 'तुला',  'name_en' => 'Libra',       'lord' => 'Venus',   'element' => 'वायु',  'type' => 'movable', 'varna' => 'शूद्र',   'vashya' => 'नर'],
        ['name' => 'वृश्चिक', 'name_en' => 'Scorpio',    'lord' => 'Mars',    'element' => 'जल',    'type' => 'fixed',   'varna' => 'ब्राह्मण', 'vashya' => 'कीट'],
        ['name' => 'धनु',   'name_en' => 'Sagittarius', 'lord' => 'Jupiter', 'element' => 'अग्नि', 'type' => 'dual',    'varna' => 'क्षत्रिय', 'vashya' => 'नर'],
        ['name' => 'मकर',   'name_en' => 'Capricorn',   'lord' => 'Saturn',  'element' => 'पृथ्वी', 'type' => 'movable', 'varna' => 'वैश्य',   'vashya' => 'चतुष्पद'],
        ['name' => 'कुम्भ', 'name_en' => 'Aquarius',    'lord' => 'Saturn',  'element' => 'वायु',  'type' => 'fixed',   'varna' => 'शूद्र',   'vashya' => 'नर'],
        ['name' => 'मीन',   'name_en' => 'Pisces',      'lord' => 'Jupiter', 'element' => 'जल',    'type' => 'dual',    'varna' => 'ब्राह्मण', 'vashya' => 'जलचर'],
    ];

    // Rashi syllables (akshar) for each sign — used in Chandra Rashi display
    public const RASHI_SYLLABLES = [
        'चू ची चे चो',   // मेष
        'ला ली लू ले',   // वृषभ
        'का की कू घ',    // मिथुन
        'हा ही हू हे',   // कर्क
        'मा मी मू मे',   // सिंह
        'ढो पा पी पू',   // कन्या
        'रा री रू रे',   // तुला
        'ना नी नू ने',   // वृश्चिक
        'भ ध फ ढ',       // धनु
        'खो जा जी',      // मकर
        'गू गे गो स',    // कुम्भ
        'दी दू थ झ',     // मीन
    ];

    // ──────────────────────────────────────────
    // NAKSHATRA (Lunar Mansions) — index 0–26
    // ──────────────────────────────────────────
    public const NAKSHATRA = [
        ['name' => 'अश्विनी',     'name_short' => 'अश्वि.',  'lord' => 'Ketu',    'gana' => 'देव',    'yoni' => 'अश्व',  'nadi' => 'आद्य',  'syllables' => ['चू', 'चे', 'चो', 'ला']],
        ['name' => 'भरणी',        'name_short' => 'भरणी',    'lord' => 'Venus',   'gana' => 'मनुष्य', 'yoni' => 'गज',    'nadi' => 'मध्य', 'syllables' => ['ली', 'लू', 'ले', 'लो']],
        ['name' => 'कृत्तिका',    'name_short' => 'कृत्ति.', 'lord' => 'Sun',     'gana' => 'राक्षस', 'yoni' => 'मेष',   'nadi' => 'अंत्य', 'syllables' => ['अ', 'ई', 'उ', 'ए']],
        ['name' => 'रोहिणी',      'name_short' => 'रोहिणी',  'lord' => 'Moon',    'gana' => 'मनुष्य', 'yoni' => 'सर्प',  'nadi' => 'आद्य',  'syllables' => ['ओ', 'वा', 'वी', 'वू']],
        ['name' => 'मृगशिरा',     'name_short' => 'मृग.',    'lord' => 'Mars',    'gana' => 'देव',    'yoni' => 'सर्प',  'nadi' => 'मध्य', 'syllables' => ['वे', 'वो', 'का', 'की']],
        ['name' => 'आर्द्रा',     'name_short' => 'आर्द्रा', 'lord' => 'Rahu',    'gana' => 'मनुष्य', 'yoni' => 'श्वान', 'nadi' => 'अंत्य', 'syllables' => ['कू', 'घ', 'ङ', 'छ']],
        ['name' => 'पुनर्वसु',    'name_short' => 'पुनर.',   'lord' => 'Jupiter', 'gana' => 'देव',    'yoni' => 'मार्जार', 'nadi' => 'आद्य', 'syllables' => ['के', 'को', 'हा', 'ही']],
        ['name' => 'पुष्य',       'name_short' => 'पुष्य',   'lord' => 'Saturn',  'gana' => 'देव',    'yoni' => 'मेष',   'nadi' => 'मध्य', 'syllables' => ['हू', 'हे', 'हो', 'ड']],
        ['name' => 'आश्लेषा',     'name_short' => 'आश्ले.',  'lord' => 'Mercury', 'gana' => 'राक्षस', 'yoni' => 'मार्जार', 'nadi' => 'अंत्य', 'syllables' => ['डी', 'डू', 'डे', 'डो']],
        ['name' => 'मघा',         'name_short' => 'मघा',     'lord' => 'Ketu',    'gana' => 'राक्षस', 'yoni' => 'मूषक',  'nadi' => 'आद्य',  'syllables' => ['मा', 'मी', 'मू', 'मे']],
        ['name' => 'पूर्वा फाल्गुनी', 'name_short' => 'पूर्वा-फा.', 'lord' => 'Venus',   'gana' => 'मनुष्य', 'yoni' => 'मूषक', 'nadi' => 'मध्य', 'syllables' => ['मो', 'टा', 'टी', 'टू']],
        ['name' => 'उत्तरा फाल्गुनी', 'name_short' => 'उत्तरा-फा.', 'lord' => 'Sun',     'gana' => 'मनुष्य', 'yoni' => 'गौ',   'nadi' => 'अंत्य', 'syllables' => ['टे', 'टो', 'पा', 'पी']],
        ['name' => 'हस्त',        'name_short' => 'हस्त',    'lord' => 'Moon',    'gana' => 'देव',    'yoni' => 'महिष', 'nadi' => 'आद्य',  'syllables' => ['पू', 'ष', 'ण', 'ठ']],
        ['name' => 'चित्रा',      'name_short' => 'चित्रा',  'lord' => 'Mars',    'gana' => 'राक्षस', 'yoni' => 'व्याघ्र', 'nadi' => 'मध्य', 'syllables' => ['पे', 'पो', 'रा', 'री']],
        ['name' => 'स्वाती',      'name_short' => 'स्वाती',  'lord' => 'Rahu',    'gana' => 'देव',    'yoni' => 'महिष', 'nadi' => 'अंत्य', 'syllables' => ['रू', 'रे', 'रो', 'ता']],
        ['name' => 'विशाखा',      'name_short' => 'विशाखा',  'lord' => 'Jupiter', 'gana' => 'राक्षस', 'yoni' => 'व्याघ्र', 'nadi' => 'आद्य', 'syllables' => ['ती', 'तू', 'ते', 'तो']],
        ['name' => 'अनुराधा',     'name_short' => 'अनुरा.',  'lord' => 'Saturn',  'gana' => 'देव',    'yoni' => 'मृग',   'nadi' => 'मध्य', 'syllables' => ['ना', 'नी', 'नू', 'ने']],
        ['name' => 'ज्येष्ठा',    'name_short' => 'ज्ये.',   'lord' => 'Mercury', 'gana' => 'राक्षस', 'yoni' => 'मृग',   'nadi' => 'अंत्य', 'syllables' => ['नो', 'या', 'यी', 'यू']],
        ['name' => 'मूल',         'name_short' => 'मूळ',     'lord' => 'Ketu',    'gana' => 'राक्षस', 'yoni' => 'श्वान', 'nadi' => 'आद्य',  'syllables' => ['ये', 'यो', 'भा', 'भी']],
        ['name' => 'पूर्वाषाढा',  'name_short' => 'पू.षा.',  'lord' => 'Venus',   'gana' => 'मनुष्य', 'yoni' => 'वानर',  'nadi' => 'मध्य', 'syllables' => ['भू', 'ध', 'फ', 'ढ']],
        ['name' => 'उत्तराषाढा',  'name_short' => 'उ.षा.',   'lord' => 'Sun',     'gana' => 'मनुष्य', 'yoni' => 'नकुल',  'nadi' => 'अंत्य', 'syllables' => ['भे', 'भो', 'जा', 'जी']],
        ['name' => 'श्रवण',       'name_short' => 'श्रवण',   'lord' => 'Moon',    'gana' => 'देव',    'yoni' => 'वानर',  'nadi' => 'आद्य',  'syllables' => ['खी', 'खू', 'खे', 'खो']],
        ['name' => 'धनिष्ठा',     'name_short' => 'धनि.',    'lord' => 'Mars',    'gana' => 'राक्षस', 'yoni' => 'सिंह',  'nadi' => 'मध्य', 'syllables' => ['गा', 'गी', 'गू', 'गे']],
        ['name' => 'शतभिषा',      'name_short' => 'शत.',     'lord' => 'Rahu',    'gana' => 'राक्षस', 'yoni' => 'अश्व',  'nadi' => 'अंत्य', 'syllables' => ['गो', 'सा', 'सी', 'सू']],
        ['name' => 'पूर्वा भाद्रपद', 'name_short' => 'पू.भा.',  'lord' => 'Jupiter', 'gana' => 'मनुष्य', 'yoni' => 'सिंह',  'nadi' => 'आद्य', 'syllables' => ['से', 'सो', 'दा', 'दी']],
        ['name' => 'उत्तरा भाद्रपद', 'name_short' => 'उ.भाद्र', 'lord' => 'Saturn',  'gana' => 'मनुष्य', 'yoni' => 'गौ',   'nadi' => 'मध्य', 'syllables' => ['दू', 'थ', 'झ', 'ञ']],
        ['name' => 'रेवती',       'name_short' => 'रेवती',   'lord' => 'Mercury', 'gana' => 'देव',    'yoni' => 'गज',    'nadi' => 'अंत्य', 'syllables' => ['दे', 'दो', 'चा', 'ची']],
    ];

    // ──────────────────────────────────────────
    // TITHI — index 0–29
    // ──────────────────────────────────────────
    public const TITHI = [
        'शुक्ल प्रतिपदा', 'शुक्ल द्वितीया', 'शुक्ल तृतीया', 'शुक्ल चतुर्थी', 'शुक्ल पंचमी',
        'शुक्ल षष्ठी', 'शुक्ल सप्तमी', 'शुक्ल अष्टमी', 'शुक्ल नवमी', 'शुक्ल दशमी',
        'शुक्ल एकादशी', 'शुक्ल द्वादशी', 'शुक्ल त्रयोदशी', 'शुक्ल चतुर्दशी', 'पूर्णिमा',
        'कृष्ण प्रतिपदा', 'कृष्ण द्वितीया', 'कृष्ण तृतीया', 'कृष्ण चतुर्थी', 'कृष्ण पंचमी',
        'कृष्ण षष्ठी', 'कृष्ण सप्तमी', 'कृष्ण अष्टमी', 'कृष्ण नवमी', 'कृष्ण दशमी',
        'कृष्ण एकादशी', 'कृष्ण द्वादशी', 'कृष्ण त्रयोदशी', 'कृष्ण चतुर्दशी', 'अमावस्या',
    ];

    // ──────────────────────────────────────────
    // YOGA — index 0–26
    // ──────────────────────────────────────────
    public const YOGA = [
        'विष्कम्भ', 'प्रीति', 'आयुष्मान', 'सौभाग्य', 'शोभन',
        'अतिगण्ड', 'सुकर्मा', 'धृति', 'शूल', 'गण्ड',
        'वृद्धि', 'ध्रुव', 'व्याघात', 'हर्षण', 'वज्र',
        'सिद्धि', 'व्यतीपात', 'वरीयान', 'परिघ', 'शिव',
        'सिद्ध', 'साध्य', 'शुभ', 'शुक्ल', 'ब्रह्म',
        'इन्द्र', 'वैधृति',
    ];

    // ──────────────────────────────────────────
    // KARANA — 7 recurring + 4 fixed = 11 total
    // ──────────────────────────────────────────
    public const KARANA_RECURRING = ['बव', 'बालव', 'कौलव', 'तैतिल', 'गर', 'वणिज', 'विष्टि'];

    public const KARANA_FIXED = ['किंस्तुघ्न', 'शकुनि', 'चतुष्पद', 'नाग'];

    // ──────────────────────────────────────────
    // HINDU MONTHS — index 0–11 (Amanta system)
    // ──────────────────────────────────────────
    public const HINDU_MONTHS = [
        'चैत्र', 'वैशाख', 'ज्येष्ठ', 'आषाढ', 'श्रावण', 'भाद्रपद',
        'आश्विन', 'कार्तिक', 'मार्गशीर्ष', 'पौष', 'माघ', 'फाल्गुन',
    ];

    // ──────────────────────────────────────────
    // DAY NAMES — index 0 (Sunday) – 6 (Saturday)
    // ──────────────────────────────────────────
    public const DAY_NAMES = [
        'रविवार', 'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार',
    ];

    // ──────────────────────────────────────────
    // PLANET DEFINITIONS
    // ──────────────────────────────────────────
    public const PLANETS = [
        'sun' => ['id' => 'sun',     'swetest_code' => '0', 'name' => 'रवि',    'name_full' => 'सूर्य',   'abbr' => 'रवि',    'dasha_years' => 6],
        'moon' => ['id' => 'moon',    'swetest_code' => '1', 'name' => 'चंद्र',   'name_full' => 'चंद्र',   'abbr' => 'चंद्र',   'dasha_years' => 10],
        'mars' => ['id' => 'mars',    'swetest_code' => '4', 'name' => 'मंगळ',   'name_full' => 'मंगल',    'abbr' => 'मंगळ',   'dasha_years' => 7],
        'mercury' => ['id' => 'mercury', 'swetest_code' => '2', 'name' => 'बुध',    'name_full' => 'बुध',     'abbr' => 'बुध',    'dasha_years' => 17],
        'jupiter' => ['id' => 'jupiter', 'swetest_code' => '5', 'name' => 'गुरु',   'name_full' => 'गुरु',    'abbr' => 'गुरु',   'dasha_years' => 16],
        'venus' => ['id' => 'venus',   'swetest_code' => '3', 'name' => 'शुक्र',   'name_full' => 'शुक्र',   'abbr' => 'शुक्र',   'dasha_years' => 20],
        'saturn' => ['id' => 'saturn',  'swetest_code' => '6', 'name' => 'शनि',    'name_full' => 'शनि',     'abbr' => 'शनि',    'dasha_years' => 19],
        'rahu' => ['id' => 'rahu',    'swetest_code' => 't', 'name' => 'राहू',    'name_full' => 'राहू',    'abbr' => 'राहू',    'dasha_years' => 18],
        'ketu' => ['id' => 'ketu',    'swetest_code' => '',  'name' => 'केतु',    'name_full' => 'केतु',    'abbr' => 'केतु',    'dasha_years' => 7],
        'uranus' => ['id' => 'uranus',  'swetest_code' => '7', 'name' => 'हर्षल',   'name_full' => 'युरेनस',  'abbr' => 'हर्षल',   'dasha_years' => 0],
        'neptune' => ['id' => 'neptune', 'swetest_code' => '8', 'name' => 'नेप.',    'name_full' => 'नेपच्यून', 'abbr' => 'नेप.',    'dasha_years' => 0],
        'pluto' => ['id' => 'pluto',   'swetest_code' => '9', 'name' => 'प्लुटो',  'name_full' => 'प्लुटो',  'abbr' => 'प्लुटो',  'dasha_years' => 0],
    ];

    // Vimshottari Dasha sequence (planet keys in order)
    public const DASHA_SEQUENCE = ['ketu', 'venus', 'sun', 'moon', 'mars', 'rahu', 'jupiter', 'saturn', 'mercury'];

    // Nakshatra-to-Dasha-Lord mapping (index 0–26 → Dasha lord planet key)
    public const NAKSHATRA_DASHA_LORD = [
        'ketu', 'venus', 'sun', 'moon', 'mars', 'rahu', 'jupiter', 'saturn', 'mercury',
        'ketu', 'venus', 'sun', 'moon', 'mars', 'rahu', 'jupiter', 'saturn', 'mercury',
        'ketu', 'venus', 'sun', 'moon', 'mars', 'rahu', 'jupiter', 'saturn', 'mercury',
    ];

    // Varga — Nakshatra-based grouping
    public const NAKSHATRA_VARGA = [
        'अश्व',  'गज',   'मेष',  'सर्प', 'श्वान', 'मार्जार', 'मूषक', 'मेष',   'मार्जार',
        'मूषक',  'मूषक', 'गौ',   'महिष', 'व्याघ्र', 'महिष',   'व्याघ्र', 'मृग',  'मृग',
        'श्वान', 'वानर', 'नकुल', 'वानर', 'सिंह',  'अश्व',   'सिंह',  'गौ',    'गज',
    ];

    // Yunja grouping based on Nakshatra
    public const NAKSHATRA_YUNJA = [
        'आदि', 'आदि', 'आदि', 'आदि', 'आदि', 'आदि', 'आदि', 'आदि', 'आदि',
        'मध्य', 'मध्य', 'मध्य', 'मध्य', 'मध्य', 'मध्य', 'मध्य', 'मध्य', 'मध्य',
        'अंत्य', 'अंत्य', 'अंत्य', 'अंत्य', 'अंत्य', 'अंत्य', 'अंत्य', 'अंत्य', 'अंत्य',
    ];

    /**
     * Get Rashi (sign) index from longitude.
     */
    public static function getRashiIndex(float $longitude): int
    {
        return (int) floor(fmod($longitude + 360, 360) / 30);
    }

    /**
     * Get Nakshatra index from Moon's longitude.
     */
    public static function getNakshatraIndex(float $moonLongitude): int
    {
        return (int) floor(fmod($moonLongitude + 360, 360) / (360 / 27));
    }

    /**
     * Get Nakshatra Pada (1–4) from Moon's longitude.
     */
    public static function getNakshatraPada(float $moonLongitude): int
    {
        $nakshatraSpan = 360 / 27; // 13.3333...
        $posInNakshatra = fmod(fmod($moonLongitude, 360) + 360, 360) - (self::getNakshatraIndex($moonLongitude) * $nakshatraSpan);
        $padaSpan = $nakshatraSpan / 4; // 3.3333...

        return min(4, (int) floor($posInNakshatra / $padaSpan) + 1);
    }

    /**
     * Get detailed breakdown of degree within sign.
     * Returns degrees, minutes, seconds, display strings (compact "23°59'", DMS "23° 59' 10\"").
     *
     * @return array{deg: int, min: int, sec: int, display: string, display_dms: string, raw: string, decimal: float}
     */
    public static function getDegreeDetails(float $longitude): array
    {
        $totalDeg = fmod(fmod($longitude, 360) + 360, 360);
        $signDeg = fmod($totalDeg, 30);
        $degrees = (int) floor($signDeg);
        $minutes = (int) floor(($signDeg - $degrees) * 60);
        $seconds = (int) round((($signDeg - $degrees) * 60 - $minutes) * 60);

        if ($seconds >= 60) {
            $seconds -= 60;
            $minutes++;
        }
        if ($minutes >= 60) {
            $minutes -= 60;
            $degrees++;
        }

        return [
            'deg' => $degrees,
            'min' => $minutes,
            'sec' => $seconds,
            'display' => sprintf("%d°%02d'", $degrees, $minutes),
            'display_dms' => sprintf("%d° %02d' %02d\"", $degrees, $minutes, $seconds),
            'raw' => sprintf('%02d:%02d:%02d', $degrees, $minutes, $seconds),
            'decimal' => round($signDeg, 4),
        ];
    }

    /**
     * Format longitude as degrees and minutes (e.g. "23°59'").
     */
    public static function formatDegree(float $longitude): string
    {
        return self::getDegreeDetails($longitude)['display'];
    }

    /**
     * Format longitude as DMS string (e.g. "23° 59' 10\"").
     */
    public static function formatDMS(float $longitude): string
    {
        return self::getDegreeDetails($longitude)['display_dms'];
    }

    /**
     * Get the Karana name for a given karana index (0-based, 0–59).
     */
    public static function getKaranaName(int $karanaIndex): string
    {
        if ($karanaIndex === 0) {
            return self::KARANA_FIXED[0]; // किंस्तुघ्न
        } elseif ($karanaIndex >= 57) {
            return self::KARANA_FIXED[$karanaIndex - 56]; // शकुनि, चतुष्पद, नाग
        } else {
            return self::KARANA_RECURRING[($karanaIndex - 1) % 7];
        }
    }

    /**
     * Get the syllable for a Nakshatra Pada.
     */
    public static function getNakshatraSyllable(int $nakshatraIndex, int $pada): string
    {
        if ($nakshatraIndex < 0 || $nakshatraIndex > 26 || $pada < 1 || $pada > 4) {
            return '';
        }

        return self::NAKSHATRA[$nakshatraIndex]['syllables'][$pada - 1] ?? '';
    }
}
