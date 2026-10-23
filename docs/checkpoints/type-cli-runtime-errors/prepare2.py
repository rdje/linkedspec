"""Qualify the original target; author a distinct real matched/no-match plan."""
import copy
import common as c


def main():
    original = c.load('cases.json')
    plan = copy.deepcopy(original)
    old = next(row for row in plan['cases'] if row['id']=='no-match')
    original_control = copy.deepcopy(old)
    old.update(id='initializer-return',value=42)
    source = 'Top::AND\n /x/ -> Top[0] { return(42) }\n'
    plan['cases'].extend([
        dict(id='no-match',source=source,input='y',value=None),
        dict(id='matched-control',source=source,input='x',value=42)])
    plan['scope'] = 'Eleven sources: three context-only failures, one thrown error and seven successful controls. The I-return qualification and real self-edge matching twins are distinct; original data/targets stay unchanged.'
    c.write_new('cases2.json',plan)
    c.write_new('control-qualification.json.gz',dict(original_control=original_control,
        qualified_initializer=old,added_controls=plan['cases'][-2:],
        reason='Selection enters a handler without matching its own regex; I return exits before matching. A bare own-regex rule returns0 here and is not a matching control. Explicit self-edge twins exercise /x/: y returns null, x returns42, through native and independently emitted execution.',
        canonical=c.read('docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md'),
        before_test=c.read('t/trace_cli.t'),producer=c.read(c.PREFIX+'prepare2.py'),
        original_oracle=c.read(c.PREFIX+'oracle.py'),original_plan=c.read(c.PREFIX+'cases.json')))
    oracle = c.source(c.PREFIX+'oracle.py').read_text()
    oracle = oracle.replace("c.load('cases.json')","c.load('cases2.json')")
    oracle = oracle.replace('successful_controls=5','successful_controls=7')
    (c.ROOT/c.PREFIX/'oracle2.py').write_text(oracle)
    baseline = c.source(c.PREFIX+'baseline.py').read_text()
    baseline = baseline.replace('baseline-inputs.json.gz','baseline2-inputs.json.gz')
    baseline = baseline.replace("+'baseline.py'","+'baseline2.py'")
    baseline = baseline.replace('cases.json','cases2.json').replace("'baseline.json.gz'","'baseline2.json.gz'")
    baseline = baseline.replace('18 CLI','22 CLI')
    (c.ROOT/c.PREFIX/'baseline2.py').write_text(baseline)
    path = c.source('t/trace_cli.t')
    text = path.read_text()
    start = text.index(" my @cases = (\n",text.index("subtest 'falsey"))
    end = text.index('\n};\n',start)
    text = text[:start]+''' my @cases = (
  ["Top: /x/\\n I { return(undef) }\\n", 'x', "null\\n"],
  ["Top: /x/\\n I { return(false) }\\n", 'x', "false\\n"],
  ["Top: /x/\\n I { return(0) }\\n", 'x', "0\\n"],
  ["Top: /x/\\n I { return(42) }\\n", 'y', "42\\n"],
  ["Top::AND\\n /x/ -> Top[0] { return(42) }\\n", 'y', "null\\n"],
  ["Top::AND\\n /x/ -> Top[0] { return(42) }\\n", 'x', "42\\n"],
 );
 for my $case (@cases) {
  my ($source, $input, $expected) = @$case;
  my ($exit, $stdout, $stderr) = _run_cmd(
   @cli, '--inline-spec', $source, '--input', $input,
  );
  is($exit, 0, 'falsey, initializer or matched/no-match result exits zero');
  is($stdout, $expected, 'result retains its canonical JSON value');
  is($stderr, '', 'successful result has no error heading');
 }'''+text[end:]
    path.write_text(text)
    c.write_new('control-revision.json.gz',dict(test=c.read('t/trace_cli.t'),
        plan=c.read(c.PREFIX+'cases2.json'),oracle=c.read(c.PREFIX+'oracle2.py'),
        baseline_producer=c.read(c.PREFIX+'baseline2.py')))
    print('Distinct eleven-source plan and genuine matched/no-match regressions prepared; original nine-source baseline stays exact')


if __name__ == '__main__':
    main()
