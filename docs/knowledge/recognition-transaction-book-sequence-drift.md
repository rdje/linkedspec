---
id: recognition-transaction-book-sequence-drift
title: Rendered review caught a stale neutral-next sentence after the transaction authority became executable
answers:
  - "why did the transaction book say the neutral artifact was next after it was executable"
  - "what caught the stale recognition transaction milestone sequence"
  - "does the neutral transaction checker govern public milestone ordering"
  - "who owns recognition transaction public sequence enforcement"
date: 2026-08-10
status: current public-sequence guard tracks Perl, Rust, Dart, and Julia admission at 3 documents / 17 forbidden / 33 mutations
tags: [transactions, documentation, mdbook, drift, governance, rendering]
evidence: "FUTURE-PARITY-BACKLOG.14.3.1.2 rendered the capture/source page and found adjacent claims that the neutral authority was executable and still next. Git blame traced the old sentence to 7c2ff407 and the missed update to e0cc7182. FUTURE-PARITY-BACKLOG.14.3.1.2.0 then extended the same canonical checker with a separate exact public projection over 3 documents, 8 forbidden claims, and 13 in-memory mutations while preserving the JSON and its 40 semantic mutations."
evidence_update_2026_08_10_perl_admission: "FUTURE-PARITY-BACKLOG.14.3.2.3 advances the same projection to current Perl support while every later leg remains RED. Separate neutral regression, Perl regression, and premature Rust promotion checks raise public sequence proof to 14 mutations; semantic proof is independently 41 mutations."
evidence_update_2026_08_10_rust_admission: "FUTURE-PARITY-BACKLOG.14.3.3.3 review finds three adjacent Perl-only statements outside the earlier eight-claim forbidden inventory: one all-other-runtimes-future sentence, one explicit Rust-through-Lua rejection sentence, and one all-other-runtimes-no-progress sentence. The checker now enumerates all eleven stale claims and injects every claim as its own mutation. Together with document, marker, and rollout mutations, public proof is 3/11/25 while semantic proof remains separately 42."
evidence_update_2026_08_11_dart_admission: "FUTURE-PARITY-BACKLOG.14.3.4.3 advances current public claims to Perl, Rust, and Dart while all later legs remain RED. It adds the superseded Perl/Rust-only model, explicit Dart-through-Lua rejection, and later-runtimes progress sentence to the forbidden inventory, plus a Dart regression mutation before premature Julia promotion. Public proof is 3/14/29 while semantic proof is separately 43."
evidence_update_2026_08_11_julia_admission: "FUTURE-PARITY-BACKLOG.14.3.5.3 advances current public claims to Perl, Rust, Dart, and Julia while both Lua runtimes and all later legs remain RED. It adds three superseded Dart-era claims plus a Julia regression and premature Lua promotion. Public proof is 3/17/33 while semantic proof is separately 44."
reverify: "bash tools/run_mdbook_local.sh && rg -n 'neutral artifact/checker is executable|neutral artifact/checker is next' docs/linkedspec-book/book/dsl/capture-marks-and-source-locations.html && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
---

`FUTURE-PARITY-BACKLOG.14.3.1.0` commit `7c2ff407` correctly taught that the neutral artifact/checker was the next
milestone before the authority existed. Implementation commit `e0cc7182` later inserted an executable-authority
paragraph and checker command but left the older sequencing sentence in place. The rendered page consequently
made two contradictory milestone claims within three paragraphs even though each individual statement originated
from a truthful slice.

The recognition-transaction checker could not catch this drift because its `current_boundary` assertion governs
the neutral JSON policy and prevents false current-runtime/public-capability claims; it does not scan the mdBook
for stale milestone-order prose. Rendered review in `.14.3.1.2` exposed the contradiction. That leaf corrects only
the sentence to say the neutral authority is executable while every runtime remains pending.

Fail-closed prevention is intentionally separate: `FUTURE-PARITY-BACKLOG.14.3.1.2.0` extends the already canonical
checker with an exact three-document marker inventory, tracked-file proof, and rollout-derived public state. Perl
admission first advanced that projection to eight forbidden claims and fourteen mutations. Rust-admission review
then found three adjacent Perl-only sentences that the earlier inventory did not name. Dart admission adds three
superseded Perl/Rust-only claims, and Julia admission adds three superseded Dart-era claims. The guard now forbids
all seventeen stale/current claims and injects each one independently, producing 33 sequence mutations alongside
neutral, Perl, Rust, Dart, Julia, and premature-next-backend rollout regressions. The JSON separately owns 44
semantic mutations. Keeping
the counts and mutation loops separate prevents public milestone governance from silently changing the semantic
contract.
