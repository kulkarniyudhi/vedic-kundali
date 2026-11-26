<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Symfony\Component\HttpFoundation\Response;

class SetAppLocale
{
    /**
     * Supported application locales.
     *
     * @var array<string>
     */
    protected array $supportedLocales = ['mr', 'en', 'hi'];

    /**
     * Default fallback locale.
     */
    protected string $defaultLocale = 'en';

    /**
     * Handle an incoming request and set Laravel application locale.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $rawLocale = $request->header('lang')
            ?? $request->header('X-Locale')
            ?? $request->header('Accept-Language')
            ?? $request->query('lang');

        $locale = $this->parseLocale($rawLocale);

        if ($locale && in_array($locale, $this->supportedLocales, true)) {
            App::setLocale($locale);
        } else {
            App::setLocale(config('app.locale', $this->defaultLocale));
        }

        return $next($request);
    }

    /**
     * Parse and normalize the locale string (e.g. 'mr-IN' -> 'mr', 'hi;q=0.9' -> 'hi').
     */
    protected function parseLocale(?string $raw): ?string
    {
        if (empty($raw)) {
            return null;
        }

        // Take the first locale if comma-separated
        $first = explode(',', $raw)[0];
        // Strip quality parameter (e.g., ;q=0.9)
        $first = explode(';', $first)[0];
        // Extract base language code (e.g., 'mr-IN' -> 'mr')
        $first = explode('-', trim($first))[0];
        $code = strtolower(trim($first));

        return $code !== '' ? $code : null;
    }
}
