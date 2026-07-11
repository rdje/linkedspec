# Capability conformance inventory

`manifest.json` is the machine-readable census of current user-observable LinkedSpec capabilities across the four
implemented backends. It complements, rather than replaces, the executable 99-fixture interpreter corpus and the
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

The census intentionally records proof quality separately from implementation belief. Passing the 99-case corpus
does not by itself prove every helper and API described by the mdBook; `FUTURE-PARITY-BACKLOG.1.6.1` owns that
coverage mapping. Generated source remains separately owned by `FUTURE-PARITY-BACKLOG.3`.
