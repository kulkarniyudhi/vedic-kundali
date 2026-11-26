<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CalculateRequest;
use App\Services\Astrology\KundaliCalculationService;
use Illuminate\Http\JsonResponse;
use InvalidArgumentException;
use Throwable;

class CalculateController extends Controller
{
    public function __construct(
        protected KundaliCalculationService $kundaliService
    ) {}

    /**
     * Handle Kundali calculation.
     */
    public function __invoke(CalculateRequest $request): JsonResponse
    {
        try {
            $result = $this->kundaliService->calculate($request->validated());

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
