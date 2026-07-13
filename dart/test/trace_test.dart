import 'dart:io';

import 'package:linkedspec_dart/linkedspec_dart.dart';
import 'package:test/test.dart';

void main() {
  test('trace levels parse names aliases and numeric thresholds', () {
    expect(LinkedSpecTraceLevel.parse('none'), LinkedSpecTraceLevel.none);
    expect(LinkedSpecTraceLevel.parse('quiet'), LinkedSpecTraceLevel.none);
    expect(LinkedSpecTraceLevel.parse('med'), LinkedSpecTraceLevel.medium);
    expect(LinkedSpecTraceLevel.parse('verbose'), LinkedSpecTraceLevel.debug);
    expect(LinkedSpecTraceLevel.parse('350').value, 350);
    expect(LinkedSpecTraceLevel.parse('-1').value, -1);
    expect(
      () => LinkedSpecTraceLevel.parse('unknown'),
      throwsA(isA<LinkedSpecTraceException>()),
    );

    expect(
      LinkedSpecTraceLevel.medium.allows(LinkedSpecTraceLevel.low),
      isTrue,
    );
    expect(
      LinkedSpecTraceLevel.low.allows(LinkedSpecTraceLevel.medium),
      isFalse,
    );
    expect(LinkedSpecTraceLevel(350).allows(LinkedSpecTraceLevel.high), isTrue);
    expect(
      LinkedSpecTraceLevel(350).allows(LinkedSpecTraceLevel.full),
      isFalse,
    );
  });

  test('trace config reads documented environment controls', () {
    final config = LinkedSpecTraceConfig.fromEnvironment({
      'LINKEDSPEC_TRACE_LEVEL': 'debug',
      'LINKEDSPEC_TRACE_FILE': 'trace.log',
      'LINKEDSPEC_TRACE_MIRROR_STDOUT': '1',
      'LINKEDSPEC_TRACE_RESET_FILE': 'yes',
      'LINKEDSPEC_TRACE_EMOJI': 'on',
    });

    expect(config.level, LinkedSpecTraceLevel.debug);
    expect(config.traceFile, 'trace.log');
    expect(config.sinkMode, LinkedSpecTraceSinkMode.mirror);
    expect(config.resetFile, isTrue);
    expect(config.emoji, isTrue);
  });

  test('route sink resets trace file and keeps stdout quiet', () {
    final traceFile = _tempTraceFile('route-reset');
    traceFile.writeAsStringSync('old\n');
    final stdout = StringBuffer();
    final emitter = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(
        LinkedSpecTraceLevel.debug,
      ).withTraceFile(traceFile.path).withResetFile(true),
      stdoutWriter: stdout.write,
    );

    emitter.emitLine(LinkedSpecTraceLevel.low, 'hello');

    expect(stdout.toString(), isEmpty);
    expect(traceFile.readAsStringSync(), 'hello\n');
  });

  test('mirror sink writes stdout and routed file', () {
    final traceFile = _tempTraceFile('mirror');
    final stdout = StringBuffer();
    final emitter = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug)
          .withTraceFile(traceFile.path)
          .withSinkMode(LinkedSpecTraceSinkMode.mirror)
          .withResetFile(true),
      stdoutWriter: stdout.write,
    );

    emitter.emitEvent(
      LinkedSpecTraceEventKind.log,
      'topic',
      'details',
      LinkedSpecTraceLevel.low,
    );

    const expected = '[LOW][log] topic details\n';
    expect(stdout.toString(), expected);
    expect(traceFile.readAsStringSync(), expected);
  });

  test('scope decision log and dump primitives produce structured events', () {
    final stdout = StringBuffer();
    final emitter = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
      stdoutWriter: stdout.write,
    );

    final scope = emitter.enterScope(
      'compile',
      'start',
      LinkedSpecTraceLevel.high,
    );
    expect(
      emitter.traceDecision(
        'use_cache',
        false,
        'miss',
        LinkedSpecTraceLevel.debug,
      ),
      isFalse,
    );
    emitter.logOutput(LinkedSpecTraceLevel.low, 'runtime message', 'ctx=run');
    emitter.logDump(LinkedSpecTraceLevel.full, 'compiled descriptor dump');
    emitter.exitScope(scope, 'done');

    final output = stdout.toString();
    expect(output, contains('[HIGH][enter] -> compile start'));
    expect(
      output,
      contains('[DEBUG][decision]   use_cache taken=0 reason=miss'),
    );
    expect(
      output,
      contains('[LOW][log]   log_output runtime message context=ctx=run'),
    );
    expect(
      output,
      contains('[FULL][dump]   log_dump compiled descriptor dump'),
    );
    expect(output, contains('[HIGH][exit] <- compile done'));
    expect(emitter.events.map((event) => event.toJson()['kind']), [
      'enter',
      'decision',
      'log',
      'dump',
      'exit',
    ]);
  });

  test('runtime traced entrypoints preserve output and route parse scope', () {
    final engine = _engine(r'''
Top::
 /x/
 E { return(match_text()) }
''');
    final untraced = engine.parse('x');

    final quietStdout = StringBuffer();
    final quietEmitter = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.disabled(),
      stdoutWriter: quietStdout.write,
    );
    final quiet = engine.parse('x', trace: quietEmitter);
    expect(quiet.toJson(), untraced.toJson());
    expect(quietStdout.toString(), isEmpty);
    expect(quietEmitter.events, isEmpty);

    final traceFile = _tempTraceFile('runtime-route');
    final routed = engine.executeWithTrace(
      'x',
      LinkedSpecTraceConfig.enabled(
        LinkedSpecTraceLevel.debug,
      ).withTraceFile(traceFile.path).withResetFile(true),
    );

    expect(routed.toJson(), untraced.toJson());
    final trace = traceFile.readAsStringSync();
    expect(trace, contains('dart_runtime:parse'));
    expect(trace, contains('top_rule=Top'));
    expect(trace, contains('matched=true cursor=1'));
  });

  test('runtime trace covers branch lifecycle cursor and boundary events', () {
    final engine = _engine(r'''
Top::
 I { set(out, []) }
 /@(\w+):[ \t]*/ -> Boundary {
   save_cursor();
   body = capture_until_boundary(Boundary);
   push(out, hash("name", match_group(0), "body", trim(body), "cursor", cursor_pos()));
   restore_cursor();
   rewind_match_start()
 }
 E { return(copy(out)) }

Boundary: /END/
''');
    final untraced = engine.parse('@a: first END');

    final stdout = StringBuffer();
    final emitter = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
      stdoutWriter: stdout.write,
    );
    final traced = engine.parse('@a: first END', trace: emitter);

    expect(traced.toJson(), untraced.toJson());
    final trace = stdout.toString();
    expect(trace, contains('dart_runtime:rule label=Top'));
    expect(trace, contains('dart_runtime:regex_match'));
    expect(trace, contains('dart_runtime:lifecycle_block'));
    expect(trace, contains('dart_runtime:cursor_control'));
    expect(trace, contains('helper=save_cursor rule=Top'));
    expect(trace, contains('helper=restore_cursor rule=Top'));
    expect(trace, contains('helper=rewind_match_start rule=Top'));
    expect(trace, contains('dart_runtime:source_boundary'));
    expect(trace, contains('helper=capture_until_boundary rule=Top'));
    expect(trace, contains('edge_family=action rule=Top target=Boundary[0]'));

    expect(
      emitter.events.map((event) => event.topic),
      containsAll({
        'dart_runtime:rule',
        'dart_runtime:regex_match',
        'dart_runtime:lifecycle_block',
        'dart_runtime:cursor_control',
        'dart_runtime:source_boundary',
        'dart_runtime:child_dispatch',
      }),
    );

    final blindEngine = _engine(r'''
Top::AND
 => ChildA
 => ChildB
 E { return(retv) }

ChildA:
 /a/
 E { return("A") }

ChildB:
 /[ \t]+b/
 E { return("B") }
''');
    final blindStdout = StringBuffer();
    final blindEmitter = LinkedSpecTraceEmitter(
      LinkedSpecTraceConfig.enabled(LinkedSpecTraceLevel.debug),
      stdoutWriter: blindStdout.write,
    );
    final blindResult = blindEngine.parse('a b', trace: blindEmitter);

    expect(blindResult.value, 'B');
    final blindTrace = blindStdout.toString();
    expect(
      blindTrace,
      contains('edge_family=blind mode=AND rule=Top index=0 target=ChildA[0]'),
    );
    expect(
      blindTrace,
      contains('edge_family=blind mode=AND rule=Top index=1 target=ChildB[0]'),
    );
  });
}

LinkedSpecRuntimeEngine _engine(String source) {
  return LinkedSpecRuntimeEngine(compileSpec(parseSpec(source)));
}

File _tempTraceFile(String name) {
  final directory = Directory.systemTemp.createTempSync(
    'linkedspec-dart-trace-$name-',
  );
  addTearDown(() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });
  return File('${directory.path}/trace.log');
}
