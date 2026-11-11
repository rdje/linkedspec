"""Asserted Dart pipeline-role writer; --check constructs without writes."""
import gzip
from pathlib import Path
import sys

BASE = Path(__file__).resolve().parent
OWNER = Path('dart/lib/src/runtime/interpreter.dart')
original = gzip.decompress((BASE / 'owner-before.dart.gz').read_bytes()).decode()
assert OWNER.read_text() == original
text = original


def replace_once(old, new):
    global text
    assert text.count(old) == 1, old[:90]
    text = text.replace(old, new)


replace_once('        final arrayTransformChain = _isOrdinaryArrayTransformResultChain(', '''        final arrayPipelineChain = _isOrdinaryArrayPipelineResultChain(
          receiver,
          calls,
        );
        final preserveInitialArrayPipelineSource =
            arrayPipelineChain &&
            !kindGuardedSource &&
            !_isOrdinaryCountResultChain(receiver, const []) &&
            !_isOrdinaryKeyCountResultChain(receiver, const []) &&
            !_isOrdinaryHashViewResultChain(receiver, const []) &&
            !_isOrdinaryHashValueResultChain(receiver, const []) &&
            !_isOrdinaryArrayTransformResultChain(receiver, const []) &&
            !_isOrdinaryArrayPipelineResultChain(receiver, const []) &&
            _isOrdinaryArrayPipelineReceiverCall(calls.first);
        // Keep the first pipeline's source fallback; its Array owns later guards.
        kindGuardedSource = kindGuardedSource || arrayPipelineChain;
        final arrayTransformChain = _isOrdinaryArrayTransformResultChain(''')
replace_once('''          preserveInitialArrayTransformSource:
              preserveInitialArrayTransformSource,
''', '''          preserveInitialArrayTransformSource:
              preserveInitialArrayTransformSource,
          preserveInitialArrayPipelineSource: preserveInitialArrayPipelineSource,
''')
replace_once('''    bool preserveInitialArrayTransformSource = false,
''', '''    bool preserveInitialArrayTransformSource = false,
    bool preserveInitialArrayPipelineSource = false,
''')
replace_once('''    var arrayTransformSourcePending = preserveInitialArrayTransformSource;
''', '''    var arrayTransformSourcePending = preserveInitialArrayTransformSource;
    var arrayPipelineSourcePending = preserveInitialArrayPipelineSource;
''')
replace_once('''      arrayTransformSourcePending = false;
''', '''      arrayTransformSourcePending = false;
      final initialArrayPipelineSource = arrayPipelineSourcePending;
      arrayPipelineSourcePending = false;
''')
replace_once('''          !initialArrayTransformSource &&
''', '''          !initialArrayTransformSource &&
          !initialArrayPipelineSource &&
''')
helpers = '''  bool _isOrdinaryArrayPipelineOperand(ActionExpr expression) =>
      _isOrdinaryArrayTransformOperand(expression) &&
      !(expression is ActionCallExpr &&
          const {
            'flat',
            'flat_array',
            'flat_hash',
          }.contains(canonicalActionHelperName(expression.name)));

  bool _isOrdinaryArrayPipelineArguments(
    String helper,
    List<ActionArgument> args, {
    required bool receiver,
  }) {
    final count = args.length + (receiver ? 1 : 0);
    final canonicalArity = switch (helper) {
      'split_each' || 'filter_match' => count == 2,
      'trim_each' ||
      'filter_nonempty' ||
      'lowercase_each' ||
      'uppercase_each' ||
      'uniq' => count == 1,
      _ => false,
    };
    if (!canonicalArity) {
      return false;
    }
    for (var index = 0; index < args.length; index++) {
      final argument = args[index];
      if (argument is! ActionPositionalArgument) {
        return false;
      }
      final value = argument.value;
      if (!_isOrdinaryArrayPipelineOperand(value) &&
          !(const {'split_each', 'filter_match'}.contains(helper) &&
              index + 1 == args.length &&
              value is ActionRegexLiteralExpr)) {
        return false;
      }
    }
    return true;
  }

  bool _isOrdinaryArrayPipelineReceiverCall(ActionFluentCall call) =>
      (call.sourceMethod ?? call.method) == call.method &&
      !call.trailingBlockArg &&
      !call.receiverTrailingBlockArg &&
      _isOrdinaryArrayPipelineArguments(call.method, call.args, receiver: true);

  // Canonical eager pipelines keep their producer/regex policies. Only ordinary
  // typed values and prefixes gain persistent actual-kind result guards.
  bool _isOrdinaryArrayPipelineResultChain(
    ActionExpr receiver,
    List<ActionFluentCall> calls,
  ) {
    if (calls.any((call) {
      final helper = canonicalActionHelperName(call.method);
      return _treeTraversalHelperNames.contains(helper) ||
          call.args.any(
            (argument) =>
                argument is! ActionPositionalArgument ||
                (helper != 'with' &&
                    !_isOrdinaryArrayPipelineOperand(argument.value) &&
                    !(argument.value is ActionRegexLiteralExpr &&
                        _isOrdinaryArrayPipelineReceiverCall(call))),
          ) ||
          ((call.trailingBlockArg || call.receiverTrailingBlockArg) &&
              helper != 'with') ||
          !(_runtimeReceiverHelperNames.contains(helper) ||
              const {'copy', 'with', 'and', 'or', 'not'}.contains(helper));
    })) {
      return false;
    }
    if (receiver is ActionCallExpr) {
      if (compiledSpec.functionRegistry.hasName(receiver.name)) {
        return false;
      }
      if ((receiver.sourceMethod ?? receiver.name) == receiver.name &&
          !receiver.trailingBlockArg &&
          _isOrdinaryArrayPipelineArguments(
            receiver.name,
            receiver.args,
            receiver: false,
          )) {
        return true;
      }
    }
    return _isOrdinaryArrayPipelineOperand(receiver) &&
        calls.length > 1 &&
        _isOrdinaryArrayPipelineReceiverCall(calls.first);
  }

'''
replace_once('  bool _isOrdinaryArrayTransformOperand(ActionExpr expression) =>', helpers + '  bool _isOrdinaryArrayTransformOperand(ActionExpr expression) =>')
assert text != original
if sys.argv[1:] == ['--check']:
    print('Read/construct-only rehearsal: canonical pipeline role, source permission and common guard')
else:
    assert not sys.argv[1:]
    OWNER.write_text(text)
    print('Installed canonical pipeline result ownership; producers/Boolean boundary/formats unchanged')
