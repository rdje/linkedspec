# Perl emitted boundary regex catalog

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.37.

The boundary helper preserves native semantics: resolve complete named-rule
regex catalogs, seek from the live cursor, choose the earliest boundary, return
the preceding String without consuming the token, capture to EOF for usable
but absent boundaries, and return null without moving for unusable labels.
Quoted labels, Unicode scalar positions and regex flags remain unchanged.

Generated `spec` entries remain executable CODE handlers. The existing private
`recognition_regex_map` is already a full per-rule regex catalog reconstructed
from compiled state. Retain that complete carrier in every generated descriptor
and allow boundary lookup to read it when the rule entry is CODE. Native HASH
entries keep priority, including empty catalogs. This adds no public metadata
field or schema: v2 remains format2 with six metadata fields and exact minimal
label/family plan rows. The recognition reader and dispatch interface remain.

The authored fixture has13sources18inputs. Before edits, all native cases pass;
four emitted source controls pass and nine source groups fail. Public and legacy
source capture agree after correcting the probe's missing dump flag. Exact
source/metadata/catalog/native/separate-process emitted records are retained.

Regenerated modules pass all13sources18inputs. Full native outcomes/catalogs,
six public metadata fields and minimal plan rows remain unchanged; the four
healthy emitted controls and recognition-only emitted source remain identical.
Original13modules replayed after repair reproduce exactly their original outcomes:
nine source groups remain wrong with accepted v2 metadata. Regenerate previously
emitted parsers that use this helper; a metadata version check cannot detect it.

Compiler/Contracts compile. Ordinary emitted/catalog, generated-source and quoted
boundary consumers pass. The nested consumer initially failed a stale historical
quoted-marker expectation: exact committed canonical files already return the
literal capture_until_boundary(end), cursor0, no error. Four old/new file pairs
with/without dump agree and candidate files were restored byte-exactly. Only the
current positive oracle changed; immutable October6 cases/claims remain intact.
The corrected nested test passes28groups. Broader lexical ownership stays separate.

Packet perl-emitted-boundary-catalog-intake.json.gz retains actual producers,
raw initial/corrected epochs, native/source/catalog/metadata channels, old/new
modules, stale replay, file matrix and current/old tests. Missing initial dump
flag and rejected overlay module origin receive no product RED/baseline credit.
Separate-process execution preloads the library; fully cold bootstrap is not
claimed. New normal/canonical registration23.4.1 and full23.4 admission/push
remain separate. No public schema, helper syntax, performance or other-backend claim.

Additional verification boundary: Additional standard Phase0 run fails28/1035 groups. Exact selected28-group replay on canonical committed-baseline and candidate files has byte-identical TAP/diagnostics; no regression from this patch is observed in those failures, and no full baseline rerun or blanket stale-test classification is claimed. P1 TYPE-REFERENCE-BOOK.1.2.23.3.45 owns each retained failure for contract-led triage/repair after40/41 and before wider feature expansion/full23.4/push. Initial selector lexical-local setup failure is retained without product credit. Phase0 is not green; full admission remains blocked on owned repairs.
