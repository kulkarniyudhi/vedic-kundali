<?php

use App\Services\Flagsmith\FlagsmithService;

test('flagsmith service falls back gracefully when server key is invalid or unreachable', function () {
    config()->set('services.flagsmith.server_key', 'invalid-key');

    $service = new FlagsmithService;

    expect($service->getExperimentFlagValue('kundali_result_layout', 'test@example.com', 'detailed'))
        ->toBe('detailed')
        ->and($service->isEnabled('kundali_result_layout', 'test@example.com'))
        ->toBeFalse()
        ->and($service->getIdentityFlags('test@example.com'))
        ->toHaveKey('kundali_result_layout');
});
