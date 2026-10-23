"""Publish verified CLI behavior without changing the frozen selector policy."""
import json
import re
import common as c
import context

CARD = 'docs/knowledge/perl-primary-cli-operational-failures.md'
INTEGRATION = 'docs/linkedspec-book/src/public-api/integration-perl.md'
FLOW = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
PATHS = [CARD,INTEGRATION,FLOW]
HEADING = 'Primary CLI runtime failures'
PROTOCOL = 'A recorded handler failure exits `1`, writes no JSON to stdout, and prints the stable invocation-failure heading to stderr.'
FLOW_MARKER = 'for the primary-command failure protocol.'


def command(case):
    assert "'" not in case['source']
    return "perl -Iperl bin/linkedspec --inline-spec '"+case['source']+"' --input "+case['input']


def field(text,name,value):
    pattern = re.compile('^'+re.escape(name)+':.*$',re.M)
    assert len(pattern.findall(text))==1
    return pattern.sub(lambda match:name+': '+json.dumps(value),text)


def main():
    assert c.load('repair-completion.json.gz')['source_restored']
    before = {path:c.read(path) for path in PATHS}
    census = c.load('activation.json.gz')['live_claims']
    intersections = {path:sorted(set(entry['inputs'])&set(PATHS)) for path,entry in census.items()
        if set(entry['inputs'])&set(PATHS)}
    assert not intersections
    assert all(c.read(path)==entry['packet'] for path,entry in census.items())
    epoch = context.snapshot()
    prior = c.run(['bash','tools/run_python_project_data.sh','docs/checkpoints/signed-array-selectors/publish.py'])
    assert prior['returncode']==0 and not c.decode(prior['stderr_base64'])
    assert c.unchanged(epoch['inputs'])
    c.write_new('documentation-inputs.json.gz',dict(context=epoch,before=before,
        producer=c.read(c.PREFIX+'document.py'),live_claims=census,direct_intersections=intersections,
        prior_readonly=prior,scope='The DSL flow link is an explicit bounded scope extension before its first write; the full accepted live census has no intersection. No historical claim or other Knowledge card changes.'))
    card = c.decode(before[CARD]['base64']).decode()
    card = field(card,'status','context-reported primary CLI failures repaired; original rollout/intake remain historical')
    card = field(card,'evidence','TYPE-REFERENCE-BOOK.1.2.17.8 retains11 source/input cases (10 source texts),22 quiet/routed CLI observations, Get/fresh proof and actual permanent source-inverse/restoration. Original intake and wrong no-match target remain exact and separately qualified; canonical proof governs admission.')
    card = field(card,'reverify','Current CLI consumer: bash tools/project_data_run.sh prove -Iperl t/trace_cli.t; dated source-bound proof: bash tools/run_python_project_data.sh docs/checkpoints/type-cli-runtime-errors/publish.py')
    start = card.index('# Context-only handler failures (October23)')
    end = card.index('# Original operational rollout (July10)',start)
    card = card[:start]+'''# Context-reported handler failures (October23)

The invocation boundary checks both saved `$@` and `runtime_ctx.last_error`.
An invalid fractional write, including a callable write, now exits1 with empty
stdout and `linkedspec: parser invocation failed` plus LF on stderr. Routed
trace ends in `invoke:error`; existing thrown errors keep the same protocol.
Null, false, zero, initializer return and real self-edge matched/no-match
results remain successful when both error channels are clear.

The prior CLI's exit0/null observations remain in signed intake17.0. Repair17.8
preserves every original control and qualifies its mistaken I-return target;
canonical lifecycle semantics and real self-edge twins distinguish no-match.
No library, selector or trace-protocol change is implied.

'''+card[end:]
    integration = c.decode(before[INTEGRATION]['base64']).decode()
    old = 'The current Perl primary CLI has a reporting gap: it checks thrown exceptions but ignores a handler failure recorded only in `last_error`. Such a failure can print `null` and exit `0`, including an invalid fractional array write. The application adapter in this chapter checks both channels and reports these failures. CLI repair is pending; the successful-null rule above applies only when neither failure channel is set.'
    assert integration.count(old)==1
    cases = {row['id']:row for row in c.load('cases2.json')['cases']}
    commands = {name:command(cases[name]) for name in ('fractional-write','valid-null')}
    new = '### '+HEADING+'\n\nThe primary Perl command checks both failure channels too. '+PROTOCOL+'\n\n'
    new += 'For example, this invalid fractional array write reports `linkedspec: parser invocation failed` on stderr:\n\n```sh\n'+commands['fractional-write']+'\n```\n\n'
    new += 'A grammar that deliberately returns `undef` remains successful and prints `null` plus a newline with exit `0`:\n\n```sh\n'+commands['valid-null']+'\n```\n\n'
    new += 'An explicit routed trace ends in `invoke:error` for a handler failure and `invoke:ok` for a successful null value. Primary CLI errors keep the portable heading; the application adapter below exposes selected structured context fields.\n\n### Native application adapter'
    integration = integration.replace(old,new,1)
    flow = c.decode(before[FLOW]['base64']).decode()
    old_link = 'for the primary-command limitation.'
    assert flow.count(old_link)==1
    flow = flow.replace(old_link,FLOW_MARKER,1)
    after = {CARD:card,INTEGRATION:integration,FLOW:flow}
    for path,text in after.items():
        c.source(path).write_text(text)
    c.write_new('documentation.json.gz',dict(before=before,after={path:c.read(path) for path in PATHS},
        commands=commands,knowledge_byte_delta=len(card.encode())-len(c.decode(before[CARD]['base64'])),
        scope='Current CLI behavior/examples and related flow link only. Every old Knowledge question and July operational rollout remains exact.'))
    print('Verified CLI book/card updated; original records and frozen selector policy unchanged')


if __name__ == '__main__':
    main()
