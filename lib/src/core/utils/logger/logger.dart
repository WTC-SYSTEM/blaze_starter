import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// {@template app_logger}
/// Logger class, that manages the logging of messages
/// {@endtemplate}
base class AppLogger extends Logger {
  /// Constructs an instance of [AppLogger].
  AppLogger({List<LogObserver> observers = const []}) : _observers = List.unmodifiable(observers);

  final List<LogObserver> _observers;

  /// Whether the logger has been destroyed.
  bool get destroyed => _destroyed;
  var _destroyed = false;

  @override
  void destroy() {
    _destroyed = true;
  }

  @override
  void log(
    String message, {
    required LogLevel level,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
    bool printStackTrace = true,
    bool printError = true,
  }) {
    if (_destroyed || _observers.isEmpty) return;

    final logMessage = LogMessage(
      message: message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      timestamp: clock.now(),
    );

    for (final observer in _observers) {
      observer.onLog(logMessage);
    }
  }
}

/// A logger that does nothing.
final class NoOpLogger extends Logger {
  /// Constructs an instance of [NoOpLogger].
  const NoOpLogger();

  @override
  void log(
    String message, {
    required LogLevel level,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
    bool printStackTrace = true,
    bool printError = true,
    // ignore: no-empty-block
  }) {
    // no-op
  }

  @override
  // ignore: no-empty-block
  void destroy() {
    // no-op
  }
}

/// {@template logger}
/// Logger class, that manages the logging of messages
/// {@endtemplate}
abstract base class Logger {
  /// Constructs an instance of [Logger].
  const Logger();

  /// Destroys the logger and releases all resources
  ///
  /// After calling this method, the logger should not be used anymore.
  void destroy();

  /// Logs a message with the specified [level].
  void log(
    String message, {
    required LogLevel level,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
    bool printStackTrace = true,
    bool printError = true,
  });

  /// Logs a zone error with [LogLevel.error].
  void logZoneError(Object error, StackTrace stackTrace) => log(
        'Zone error',
        level: LogLevel.error,
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs a flutter error with [LogLevel.error].
  void logFlutterError(FlutterErrorDetails details) {
    log(
      details.summary.toString(),
      level: LogLevel.error,
      error: details.exception,
      stackTrace: details.stack,
      printStackTrace: false,
      printError: false,
    );
  }

  /// Logs a platform dispatcher error with [LogLevel.error].
  bool logPlatformDispatcherError(Object error, StackTrace stackTrace) {
    log(
      'Platform Error',
      level: LogLevel.error,
      error: error,
      stackTrace: stackTrace,
    );

    return true;
  }

  /// Logs a message with [LogLevel.trace].
  void trace(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
    bool printStackTrace = true,
    bool printError = true,
  }) =>
      log(
        message,
        level: LogLevel.trace,
        error: error,
        stackTrace: stackTrace,
        context: context,
        printStackTrace: printStackTrace,
        printError: printError,
      );

  /// Logs a message with [LogLevel.debug].
  void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
    bool printStackTrace = true,
    bool printError = true,
  }) =>
      log(
        message,
        level: LogLevel.debug,
        error: error,
        stackTrace: stackTrace,
        context: context,
        printStackTrace: printStackTrace,
        printError: printError,
      );

  /// Logs a message with [LogLevel.info].
  void info(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
    bool printStackTrace = true,
    bool printError = true,
  }) =>
      log(
        message,
        level: LogLevel.info,
        error: error,
        stackTrace: stackTrace,
        context: context,
        printStackTrace: printStackTrace,
        printError: printError,
      );

  /// Logs a message with [LogLevel.warn].
  void warn(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
    bool printStackTrace = true,
    bool printError = true,
  }) =>
      log(
        message,
        level: LogLevel.warn,
        error: error,
        stackTrace: stackTrace,
        context: context,
        printStackTrace: printStackTrace,
        printError: printError,
      );

  /// Logs a message with [LogLevel.error].
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
    bool printStackTrace = true,
    bool printError = true,
  }) =>
      log(
        message,
        level: LogLevel.error,
        error: error,
        stackTrace: stackTrace,
        context: context,
        printStackTrace: printStackTrace,
        printError: printError,
      );

  /// Logs a message with [LogLevel.fatal].
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
    bool printStackTrace = true,
    bool printError = true,
  }) =>
      log(
        message,
        level: LogLevel.fatal,
        error: error,
        stackTrace: stackTrace,
        context: context,
        printStackTrace: printStackTrace,
        printError: printError,
      );
}

/// Log level, that describes the severity of the log message
///
/// Index of the log level is used to determine the severity of the log message.
enum LogLevel implements Comparable<LogLevel> {
  /// A log level describing events showing step by step execution of your code
  /// that can be ignored during the standard operation,
  /// but may be useful during extended debugging sessions.
  trace._(),

  /// A log level used for events considered to be useful during software
  /// debugging when more granular information is needed.
  debug._(),

  /// An event happened, the event is purely informative
  /// and can be ignored during normal operations.
  info._(),

  /// Unexpected behavior happened inside the application, but it is continuing
  /// its work and the key business features are operating as expected.
  warn._(),

  /// One or more functionalities are not working,
  /// preventing some functionalities from working correctly.
  /// For example, a network request failed, a file is missing, etc.
  error._(),

  /// One or more key business functionalities are not working
  /// and the whole system doesn’t fulfill the business functionalities.
  fatal._();

  const LogLevel._();

  @override
  int compareTo(LogLevel other) => index - other.index;

  /// Return short name of the log level.
  String toShortName() => switch (this) {
        LogLevel.trace => 'TRC',
        LogLevel.debug => 'DBG',
        LogLevel.info => 'INF',
        LogLevel.warn => 'WRN',
        LogLevel.error => 'ERR',
        LogLevel.fatal => 'FTL',
      };
}

/// Represents a single log message with various details
/// for debugging and information purposes.
class LogMessage {
  /// Constructs an instance of [LogMessage].
  ///
  /// - [message]: The main content of the log message.
  /// - [level]: The severity level of the log message,
  ///   represented by [LogLevel].
  /// - [timestamp]: The date and time when the log message was created.
  /// - [error]: Optional. Any error object associated with the log message.
  /// - [stackTrace]: Optional. The stack trace associated with the log message,
  ///   typically provided when logging errors.
  const LogMessage({
    required this.message,
    required this.level,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  /// The main content of the log message.
  final String message;

  /// The severity level of the log message.
  final LogLevel level;

  /// The date and time when the log message was created.
  final DateTime timestamp;

  /// Any error object associated with the log message.
  ///
  /// This is typically used when the log message is related
  /// to an exception or error condition.
  final Object? error;

  /// The stack trace associated with the log message.
  ///
  /// This provides detailed information about the call stack leading
  /// up to the log message, which is particularly useful when logging errors.
  final StackTrace? stackTrace;
}

/// {@template log_observer}
/// Observer class, that is notified when a new log message is created
/// {@endtemplate}
mixin class LogObserver {
  /// Constructs an instance of [LogObserver].
  const LogObserver();

  /// Called when a new log message is created.
  void onLog(LogMessage logMessage) {}
}
