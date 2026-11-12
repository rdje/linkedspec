"""Prepare unused independent Lua publication reader and finish exact flow anchors."""
import gzip
from pathlib import Path
import subprocess
BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[2]
old=ROOT/'docs/checkpoints/array-concat-open-arity-julia-2026-11-12/review_publication.py'
body=old.read_bytes();assert body==subprocess.check_output(['git','show','HEAD:'+str(old.relative_to(ROOT))])
(BASE/'publication-reader-template.py.gz').write_bytes(gzip.compress(body,mtime=0))
s=body.decode().replace('Julia','Lua').replace('julia-open-arity-concat','lua-open-arity-concat').replace('TYPE-REFERENCE-BOOK.1.2.23.3.80.4','TYPE-REFERENCE-BOOK.1.2.23.3.80.5')
s=s.replace("(proof['programs'], proof['supported'], proof['legacy_compatibility'], proof['preserved'], proof['direct_assertions']) == (508, 20, 4, 484, 4959)","(proof['programs_per_host'], proof['supported_per_host'], proof['separate_compatibility_per_host'], proof['preserved_per_host'], proof['direct_checks_per_host']) == (508, 20, 4, 484, 6987)")
s=s.replace("== 5, 'accepted claim bindings'","== 9, 'accepted claim bindings'")
s=s.replace("f'readonly{controls}/current{identities}' in card.lower()","f'{controls}/current{identities}' in card.lower()")
s=s.replace("and 'Lua80.5' in memory","and 'discovery23.4.1' in memory")
s=s.replace("b'Lua80.4 existing concat result guards have focused proof'", "b'All five bounded concat80 backend implementations have focused outcomes'")
s=s.replace("b'Independent Lua80.4 now has a one-line'", "b'Installed Lua80.5 now has a one-line'")
s=s.replace("b'Perl, Rust, Dart and Lua result guards now cover'", "b'Perl, Rust, Dart, Julia and installed Lua result guards now cover'")
s=s.replace("assert b'bounded Lua proof here covers free-two/receiver-one.' in flow, 'independent Lua boundary'", "assert b'Installed Lua independently passes508 programs/four routes' in flow, 'independent Lua boundary'")
s=s.replace("assert b'Lua independently passes\\n508 four-route controls' in flow, 'Lua flow explanation'", "assert b'raw-table4.28/declared5.4/full admission separate' in flow, 'Lua flow qualification'")
compile(s,'review_publication.py','exec');(BASE/'review_publication.py').write_text(s)
p=BASE/'publish.py';s=p.read_text()
anchor="handoff='docs/linkedspec-book/src/appendix/backend-handoff.md'"
added='''flow='docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
edit(flow,'and `sorted`/`reversed` take no extra receiver operands. Perl, Rust, Dart and Julia guarded\\n`concat_arrays` forms now retain the existing one-or-more Array signature; the\\nbounded Lua proof here covers free-two/receiver-one.', 'and `sorted`/`reversed` take no extra receiver operands. Perl, Rust, Dart, Julia and installed Lua\\nguarded `concat_arrays` forms retain the existing one-or-more Array signature.')
edit(flow,'`["head","tail","end"]`. Perl, Rust, Dart and Julia additionally accept the single-Array terminal', '`["head","tail","end"]`. Perl, Rust, Dart, Julia and installed Lua additionally accept the single-Array terminal')
edit(flow,'recorded one/two/three-Array Perl, independent Rust, Dart and Julia controls, including empty Arrays entering with.', 'recorded one/two/three-Array Perl, independent Rust, Dart, Julia and installed Lua controls, including empty Arrays entering with.')
edit(flow,'Perl80.1, Rust80.2, Dart80.3 and Julia80.4 retain result guards through these existing arities for', 'Perl80.1, Rust80.2, Dart80.3, Julia80.4 and installed Lua80.5 retain result guards through these existing arities for')
edit(flow,'rest order, snapshots and nested kinds remain. Rebuild Julia applications. Lua\\nacquires its own policies before implementation; full continuation/context\\nadmission is separate.', 'rest order, snapshots and nested kinds remain. Rebuild Julia applications.\\nInstalled Lua independently passes508 programs/four routes with20 supported targets,\\nfour separately qualified legacy continuations and484 preserved records, including\\n80 initial/eight invalid signatures. Callable SX/ordinary SA/scalar elements remain\\nown terminal compatibility. Full published JSON/text/named flags and field absence\\nsurvive, with raw-table4.28/declared5.4/full admission separate. Reload Lua applications.')
'''
assert s.count(anchor)==1;s=s.replace(anchor,added+anchor)
compile(s,'publish.py','exec');p.write_text(s)
print('Prepared independent publication recovery/three corruptions and exact Lua flow behavior anchors')
