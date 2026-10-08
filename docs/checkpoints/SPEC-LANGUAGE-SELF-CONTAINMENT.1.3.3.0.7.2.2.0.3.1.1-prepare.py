"""Retain preliminary authored RED and prepare immutable replacement oracles."""
from pathlib import Path
import base64,gzip,hashlib,json
ROOT=Path(__file__).resolve().parents[2]
LEAF='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1'
PREFIX='docs/checkpoints/'+LEAF+'-'
OLD='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0-'
def sha(raw):return hashlib.sha256(raw).hexdigest()
def envelope(raw):return {'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),'data':base64.b64encode(gzip.compress(raw,mtime=0)).decode()}
fixture=ROOT/(PREFIX+'replacement-fixture.t');initial=fixture.read_bytes()
unused=b'    return $owner->_new_source_edit_map($_[0]) if 0; # Never pass a package argument to the private function.\n'
assert initial.count(unused)==1
(ROOT/(PREFIX+'replacement-fixture-initial.t')).write_bytes(initial)
fixture.write_bytes(initial.replace(unused,b''))
log=(ROOT/'.linkedspec-data/logs/mapped-replacement-authored-red-initial.log').read_bytes()
assert b'Failed tests:  1-9' in log and b'Files=1, Tests=10' in log
record={'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),'initial_fixture_sha256':sha(initial),'final_fixture_sha256':sha(fixture.read_bytes()),'actual_preliminary_combined_channel':envelope(log),'scope':'Actual preliminary authored fixture RED9/10, production unchanged at6feff5d40. Remove one unreachable development reminder only; no assertion, callback, expectation or measured result changes. Complete original fixture/channel remain retained; separate original stdout/stderr are unavailable for this shell-redirection run. Final supplied-tree capture retains both channels independently before production edits.'}
(ROOT/(PREFIX+'preparation.json')).write_text(json.dumps(record,indent=2)+'\n')
cases=json.loads((ROOT/(OLD+'cases.json')).read_bytes());original_count=len(cases)
for source_id,new_id,separator in [('quoted_before','lf_quoted_before','\n'),('quoted_before','crlf_quoted_before','\r\n'),('generated_data','lf_generated_data','\n'),('interleaved_equal','lf_interleaved_equal','\n')]:
    original=next(c for c in cases[:original_count] if c['id']==source_id)
    case=json.loads(json.dumps(original));case['id']=new_id
    for segment in case['segments']:
        if segment['role']=='plain':segment['text']=segment['text'].replace('; ',separator)
    case['action']=''.join(s['text'] for s in case['segments']);case['source']='Top:: I { '+case['action']+' }'
    spans=[];offset=0
    for segment in case['segments']:
        raw=segment['text']
        if segment['role'] in ('real','literal_twin'):spans.append({'role':segment['role'],'raw':raw,'start':offset,'end':offset+len(raw)})
        offset+=len(raw)
    case['spans']=spans;case['scope']='Authored '+repr(separator)+' separator variant of '+source_id+' with unchanged independent literal/value oracle; original source population remains unmodified.'
    cases.append(case)
(ROOT/(PREFIX+'cases.json')).write_text(json.dumps(cases,ensure_ascii=False,indent=2)+'\n')
probe=(ROOT/(OLD+'probe.pl')).read_text().replace(OLD,PREFIX)
probe=probe.replace('use LinkedSpec::ActionIR::SourceMembership ();','use LinkedSpec::ActionIR::SourceMembership ();\nuse LinkedSpec::ActionIR::SourceOrigins ();')
probe=probe.replace('my (@lookups, @scans, @canonicalization, $collection);','my (@lookups, @scans, @canonicalization, $collection);\nmy (@mapped_spans, @actual_edits);')
call="            $substitution = LinkedSpec::call_spec_handler_subst('Top', $action);"
assert probe.count(call)==1
replacement='''            my $mapped = LinkedSpec::ActionIR::RewritePipeline->can('_mapped_event_span');
            my $apply = LinkedSpec::ActionIR::RewritePipeline->can('_apply_source_edit');
            if ($mapped && $apply) {
                local *LinkedSpec::ActionIR::RewritePipeline::_mapped_event_span = sub {
                    my ($map, $rewritten, $event) = @_;
                    my $result = $mapped->(@_);
                    push @mapped_spans, {event_id => identity($event), event => project($event),
                        original => project(LinkedSpec::ActionIR::SourceOrigins::_origin_for($event)),
                        map => project($map), rewritten => $rewritten, result => project($result)};
                    return $result;
                };
                local *LinkedSpec::ActionIR::RewritePipeline::_apply_source_edit = sub {
                    my ($rewritten, $map, $position, $removed, $replacement) = @_;
                    my $before = $$rewritten;
                    my $result = $apply->(@_);
                    push @actual_edits, {original_source => $map ? $map->{source} : undef,
                        position => $position, removed => $removed, replacement => $replacement,
                        before => $before, after => $$rewritten, map_after => project($map)};
                    return $result;
                };
                $substitution = LinkedSpec::call_spec_handler_subst('Top', $action);
            } else {
                $substitution = LinkedSpec::call_spec_handler_subst('Top', $action);
            }'''
probe=probe.replace(call,replacement)
probe=probe.replace('lookups => \\@lookups, dump => $dump, emitted => $emitted,','lookups => \\@lookups, mapped_spans => \\@mapped_spans, actual_edits => \\@actual_edits, dump => $dump, emitted => $emitted,')
(ROOT/(PREFIX+'probe.pl')).write_text(probe)
print('Prepared',len(cases),'authored cases and complete preliminary RED retention; production unchanged.')
