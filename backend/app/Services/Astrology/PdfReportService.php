<?php

namespace App\Services\Astrology;

use Mpdf\Mpdf;
use Mpdf\Output\Destination;

class PdfReportService
{
    public function __construct(
        protected ChartRenderer $renderer
    ) {}

    /**
     * Get or create temp directory for mPDF.
     */
    protected function getTempDir(): string
    {
        $userSuffix = function_exists('posix_geteuid') ? ('_'.posix_geteuid()) : ('_'.getmyuid());
        $tempDir = sys_get_temp_dir().'/kundali_mpdf'.$userSuffix;
        if (! file_exists($tempDir)) {
            @mkdir($tempDir, 0777, true);
            @chmod($tempDir, 0777);
        }

        return $tempDir;
    }

    /**
     * Helper to clean SVG of title tags.
     */
    protected function cleanSvg(string $svg): string
    {
        return (string) preg_replace('/<title>.*?<\/title>/s', '', $svg);
    }

    /**
     * Build planet map for ChartRenderer.
     *
     * @param  array<int, array<string, mixed>>  $planetDetails
     * @return array<string, array<string, mixed>>
     */
    protected function buildPlanetMap(array $planetDetails): array
    {
        $map = [];
        foreach ($planetDetails as $p) {
            if (($p['id'] ?? '') !== 'lagna') {
                $map[$p['id']] = [
                    'retrograde' => $p['retrograde'] ?? false,
                    'degree' => $p['degree'] ?? '',
                    'degree_dms' => $p['degree_dms'] ?? $p['degree'] ?? '',
                    'rashi' => $p['rashi'] ?? '',
                    'name' => $p['name'] ?? '',
                ];
            }
        }

        return $map;
    }

    /**
     * Generate Vedic Kundali PDF as raw binary string.
     *
     * @param  array<string, mixed>  $data
     * @return string PDF binary
     */
    public function generateKundaliPdf(array $data): string
    {
        $planetMap = $this->buildPlanetMap($data['planet_details'] ?? []);

        $lagnaSvg = $this->renderer->createChartSVG($data['charts']['lagna'], $planetMap);
        $navamshaSvg = $this->renderer->createChartSVG($data['charts']['navamsha'], $planetMap);
        $chalitSvg = $this->renderer->createChartSVG($data['charts']['chalit'], $planetMap);
        $chandraSvg = $this->renderer->createChartSVG($data['charts']['chandra'], $planetMap);

        $info = $data['birth_info'];
        $panchang = $data['panchang'];
        $cal = $data['hindu_calendar'];
        $ayan = $data['ayanamsha'];

        $html = '
<style>
    body { font-family: freeserif, sans-serif; color: #2c1a11; font-size: 14pt; }
    h1 { text-align: center; color: #d45d00; font-size: 26pt; margin-bottom: 5px; }
    h2 { color: #c84b31; font-size: 20pt; border-bottom: 1px solid #d45d00; padding-bottom: 5px; margin-top: 30px; }
    .subtitle { text-align: center; color: #5e412f; font-size: 14pt; margin-bottom: 20px; }
    .grid { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    .grid td { padding: 8px 5px; vertical-align: top; width: 50%; font-size: 14pt; }
    .label { color: #5e412f; font-weight: bold; width: 150px; display: inline-block; }
    .value { color: #2c1a11; }
    .chart-wrapper { text-align: center; margin-bottom: 20px; }
    .chart-container { display: inline-block; width: 45%; text-align: center; margin-bottom: 30px; }
    .chart-title { font-size: 18pt; color: #c84b31; margin-bottom: 10px; font-weight: bold; }
    .data-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    .data-table th { background-color: #f2ebd9; color: #c84b31; padding: 10px; text-align: left; border-bottom: 1px solid #d45d00; font-size: 14pt; }
    .data-table td { padding: 10px; border-bottom: 1px solid #e0e0e0; font-size: 14pt; }
</style>

<h1>॥ वैदिक कुण्डली ॥</h1>
<div class="subtitle">Premium Astrology Engine • '.htmlspecialchars((string) ($ayan['system'] ?? 'Lahiri')).' Ayanamsha</div>

<h2>॥ जन्म विवरण व पंचांग ॥</h2>
<table class="grid">
    <tr>
        <td>
            <div><span class="label">जन्म दिनांक :</span> <span class="value">'.htmlspecialchars((string) ($info['date'] ?? '')).'</span></div>
            <div><span class="label">जन्म वेळ (इष्टघटी) :</span> <span class="value">'.htmlspecialchars((string) ($info['time'] ?? '')).' ('.htmlspecialchars((string) ($info['ishta_ghati']['display'] ?? '')).')</span></div>
            <div><span class="label">स्थान :</span> <span class="value">'.htmlspecialchars((string) ($info['place'] ?? '')).' / India</span></div>
            <div><span class="label">हिन्दु महिना (का.) :</span> <span class="value">'.htmlspecialchars((string) (($cal['vikram_kartik'] ?? '').' - '.($cal['hindu_month'] ?? ''))).'</span></div>
            <div><span class="label">चंद्र राशी :</span> <span class="value">'.htmlspecialchars((string) ($panchang['rashi']['display'] ?? '')).'</span></div>
            <div><span class="label">नक्षत्र :</span> <span class="value">'.htmlspecialchars((string) ($panchang['nakshatra']['display'] ?? '')).'</span></div>
            <div><span class="label">करण :</span> <span class="value">'.htmlspecialchars((string) ($panchang['karana']['name'] ?? '')).'</span></div>
        </td>
        <td>
            <div><span class="label">जन्म दिवस :</span> <span class="value">'.htmlspecialchars((string) ($info['day'] ?? '')).'</span></div>
            <div><span class="label">अयनांश :</span> <span class="value">'.htmlspecialchars((string) ($ayan['display'] ?? '')).' ( '.htmlspecialchars((string) ($ayan['system'] ?? '')).' )</span></div>
            <div><span class="label">हिन्दु महिना (चै.) :</span> <span class="value">'.htmlspecialchars((string) (($cal['vikram_chaitra'] ?? '').' - '.($cal['hindu_month'] ?? ''))).'</span></div>
            <div><span class="label">तिथी :</span> <span class="value">'.htmlspecialchars((string) ($panchang['tithi']['display'] ?? '')).'</span></div>
            <div><span class="label">योग :</span> <span class="value">'.htmlspecialchars((string) ($panchang['yoga']['name'] ?? '')).'</span></div>
            <div><span class="label">शक संवत् :</span> <span class="value">'.htmlspecialchars((string) ($cal['shaka_samvat'] ?? '')).'</span></div>
        </td>
    </tr>
</table>

<h2>॥ कुण्डली (Lagna & Navamsha) ॥</h2>
<div style="width: 48%; float: left; text-align: center;">
    <div class="chart-title">'.htmlspecialchars((string) ($data['charts']['lagna']['title'] ?? 'लग्न कुंडली')).'</div>
    '.$lagnaSvg.'
</div>
<div style="width: 48%; float: right; text-align: center;">
    <div class="chart-title">'.htmlspecialchars((string) ($data['charts']['navamsha']['title'] ?? 'नवमांश कुंडली')).'</div>
    '.$navamshaSvg.'
</div>
<div style="clear: both; margin-bottom: 20px;"></div>

<pagebreak />

<h2>॥ कुण्डली (Chalit & Chandra) ॥</h2>
<div style="width: 48%; float: left; text-align: center;">
    <div class="chart-title">'.htmlspecialchars((string) ($data['charts']['chalit']['title'] ?? 'चलित कुंडली')).'</div>
    '.$chalitSvg.'
</div>
<div style="width: 48%; float: right; text-align: center;">
    <div class="chart-title">'.htmlspecialchars((string) ($data['charts']['chandra']['title'] ?? 'चंद्र राशी कुंडली')).'</div>
    '.$chandraSvg.'
</div>
<div style="clear: both; margin-bottom: 20px;"></div>

<pagebreak />

<h2>॥ निरयण स्पष्ट ग्रह ॥</h2>
<table class="data-table" style="width: 100%;">
    <thead>
        <tr>
            <th>ग्रह</th>
            <th>राशी</th>
            <th>अंश</th>
            <th>नक्षत्र</th>
            <th>पद</th>
        </tr>
    </thead>
    <tbody>';

        foreach ($data['planet_details'] as $p) {
            $retroMark = ! empty($p['retro_marker']) ? $p['retro_marker'].' ' : '';
            $degDisplay = $p['degree_dms'] ?? $p['degree'] ?? '';
            $padaDisplay = $p['pada'].(! empty($p['syllable']) ? ' ('.$p['syllable'].')' : '');
            $html .= '<tr>
            <td><strong>'.htmlspecialchars((string) $p['name']).'</strong></td>
            <td>'.htmlspecialchars((string) ($retroMark.$p['rashi'])).'</td>
            <td><strong>'.htmlspecialchars((string) $degDisplay).'</strong></td>
            <td>'.htmlspecialchars((string) $p['nakshatra']).'</td>
            <td>'.htmlspecialchars((string) $padaDisplay).'</td>
        </tr>';
        }

        $html .= '
    </tbody>
</table>

<h2>॥ विंशोत्तरी महादशा ॥</h2>
<table class="data-table" style="width: 100%;">
    <thead>
        <tr>
            <th>महादशा</th>
            <th>समाप्ती तारीख</th>
        </tr>
    </thead>
    <tbody>';

        foreach ($data['mahadasha'] as $p) {
            $html .= '<tr>
            <td><strong>'.htmlspecialchars((string) $p['planet_name']).'</strong></td>
            <td>'.htmlspecialchars((string) $p['end_date']).'</td>
        </tr>';
        }

        $html .= '
    </tbody>
</table>';

        $mpdf = new Mpdf([
            'tempDir' => $this->getTempDir(),
            'mode' => 'utf-8',
            'format' => 'A4',
            'margin_left' => 15,
            'margin_right' => 15,
            'margin_top' => 16,
            'margin_bottom' => 16,
            'margin_header' => 9,
            'margin_footer' => 9,
            'autoScriptToLang' => true,
            'autoLangToFont' => true,
        ]);

        $mpdf->SetTitle('Vedic Kundali');
        $mpdf->WriteHTML($html);

        return $mpdf->Output('', Destination::STRING_RETURN);
    }

    /**
     * Generate Gun Milan PDF report as raw binary string.
     *
     * @param  array<string, mixed>  $data
     * @return array{binary: string, filename: string}
     */
    public function generateGunMilanPdf(array $data): array
    {
        $boy = $data['boy'];
        $girl = $data['girl'];
        $gunMilan = $data['gun_milan'];
        $mangal = $data['mangal_dosha'] ?? [];

        $boyPlanetMap = $this->buildPlanetMap($boy['planet_details'] ?? []);
        $girlPlanetMap = $this->buildPlanetMap($girl['planet_details'] ?? []);

        $boyLagnaSvg = $this->cleanSvg($this->renderer->createChartSVG($boy['charts']['lagna'], $boyPlanetMap));
        $girlLagnaSvg = $this->cleanSvg($this->renderer->createChartSVG($girl['charts']['lagna'], $girlPlanetMap));

        $boyNavamshaSvg = $this->cleanSvg($this->renderer->createChartSVG($boy['charts']['navamsha'], $boyPlanetMap));
        $girlNavamshaSvg = $this->cleanSvg($this->renderer->createChartSVG($girl['charts']['navamsha'], $girlPlanetMap));

        $boyChalitSvg = $this->cleanSvg($this->renderer->createChartSVG($boy['charts']['chalit'], $boyPlanetMap));
        $girlChalitSvg = $this->cleanSvg($this->renderer->createChartSVG($girl['charts']['chalit'], $girlPlanetMap));

        $bInfo = $boy['birth_info'];
        $gInfo = $girl['birth_info'];
        $bPan = $boy['panchang'];
        $gPan = $girl['panchang'];
        $bAvk = $boy['avakhada'];
        $gAvk = $girl['avakhada'];

        $boyName = ! empty($bInfo['name']) ? $bInfo['name'] : 'युवक (Boy)';
        $girlName = ! empty($gInfo['name']) ? $gInfo['name'] : 'युवती (Girl)';
        $ayanName = $boy['ayanamsha']['system'] ?? 'Lahiri';

        $score = (float) ($gunMilan['total_obtained'] ?? 0);
        $scoreBadgeColor = ($score >= 18) ? '#2e7d32' : '#c62828';
        $scoreBgColor = ($score >= 18) ? '#e8f5e9' : '#ffebee';

        $html = '
<style>
    body { font-family: freeserif, sans-serif; color: #2c1a11; font-size: 10pt; line-height: 1.3; }
    h1 { text-align: center; color: #d45d00; font-size: 18pt; margin: 0 0 3px 0; }
    h2 { color: #c84b31; font-size: 12pt; border-bottom: 1px solid #d45d00; padding-bottom: 2px; margin: 10px 0 6px 0; font-weight: bold; }
    .subtitle { text-align: center; color: #5e412f; font-size: 9.5pt; margin-bottom: 10px; }
    
    .compare-table { width: 100%; border-collapse: collapse; margin-bottom: 8px; }
    .compare-table th { background-color: #f2ebd9; color: #c84b31; padding: 5px 8px; font-size: 10pt; border: 1px solid #e0d0b8; text-align: center; }
    .compare-table td { padding: 4px 7px; font-size: 9.5pt; border: 1px solid #ebdcc5; vertical-align: middle; }
    .col-label { width: 28%; font-weight: bold; color: #5e412f; background-color: #faf5ed; text-align: center; }
    .col-boy { width: 36%; color: #1a365d; }
    .col-girl { width: 36%; color: #701a45; }
    .person-header-boy { background-color: #e8f0fe !important; color: #1a365d !important; font-weight: bold; }
    .person-header-girl { background-color: #fce8f3 !important; color: #701a45 !important; font-weight: bold; }

    .guna-table { width: 100%; border-collapse: collapse; margin: 6px 0; }
    .guna-table th { background-color: #f2ebd9; color: #c84b31; padding: 5px; font-size: 10pt; border: 1px solid #d45d00; text-align: center; }
    .guna-table td { padding: 4px 5px; border: 1px solid #ebdcc5; font-size: 9.5pt; text-align: center; }
    .guna-table td.guna-name { font-weight: bold; text-align: left; padding-left: 8px; color: #2c1a11; }
    .guna-table tr:nth-child(even) td { background-color: #fdfbf7; }
    .guna-total-row td { background-color: #f4ecdc !important; font-weight: bold; font-size: 10.5pt; border-top: 2px solid #d45d00; }
    .score-highlight { font-size: 13pt; color: '.$scoreBadgeColor.'; font-weight: bold; }

    .mangal-box { border: 1px solid #ebdcc5; border-radius: 4px; padding: 7px 9px; background-color: #fff9f5; margin-bottom: 6px; }
    .mangal-title { font-size: 11pt; font-weight: bold; color: #c84b31; margin-bottom: 4px; }
    .mangal-col { width: 49%; vertical-align: top; }
    .mangal-badge { display: inline-block; padding: 2px 7px; font-size: 9pt; font-weight: bold; border-radius: 3px; }
    .mangal-badge-none { background-color: #e8f5e9; color: #2e7d32; }
    .mangal-badge-warn { background-color: #fff3e0; color: #e65100; }
    .mangal-badge-danger { background-color: #ffebee; color: #c62828; }
    .mangal-verdict { padding: 5px 8px; background-color: #fff; border-left: 3px solid #d45d00; font-size: 9.5pt; font-weight: bold; color: #2c1a11; margin-top: 5px; }

    .conclusion-card { border: 1.5px solid #d45d00; border-radius: 4px; padding: 7px 10px; background-color: '.$scoreBgColor.'; margin-top: 6px; text-align: center; }
    .conclusion-text { font-size: 10.5pt; font-weight: bold; color: '.$scoreBadgeColor.'; line-height: 1.35; }
    .note-text { font-size: 8pt; color: #7a6352; font-style: italic; margin-top: 3px; }

    .chart-col { width: 50%; text-align: center; vertical-align: top; }
    .chart-box { width: 230px; margin: 0 auto; }
    .chart-title { font-size: 11pt; color: #c84b31; margin-bottom: 5px; font-weight: bold; }
    .planet-table { width: 100%; border-collapse: collapse; margin-top: 3px; }
    .planet-table th { background-color: #f2ebd9; color: #c84b31; padding: 4px 5px; font-size: 8.5pt; border: 1px solid #d45d00; }
    .planet-table td { padding: 3px 4px; border: 1px solid #ebdcc5; font-size: 8pt; text-align: center; }
    .planet-table tr:nth-child(even) td { background-color: #fdfbf7; }
</style>

<h1>॥ वैदिक कुण्डली - गुण मिलान पत्रिका ॥</h1>
<div class="subtitle">Ashtakoot Matchmaking Report • '.htmlspecialchars((string) $ayanName).' Ayanamsha</div>

<h2>॥ जन्म विवरण व पंचांग तुलना ॥</h2>
<table class="compare-table">
    <thead>
        <tr>
            <th class="person-header-boy">युवक : '.htmlspecialchars((string) $boyName).'</th>
            <th>तपशील (Parameter)</th>
            <th class="person-header-girl">युवती : '.htmlspecialchars((string) $girlName).'</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td class="col-boy">'.htmlspecialchars((string) ($bInfo['date'] ?? '')).' ('.htmlspecialchars((string) ($bInfo['day'] ?? '')).')</td>
            <td class="col-label">जन्म दिनांक (दिवस)</td>
            <td class="col-girl">'.htmlspecialchars((string) ($gInfo['date'] ?? '')).' ('.htmlspecialchars((string) ($gInfo['day'] ?? '')).')</td>
        </tr>
        <tr>
            <td class="col-boy">'.htmlspecialchars((string) ($bInfo['time'] ?? '')).' ('.htmlspecialchars((string) ($bInfo['ishta_ghati']['display'] ?? '')).')</td>
            <td class="col-label">जन्म वेळ (इष्टघटी)</td>
            <td class="col-girl">'.htmlspecialchars((string) ($gInfo['time'] ?? '')).' ('.htmlspecialchars((string) ($gInfo['ishta_ghati']['display'] ?? '')).')</td>
        </tr>
        <tr>
            <td class="col-boy">'.htmlspecialchars((string) ($bInfo['place'] ?? '')).' ('.htmlspecialchars((string) ($bInfo['state'] ?? '')).')</td>
            <td class="col-label">जन्म स्थान</td>
            <td class="col-girl">'.htmlspecialchars((string) ($gInfo['place'] ?? '')).' ('.htmlspecialchars((string) ($gInfo['state'] ?? '')).')</td>
        </tr>
        <tr>
            <td class="col-boy"><strong>'.htmlspecialchars((string) ($bPan['rashi']['display'] ?? '')).'</strong></td>
            <td class="col-label">चंद्र राशी</td>
            <td class="col-girl"><strong>'.htmlspecialchars((string) ($gPan['rashi']['display'] ?? '')).'</strong></td>
        </tr>
        <tr>
            <td class="col-boy">'.htmlspecialchars((string) ($bPan['nakshatra']['display'] ?? '')).'</td>
            <td class="col-label">जन्म नक्षत्र व चरण</td>
            <td class="col-girl">'.htmlspecialchars((string) ($gPan['nakshatra']['display'] ?? '')).'</td>
        </tr>
        <tr>
            <td class="col-boy">'.htmlspecialchars((string) ($bAvk['gana']['value'] ?? ($bAvk['gana'] ?? ''))).' / '.htmlspecialchars((string) ($bAvk['nadi']['value'] ?? ($bAvk['nadi'] ?? ''))).'</td>
            <td class="col-label">गण / नाडी</td>
            <td class="col-girl">'.htmlspecialchars((string) ($gAvk['gana']['value'] ?? ($gAvk['gana'] ?? ''))).' / '.htmlspecialchars((string) ($gAvk['nadi']['value'] ?? ($gAvk['nadi'] ?? ''))).'</td>
        </tr>
        <tr>
            <td class="col-boy">'.htmlspecialchars((string) ($bAvk['yoni']['value'] ?? ($bAvk['yoni'] ?? ''))).' / '.htmlspecialchars((string) ($bAvk['varna']['value'] ?? ($bAvk['varna'] ?? ''))).'</td>
            <td class="col-label">योनि / वर्ण</td>
            <td class="col-girl">'.htmlspecialchars((string) ($gAvk['yoni']['value'] ?? ($gAvk['yoni'] ?? ''))).' / '.htmlspecialchars((string) ($gAvk['varna']['value'] ?? ($gAvk['varna'] ?? ''))).'</td>
        </tr>
    </tbody>
</table>

<h2>॥ अष्टकूट गुणा वर्णन टेबल ॥</h2>
<table class="guna-table">
    <thead>
        <tr>
            <th style="width: 25%;">गुणा (Koota)</th>
            <th style="width: 25%;">युवक ('.htmlspecialchars((string) $boyName).')</th>
            <th style="width: 25%;">युवती ('.htmlspecialchars((string) $girlName).')</th>
            <th style="width: 12%;">कमाल</th>
            <th style="width: 13%;">प्राप्त</th>
        </tr>
    </thead>
    <tbody>';

        foreach ($gunMilan['gunas'] as $g) {
            $noteStar = ! empty($g['note']) ? '*' : '';
            $hasPoints = isset($g['max_points']) && is_numeric($g['max_points']);
            $maxDisplay = $hasPoints ? (int) $g['max_points'] : '-';
            if ($hasPoints) {
                $obtainedDisplay = ($g['obtained'] == (int) $g['obtained']) ? (int) $g['obtained'] : number_format($g['obtained'], 1);
                $obtainedHtml = '<strong>'.$obtainedDisplay.'</strong>';
            } else {
                $obtainedHtml = '-';
            }
            $html .= '<tr>
            <td class="guna-name">'.htmlspecialchars((string) $g['name']).' <span style="font-size: 8pt; color: #5e412f;">('.htmlspecialchars((string) $g['name_en']).')'.$noteStar.'</span></td>
            <td>'.htmlspecialchars((string) $g['boy_value']).'</td>
            <td>'.htmlspecialchars((string) $g['girl_value']).'</td>
            <td>'.$maxDisplay.'</td>
            <td>'.$obtainedHtml.'</td>
        </tr>';
        }

        $html .= '
        <tr class="guna-total-row">
            <td colspan="3" style="text-align: right; padding-right: 12px;"><strong>एकूण प्राप्त गुण (Total Gunas) :</strong></td>
            <td><strong>'.(int) $gunMilan['total_max'].'</strong></td>
            <td><span class="score-highlight">'.$gunMilan['total_obtained'].'</span></td>
        </tr>
        <tr class="guna-total-row">
            <td colspan="3" style="text-align: right; padding-right: 12px;"><strong>गुण प्रतिशत (Percentage) :</strong></td>
            <td colspan="2"><strong>'.number_format($gunMilan['percentage'], 1).' %</strong></td>
        </tr>
    </tbody>
</table>

<h2>॥ मंगळ दोष विचार (भाव चलित कुंडलीनुसार) ॥</h2>
<div class="mangal-box">';

        $bM = $mangal['boy'] ?? [];
        $gM = $mangal['girl'] ?? [];

        $bHasMangal = ! empty($bM['has_mangal']);
        $gHasMangal = ! empty($gM['has_mangal']);

        $bStatusText = $bHasMangal ? 'मंगळी' : 'मंगळ दोष नाही';
        $gStatusText = $gHasMangal ? 'मंगळी' : 'मंगळ दोष नाही';

        $bBadgeClass = $bHasMangal ? 'mangal-badge-danger' : 'mangal-badge-none';
        $gBadgeClass = $gHasMangal ? 'mangal-badge-danger' : 'mangal-badge-none';

        $bDesc = $bM['description'] ?? '';
        $gDesc = $gM['description'] ?? '';
        $mangalSummary = $mangal['summary'] ?? ($mangal['status'] ?? '');

        $html .= '
<table style="width: 100%; border: none;">
    <tr>
        <td class="mangal-col" style="border: none; padding-right: 8px;">
            <div style="font-weight: bold; color: #1a365d; font-size: 10pt; margin-bottom: 3px;">
                '.htmlspecialchars((string) $boyName).' मंगळ स्थिती: <span class="mangal-badge '.$bBadgeClass.'">'.htmlspecialchars((string) $bStatusText).'</span>
            </div>
            <div style="font-size: 9pt; color: #444;">भाव चलित स्थान: <strong>'.htmlspecialchars((string) ($bM['chalit_house'] ?? '-')).'</strong> | लग्न स्थान: <strong>'.htmlspecialchars((string) ($bM['lagna_house'] ?? '-')).'</strong></div>
            <div style="font-size: 8.5pt; color: #666; margin-top: 2px;">'.htmlspecialchars((string) $bDesc).'</div>
        </td>
        <td class="mangal-col" style="border: none; padding-left: 8px; border-left: 1px solid #ebdcc5;">
            <div style="font-weight: bold; color: #701a45; font-size: 10pt; margin-bottom: 3px;">
                '.htmlspecialchars((string) $girlName).' मंगळ स्थिती: <span class="mangal-badge '.$gBadgeClass.'">'.htmlspecialchars((string) $gStatusText).'</span>
            </div>
            <div style="font-size: 9pt; color: #444;">भाव चलित स्थान: <strong>'.htmlspecialchars((string) ($gM['chalit_house'] ?? '-')).'</strong> | लग्न स्थान: <strong>'.htmlspecialchars((string) ($gM['lagna_house'] ?? '-')).'</strong></div>
            <div style="font-size: 8.5pt; color: #666; margin-top: 2px;">'.htmlspecialchars((string) $gDesc).'</div>
        </td>
    </tr>
</table>';

        if (! empty($mangalSummary)) {
            $html .= '<div class="mangal-verdict">निर्णय: '.htmlspecialchars((string) $mangalSummary).'</div>';
        }

        $html .= '
</div>

<div class="conclusion-card">
    <div class="conclusion-text">॥ '.htmlspecialchars((string) ($gunMilan['conclusion'] ?? '')).' ॥</div>
    <div class="note-text">* भकूट विचार कालनिर्णयानुसार केला आहे. वरील निर्णय अवकहडा चक्र व मंगळ दोषाच्या आधारे दिला आहे.</div>
</div>

<pagebreak />

<h1>॥ लग्न कुण्डली व ग्रह स्थिती ॥</h1>
<div class="subtitle">'.htmlspecialchars((string) $boyName).' & '.htmlspecialchars((string) $girlName).' • Lagna Kundali & Planetary Longitudes</div>

<h2>॥ लग्न कुंडली तुलना (Lagna Kundali Comparison) ॥</h2>
<table style="width: 100%; border: none; margin-bottom: 8px;">
    <tr>
        <td class="chart-col" style="border: none; padding-right: 10px;">
            <div class="chart-title" style="color: #1a365d;">'.htmlspecialchars((string) $boyName).' - लग्न कुंडली</div>
            <div class="chart-box">'.$boyLagnaSvg.'</div>
        </td>
        <td class="chart-col" style="border: none; padding-left: 10px;">
            <div class="chart-title" style="color: #701a45;">'.htmlspecialchars((string) $girlName).' - लग्न कुंडली</div>
            <div class="chart-box">'.$girlLagnaSvg.'</div>
        </td>
    </tr>
</table>

<h2>॥ निरयण स्पष्ट ग्रह स्थिती (Planetary Longitudes) ॥</h2>
<table style="width: 100%; border: none;">
    <tr>
        <td style="width: 49%; vertical-align: top; border: none; padding-right: 6px;">
            <div style="font-weight: bold; color: #1a365d; font-size: 9.5pt; margin-bottom: 2px; text-align: center;">'.htmlspecialchars((string) $boyName).' - ग्रह स्थिती</div>
            <table class="planet-table">
                <thead>
                    <tr>
                        <th>ग्रह</th>
                        <th>राशी</th>
                        <th>अंश</th>
                        <th>नक्षत्र</th>
                        <th>पद</th>
                    </tr>
                </thead>
                <tbody>';

        foreach ($boy['planet_details'] as $p) {
            $retro = ! empty($p['retrograde']) && $p['id'] !== 'rahu' && $p['id'] !== 'ketu' ? ' (व)' : '';
            $html .= '<tr>
            <td><strong>'.htmlspecialchars((string) $p['name']).$retro.'</strong></td>
            <td>'.htmlspecialchars((string) $p['rashi']).'</td>
            <td>'.htmlspecialchars((string) ($p['degree_dms'] ?? $p['degree'] ?? '')).'</td>
            <td>'.htmlspecialchars((string) $p['nakshatra']).'</td>
            <td>'.htmlspecialchars((string) ($p['pada'].(! empty($p['syllable']) ? ' ('.$p['syllable'].')' : ''))).'</td>
        </tr>';
        }

        $html .= '
                </tbody>
            </table>
        </td>
        <td style="width: 49%; vertical-align: top; border: none; padding-left: 6px;">
            <div style="font-weight: bold; color: #701a45; font-size: 9.5pt; margin-bottom: 2px; text-align: center;">'.htmlspecialchars((string) $girlName).' - ग्रह स्थिती</div>
            <table class="planet-table">
                <thead>
                    <tr>
                        <th>ग्रह</th>
                        <th>राशी</th>
                        <th>अंश</th>
                        <th>नक्षत्र</th>
                        <th>पद</th>
                    </tr>
                </thead>
                <tbody>';

        foreach ($girl['planet_details'] as $p) {
            $retro = ! empty($p['retrograde']) && $p['id'] !== 'rahu' && $p['id'] !== 'ketu' ? ' (व)' : '';
            $html .= '<tr>
            <td><strong>'.htmlspecialchars((string) $p['name']).$retro.'</strong></td>
            <td>'.htmlspecialchars((string) $p['rashi']).'</td>
            <td>'.htmlspecialchars((string) ($p['degree_dms'] ?? $p['degree'] ?? '')).'</td>
            <td>'.htmlspecialchars((string) $p['nakshatra']).'</td>
            <td>'.htmlspecialchars((string) ($p['pada'].(! empty($p['syllable']) ? ' ('.$p['syllable'].')' : ''))).'</td>
        </tr>';
        }

        $html .= '
                </tbody>
            </table>
        </td>
    </tr>
</table>

<pagebreak />

<h1>॥ नवमांश व भाव चलित कुण्डली तुलना ॥</h1>
<div class="subtitle">'.htmlspecialchars((string) $boyName).' & '.htmlspecialchars((string) $girlName).' • Navamsha (D9) & Bhava Chalit Kundali</div>

<h2>॥ नवमांश कुंडली तुलना (D9 Navamsha Comparison) ॥</h2>
<table style="width: 100%; border: none; margin-bottom: 10px;">
    <tr>
        <td class="chart-col" style="border: none; padding-right: 10px;">
            <div class="chart-title" style="color: #1a365d;">'.htmlspecialchars((string) $boyName).' - नवमांश कुंडली</div>
            <div class="chart-box">'.$boyNavamshaSvg.'</div>
        </td>
        <td class="chart-col" style="border: none; padding-left: 10px;">
            <div class="chart-title" style="color: #701a45;">'.htmlspecialchars((string) $girlName).' - नवमांश कुंडली</div>
            <div class="chart-box">'.$girlNavamshaSvg.'</div>
        </td>
    </tr>
</table>

<h2>॥ भाव चलित कुंडली तुलना (Bhava Chalit Comparison) ॥</h2>
<table style="width: 100%; border: none;">
    <tr>
        <td class="chart-col" style="border: none; padding-right: 10px;">
            <div class="chart-title" style="color: #1a365d;">'.htmlspecialchars((string) $boyName).' - भाव चलित कुंडली</div>
            <div class="chart-box">'.$boyChalitSvg.'</div>
        </td>
        <td class="chart-col" style="border: none; padding-left: 10px;">
            <div class="chart-title" style="color: #701a45;">'.htmlspecialchars((string) $girlName).' - भाव चलित कुंडली</div>
            <div class="chart-box">'.$girlChalitSvg.'</div>
        </td>
    </tr>
</table>';

        $mpdf = new Mpdf([
            'tempDir' => $this->getTempDir(),
            'mode' => 'utf-8',
            'format' => 'A4',
            'margin_left' => 12,
            'margin_right' => 12,
            'margin_top' => 12,
            'margin_bottom' => 12,
            'margin_header' => 6,
            'margin_footer' => 6,
            'autoScriptToLang' => true,
            'autoLangToFont' => true,
        ]);

        $asciiBoy = preg_replace('/[^a-zA-Z0-9_-]/', '', (string) $boyName);
        $asciiGirl = preg_replace('/[^a-zA-Z0-9_-]/', '', (string) $girlName);
        $filename = ($asciiBoy !== '' && $asciiGirl !== '')
            ? "gunmilan_{$asciiBoy}_{$asciiGirl}.pdf"
            : 'vedic_gunmilan.pdf';

        $mpdf->SetTitle('Gun Milan - '.$boyName.' & '.$girlName);
        $mpdf->SetFooter('॥ वैदिक कुण्डली - गुण मिलान ॥|पान क्र. {PAGENO} / {nbpg}|Astronomy Engine');
        $mpdf->WriteHTML($html);

        return [
            'binary' => $mpdf->Output('', Destination::STRING_RETURN),
            'filename' => $filename,
        ];
    }
}
