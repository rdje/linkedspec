# Historical Rust serialized-input retention boundary

Owner now: TYPE-REFERENCE-BOOK.1.2.23.3.79.6.2; historical follow-up:
TYPE-REFERENCE-BOOK.1.2.23.4.24, after feature coverage and before full admission.

The original ordinary-pipeline observer's actual archived main.rs equals the
retained observer.rs byte-for-byte (4113 bytes, SHA recorded in
restore-order-result2.json). It restores serialized data at line32 and persists
that value at line34. The two before-build archive owners agree on its identity.
The public input record is printed later. Thus exact later source/input recovery
is retained, but persisting serialized bytes before their first restoration is
not established. No historical first-use retention credit is added by this audit.
Existing runtime observations remain actual; broader native/toolchain/custody
admission was already separately open. Historical instruments/outputs stay exact.

The maintained Rust pipeline Knowledge card is qualified now. The current callable
observer must write and read back actual serialized bytes before restoration and
print its input record before native/restored/plan execution. Existing generated
module files remain captured before fresh compilation/execution. Task4.24 owns
the bounded inherited-observer/maintained-claim audit and prospective repair before
admission; it may not reconstruct missing historical first-use records as facts.

The first audit exited1 because it expected only one archive owner; its original
source and empty result survive, with the unretained raw-stderr limitation explicit
in restore-order-first-failure.json. The separate audit2 verifies both equal
identities and exits0. Reproduce the static archived-source distinction with:

```sh
bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/array-pipeline-callable-rust-2026-11-11/audit_restore_order2.py
```
