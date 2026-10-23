"""Add deferred-write retrieval within unchanged Knowledge bytes and retain history."""
import re
import common as c
path='docs/knowledge/write-vivification-perl-reference.md'
original=c.read(path);old=c.decode(original['base64']).decode()
t=old.replace('date: 2026-10-19','date: 2026-10-23',1)
t=t.replace('date: 2026-10-23','  - "do Perl deferred codeblocks support indexed writes"\n  - "how does a deferred Perl assignment preserve caller null presence"\n  - "why does a deferred with call raise unknown_helper"\ndate: 2026-10-23',1)
t=re.sub(r'^evidence: .*$', 'evidence: "Original FUTURE-PARITY-BACKLOG.19.2.1 and frozen v1 fixture; deferred extension TYPE-REFERENCE-BOOK.1.2.12. Full original card: git show 24e9c72a31b7eb31ce94b09beab9655ae85378cb:docs/knowledge/write-vivification-perl-reference.md."',t,count=1,flags=re.M)
t=t.replace('prove -Iperl t/write_vivification_perl_contract.t','prove -Iperl t/callable_codeblock_literal_contract.t t/write_vivification_perl_contract.t',1)
start=t.index('This card owns the Perl milestone.')
end=t.index('\nRelated:',start)
t=t[:start]+'''The September6 intermediate snapshot is historical: Rust/Dart and Julia writes
had landed while Lua was pending. Later portable admission, six-runtime recurrence
and public closeout belong to FUTURE-PARITY-BACKLOG.19.7-.9.
'''+t[end:]
extra='''
## Deferred execution (October23)

CodeblockRuntime dispatches the typed write node to BindingRuntime. Compiled
call sites pass their invocation-local presence flags by reference; dynamic calls
share them. Scalar assignment marks presence. Copied fixed/rest parameters use
separate flags and restore caller slots/flags on every exit. Keys then RHS run
once before the root snapshot. Guards precede operands; structural failures
publish nothing. Returned roots stay detached. Malformed records reject before
effects. Native/fresh and frozen write cases run in
t/callable_codeblock_literal_contract.t. Deferred with still raises
unknown_helper:with; TYPE-REFERENCE-BOOK.1.2.16 owns repair after last14.
Only this bounded Perl extension is admitted.

Historical .19.2.1 proof: 5 AST/7 syntax/11 success/16 structural cases plus
kind, detachment, evaluation, re-entrancy, both null spellings, spans and functions;
ActionIR/trace/uniform50 and Phase0 1032/963s after12 stale expectations.
Other backends were pending .19.3-.6 at that Perl-only boundary.
'''
t=t.replace('\nRelated: ',extra+'\nRelated: ',1)
assert len(t.encode())<=len(old.encode()),(len(t.encode()),len(old.encode()))
c.save('fact-update.json.gz',dict(before=original,after=t,producer=c.read(c.PREFIX+'document_fact.py'),scope='Condense duplicated historical summary; preserve all old questions, original full card in accepted Git, named historical proofs and portable rollout owners. No cap or authority change.'))
(c.ROOT/path).write_text(t)
print('Fact bytes',len(old.encode()),'->',len(t.encode()))
