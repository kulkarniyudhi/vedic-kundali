<?php

namespace App\Services\Astrology;

use DateTimeInterface;
use RuntimeException;

class AstronomyEngine
{
    private string $binPath;

    private ?array $cachedResult = null;

    private string $cacheKey = '';

    public function __construct(?string $binaryPath = null)
    {
        $bin = $binaryPath ?? config('astrology.binary_path', base_path('engine/astroengine'));
        $winBin = $bin.'.exe';

        if (file_exists($bin) && is_executable($bin)) {
            $this->binPath = $bin;
        } elseif (file_exists($winBin)) {
            $this->binPath = $winBin;
        } elseif (file_exists($bin)) {
            @chmod($bin, 0755);
            $this->binPath = $bin;
        } else {
            throw new RuntimeException("Astronomy Engine binary not found at: {$bin}");
        }
    }

    /**
     * Compute full astrological data in a single call.
     *
     * @param  DateTimeInterface  $utcTime  UTC DateTime
     * @param  float  $lat  Geographic latitude
     * @param  float  $lng  Geographic longitude
     * @param  string|int  $ayanamsha  'lahiri' or 'kp' or int code
     * @return array<string, mixed>
     */
    public function compute(DateTimeInterface $utcTime, float $lat, float $lng, string|int $ayanamsha = 'lahiri'): array
    {
        $dateStr = $utcTime->format('Y-m-d');
        $timeStr = $utcTime->format('H:i:s');
        $ayanStr = (is_numeric($ayanamsha) && (int) $ayanamsha === 5)
            ? 'kp'
            : (is_string($ayanamsha) ? strtolower($ayanamsha) : 'lahiri');

        $key = "{$dateStr}_{$timeStr}_{$lat}_{$lng}_{$ayanStr}";
        if ($this->cacheKey === $key && $this->cachedResult !== null) {
            return $this->cachedResult;
        }

        $cmd = sprintf(
            '%s %s %s %F %F %s 2>&1',
            escapeshellarg($this->binPath),
            escapeshellarg($dateStr),
            escapeshellarg($timeStr),
            $lat,
            $lng,
            escapeshellarg($ayanStr)
        );

        $output = shell_exec($cmd);
        if ($output === null || empty(trim($output))) {
            throw new RuntimeException("Astronomy Engine failed to execute: {$cmd}");
        }

        $data = json_decode($output, true);
        if (! $data || empty($data['success'])) {
            throw new RuntimeException('Astronomy Engine returned invalid output: '.substr($output, 0, 200));
        }

        $this->cacheKey = $key;
        $this->cachedResult = $data;

        return $data;
    }

    /**
     * Get sidereal planetary positions.
     *
     * @return array<string, array{longitude: float, speed: float, retrograde: bool}>
     */
    public function getPlanetPositions(DateTimeInterface $utcTime, int $ayanamshaCode = 1, float $lat = 0.0, float $lng = 0.0): array
    {
        $data = $this->compute($utcTime, $lat, $lng, $ayanamshaCode);

        return $data['planets'];
    }

    /**
     * Get house cusps and Ascendant.
     *
     * @return array{ascendant: float, mc: float, houses: array<int, float>, planets: array<string, float>}
     */
    public function getHouseCusps(DateTimeInterface $utcTime, float $lat, float $lng, int $ayanamshaCode = 1): array
    {
        $data = $this->compute($utcTime, $lat, $lng, $ayanamshaCode);

        $houses = [];
        foreach ($data['houses'] as $h => $deg) {
            $houses[(int) $h] = (float) $deg;
        }

        return [
            'ascendant' => (float) $data['ascendant'],
            'mc' => (float) $data['mc'],
            'houses' => $houses,
            'planets' => array_map(fn ($p) => $p['longitude'], $data['planets']),
        ];
    }

    /**
     * Get Ayanamsha value.
     */
    public function getAyanamsha(DateTimeInterface $utcTime, int $ayanamshaCode = 1): float
    {
        $data = $this->compute($utcTime, 0.0, 0.0, $ayanamshaCode);

        return (float) $data['ayanamsha'];
    }
}
