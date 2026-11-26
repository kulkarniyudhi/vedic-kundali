<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CitySearchRequest;
use App\Services\Astrology\CitySearchService;
use Illuminate\Http\JsonResponse;

class CityController extends Controller
{
    public function __construct(
        protected CitySearchService $citySearchService
    ) {}

    /**
     * Handle city autocomplete search.
     */
    public function __invoke(CitySearchRequest $request): JsonResponse
    {
        $query = (string) $request->input('q', '');
        $limit = (int) $request->input('limit', 15);

        if (mb_strlen(trim($query), 'UTF-8') < 2) {
            return response()->json([
                'results' => [],
                'error' => __('validation.city_query_min'),
            ]);
        }

        $results = $this->citySearchService->search($query, $limit);

        return response()->json(['results' => $results]);
    }
}
