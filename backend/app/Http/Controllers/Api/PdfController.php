<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\Astrology\PdfReportService;
use App\Services\Flagsmith\FlagsmithService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;
use Throwable;

class PdfController extends Controller
{
    public function __construct(
        protected PdfReportService $pdfService
    ) {}

    /**
     * Parse incoming data payload from either form field or JSON request body.
     *
     * @return array<string, mixed>|null
     */
    protected function parsePayload(Request $request): ?array
    {
        $payload = $request->input('payload');
        if (is_string($payload)) {
            $data = json_decode($payload, true);
            if (is_array($data)) {
                return $data;
            }
        } elseif (is_array($payload)) {
            return $payload;
        }

        $all = $request->all();
        if (! empty($all) && (isset($all['success']) || isset($all['boy']) || isset($all['charts']))) {
            return $all;
        }

        return null;
    }

    /**
     * Generate & stream Vedic Kundali PDF report.
     */
    public function kundali(Request $request): Response
    {
        $data = $this->parsePayload($request);

        if (! $data || empty($data['success']) || empty($data['birth_info']) || empty($data['charts'])) {
            return response('Invalid data payload.', 400, [
                'Content-Type' => 'text/plain; charset=utf-8',
            ]);
        }

        try {
            // Log experiment variation for Flagsmith A/B test tracking
            $user = $request->user();
            if ($user) {
                try {
                    $flagsmith = app(FlagsmithService::class);
                    $variation = $flagsmith->getFlagValue('kundali_result_layout', $user->email);

                    Log::info('Flagsmith Experiment: PDF Download', [
                        'user' => $user->email,
                        'variation' => $variation,
                        'event' => 'pdf_download',
                        'timestamp' => now()->toISOString(),
                    ]);
                } catch (\Exception $e) {
                    // Don't let experiment tracking break PDF generation
                }
            }

            $pdfBinary = $this->pdfService->generateKundaliPdf($data);

            return response($pdfBinary, 200, [
                'Content-Type' => 'application/pdf',
                'Content-Disposition' => 'attachment; filename="vedic_kundali.pdf"',
            ]);
        } catch (Throwable $e) {
            return response('PDF Generation Error: '.$e->getMessage(), 500, [
                'Content-Type' => 'text/plain; charset=utf-8',
            ]);
        }
    }

    /**
     * Generate & stream Gun Milan PDF report.
     */
    public function gunmilan(Request $request): Response
    {
        $data = $this->parsePayload($request);

        if (! $data || empty($data['success']) || empty($data['boy']) || empty($data['girl']) || empty($data['gun_milan'])) {
            return response('Incomplete Gun Milan payload.', 400, [
                'Content-Type' => 'text/plain; charset=utf-8',
            ]);
        }

        try {
            $result = $this->pdfService->generateGunMilanPdf($data);

            return response($result['binary'], 200, [
                'Content-Type' => 'application/pdf',
                'Content-Disposition' => 'attachment; filename="'.$result['filename'].'"',
            ]);
        } catch (Throwable $e) {
            return response('PDF Generation Error: '.$e->getMessage(), 500, [
                'Content-Type' => 'text/plain; charset=utf-8',
            ]);
        }
    }
}
