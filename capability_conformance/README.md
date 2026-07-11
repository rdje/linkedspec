# Capability conformance inventory

`manifest.json` is the machine-readable census of current user-observable LinkedSpec capabilities across the four
implemented backends. It complements, rather than replaces, the executable 105-fixture interpreter corpus and the
61-case primary CLI manifest.

Run its structural and ownership gate from the repository root:

```bash
perl tools/check_capability_conformance.pl
```

Statuses mean:

- `pass`: current source plus executable evidence supports the contract;
- `partial`: an implementation or proof boundary is incomplete and has an explicit task owner;
- `gap`: the documented capability is absent and has an explicit task owner.

Every capability lists canonical contract sources and backend-specific evidence paths. The checker rejects unknown
fields/statuses/backends, duplicate ids, missing evidence paths, unowned partial/gap states, missing task-tree owner
ids, absolute paths, and future/excluded surfaces without an owner. Current language behavior belongs in
`capabilities`; deprecated or genuinely not-yet-adopted directions belong in `excluded_or_future`.

`outward_descriptor_contract.json` is the executable shared schema for the public compiled-descriptor projection.
Perl, Rust, Dart, and Julia descriptor tests consume the same exact top-level, metadata, and function-record field
sets so a backend-specific serialization convention cannot silently become public API.

`generated_source_contract.json` is the versioned semantic contract for host-language source emission. It fixes
compiled-spec-plus-identity input, deterministic source markers, independent compile/load, execute and traced-
execute roles, the ten structural families, plan rejection, stable generated-source errors, one direct behavior
fixture, the accepted eight-case generated subset, and the 105-case interpreter oracle. It explicitly does not
require identical host API names, source syntax, or bytes. Run:

```bash
perl tools/check_generated_source_contract.pl
```

The census intentionally records proof quality separately from implementation belief. Passing the 105-case corpus
does not by itself prove every helper and API described by the mdBook; `FUTURE-PARITY-BACKLOG.1.6.1` owns that
coverage mapping. Generated source remains separately owned by `FUTURE-PARITY-BACKLOG.3`. `.3.1.0` demonstrates
why execution proof matters: Perl captured source compiles but currently loses dependency-regex alternative indexes
when loaded independently, so Perl is partial until `.3.1.2-.3` repair and admit it.
