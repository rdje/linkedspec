import 'dart:io';

import '../ast/spec_ast.dart';

const linkedSpecTraceDumpNone = 0;
const linkedSpecTraceDumpLow = 100;
const linkedSpecTraceDumpMedium = 200;
const linkedSpecTraceDumpHigh = 300;
const linkedSpecTraceDumpFull = 400;
const linkedSpecTraceDumpDebug = 500;

final class LinkedSpecTraceException implements Exception {
  const LinkedSpecTraceException(this.message);

  final String message;

  @override
  String toString() => 'LinkedSpecTraceException: $message';
}

final class LinkedSpecTraceLevel implements Comparable<LinkedSpecTraceLevel> {
  const LinkedSpecTraceLevel(this.value);

  static const none = LinkedSpecTraceLevel(linkedSpecTraceDumpNone);
  static const low = LinkedSpecTraceLevel(linkedSpecTraceDumpLow);
  static const medium = LinkedSpecTraceLevel(linkedSpecTraceDumpMedium);
  static const high = LinkedSpecTraceLevel(linkedSpecTraceDumpHigh);
  static const full = LinkedSpecTraceLevel(linkedSpecTraceDumpFull);
  static const debug = LinkedSpecTraceLevel(linkedSpecTraceDumpDebug);

  final int value;

  static LinkedSpecTraceLevel parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const LinkedSpecTraceException('empty trace level');
    }
    final numeric = int.tryParse(trimmed);
    if (numeric != null) {
      return LinkedSpecTraceLevel(numeric);
    }

    return switch (trimmed.toLowerCase()) {
      'none' || 'quiet' || 'off' => none,
      'low' => low,
      'medium' || 'med' => medium,
      'high' => high,
      'full' => full,
      'debug' || 'verbose' => debug,
      _ => throw LinkedSpecTraceException("unsupported trace level '$input'"),
    };
  }

  bool allows(LinkedSpecTraceLevel eventLevel) {
    return value > linkedSpecTraceDumpNone &&
        eventLevel.value > linkedSpecTraceDumpNone &&
        value >= eventLevel.value;
  }

  String get bucketName {
    return switch (value) {
      <= linkedSpecTraceDumpNone => 'none',
      <= linkedSpecTraceDumpLow => 'low',
      <= linkedSpecTraceDumpMedium => 'medium',
      <= linkedSpecTraceDumpHigh => 'high',
      <= linkedSpecTraceDumpFull => 'full',
      _ => 'debug',
    };
  }

  @override
  int compareTo(LinkedSpecTraceLevel other) {
    return value.compareTo(other.value);
  }

  @override
  bool operator ==(Object other) {
    return other is LinkedSpecTraceLevel && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => bucketName;
}

enum LinkedSpecTraceSinkMode {
  stdout,
  route,
  mirror;

  static LinkedSpecTraceSinkMode parse(String input) {
    return switch (input.trim().toLowerCase()) {
      'stdout' || 'console' => stdout,
      'route' || 'routed' || 'file' => route,
      'mirror' || 'both' => mirror,
      _ => throw LinkedSpecTraceException(
        "unsupported trace sink mode '$input'",
      ),
    };
  }
}

final class LinkedSpecTraceConfig {
  const LinkedSpecTraceConfig({
    this.level = LinkedSpecTraceLevel.none,
    this.traceFile,
    this.sinkMode = LinkedSpecTraceSinkMode.stdout,
    this.resetFile = false,
    this.emoji = false,
  });

  factory LinkedSpecTraceConfig.disabled() {
    return const LinkedSpecTraceConfig();
  }

  factory LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel level) {
    return LinkedSpecTraceConfig(level: level);
  }

  factory LinkedSpecTraceConfig.fromEnvironment([
    Map<String, String>? environment,
  ]) {
    final env = environment ?? Platform.environment;
    var config = const LinkedSpecTraceConfig();
    final level =
        env['LINKEDSPEC_TRACE_LEVEL'] ?? env['LINKEDSPEC_DUMP_VERBOSITY'];
    if (level != null) {
      config = config.withLevel(LinkedSpecTraceLevel.parse(level));
    }

    final traceFile = env['LINKEDSPEC_TRACE_FILE']?.trim();
    if (traceFile != null && traceFile.isNotEmpty) {
      config = config.withTraceFile(traceFile);
      if (_traceTruthy(env['LINKEDSPEC_TRACE_MIRROR_STDOUT'])) {
        config = config.withSinkMode(LinkedSpecTraceSinkMode.mirror);
      }
    }

    if (_traceTruthy(env['LINKEDSPEC_TRACE_RESET_FILE'])) {
      config = config.withResetFile(true);
    }
    if (_traceTruthy(env['LINKEDSPEC_TRACE_EMOJI'])) {
      config = config.withEmoji(true);
    }
    return config;
  }

  final LinkedSpecTraceLevel level;
  final String? traceFile;
  final LinkedSpecTraceSinkMode sinkMode;
  final bool resetFile;
  final bool emoji;

  LinkedSpecTraceConfig withLevel(LinkedSpecTraceLevel level) {
    return LinkedSpecTraceConfig(
      level: level,
      traceFile: traceFile,
      sinkMode: sinkMode,
      resetFile: resetFile,
      emoji: emoji,
    );
  }

  LinkedSpecTraceConfig withTraceFile(String path) {
    return LinkedSpecTraceConfig(
      level: level,
      traceFile: path,
      sinkMode: sinkMode == LinkedSpecTraceSinkMode.stdout
          ? LinkedSpecTraceSinkMode.route
          : sinkMode,
      resetFile: resetFile,
      emoji: emoji,
    );
  }

  LinkedSpecTraceConfig withSinkMode(LinkedSpecTraceSinkMode sinkMode) {
    return LinkedSpecTraceConfig(
      level: level,
      traceFile: traceFile,
      sinkMode: sinkMode,
      resetFile: resetFile,
      emoji: emoji,
    );
  }

  LinkedSpecTraceConfig withResetFile(bool resetFile) {
    return LinkedSpecTraceConfig(
      level: level,
      traceFile: traceFile,
      sinkMode: sinkMode,
      resetFile: resetFile,
      emoji: emoji,
    );
  }

  LinkedSpecTraceConfig withEmoji(bool emoji) {
    return LinkedSpecTraceConfig(
      level: level,
      traceFile: traceFile,
      sinkMode: sinkMode,
      resetFile: resetFile,
      emoji: emoji,
    );
  }

  bool shouldEmit(LinkedSpecTraceLevel eventLevel) {
    return level.allows(eventLevel);
  }
}

enum LinkedSpecTraceEventKind { enter, exit, decision, mark, dump, log }

final class LinkedSpecTraceEvent {
  const LinkedSpecTraceEvent({
    required this.kind,
    required this.topic,
    required this.details,
    required this.level,
  });

  final LinkedSpecTraceEventKind kind;
  final String topic;
  final String details;
  final LinkedSpecTraceLevel level;

  JsonObject toJson() => {
    'kind': kind.name,
    'topic': topic,
    'details': details,
    'level': level.bucketName,
    'level_value': level.value,
  };
}

final class LinkedSpecTraceScope {
  const LinkedSpecTraceScope({
    required this.topic,
    required this.level,
    required this.emitted,
  });

  final String topic;
  final LinkedSpecTraceLevel level;
  final bool emitted;
}

final class LinkedSpecTraceEmitter {
  LinkedSpecTraceEmitter(
    this.config, {
    void Function(String payload)? stdoutWriter,
  }) : _stdoutWriter = stdoutWriter ?? stdout.write {
    if (_usesFileSink) {
      final path = config.traceFile;
      if (path == null || path.trim().isEmpty) {
        return;
      }
      final file = File(path);
      if (config.resetFile) {
        file.writeAsStringSync('');
      } else if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
    }
  }

  final LinkedSpecTraceConfig config;
  final void Function(String payload) _stdoutWriter;
  final List<LinkedSpecTraceEvent> _events = <LinkedSpecTraceEvent>[];
  final List<String> _lines = <String>[];
  var _indentLevel = 0;

  List<LinkedSpecTraceEvent> get events {
    return List<LinkedSpecTraceEvent>.unmodifiable(_events);
  }

  List<String> get lines {
    return List<String>.unmodifiable(_lines);
  }

  bool get _usesFileSink {
    return config.sinkMode == LinkedSpecTraceSinkMode.route ||
        config.sinkMode == LinkedSpecTraceSinkMode.mirror;
  }

  bool shouldEmit(LinkedSpecTraceLevel level) {
    return config.shouldEmit(level);
  }

  void emitLine(LinkedSpecTraceLevel level, String line) {
    if (!shouldEmit(level)) {
      return;
    }
    final payload = line.endsWith('\n') ? line : '$line\n';
    _lines.add(payload);
    _writePayload(payload);
  }

  void emitEvent(
    LinkedSpecTraceEventKind kind,
    String topic,
    String details,
    LinkedSpecTraceLevel level,
  ) {
    if (!shouldEmit(level)) {
      return;
    }
    final event = LinkedSpecTraceEvent(
      kind: kind,
      topic: topic,
      details: details,
      level: level,
    );
    _events.add(event);
    emitLine(level, _renderEvent(event));
  }

  LinkedSpecTraceScope enterScope(
    String topic,
    String details,
    LinkedSpecTraceLevel level,
  ) {
    final emitted = shouldEmit(level);
    if (emitted) {
      emitEvent(LinkedSpecTraceEventKind.enter, topic, details, level);
      _indentLevel += 1;
    }
    return LinkedSpecTraceScope(topic: topic, level: level, emitted: emitted);
  }

  void exitScope(LinkedSpecTraceScope scope, String details) {
    if (!scope.emitted) {
      return;
    }
    _indentLevel = _indentLevel <= 0 ? 0 : _indentLevel - 1;
    emitEvent(LinkedSpecTraceEventKind.exit, scope.topic, details, scope.level);
  }

  bool traceDecision(
    String decisionName,
    bool taken,
    String reason,
    LinkedSpecTraceLevel level,
  ) {
    emitEvent(
      LinkedSpecTraceEventKind.decision,
      decisionName,
      'taken=${taken ? 1 : 0} reason=$reason',
      level,
    );
    return taken;
  }

  void logOutput(
    LinkedSpecTraceLevel level,
    String message, [
    String context = '',
  ]) {
    final details = context.isEmpty ? message : '$message context=$context';
    emitEvent(LinkedSpecTraceEventKind.log, 'log_output', details, level);
  }

  void logDump(LinkedSpecTraceLevel level, String message) {
    emitEvent(LinkedSpecTraceEventKind.dump, 'log_dump', message, level);
  }

  String _renderEvent(LinkedSpecTraceEvent event) {
    final indent = '  ' * _indentLevel;
    final details = event.details.trim().isEmpty ? '' : ' ${event.details}';
    final level = event.level.bucketName.toUpperCase();
    final kind = event.kind.name;
    return switch (event.kind) {
      LinkedSpecTraceEventKind.enter =>
        '[$level][$kind] $indent-> ${event.topic}$details',
      LinkedSpecTraceEventKind.exit =>
        '[$level][$kind] $indent<- ${event.topic}$details',
      _ => '[$level][$kind] $indent${event.topic}$details',
    };
  }

  void _writePayload(String payload) {
    if (config.sinkMode != LinkedSpecTraceSinkMode.route) {
      _stdoutWriter(payload);
    }
    if (_usesFileSink) {
      final path = config.traceFile;
      if (path != null && path.trim().isNotEmpty) {
        File(path).writeAsStringSync(payload, mode: FileMode.append);
      }
    }
  }
}

bool _traceTruthy(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return false;
  }
  return switch (trimmed.toLowerCase()) {
    '0' || 'false' || 'no' || 'off' => false,
    _ => true,
  };
}
