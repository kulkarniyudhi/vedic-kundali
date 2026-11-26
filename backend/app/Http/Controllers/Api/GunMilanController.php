<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\GunMilanRequest;
use App\Services\Astrology\GunMilanCalculationService;
use Illuminate\Http\JsonResponse;
use InvalidArgumentException;
use Throwable;

class GunMilanController extends Controller
{
    public function __construct(
        protected GunMilanCalculationService $gunMilanService
    ) {}

    /**
     * Handle Gun Milan matchmaking calculation.
     */
    public function __invoke(GunMilanRequest $request): JsonResponse
    {
        try {
            $result = $this->gunMilanService->calculate($request->validated());

            return response()->json($result);
        } catch (InvalidArgumentException $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
            ], 400);
        } catch (Throwable $e) {
            return response()->json([
                'success' => false,
                'error' => 'Calculation error: '.$e->getMessage(),
            ], 500);
        }
    }
}
