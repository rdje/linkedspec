# ADR 0126: Publish measurements with three named legs and watched source identities

- Date: 2026-10-02
- Status: accepted; implementation owned by SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1
- Tags: claims, evidence, durability, doctrine, review

## Context

The director requested adoption/update review of the supplied portable claim-verification
policy. Its reviewed source SHA256 is
`9f99df25209c43afb74d77e348dd2d0cdb68ce96cf17a4f272ede8328f6046bd`, unchanged from the
September review. The policy is an authorized read-only external reference, not a build
input. Local adoption and the broader audit have different completion boundaries.

Selected callable checkpoint producers originally stored ignored paths and hashes.
`.0.2.1.4.0` preserves exact historical source bodies and recovery controls without
rewriting old results. That bounded repair does not establish a project-wide producer
census, independence audit, or completion of startup reading/alignment.

## Decision

The normative local working contract lives in `DOCTRINE_ENFORCEMENT.md` section 12,
within its existing bounded contributor surface. `COMMIT.md` provides its review
format. Adopt re-derivation at the claim's granularity, distinguishing falsification,
recoverable producers, full artifact-input identity, explicit missing legs, exact
contract/instance grading and intervals for stochastic measurements. Examples do not
carry domain rules; donor measurements are not LinkedSpec results.

Each new staged owning leaf declares one claim record, or explains that it publishes
no measured claims. Records under `docs/claims/` are bounded per leaf and name the
claim/scope, command/result, competing hypothesis/oracle/observed RED, and durability.
A missing leg requires a reason and an open current repair owner.

The registered CLAIM-VERIFICATION doctrine validates strict record schema, staged
single-owner disclosure, regular tracked producer/input blobs and SHA256 identities.
Live inputs are checked against the index; historical captures name an exact existing
Git revision. All declared artifact inputs include the instrument. A source hash gates
staleness, not semantic truth. Recorded JSON/Markdown commands are never executed.
The existing single-owner verification tool gains only an explicit owner-query option;
its default tier-only interface and identity/relocation rules remain unchanged.

New checker/registration/cadence paths require canonical verification under ADR0073.
The broader constants/published-producer/control/alignment audit remains scheduled
under SESSION-STARTUP-READING.5, with diagnostic-path repair .29 before its closeout.
This leaf adopts working rules and bounded mechanization; whole-project adoption is
not complete.

## Consequences

Disclosure and declared source drift fail cheaply through the common hook/CI registry.
Author review must still establish list completeness, actual execution, oracle
independence, truthful scope and whether a no-claim explanation is justified. Selected
focused proof and canonical receipts keep their actual behavior-verification role.

Historical records remain historical. Do not refresh an old source hash merely to
make a gate pass; re-measure, explicitly supersede, or preserve its actual prior capture
with an existing commit and honest scope. Git owns commit identity; records cannot
contain their own future commit hash.

## Links

- `DOCTRINE_ENFORCEMENT.md` section 12 and `COMMIT.md`
- `scripts/check_claim_verification.sh` and `tools/check_claim_verification.py`
- `tools/test_claim_verification_staged.py`
- `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`
- `docs/tasks/SESSION-STARTUP-READING.md`
