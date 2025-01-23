import 'dart:async';

import 'package:sizzle_starter/src/core/utils/logger/logger.dart';

/// {@template error_reporter}
/// An interface for reporting errors.
///
/// Implementations should report errors to a service like Sentry/Crashlytics.
/// {@endtemplate}
abstract interface class ErrorReporter {
  /// Returns `true` if the error reporting service is initialized
  /// and ready to report errors.
  ///
  /// If this returns `false`, the error reporting service should not be used.
  bool get isInitialized;

  /// Initializes the error reporting service.
  Future<void> initialize();

  /// Closes the error reporting service.
  Future<void> close();

  /// Capture an exception to be reported.
  ///
  /// The [throwable] is the exception that was thrown.
  /// The [stackTrace] is the stack trace associated with the exception.
  Future<void> captureException({
    required Object throwable,
    StackTrace? stackTrace,
  });
}

/// {@template error_reporter_log_observer}
/// An observer that reports logs to the error reporter if it is active.
/// {@endtemplate}
final class ErrorReporterLogObserver with LogObserver {
  /// {@macro error_reporter_log_observer}
  const ErrorReporterLogObserver(this._errorReporter);

  /// Error reporter used to report errors.
  final ErrorReporter _errorReporter;

  @override
  void onLog(LogMessage logMessage) {
    // If the error reporter is not initialized, do nothing
    if (!_errorReporter.isInitialized) return;

    // If the log level is error or higher, report the error
    if (logMessage.level.index >= LogLevel.error.index) {
      _errorReporter.captureException(
        throwable: logMessage.error ?? ReportedMessageException(logMessage.message),
        stackTrace: logMessage.stackTrace ?? StackTrace.current,
      );
    }
  }
}

/// An exception used for error logs without an exception, only a message.
class ReportedMessageException implements Exception {
  /// Constructs an instance of [ReportedMessageException].
  const ReportedMessageException(this.message);

  /// The message that was reported.
  final String message;

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReportedMessageException && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
