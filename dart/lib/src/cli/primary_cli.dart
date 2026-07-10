import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../compiler/compiled_spec.dart';
import '../parser/user_function_definition_parser.dart';
import '../runtime/interpreter.dart';
import '../runtime/matching.dart';

const linkedspecDartDisplayCommand = 'dart run bin/linkedspec_dart.dart';

const _primaryCliHelpTemplate = r'''Usage:
  {{COMMAND}} --spec NAME --input TEXT [options]
  {{COMMAND}} --spec-file PATH --input-file PATH [options]
  {{COMMAND}} --inline-spec TEXT --input TEXT [options]

Source selection (choose exactly one):
  --spec NAME          Resolve and compile a named .spec
  --spec-file PATH     Compile .spec source read from PATH
  --inline-spec TEXT   Compile the literal .spec source TEXT

Input selection (choose exactly one):
  --input TEXT         Parse TEXT
  --input-file PATH    Parse file contents read from PATH

Text encoding:
  Arguments, source, input, JSON, help/errors, and trace use strict UTF-8.
  Text is not normalized, trimmed, or newline/BOM converted. UTF-16/UTF-32
  files are not detected implicitly.

Parser options:
  --top-rule NAME      Select the entry rule
  --parse-mode MODE    MODE is seek or consume

Trace options:
  --trace LEVEL        LEVEL is none/quiet, low, medium/med, high, full,
                       debug/verbose, or an integer
  --trace-file PATH    Write trace output to PATH
  --trace-mode MODE    MODE is stdout, route, or mirror
  --trace-reset        Truncate --trace-file before writing
  --trace-emoji        Enable emoji trace prefixes

Help:
  --help, -h           Show this help

Trace output:
  Emits deterministic compile/input/invoke phase records shared by every primary
  backend command. Native embedding APIs retain richer backend-internal events.

Output:
  Prints the parser result as canonical JSON on stdout. When trace output is sent
  to stdout it is intentionally interleaved with that JSON; use --trace-file with
  --trace-mode route for machine-readable stdout plus routed trace.

Failures:
  Compilation, input-load, and parser-invocation failures write one stable phase
  heading to stderr and exit 1. Usage errors write this help and exit 2.

Examples:
  {{COMMAND}} --spec Lispish --input '(hello world)'
  {{COMMAND}} --spec-file demo.spec --input-file demo.txt \
    --trace high --trace-file linkedspec.trace.log --trace-mode route --trace-reset
''';

String linkedspecDartPrimaryCliHelp() => _primaryCliHelpTemplate.replaceAll(
  '{{COMMAND}}',
  linkedspecDartDisplayCommand,
);

final class PrimaryCliCommandOutput {
  PrimaryCliCommandOutput({
    required List<int> stdoutBytes,
    required List<int> stderrBytes,
    required this.exitCode,
  }) : stdoutBytes = Uint8List.fromList(stdoutBytes),
       stderrBytes = Uint8List.fromList(stderrBytes);

  factory PrimaryCliCommandOutput.success(String stdoutText) =>
      PrimaryCliCommandOutput(
        stdoutBytes: utf8.encode(stdoutText),
        stderrBytes: const [],
        exitCode: 0,
      );

  factory PrimaryCliCommandOutput.successBytes(List<int> stdoutBytes) =>
      PrimaryCliCommandOutput(
        stdoutBytes: stdoutBytes,
        stderrBytes: const [],
        exitCode: 0,
      );

  factory PrimaryCliCommandOutput.usageFailure(String message) =>
      PrimaryCliCommandOutput(
        stdoutBytes: const [],
        stderrBytes: utf8.encode(
          'linkedspec: $message\n\n${linkedspecDartPrimaryCliHelp()}',
        ),
        exitCode: 2,
      );

  factory PrimaryCliCommandOutput.operationalFailure(
    String message, {
    List<int> stdoutBytes = const [],
  }) => PrimaryCliCommandOutput(
    stdoutBytes: stdoutBytes,
    stderrBytes: utf8.encode('linkedspec: $message\n'),
    exitCode: 1,
  );

  final Uint8List stdoutBytes;
  final Uint8List stderrBytes;
  final int exitCode;
}

int runLinkedSpecDartCli(List<String> arguments) {
  final output = runLinkedSpecDartPrimaryCli(arguments);
  stdout.add(output.stdoutBytes);
  stderr.add(output.stderrBytes);
  return output.exitCode;
}

PrimaryCliCommandOutput runLinkedSpecDartPrimaryCli(
  List<String> arguments, {
  Directory? workingDirectory,
  Directory? repositoryRoot,
}) {
  final parseResult = _parseArguments(List<String>.unmodifiable(arguments));
  if (parseResult.error != null) {
    return PrimaryCliCommandOutput.usageFailure(parseResult.error!);
  }
  if (parseResult.help) {
    return PrimaryCliCommandOutput.success(linkedspecDartPrimaryCliHelp());
  }

  final cwd = workingDirectory?.absolute ?? Directory.current.absolute;
  final repoRoot = repositoryRoot?.absolute ?? _findRepositoryRoot();
  final trace = _CanonicalTrace.create(parseResult.options!, cwd);
  if (trace == null) {
    return PrimaryCliCommandOutput.operationalFailure(
      'parser compilation failed',
    );
  }
  final sourceKind = parseResult.options!.spec != null
      ? 'named'
      : parseResult.options!.specFile != null
      ? 'file'
      : 'inline';
  final inputKind = parseResult.options!.inputFile != null ? 'file' : 'literal';
  final sourceArgument =
      parseResult.options!.spec ??
      parseResult.options!.specFile ??
      parseResult.options!.inlineSpec ??
      '';
  final inputArgument =
      parseResult.options!.inputFile ?? parseResult.options!.input ?? '';
  final topRule = parseResult.options!.topRule == null
      ? '<default>'
      : _traceField(parseResult.options!.topRule!);
  final parseMode = parseResult.options!.parseMode ?? 'seek';

  PrimaryCliCommandOutput? emit(int threshold, String level, String event) {
    if (trace.emit(threshold, level, event)) {
      return null;
    }
    return PrimaryCliCommandOutput.operationalFailure(
      'parser compilation failed',
      stdoutBytes: trace.takeStdout(),
    );
  }

  PrimaryCliCommandOutput phaseFailure(String event, String message) {
    final emitted = trace.emit(100, 'low', event);
    return PrimaryCliCommandOutput.operationalFailure(
      emitted ? message : 'parser compilation failed',
      stdoutBytes: trace.takeStdout(),
    );
  }

  final traceFailure =
      emit(100, 'low', 'compile:start') ??
      emit(
        200,
        'medium',
        'request source=$sourceKind input=$inputKind '
            'top_rule=$topRule parse_mode=$parseMode',
      ) ??
      emit(
        300,
        'high',
        'arguments source_bytes=${utf8.encode(sourceArgument).length} '
            'input_bytes=${utf8.encode(inputArgument).length}',
      ) ??
      emit(500, 'debug', 'protocol version=1');
  if (traceFailure != null) {
    return traceFailure;
  }

  final prepared = _prepareRequest(parseResult.options!, cwd, repoRoot);
  if (prepared == null) {
    return phaseFailure('compile:error', 'parser compilation failed');
  }

  final CompiledSpec compiled;
  try {
    // Dart's String.trim() treats U+FEFF as whitespace. The portable CLI does
    // not strip a source BOM, so reject it before the frontend can erase it.
    if (prepared.specSource.startsWith('\uFEFF')) {
      throw const FormatException('leading source BOM is preserved');
    }
    compiled = compileSpec(
      parseSpecWithStagedUserFunctionDefinitions(prepared.specSource),
    );
  } on Object {
    return phaseFailure('compile:error', 'parser compilation failed');
  }
  final compileTraceFailure = emit(100, 'low', 'compile:ok');
  if (compileTraceFailure != null) {
    return compileTraceFailure;
  }

  final inputStartFailure = emit(100, 'low', 'input:start');
  if (inputStartFailure != null) {
    return inputStartFailure;
  }
  final input = _loadInput(prepared.input);
  if (input == null) {
    return phaseFailure('input:error', 'input load failed');
  }
  final inputTraceFailure =
      emit(300, 'high', 'input bytes=${utf8.encode(input).length}') ??
      emit(100, 'low', 'input:ok') ??
      emit(100, 'low', 'invoke:start');
  if (inputTraceFailure != null) {
    return inputTraceFailure;
  }

  try {
    final parseMode = prepared.options.parseMode == 'consume'
        ? LinkedSpecParseMode.consume
        : LinkedSpecParseMode.seek;
    final result = LinkedSpecRuntimeEngine(
      compiled,
      parseMode: parseMode,
    ).execute(input, topRule: prepared.options.topRule);
    final json = jsonEncode(_canonicalJson(result.value));
    final invokeTraceFailure = emit(100, 'low', 'invoke:ok');
    if (invokeTraceFailure != null) {
      return invokeTraceFailure;
    }
    final jsonBytes = utf8.encode(json);
    final resultTraceFailure = emit(
      400,
      'full',
      'result json_bytes=${jsonBytes.length}',
    );
    if (resultTraceFailure != null) {
      return resultTraceFailure;
    }
    return PrimaryCliCommandOutput.successBytes([
      ...trace.takeStdout(),
      ...jsonBytes,
      0x0A,
    ]);
  } on Object {
    return phaseFailure('invoke:error', 'parser invocation failed');
  }
}

final class _PrimaryCliOptions {
  String? spec;
  String? specFile;
  String? inlineSpec;
  String? input;
  String? inputFile;
  String? topRule;
  String? parseMode;
  String? traceLevel;
  String? traceFile;
  String? traceMode;
  var traceReset = false;
  var traceEmoji = false;
}

final class _ArgumentParseResult {
  const _ArgumentParseResult({
    required this.help,
    required this.options,
    required this.error,
  });

  const _ArgumentParseResult.help() : help = true, options = null, error = null;

  const _ArgumentParseResult.failure(this.error) : help = false, options = null;

  final bool help;
  final _PrimaryCliOptions? options;
  final String? error;
}

_ArgumentParseResult _parseArguments(List<String> arguments) {
  final options = _PrimaryCliOptions();
  final errors = <String>[];
  var help = false;
  var index = 0;

  while (index < arguments.length) {
    final argument = arguments[index];
    final split = _splitOption(argument);
    final option = split.$1;
    final inlineValue = split.$2;

    if (option == '--help' || option == '-h') {
      if (inlineValue != null) {
        errors.add('$option does not accept a value');
      } else {
        help = true;
      }
    } else if (option == '--trace-reset' || option == '--trace-emoji') {
      if (inlineValue != null) {
        errors.add('$option does not accept a value');
      } else if (option == '--trace-reset') {
        options.traceReset = true;
      } else {
        options.traceEmoji = true;
      }
    } else if (_valueOptions.contains(option)) {
      final String value;
      if (inlineValue != null) {
        value = inlineValue;
      } else if (index + 1 >= arguments.length) {
        errors.add('$option requires a value');
        index += 1;
        continue;
      } else {
        index += 1;
        value = arguments[index];
      }
      _setValueOption(options, option, value);
    } else if (option.startsWith('-')) {
      errors.add("unknown option '$option'");
    } else {
      errors.add("unexpected positional argument '$argument'");
    }
    index += 1;
  }

  if (errors.isNotEmpty) {
    return _ArgumentParseResult.failure(errors.join('; '));
  }
  if (help) {
    return const _ArgumentParseResult.help();
  }
  if (_definedCount([options.spec, options.specFile, options.inlineSpec]) !=
      1) {
    return const _ArgumentParseResult.failure(
      'choose exactly one source option: --spec, --spec-file, or --inline-spec',
    );
  }
  if (_definedCount([options.input, options.inputFile]) != 1) {
    return const _ArgumentParseResult.failure(
      'choose exactly one input option: --input or --input-file',
    );
  }
  if (options.parseMode != null &&
      options.parseMode != 'seek' &&
      options.parseMode != 'consume') {
    return const _ArgumentParseResult.failure(
      "--parse-mode must be 'seek' or 'consume'",
    );
  }
  if (options.traceLevel != null && !_validTraceLevel(options.traceLevel!)) {
    return _ArgumentParseResult.failure(
      "--trace has an unsupported level '${options.traceLevel}'",
    );
  }
  if (options.traceMode != null &&
      options.traceMode != 'stdout' &&
      options.traceMode != 'route' &&
      options.traceMode != 'mirror') {
    return const _ArgumentParseResult.failure(
      "--trace-mode must be 'stdout', 'route', or 'mirror'",
    );
  }
  return _ArgumentParseResult(help: false, options: options, error: null);
}

const _valueOptions = <String>{
  '--spec',
  '--spec-file',
  '--inline-spec',
  '--input',
  '--input-file',
  '--top-rule',
  '--parse-mode',
  '--trace',
  '--trace-file',
  '--trace-mode',
};

(String, String?) _splitOption(String argument) {
  if (argument.startsWith('--')) {
    final equalsIndex = argument.indexOf('=');
    if (equalsIndex >= 0) {
      return (
        argument.substring(0, equalsIndex),
        argument.substring(equalsIndex + 1),
      );
    }
  }
  return (argument, null);
}

void _setValueOption(_PrimaryCliOptions options, String option, String value) {
  switch (option) {
    case '--spec':
      options.spec = value;
    case '--spec-file':
      options.specFile = value;
    case '--inline-spec':
      options.inlineSpec = value;
    case '--input':
      options.input = value;
    case '--input-file':
      options.inputFile = value;
    case '--top-rule':
      options.topRule = value;
    case '--parse-mode':
      options.parseMode = value;
    case '--trace':
      options.traceLevel = value;
    case '--trace-file':
      options.traceFile = value;
    case '--trace-mode':
      options.traceMode = value;
  }
}

int _definedCount(Iterable<String?> values) =>
    values.where((value) => value != null).length;

bool _validTraceLevel(String level) {
  if (RegExp(r'^-?\d+$').hasMatch(level)) {
    return true;
  }
  return const {
    'none',
    'quiet',
    'low',
    'medium',
    'med',
    'high',
    'full',
    'debug',
    'verbose',
  }.contains(level.toLowerCase());
}

int _traceLevelNumber(String? level) {
  if (level == null) {
    return 0;
  }
  final numeric = int.tryParse(level);
  if (numeric != null) {
    return numeric;
  }
  return switch (level.toLowerCase()) {
    'none' || 'quiet' => 0,
    'low' => 100,
    'medium' || 'med' => 200,
    'high' => 300,
    'full' => 400,
    'debug' || 'verbose' => 500,
    _ => throw StateError('trace level was validated by the argument parser'),
  };
}

enum _CanonicalTraceMode { stdout, route, mirror }

final class _CanonicalTrace {
  _CanonicalTrace({
    required this.level,
    required this.file,
    required this.mode,
    required this.emoji,
  });

  static _CanonicalTrace? create(_PrimaryCliOptions options, Directory cwd) {
    final file = options.traceFile == null || options.traceFile!.isEmpty
        ? null
        : _explicitFile(options.traceFile!, cwd);
    final mode = switch (options.traceMode) {
      'route' => _CanonicalTraceMode.route,
      'mirror' => _CanonicalTraceMode.mirror,
      'stdout' => _CanonicalTraceMode.stdout,
      null when file != null => _CanonicalTraceMode.route,
      null => _CanonicalTraceMode.stdout,
      _ => throw StateError('trace mode was validated by the argument parser'),
    };
    try {
      if (options.traceReset && file != null) {
        file.writeAsBytesSync(const [], flush: true);
      }
    } on FileSystemException {
      return null;
    }
    return _CanonicalTrace(
      level: _traceLevelNumber(options.traceLevel),
      file: file,
      mode: mode,
      emoji: options.traceEmoji,
    );
  }

  final int level;
  final File? file;
  final _CanonicalTraceMode mode;
  final bool emoji;
  final BytesBuilder _stdout = BytesBuilder(copy: false);

  bool emit(int threshold, String levelName, String event) {
    if (level < threshold) {
      return true;
    }
    final emojiPrefix = emoji ? '${_traceEmojiPrefix(threshold)} ' : '';
    final bytes = utf8.encode('[linkedspec][$levelName] $emojiPrefix$event\n');
    if (mode == _CanonicalTraceMode.stdout ||
        mode == _CanonicalTraceMode.mirror) {
      _stdout.add(bytes);
    }
    if ((mode == _CanonicalTraceMode.route ||
            mode == _CanonicalTraceMode.mirror) &&
        file != null) {
      try {
        file!.writeAsBytesSync(bytes, mode: FileMode.append, flush: true);
      } on FileSystemException {
        return false;
      }
    }
    return true;
  }

  Uint8List takeStdout() {
    final bytes = _stdout.takeBytes();
    return bytes;
  }
}

String _traceEmojiPrefix(int level) => switch (level) {
  100 => 'ℹ️',
  200 => '🔎',
  300 => '🧭',
  400 => '🐞',
  _ => '🔥',
};

String _traceField(String value) {
  final escaped = StringBuffer();
  for (final byte in utf8.encode(value)) {
    final allowed =
        (byte >= 0x30 && byte <= 0x39) ||
        (byte >= 0x41 && byte <= 0x5A) ||
        (byte >= 0x61 && byte <= 0x7A) ||
        byte == 0x5F ||
        byte == 0x2E ||
        byte == 0x3A ||
        byte == 0x2D;
    if (allowed) {
      escaped.writeCharCode(byte);
    } else {
      escaped.write('%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
    }
  }
  return escaped.toString();
}

final class _PreparedRequest {
  const _PreparedRequest({
    required this.options,
    required this.specSource,
    required this.input,
  });

  final _PrimaryCliOptions options;
  final String specSource;
  final _InputSelection input;
}

sealed class _InputSelection {
  const _InputSelection();
}

final class _LiteralInput extends _InputSelection {
  const _LiteralInput(this.value);

  final String value;
}

final class _FileInput extends _InputSelection {
  const _FileInput(this.file);

  final File file;
}

_PreparedRequest? _prepareRequest(
  _PrimaryCliOptions options,
  Directory cwd,
  Directory? repoRoot,
) {
  final String? source;
  if (options.spec != null) {
    final file = resolvePrimaryCliNamedSpec(options.spec!, cwd, repoRoot);
    source = file == null ? null : readPrimaryCliStrictUtf8File(file);
  } else if (options.specFile != null) {
    source = readPrimaryCliStrictUtf8File(
      _explicitFile(options.specFile!, cwd),
    );
  } else {
    source = options.inlineSpec!;
  }
  if (source == null) {
    return null;
  }

  final input = options.inputFile == null
      ? _LiteralInput(options.input!)
      : _FileInput(_explicitFile(options.inputFile!, cwd));
  return _PreparedRequest(options: options, specSource: source, input: input);
}

File _explicitFile(String path, Directory cwd) {
  final file = File(path);
  return file.isAbsolute
      ? file
      : File('${cwd.path}${Platform.pathSeparator}$path');
}

File? resolvePrimaryCliNamedSpec(
  String name,
  Directory cwd,
  Directory? repositoryRoot,
) {
  final filename = name.endsWith('.spec') ? name : '$name.spec';
  final candidates = <File>[
    _explicitFile(name, cwd),
    _explicitFile(filename, cwd),
    if (repositoryRoot != null)
      File(
        '${repositoryRoot.path}${Platform.pathSeparator}specs'
        '${Platform.pathSeparator}$filename',
      ),
  ];
  for (final candidate in candidates) {
    if (candidate.existsSync()) {
      return candidate;
    }
  }
  return null;
}

String? _loadInput(_InputSelection input) => switch (input) {
  _LiteralInput(:final value) => value,
  _FileInput(:final file) => readPrimaryCliStrictUtf8File(file),
};

String? readPrimaryCliStrictUtf8File(File file) {
  try {
    final bytes = file.readAsBytesSync();
    var decoded = utf8.decode(bytes, allowMalformed: false);
    if (_startsWithUtf8Bom(bytes) && !decoded.startsWith('\uFEFF')) {
      decoded = '\uFEFF$decoded';
    }
    return decoded;
  } on FileSystemException {
    return null;
  } on FormatException {
    return null;
  }
}

bool _startsWithUtf8Bom(Uint8List bytes) =>
    bytes.length >= 3 &&
    bytes[0] == 0xEF &&
    bytes[1] == 0xBB &&
    bytes[2] == 0xBF;

Directory? _findRepositoryRoot() {
  final anchors = <Directory>[
    Directory.current.absolute,
    if (Platform.script.scheme == 'file') File.fromUri(Platform.script).parent,
  ];
  for (final anchor in anchors) {
    var directory = anchor.absolute;
    while (true) {
      final marker = File(
        '${directory.path}${Platform.pathSeparator}specs'
        '${Platform.pathSeparator}user_function_definition.spec',
      );
      if (marker.existsSync()) {
        return directory;
      }
      final parent = directory.parent;
      if (parent.path == directory.path) {
        break;
      }
      directory = parent;
    }
  }
  return null;
}

Object? _canonicalJson(Object? value) {
  if (value is List) {
    return [for (final item in value) _canonicalJson(item)];
  }
  if (value is Map) {
    final entries = value.entries.toList()
      ..sort(
        (left, right) => left.key.toString().compareTo(right.key.toString()),
      );
    return {
      for (final entry in entries)
        entry.key.toString(): _canonicalJson(entry.value),
    };
  }
  return value;
}
