import 'dart:io';

/// Returns true when the current process is running in a CI environment.
///
/// This checks common environment variables (CI, CONTINUOUS_INTEGRATION, BUILD_NUMBER).
final bool kIsRunningInCi = Platform.environment.containsKey('CI') ||
    Platform.environment.containsKey('CONTINUOUS_INTEGRATION') ||
    Platform.environment.containsKey('BUILD_NUMBER');
