import 'dart:async';
import 'package:flagsmith/flagsmith.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

/// Service for managing Flagsmith feature flags and A/B experiments.
///
/// Integrates with Flagsmith Native Experimentation (`enableEvents: true`) to:
/// 1. Identify users stably via their email.
/// 2. Evaluate the `kundali_result_layout` experiment flag and record `$flag_exposure`.
/// 3. Track conversion events (`pdf_download`, etc.) and flush them to Flagsmith.
class FlagsmithService {
  static FlagsmithClient? _client;
  static bool _initialized = false;
  static Identity? _currentIdentity;
  static String? _lastVariation;

  /// Flagsmith Client-Side Environment Key (override via --dart-define=FLAGSMITH_CLIENT_KEY=...)
  static const String _apiKey = String.fromEnvironment(
    'FLAGSMITH_CLIENT_KEY',
    defaultValue: 'Kb9Ke5TGYncQpRDC54QJT9',
  );

  /// Initialize the Flagsmith client with native event tracking enabled.
  static Future<void> init() async {
    try {
      _client = await FlagsmithClient.init(
        apiKey: _apiKey,
        config: FlagsmithConfig(
          isDebug: kDebugMode,
          enableEvents: true,
        ),
      );
      _initialized = true;
    } catch (e) {
      _initialized = false;
      debugPrint('[Flagsmith] Init failed: $e');
    }
  }

  static Identity? _resolveIdentity() {
    if (_currentIdentity != null) return _currentIdentity;
    final email = AuthService.userEmail.trim().toLowerCase();
    if (email.isNotEmpty) {
      _currentIdentity = Identity(identifier: email);
    }
    return _currentIdentity;
  }

  /// Identify the current logged-in user for consistent experiment bucketing.
  /// Uses the user's email as a stable identifier across sessions.
  static Future<void> identifyUser() async {
    if (!_initialized || _client == null) return;

    final userEmail = AuthService.userEmail.trim().toLowerCase();
    if (userEmail.isEmpty) return;

    _currentIdentity = Identity(identifier: userEmail);
    try {
      await _client!.getFeatureFlags(user: _currentIdentity!, reload: true);
      debugPrint('[Flagsmith] Identified user: $userEmail');
    } catch (e) {
      debugPrint('[Flagsmith] Identify failed: $e');
    }
  }

  /// Clear the cached identity on logout.
  static void clearUser() {
    _currentIdentity = null;
    _lastVariation = null;
    if (_client != null) {
      _client!.cachedUser = null;
    }
  }

  /// Evaluate an experiment feature flag and automatically record `$flag_exposure`
  /// when an active Flagsmith experiment is running for this feature.
  ///
  /// Falls back to [defaultValue] if Flagsmith is unavailable or flag is disabled.
  static Future<String> getExperimentFlag(
    String flagName, {
    String defaultValue = 'detailed',
    bool reload = false,
  }) async {
    if (!_initialized || _client == null) return defaultValue;

    final identity = _resolveIdentity();
    try {
      final flag = await _client!.getExperimentFlag(
        flagName,
        user: identity,
        reload: reload ? true : null,
      );

      if (flag != null && flag.enabled == true) {
        final resolved = flag.stateValue ?? flag.value?.toString() ?? defaultValue;
        _lastVariation = resolved;
        debugPrint(
          '[Flagsmith] Experiment "$flagName" -> "$resolved" '
          '(user: ${identity?.identifier ?? "anonymous"}, '
          'inExperiment: ${flag.experiment?.inExperiment ?? false})',
        );
        return resolved;
      }
      return defaultValue;
    } catch (e) {
      debugPrint('[Flagsmith] Error evaluating "$flagName": $e');
      return defaultValue;
    }
  }

  /// Get the kundali result layout variation for the current user and record exposure.
  ///
  /// Returns either `'detailed'` (control) or `'summary_first'` (test).
  static Future<String> getKundaliLayout() async {
    return getExperimentFlag('kundali_result_layout', defaultValue: 'detailed');
  }

  /// Check if a feature flag is enabled for the current user.
  static Future<bool> isEnabled(String flagName) async {
    if (!_initialized || _client == null) return false;

    try {
      return await _client!.isFeatureFlagEnabled(
        flagName,
        user: _resolveIdentity(),
      );
    } catch (e) {
      return false;
    }
  }

  /// Track a conversion event for Flagsmith Experimentation and flush immediately.
  ///
  /// The [eventName] must match the metric configured in the Flagsmith dashboard
  /// (e.g., `'pdf_download'`).
  static Future<void> trackConversion(
    String eventName, {
    Object? value,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_initialized || _client == null) return;

    final identity = _resolveIdentity();
    try {
      _client!.trackEvent(
        eventName,
        user: identity,
        value: value,
        metadata: {
          if (_lastVariation != null) 'layout_variation': _lastVariation,
          ...?metadata,
        },
      );
      await _client!.flushEvents();
      debugPrint(
        '[Flagsmith] Tracked & flushed conversion "$eventName" '
        '(user: ${identity?.identifier ?? "anonymous"}, variation: $_lastVariation)',
      );
    } catch (e) {
      debugPrint('[Flagsmith] Conversion tracking failed: $e');
    }
  }

  /// Flush any buffered Flagsmith events immediately.
  static Future<void> flushEvents() async {
    if (!_initialized || _client == null) return;
    await _client!.flushEvents();
  }

  /// Last resolved layout variation (useful for debugging / display).
  static String? get lastVariation => _lastVariation;

  /// Whether the Flagsmith client is successfully initialized.
  static bool get isReady => _initialized;
}
