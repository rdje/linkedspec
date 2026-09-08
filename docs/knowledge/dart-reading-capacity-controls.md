---
id: dart-reading-capacity-controls
title: Approved Dart reading capacity preserves bounded members and tests the real validators
answers:
  - what are the current task and Knowledge capacity limits for Dart reading
  - which guard enforces the approved Dart task collection capacity
  - how do I verify task and Knowledge boundaries at their exact limits
  - did the director approve the capacity exception before full codebase reading
  - does the Dart capacity exception permit parser repairs or artifact purge
  - how do I independently verify retained evidence and the complete Dart capacity reserve
date: 2026-09-08
status: implemented at 4489f5e9 with canonical proof; independently recomposed under LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.3
tags: [capacity, task-tree, knowledge, doctrine, continuity]
evidence: "The director approved ADR 0108 with I greenlight the exception. ADR 0109 authorizes exactly four aggregate scalar changes. The task main census and 31 self-test classes share the real collection validators; new boundary expectations reject the old guards and pass after the two aggregate adjustments. The registry-bound audit below also exercises the unchanged routing validator directly. Canonical completion evidence belongs to the .7.2 commit and exact receipt; independent .7.3 and admission .7.4 remain pending."
evidence_update_2026_09_09: "Canonical .7.2 lands at 4489f5e9 with all nine doctrines, CLI 66x2 and Phase 0 1032/1032 in 1152 seconds; 25 optional gates are not fresh proof. Independent .7.3 rechecks real boundaries, retained evidence and lookup, current controls, and the complete reserve with all original allowances applied again. Admission .7.4 remains pending."
reverify:
  - "bash tools/project_data_run.sh perl scripts/check_task_tree_partitions.pl"
  - "Run the repository-managed CAPACITY_BOUNDARY_AUDIT block below."
  - "Run the repository-managed CONTAINMENT73_AUDIT block below for exact historical retention and current reserve."
  - "bash tools/project_data_run.sh perl scripts/check_readme_routing_pressure.pl --report"
---

# Exact scope and actual validator proof

ADR `0109` authorizes task totals of 88,000 lines / 9,437,184 bytes and Knowledge totals of
1,152 files / 72,000 lines. Task file count remains 128, task members remain 8,000 lines /
1,048,576 bytes, and Knowledge members remain 512 lines / 65,536 bytes with 6,291,456 total bytes.
Knowledge Map limits and all FUTURE partition/member/source/identity contracts remain unchanged.

The scope is capacity infrastructure and direct verification/continuity. It does not authorize parser
repairs, a mutation campaign, recovery/purge, parked authoring ideas or Dart source-reading credit.
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.3` independently recomposes the controls; `.7.4` owns admission
before the separate Dart tree decomposes its source-reading children.

The partition checker main census calls `collection_member_errors` and `collection_total_errors`.
The partition census covers Markdown members; the routing census also includes the registered JSONL index.
That existing scope difference is preserved; agreement means matching ceilings, not identical census counts.
Its seven collection self-test classes exercise equality, independent and simultaneous overflow
through those same functions. The original non-capacity tests are retained; the total is now 31.

The audit below loads the exact pure validator definitions from the tracked checkers without executing
their repository scans, and passes the real approved registry objects. It checks two collections with
eight cases each: below all ceilings, equal to all ceilings, five independent overflows, and all five
overflows together. Task cases also execute the independent partition validators: sixteen cases and
twenty-four validator executions. This isolated boundary proof complements the full resulting-tree
checker and its unchanged 32 mutation classes; it is not a substitute for that integration check.

```bash
bash tools/project_data_run.sh perl - <<'CAPACITY_BOUNDARY_AUDIT'
use strict;
use warnings;
use JSON::PP ();
sub read_source {
    my ($path) = @_;
    open my $fh, '<:raw', $path or die "$path: $!\n";
    local $/;
    my $source = <$fh>;
    close $fh or die "$path: $!\n";
    return $source;
}
my $routing = read_source('scripts/check_readme_routing_pressure.pl');
my ($route_function) = $routing =~ /(^sub exceeds_limits \{.*?^\})/ms;
die "routing validator definition missing\n" unless defined $route_function;
my $partition = read_source('scripts/check_task_tree_partitions.pl');
my @task_functions = $partition =~ /(^sub collection_(?:member|total)_errors \{.*?^\})/msg;
die "task validator definitions missing\n" unless @task_functions == 2;
eval(join("\n", $route_function, @task_functions) . "\n1;") or die $@;
my $json = JSON::PP->new->canonical(1);
my @records = map { $json->decode($_) } split /\n/, read_source('doctrine/readme_stability/routes.jsonl');
my %expected = (
    task_evidence => {max_files=>128, max_lines_per_file=>8000, max_bytes_per_file=>1048576,
        max_total_lines=>88000, max_total_bytes=>9437184},
    knowledge_cards => {max_files=>1152, max_lines_per_file=>512, max_bytes_per_file=>65536,
        max_total_lines=>72000, max_total_bytes=>6291456},
);
my ($cases, $executions) = (0, 0);
for my $name (sort keys %expected) {
    my @surface = grep { $_->{type} eq 'surface' && $_->{id} eq $name } @records;
    die "$name registry identity is not unique\n" unless @surface == 1;
    my $limits = $surface[0]{limits};
    die "$name approved limits changed; review the new capacity owner\n"
        unless $json->encode($limits) eq $json->encode($expected{$name});
    my $ceiling = {
        files=>$limits->{max_files}, lines=>$limits->{max_total_lines}, bytes=>$limits->{max_total_bytes},
        members=>['boundary.md'], per_file=>{'boundary.md'=>{
            lines=>$limits->{max_lines_per_file}, bytes=>$limits->{max_bytes_per_file}}},
    };
    my @labels = ('files', 'aggregate lines', 'aggregate bytes', 'boundary.md lines', 'boundary.md bytes');
    for my $case (-2 .. 5) {
        my $m = $json->decode($json->encode($ceiling));
        my @slots = (\$m->{files}, \$m->{lines}, \$m->{bytes},
            \$m->{per_file}{'boundary.md'}{lines}, \$m->{per_file}{'boundary.md'}{bytes});
        if ($case == -2) { --$$_ for @slots }
        elsif ($case == 5) { ++$$_ for @slots }
        elsif ($case >= 0) { ++${$slots[$case]} }
        my @actual = exceeds_limits($m, $limits);
        my @wanted = $case == 5 ? @labels : $case >= 0 ? ($labels[$case]) : ();
        my @actual_labels = map { my $s=$_; $s =~ s/ \d+\/\d+\z//; $s } @actual;
        die "$name case $case routing mismatch: @actual\n"
            unless $json->encode(\@actual_labels) eq $json->encode(\@wanted);
        ++$executions;
        if ($name eq 'task_evidence') {
            my @task = (collection_total_errors(@$m{qw(files lines bytes)}),
                collection_member_errors('boundary.md', @{$m->{per_file}{'boundary.md'}}{qw(lines bytes)}));
            die "$name case $case task/routing disagreement: @task\n" unless @task == @wanted;
            ++$executions;
        }
        ++$cases;
    }
}
die "boundary census changed\n" unless $cases == 16 && $executions == 24;
print "PASS $cases registry-bound cases / $executions actual validator executions; all independent limits preserved\n";
CAPACITY_BOUNDARY_AUDIT
```

## Independent recomposition — 2026-09-09

The implementation diff preserves all 100 task Markdown paths, all 1,018 prior Knowledge paths
and their question blocks, all 59 history-store files (56 immutable segments and three manifests) and all 11 FUTURE task/index files.
The audit compares 2,137 ID-prefixed blocks, including 64 headers with trailing text; the unchanged
current-ID checker separately counts 2,073 exact complete-line definitions. These are different
census scopes, not interchangeable totals. Non-owned blocks remain byte-identical.
Stable lookup emits the exact registered owner from root and docs/, without moving any record.

The calculation below applies every original template, twice-growth and setup allowance again to
the current population. This conservative check does not subtract already spent setup allowance.
It enumerates current registered members, including new files, and verifies the actual collection and
single-file schemas, including every stricter task-member limit.
The new Dart member projection remains 5,146 lines / 856,902 bytes. Actual admission and subsequent
slices must remeasure their complete resulting population; unknown findings remain unbounded.
The executable guard and registry must still match implementation 4489f5e9; later control changes
require a new owner and audit. The command reports current metrics, not a frozen future guarantee.

```bash
bash tools/project_data_run.sh python3 - <<'CONTAINMENT73_AUDIT'
import subprocess,json,re,hashlib,glob
from pathlib import Path
OLD='b7638e34ad5e3fe245a639bc8bfb378b8fd3ba63'
IMPL='4489f5e9a3cf60fabf6c4f69d27aedfc87cbac6b'
def git(*args): return subprocess.check_output(['git',*args])
def listing(ref):
    return {p.decode():h.decode() for mode,kind,h,p in
            (row.split(None,3) for row in git('ls-tree','-r',ref).splitlines()) if kind==b'blob'}
def blobs(ref,paths):
    raw=subprocess.check_output(['git','cat-file','--batch'],
        input=''.join(ref+':'+p+'\n' for p in paths).encode())
    out={};offset=0
    for p in paths:
        end=raw.index(b'\n',offset);head=raw[offset:end].split()
        assert len(head)==3 and head[1]==b'blob'
        n=int(head[2]);offset=end+1;out[p]=raw[offset:offset+n];offset+=n
        assert raw[offset:offset+1]==b'\n';offset+=1
    assert offset==len(raw)
    return out
a=listing(OLD);b=listing(IMPL)
registry='doctrine/readme_stability/routes.jsonl'
ra=git('show',OLD+':'+registry).splitlines()
rb=git('show',IMPL+':'+registry).splitlines()
assert len(ra)==len(rb)
expected={'task_evidence':{'max_total_lines':(80000,88000),'max_total_bytes':(8388608,9437184)},
          'knowledge_cards':{'max_files':(1024,1152),'max_total_lines':(64000,72000)}}
seen=set()
for x,y in zip(ra,rb):
    if x==y: continue
    ox=json.loads(x);ny=json.loads(y);name=ox['id']
    assert name in expected and name not in seen
    seen.add(name)
    for key,(old,new) in expected[name].items():
        assert ox['limits'][key]==old and ny['limits'][key]==new
        ox['limits'][key]=new
    assert ox==ny
assert seen==set(expected)
for p in a:
    if p.startswith(('docs/history/','docs/tasks/FUTURE-PARITY-BACKLOG')):
        assert a[p]==b.get(p),p
tasks=sorted(p for p in a if p.startswith('docs/tasks/') and p.endswith('.md'))
assert tasks==sorted(p for p in b if p.startswith('docs/tasks/') and p.endswith('.md'))
ta=blobs(OLD,tasks);tb=blobs(IMPL,tasks);q=chr(96)
def nodes(data):
    text=data.decode();marks=list(re.finditer(r'^- ID: '+q+'([^'+q+']+)'+q,text,re.M));out={}
    for i,m in enumerate(marks):
        end=marks[i+1].start() if i+1<len(marks) else len(text)
        section=re.search(r'^## ',text[m.end():end],re.M)
        if section: end=m.end()+section.start()
        assert m[1] not in out,m[1]
        out[m[1]]=text[m.start():end]
    return out
lookup_args=['perl','tools/read_task_tree.pl','--tree','FUTURE-PARITY-BACKLOG','--id','FUTURE-PARITY-BACKLOG.14.3.1.1']
lookup=subprocess.check_output(lookup_args)
assert lookup==tb['docs/tasks/FUTURE-PARITY-BACKLOG.14.md']
lookup_args[1]='../tools/read_task_tree.pl'
assert subprocess.check_output(lookup_args,cwd='docs')==lookup
assert ('- ID: '+q+'FUTURE-PARITY-BACKLOG.14.3.1.1'+q).encode() in lookup
node_count=0
allowed={'LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7','LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.2'}
for p in tasks:
    na=nodes(ta[p]);nb=nodes(tb[p]);assert na.keys()==nb.keys(),p
    node_count+=len(na)
    for key in na:
        if key not in allowed: assert na[key]==nb[key],(p,key)
    if p not in ('docs/tasks/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.md','docs/tasks/SESSION-STARTUP-READING.md'):
        assert ta[p]==tb[p],p
kp=sorted(p for p in a if p.startswith('docs/knowledge/') and p.endswith('.md'))
assert set(kp)<=set(b)
ka=blobs(OLD,kp);kb=blobs(IMPL,kp)
def questions(data):
    front=data.split(b'\n---',1)[0]
    match=re.search(rb'^answers:[^\n]*(?:\n[ \t]+[^\n]*)*',front,re.M)
    return match[0] if match else None
assert all(questions(ka[p])==questions(kb[p]) for p in kp)
changed=git('diff','--name-only',OLD,IMPL).decode().splitlines()
assert len(changed)==19
assert [p for p in changed if p.startswith(('scripts/','tools/','.githooks/'))]==['scripts/check_task_tree_partitions.pl']
assert not any(p.startswith(('perl/','rust/','dart/','julia/','lua/','specs/','t/','tests/','bin/')) for p in changed)
assert Path(registry).read_bytes()==git('show',IMPL+':'+registry)
assert Path('scripts/check_task_tree_partitions.pl').read_bytes()==git('show',IMPL+':scripts/check_task_tree_partitions.pl')
records=[json.loads(line) for line in rb]
pressure={}
for name in ('task_evidence','knowledge_cards','knowledge_map'):
    record=next(r for r in records if r.get('type')=='surface' and r.get('id')==name)
    paths=sorted({p for pattern in record['members'] for p in glob.glob(pattern)})
    assert all(Path(p).is_file() and not Path(p).is_symlink() for p in paths)
    values={p:Path(p).read_bytes() for p in paths}
    metrics={'files':len(paths),'lines':sum(v.count(b'\n') for v in values.values()),'bytes':sum(map(len,values.values()))}
    caps=record['limits']
    fields=('lines','bytes') if name=='knowledge_map' else ('files','lines','bytes')
    if name=='knowledge_map': assert paths==['KNOWLEDGE_MAP.md']
    for field in fields:
        key='max_'+field if name=='knowledge_map' else 'max_files' if field=='files' else 'max_total_'+field
        assert metrics[field]<=caps[key]
    for p,v in values.items():
        per=record['member_limits'].get(p,{})
        lc=per.get('max_lines',caps.get('max_lines_per_file',caps.get('max_lines')))
        bc=per.get('max_bytes',caps.get('max_bytes_per_file',caps.get('max_bytes')))
        assert v.count(b'\n')<=lc and len(v)<=bc,p
    pressure[name]=metrics
reserves={'task_evidence':{'files':4,'lines':616+2*2096+1000,'bytes':39000+2*318581+200000},
          'knowledge_cards':{'files':2*36+4,'lines':2*5865+256,'bytes':2*407816+65536},
          'knowledge_map':{'lines':2*529+256,'bytes':2*151509+65536}}
projected={}
for name,extra in reserves.items():
    caps=next(r['limits'] for r in records if r.get('type')=='surface' and r.get('id')==name)
    projected[name]={}
    for field,delta in extra.items():
        limit=caps['max_'+field if name=='knowledge_map' else 'max_files' if field=='files' else 'max_total_'+field]
        use=pressure[name][field]+delta
        assert use<=limit,(name,field,use,limit)
        projected[name][field]={'use':use,'limit':limit,'remaining':limit-use}
new_member={'lines':616+2*2115+300,'bytes':39000+2*308951+200000}
assert new_member['lines']<=8000 and new_member['bytes']<=1048576
exact_lines=sum(len(re.findall(r'^- ID: '+q+'[^'+q+']+'+q+r'[ \t]*$',v.decode(),re.M)) for v in ta.values())
assert exact_lines==2073 and node_count==2137
report={'implementation':IMPL,'previous':OLD,'task_files':len(tasks),'node_bodies':node_count,
        'exact_id_lines':exact_lines,'lookup_sha256':hashlib.sha256(lookup).hexdigest(),
        'knowledge_paths_retained':len(kp),'history_store_files':sum(p.startswith('docs/history/') for p in a),
        'future_files':sum(p.startswith('docs/tasks/FUTURE-PARITY-BACKLOG') for p in a),
        'pressure':pressure,'projection_with_full_allowances':projected,'new_dart_member_projection':new_member}
print(json.dumps(report,indent=2,sort_keys=True))
print('PASS exact approved diff, retained nodes/questions/immutable bytes, current controls and full remaining reserve')
CONTAINMENT73_AUDIT
```
