---
id: startup-task-partition-plan
title: "Startup task partition plan preserves every source byte under unchanged collection limits"
answers:
  - "why must the startup task tree be partitioned before more repairs"
  - "where is the exact startup task partition migration plan"
  - "which startup task source ranges belong to each semantic part"
  - "does moving historical task verification metadata require another receipt"
  - "which consumers must change for startup task partitioning"
date: 2026-09-24
status: implemented under containment .16.2; exact staged canonical acceptance required before landing
tags: [task-tree, continuity, containment, retrieval, verification]
evidence: "LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.1; docs/checkpoints/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.1-plan.json; clean 567b583f7535c6fac643b27d44e24ba5b729f5a8"
reverify: "Run perl scripts/check_startup_task_partitions.pl and perl tools/check_task_verification_fields.pl --self-test, then the independent pinned source/range replay below."
---

## Applied migration

Containment .16.2 implements the plan below from clean `58a5ff936`, whose startup blob
is identical to the planned source. The current root has 77 lines; part sizes are
4359 / 1467 / 1629 / 559 lines, and the index has five records. The independent startup
validator rejects 60 mutated inputs and passes nine pressure controls; cadence uses
stable task identity with 14 relocation/declaration controls. The exact migration proof
is `docs/checkpoints/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.2-verification.json`.
Ordinary exact staged canonical acceptance and normal hooks govern atomic landing.

The following sections preserve the measured planning decision and its implementation
obligations; statements about the old FUTURE-only registration and diff-line cadence
refer to the .16.1 planning baseline.

## Measured need and scope

Startup .88 leaves `docs/tasks/SESSION-STARTUP-READING.md` at 7,994 lines / 960,362 bytes,
only six lines below its existing ceiling. The exact clean source has Git blob
`f1aed39e1f7cb00d228642fed1b5ac49356747b9`, SHA-256
`e5a1199d0a15fbbd29ada47fb9a262dbeeefd831e971bc08cb084a7e8a7b6209`, and 396 unique
definitions: one root and 395 children. An exact blank-line-delimited paragraph census
(at least three lines and 150 bytes) finds no duplicate paragraphs. This does not claim
there is no semantic repetition or justify discarding unique evidence.

Containment .16.1 plans; .16.2 implements and closes the parent atomically with canonical
proof. No parser behavior, startup source byte, route limit or production tool changes
in the planning slice. Perl read-purity startup .89 is the next repair, before .51.

## Frozen source routing

All ranges are inclusive lines of the pinned source, never shifting working-file offsets.
Every source line has exactly one preservation owner. Parts retain original bytes,
including old claims, with bounded explanatory headings identifying their historical context.

| Suffix of `docs/tasks/SESSION-STARTUP-READING` | Source ranges | Payload lines / bytes | Definitions |
| --- | --- | ---: | ---: |
| `.01-03.md` | 41–2205; 5076–5574; 5826–7515 | 4354 / 528673 | 140 |
| `.04-49.md` | 2206–3416; 5575–5825 | 1462 / 140546 | 107 |
| `.50-99.md` | 3417–5040 | 1624 / 189983 | 148 |
| `.history.md` | 1–40; 5041–5075; 7516–7994 | 554 / 101160 | 1 historical root |

The .31 forward-reading/intake section stays with .04–49. All .2/.3 reading evidence
stays with .01–03. The historical part preserves original prelude, root, frontier,
reading summary, global decisions, verification and commit chronology. It is immutable
after migration and excluded from the current-ID census only by its registered index.
ADR0123 and the current AGENTS dependency black-box boundary supersede contrary older
instructions; preserved text grants no renewed implementation access or reading credit.

The existing `.md` path becomes a current index with one root definition, no duplicate
child nodes, a precise frontier, current decisions/blockers, all part links and lookup
commands. Its provenance ranges are empty: all original bytes have preservation owners
above. The new root is a current projection, not the only copy of any original source.
The schema-v1 `.index.jsonl` has metadata plus four part records. Mutable parts own
numeric top-level prefixes 1–3, 4–49 and 50–99; unallocated IDs such as .48 or .99 must
still fail lookup. The source commit may advance to clean .16.2 activation only if its
startup blob and every pinned byte remain identical.

## Capacity without increasing a ceiling

Existing global controls remain 128 files / 120,000 lines / 12,582,912 bytes, with
8,000 lines / 1,048,576 bytes per Markdown member. Existing FUTURE-specific controls
also remain exact. New startup parts get stricter 5,000-line / 786,432-byte caps;
the current root gets 256 / 32,768 and the five-record index 5 / 16,384.

The clean Markdown census is 109 files / 92,643 lines / 10,319,900 bytes. The routed
census includes the existing FUTURE index: 110 / 92,653 / 10,325,615. A conservative
projection permits the full new root/index caps, 32 lines / 4,096 bytes of heading
per part, and 512 lines / 65,536 bytes of other task-document growth: at most
115 files / 93,554 lines / 10,456,687 bytes. This is a planning envelope, not a claim
that migration outputs exist. .50–99 retains at least 3,344 lines after the heading
allowance; .01–03 retains 614. Future unrelated growth still faces the same gates.

## Consumers and implementation boundary

The executable-scope literal census finds no startup-tree path/name consumer in
`scripts/`, `tools/`, `capability_conformance/`, `doctrine/` or `.githooks/` at activation.
Dynamic consumers nevertheless need explicit review:

- Register startup in `tools/read_task_tree.pl`, `tools/update_task_tree_index.pl` and
  `scripts/check_task_tree_current_ids.pl`; retain existing FUTURE behavior and data.
- Compose a separate strict `scripts/check_startup_task_partitions.pl` from the task
  metadata driver. Leave the historical FUTURE builder and verifier unchanged.
- The cadence gate currently counts added diff lines. Relocating this source introduces
  166 historical tier/focused/trigger triplets into new files. Compare declarations by
  task ID and exact field value across HEAD and the index, so relocation grants no
  new slice while changed, duplicated, missing or foreign-node declarations still fail.
  Exactly one owning node and one complete triplet remain required, with normal receipts.
- The memory handoff checker already globs all Markdown task members. Root duplication
  in registered immutable history has the same active status; no child is archived.
  Verify the actual pointer and current-ID census; do not weaken duplicate detection.
- Extend the routed collection by the startup index and exact stricter member controls.
  A newly staged, accepted, indexed execution ADR records the old/new contract; this
  committed plan is not execution-time route authorization.
- Update bootstrap/task doctrine and the mdBook retrieval section only when the tools
  work. Transfer maintained Knowledge lookups to semantic owners. Preserve dated Git
  recipes and capacity allowlists; do not mass-replace historical source paths.

The checkpoint lists the 25 pre-existing Knowledge path references and exact consumer
dispositions. `startup-codebase-reading-inventory` has three working-tree node reads;
`macos-rust-first-launch-validation-latency` has an active reverify path. Supporting
coverage/closeout recipes mix working reads with dated source/checker identities: route
their task reads or mark the original replay's date explicitly without pretending
all historical source assertions remain current. Plain landing-page links may remain.

## Acceptance and rollback

.16.2 must independently reconstruct all source bytes, compare every node field and
ID-scoped section, resolve all 395 children, exercise boundary/absent/outside-CWD
lookup, prove idempotent snapshot refresh and reject immutable-history edits. Mutation
proof covers malformed schema/order/ranges, source/digest drift, duplicate/lost/wrong
IDs, unsafe/symlink paths, root/frontier drift, stale consumers and each independent
pressure boundary. Cadence mutations cover relocation, changed or duplicate fields,
missing fields, split ownership and unchanged canonical receipt requirements.

Preserve all existing FUTURE bytes and behavior; run the generic memory/current-ID
checks, maintained retrieval proof, rendered book, all doctrines and exact staged
canonical CI. Commit and clear the brief before startup .89. Before landing, the clean
activation source is recovery authority; afterward use a reviewed atomic revert.
All scratch outputs stay under `.linkedspec-data`; no dependency internals are inputs.

## Independent source/range replay

This uses core Perl rather than the planning Python implementation. It remains valid
after migration because it reads the pinned Git source and the durable checkpoint.

```sh
env PERL5LIB= perl - <<'PERL'
use strict; use warnings; use JSON::PP; use Digest::SHA qw(sha256_hex);
open my $f, '<:raw', 'docs/checkpoints/LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.1-plan.json' or die $!;
local $/; my $p = decode_json(<$f>); close $f;
open my $g, '-|', 'git', 'show', "$p->{source}{commit}:$p->{source}{path}" or die $!;
binmode $g; my $raw = <$g>; close $g or die 'git show failed';
die 'source hash' unless sha256_hex($raw) eq $p->{source}{sha256};
my @lines = $raw =~ /[^\n]*\n|[^\n]+\z/g; my @out;
for my $part (@{$p->{parts}}) {
    my $bytes = '';
    for my $r (@{$part->{source_ranges}}) {
        for my $n ($r->{start_line} .. $r->{end_line}) {
            die 'overlap' if defined $out[$n - 1];
            $out[$n - 1] = $lines[$n - 1]; $bytes .= $lines[$n - 1];
        }
    }
    die 'payload hash' unless sha256_hex($bytes) eq $part->{sha256};
    die 'payload bytes' unless length($bytes) == $part->{byte_count};
}
die 'source reconstruction' unless join('', @out) eq $raw;
print "PASS independent whole-source reconstruction and all four payload hashes\n";
PERL
```
