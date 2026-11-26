<?php

namespace App\Services\Flagsmith;

use Flagsmith\Flagsmith;
use Throwable;

class FlagsmithService
{
    protected Flagsmith $client;

    public function __construct()
    {
        $this->client = new Flagsmith(
            apiKey: config('services.flagsmith.server_key'),
            enableEvents: true,
        );
    }

    /**
     * Get feature flag value for a specific user identity.
     */
    public function getFlagValue(string $flagName, string $userIdentifier): mixed
    {
        try {
            $flags = $this->client->getIdentityFlags($userIdentifier);

            return $flags->getFeatureValue($flagName);
        } catch (Throwable $e) {
            report($e);

            return null;
        }
    }

    /**
     * Evaluate an experiment flag for a user and record a Flagsmith exposure event.
     */
    public function getExperimentFlagValue(string $flagName, string $userIdentifier, mixed $default = 'detailed'): mixed
    {
        try {
            $flag = $this->client->getExperimentFlag($flagName, $userIdentifier);
            $this->client->flushEvents();

            return $flag->getEnabled() ? ($flag->getValue() ?? $default) : $default;
        } catch (Throwable $e) {
            report($e);

            return $default;
        }
    }

    /**
     * Check if a feature is enabled for a user.
     */
    public function isEnabled(string $flagName, string $userIdentifier): bool
    {
        try {
            $flags = $this->client->getIdentityFlags($userIdentifier);

            return $flags->isFeatureEnabled($flagName);
        } catch (Throwable $e) {
            report($e);

            return false;
        }
    }

    /**
     * Track a conversion event for Flagsmith Experimentation and flush immediately.
     */
    public function trackEvent(string $eventName, string $userIdentifier, mixed $value = null, ?array $metadata = null): void
    {
        try {
            $this->client->trackEvent(
                event: $eventName,
                identifier: $userIdentifier,
                value: $value,
                metadata: $metadata,
            );
            $this->client->flushEvents();
        } catch (Throwable $e) {
            report($e);
        }
    }

    /**
     * Get all flags for a user identity.
     */
    public function getIdentityFlags(string $userIdentifier): array
    {
        try {
            $flags = $this->client->getIdentityFlags($userIdentifier);

            return [
                'kundali_result_layout' => $flags->getFeatureValue('kundali_result_layout'),
            ];
        } catch (Throwable $e) {
            report($e);

            return [
                'kundali_result_layout' => 'detailed',
            ];
        }
    }
}
