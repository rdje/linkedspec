---
id: julia-recognition-transaction-integration
title: Julia recognition transactions are integrated privately and admitted through exact proof
answers:
  - "where are Julia recognition transactions integrated"
  - "which Julia nodes represent recognition transactions"
  - "how does Julia preserve a false recognition payload"
  - "how does Julia bind recognition transactions to cursor boundary and marks"
  - "which Julia recognition transaction carriers pass"
  - "does emitted Julia source execute recognition transactions"
  - "are Julia recognition transactions admitted or public"
  - "why does Julia recognition rollout remain red after integration"
date: 2026-08-11
status: current private integrated boundary with ordinary and canonical admission
tags: [julia, recognition, transaction, ActionIR, effects, progress, generated-source, private, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.5.2 adds ActionRecognitionCheckpointExpr, ActionRecognizeOnceExpr, ActionRecognitionCommitExpr, and ActionRecognitionRollbackExpr with exact static normalization after ordinary argument parsing. recognize_once retains only the token slot and static child-rule label, so call(Rule) never enters ordinary helper dispatch. RecognitionTransaction implements the neutral six-graph recursive effect fixed point and eight-case cursor-progress policy. Interpreter enters one private frame per rule invocation and synchronizes the existing UTF-8 code-unit cursor, anonymous boundary, and isolated same-label mark bucket through the non-exported authority. Native, reconstructed, generated-plan, and independently loaded emitted-module execution preserve a successful false payload. Admission `.14.3.5.3` runs the unchanged 203-assertion consumer exactly once ordinarily/canonically, removes selector dormancy, retains the unexported namespace, and promotes only Julia to neutral 132/246/44 at rollout 5/9."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/recognition_transaction_contract_test.jl\")' && test \"$(rg -c '^include\\(\"recognition_transaction_contract_test[.]jl\"\\)$' julia/test/runtests.jl)\" = 1 && rg -n 'julia/test/recognition_transaction_contract_test[.]jl' tools/run_ci_local.sh"
---

# Private Julia recognition-transaction integration

The Julia action parser replaces only the four exact static forms with
dedicated nodes. The attempt node stores an opaque token-slot name and a static
child-rule label; its `call(Rule)` operand is structure, not an eager callable
helper. Contract resolution and callable-codeblock normalization therefore do
not add these intrinsics to the ordinary 246-name call inventory.

The private transaction authority evaluates the neutral effect graphs to a
fixed point, including direct and mutual recursion, and rejects the closed
forbidden vocabulary. Progress is separate: repetition and recursive-cycle
edges require UTF-8 code-unit cursor advance, while one-shot zero-width
recognition remains valid. Binding, mark, or transaction changes never count as
progress.

Each runtime rule invocation owns one private authority frame. The adapter
copies the live code-unit cursor, anonymous capture boundary, and a fresh
same-label mark bucket into transaction state, then restores the caller's mark
bucket at exit. Attempt presence is independent of payload truthiness, so a
recognized `false` survives commit.

Native and reconstructed specs compile the same action source. Generated plans
already invoke the effective runtime, and emitted modules reconstruct and
compile the same spec before invoking that plan. The unchanged dormant consumer
therefore proves all four carriers at 203/203 without an emitter-specific fork.

This remains an internal implementation boundary. The module is unexported,
but ordinary Julia and canonical CI now run the exact final-path consumer once,
so authored Julia support is admitted at rollout 5/9. The integration leaf's
complete canonical gate passed all eight doctrines, CLI 66x2, the 65% RAM
guard, and Phase 0 at 1,031/1,031 in 731 seconds.

## Links

- Neutral contract: [[recognition-transaction-neutral-contract]].
- Dormant boundary: [[julia-recognition-transaction-dormant-red]].
- Private authority: [[julia-recognition-transaction-private-authority]].
- Admission: [[julia-recognition-transaction-admission]].
- Dart precedent: [[dart-recognition-transaction-dormant-red]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.5.2-.3`.

## September 11 effect-coverage qualification

Julia .1.13 reads the runtime frame/observation/rollback adapters through Interpreter1615.
The fresh recognition207/observation30/gap319/typed127 suites pass. The standalone
classifier and the tested explicit-call graphs do not prove full production effect
closure: [[julia-recognition-effect-integration-gap]] records missing structural
edges and forbidden binding persistence, owned by Julia .2.3. Earlier broad effect
claims are limited by that open repair. The original203-assertion and rollout5/9
snapshots are dated admission history; current neutral recognition is138/250/58,
rollout9/9, and typed source is14/0/231. Current focused replay lives in
[[julia-runtime-structured-diagnostics]]. No repair is closed by this reading.

## September 11 attempt-order qualification

Julia .1.15 reads RecognizeOnce dispatch and confirms that the requested child
runs before token lookup and attempt-state validation. Missing tokens and repeated
or post-commit attempts therefore emit child slot events before rejection through
all four measured native/generated-plan conveniences. Existing recognition 207 and
neutral 138/250/58 remain green. [[julia-recognition-attempt-preflight-gap]] owns
80 exact diagnostic assertions and repair .2.7; static effect repair .2.3 and
startup .38 stale-snapshot restoration remain distinct. The earlier one-attempt
contract is not proven by tests of the standalone authority alone.
