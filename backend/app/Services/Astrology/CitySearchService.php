<?php

namespace App\Services\Astrology;

use PDO;
use Throwable;

class CitySearchService
{
    private string $citiesDb;

    private string $citiesJson;

    public function __construct(?string $dbPath = null, ?string $jsonPath = null)
    {
        $this->citiesDb = $dbPath ?? config('astrology.cities_db', database_path('data/cities.db'));
        $this->citiesJson = $jsonPath ?? config('astrology.cities_json', database_path('data/cities.json'));
    }

    /**
     * Search Indian cities by name or district.
     *
     * @return array<int, array{name: string, state: string, district: string, lat: float, lng: float, tz: string, display: string}>
     */
    public function search(string $query, int $limit = 15): array
    {
        $query = trim($query);
        if (mb_strlen($query, 'UTF-8') < 2) {
            return [];
        }

        // Method 1: SQLite lookup
        if (file_exists($this->citiesDb) && extension_loaded('pdo_sqlite')) {
            try {
                $db = new PDO('sqlite:'.$this->citiesDb);
                $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_SILENT);

                $qLower = mb_strtolower($query, 'UTF-8');
                $qTerm = '%'.$qLower.'%';
                $qPrefix = $qLower.'%';

                $sql = 'SELECT name, state, district, lat, lng FROM cities
                        WHERE name LIKE :term OR district LIKE :term
                        ORDER BY
                          CASE
                            WHEN LOWER(name) = :exact THEN 0
                            WHEN LOWER(name) LIKE :prefix THEN 1
                            WHEN LOWER(name) LIKE :term THEN 2
                            ELSE 3
                          END,
                          priority DESC,
                          LENGTH(name) ASC
                        LIMIT :limit';

                $stmt = $db->prepare($sql);
                $stmt->bindValue(':term', $qTerm, PDO::PARAM_STR);
                $stmt->bindValue(':prefix', $qPrefix, PDO::PARAM_STR);
                $stmt->bindValue(':exact', $qLower, PDO::PARAM_STR);
                $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
                $stmt->execute();

                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
                $results = [];

                foreach ($rows as $row) {
                    $distStr = ! empty($row['district']) ? $row['district'].', ' : '';
                    $results[] = [
                        'name' => $row['name'],
                        'state' => $row['state'],
                        'district' => $row['district'] ?? '',
                        'lat' => round((float) $row['lat'], 4),
                        'lng' => round((float) $row['lng'], 4),
                        'tz' => 'Asia/Kolkata',
                        'display' => $row['name'].', '.$distStr.$row['state'],
                    ];
                }

                return $results;
            } catch (Throwable) {
                // Fallback to JSON streaming if SQLite query fails
            }
        }

        // Method 2: Memory-safe JSON streaming fallback
        if (file_exists($this->citiesJson)) {
            $fp = fopen($this->citiesJson, 'r');
            if ($fp) {
                $qLower = mb_strtolower($query, 'UTF-8');
                $qPrefix = $qLower;
                $exactMatches = [];
                $prefixMatches = [];
                $otherMatches = [];

                while (($line = fgets($fp)) !== false) {
                    $trimmed = trim($line, " \t\n\r,[]");
                    if (empty($trimmed) || $trimmed[0] !== '{') {
                        continue;
                    }

                    if (stripos($trimmed, $query) !== false) {
                        $city = json_decode($trimmed, true);
                        if (! $city || empty($city['name'])) {
                            continue;
                        }

                        $nameLower = mb_strtolower($city['name'], 'UTF-8');
                        $distLower = mb_strtolower($city['district'] ?? '', 'UTF-8');

                        if (str_contains($nameLower, $qLower) || str_contains($distLower, $qLower)) {
                            $distStr = ! empty($city['district']) ? $city['district'].', ' : '';
                            $item = [
                                'name' => $city['name'],
                                'state' => $city['state'],
                                'district' => $city['district'] ?? '',
                                'lat' => round((float) $city['lat'], 4),
                                'lng' => round((float) $city['lng'], 4),
                                'tz' => 'Asia/Kolkata',
                                'display' => $city['name'].', '.$distStr.$city['state'],
                            ];

                            if ($nameLower === $qLower) {
                                $exactMatches[] = $item;
                            } elseif (str_starts_with($nameLower, $qPrefix)) {
                                $prefixMatches[] = $item;
                            } else {
                                $otherMatches[] = $item;
                            }

                            if (count($exactMatches) + count($prefixMatches) + count($otherMatches) >= $limit) {
                                break;
                            }
                        }
                    }
                }
                fclose($fp);

                $results = array_merge($exactMatches, $prefixMatches, $otherMatches);

                return array_slice($results, 0, $limit);
            }
        }

        return [];
    }
}
