# Perl definedness numeric calibration

Owner: `TYPE-REFERENCE-BOOK.1.2.23.1.28.0`.
Claim record: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.1.28.0.json`.

`intake.json.gz` retains 147 size/hash-bound inputs, including the actual public
probe and instruments, all source/wrapper inputs, original selection21 cases
and observations, separate calibrated expectations, native/fresh scalar captures,
commands, exits and the passing normal regression. `probe.pl` is the exact actual
instrument. Historical activation/seal writers are one-shot provenance; do not
replay them. The capture is dated Perl5.34.1 at source epoch
`d0174bb475fa6eabc02096713247e6605a1e1765`.

Read-only retained-capture verification:

```sh
bash tools/run_python_project_data.sh docs/checkpoints/definedness-numeric-calibration/review.py
```

This exits0 after verifying all retained bytes and fifteen programs/thirty
native/fresh observations. To falsify the assumption that equal serialized empty
text implies equal numeric classification:

```sh
bash tools/run_python_project_data.sh docs/checkpoints/definedness-numeric-calibration/review.py --falsify-json-kind
```

Expected exit1 with `observed_red: true`: native false adds to `1`, literal empty
text adds to null. Internal capture failures instead exit2. This is a classifier
negative control, not a product runtime RED. `review-results.json` retains the
actual commands, exits and complete output from both checks.

The original provisional `value_kinds` expected null is corrected to `1` in a
separate epoch, with source/operand/peer expectations unchanged. Existing numeric
and predicate producers remain unchanged. Current behavior can be checked with:

```sh
bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/definedness_native_numeric_contract.t
```

Two groups pass before any production edit. Public slot masks are derived from
the recorded host constants; total/private flags are retained diagnostics only.
This capture does not reconstruct other hosts or establish portable type
normalization, exhaustive domains, general isolation or full admission.

`focused_claim_check.py` records the focused staged-commit check: it uses the
existing strict claim validator and self-tests, validates this new record and
its input bytes/owner/declaration, and rejects any staged intersection with a
pre-existing live claim input. It checks that the candidate fingerprint stays
unchanged. This is not historical collection revalidation; that remains a
canonical admission/push requirement under the authorized feature-first cadence.
