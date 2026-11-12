---
id: perl-open-arity-concat-result-guards
title: Perl concat result roles preserve the existing one-or-more Array signature
answers:
  - "how do Perl open arity concat result guards work"
  - "are Perl one and three Array concat results guarded through Hash rejection"
  - "why did Perl concat bad signature diagnostics change without admitting functions"
  - "which Perl concat compatibility profiles changed in family80"
date: 2026-11-12
status: Perl80.1 implemented with focused proof; independent peers and full admission open
tags: [perl, arrays, concat, arity, functions, guards, compatibility]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.80.1; docs/checkpoints/array-concat-open-arity-perl-2026-11-12/REVIEW.md;504 programs/26 supported targets/four separate compatibility/474 full preservation; exact-old30/current504/direct1028; first independent readonly0/25 controls/current186. Original before28/after2 capture1/comparator1/qualification1 remain."
reverify:
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/array-concat-open-arity-perl-2026-11-12/review_qualified.py"
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/array-concat-open-arity-perl-2026-11-12/review_owned_narrative.py"
---

MethodLowering.pm's _ordinary_array_transform_result_call counts a receiver as
the first argument. Concat now uses its existing minimum-one/unbounded count;
other transforms retain their bounds. Only result-role ownership changes, with
the original producer/invocation/signature code intact. Source S and additional
Arrays T/U evaluate once in order before a wrong Hash consumer rejects and skips
K/V. That rejection persists through copy/logical/with, skipping D/W; needed
errors propagate. Valid fixed/rest function results and ordinary constructor
results retain this behavior. Empty Arrays still enter immediate with.

Fresh own504 acquisition combines source-exact selection84/source-only legacy312/
own108.26 supported targets are distinct from four compatibility changes. Two
legacy excess non-Array operands retain terminal SX; only their two expectation
objects/diagnostic label move, without input-domain/product-RED authority. Two
already-rejected bad-signature free compositions now name their original pair/
keep callee and retain terminal TU; they remain unready/unresolved. Exact-original
canonical-two public controls already have those rejection/producer semantics.
All80 initial policies, other six invalid-signature records and474 full records
stay exact. No malformed function is admitted.

First after normal2/capture1 and the original before28 remain. Qualified same-path
old30/current504/direct1028 and strict independent reader0 prove the final scoped
result; they do not rewrite the original runs. Normal JSON comparisons/strict
reader retain Bool/Number and full field distinctions.3024 actual six-epoch pairs
plus four signature-oracle pairs survive; native dumps follow Get compilation.
Complete native/cache/transitive/source/context/canonical discovery/full23.4 and
independent Rust/Dart/Julia/Lua80.2-.5 remain separately owned.

First staged whitespace2 flags a required raw unified-diff context space. Exact
patch bytes/mode survive gzip/use/retirement; qualified reader0 has the same
25-control verdict and gates the new producer/archive inputs. Original first
reader0/source/seal stay intact; qualified current186 passes after retirement.

First normal landing has nine doctrine PASS/one task-size FAIL at12590016/
12582912 bytes. Only this new leaf's commentary routes10915 bytes to its retained
packet, with contracts/six signoff checks/all other nodes/full future tail exact.
Independent routing recovery0/seven controls passes; headroom29 precedes Rust80.2.
The focused post-route README/pressure check0 also passes before normal retry.
