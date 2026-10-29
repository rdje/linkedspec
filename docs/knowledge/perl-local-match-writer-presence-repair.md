---
id: perl-local-match-writer-presence-repair
title: Perl local-match mark writers preserve targets without missing-endpoint writes or warnings
answers:
  - "how does Perl mark_match_start behave before a local match"
  - "does the Perl local writer repair preserve entry boundary fallback"
  - "must Perl emitted parsers be regenerated for missing-local mark writers"
  - "does an absent Perl local-match writer still evaluate its mark name"
date: 2026-10-29
status: bounded49.1 focused repair verified; independent peers/selection/full admission separate
tags: [perl, marks, writer, match, absence, endpoint, mutation]
evidence: "perl-writer-absence-intake.json.gz retains own15-source7healthy8RED ->15pass native/fresh clean+seeded,34 selected groups, public2changed8unchanged writer bodies and original-module replay."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/named_writer_endpoint_absence.t t/mark_name_write_arguments.t t/complete_named_mark_contract.t"
---

The existing named writer factory previously stored raw LSPOS/LMATCH-derived
coordinates without a local match, creating invalid marks and warnings. It now
builds the same writer body and wraps only mark_match_start/end with definedness
checks. Accepted names have already evaluated through existing lowering. Missing
local endpoints leave targets alone after those authored effects; valid empty/zero
still execute original storage/trace operations. The typed mark/frame validator
and independently valid entry/IPOS fallback are unchanged.

## Perl repair49.1 (2026-10-29)

Only mark_match_start/end now require defined LMATCH/LSPOS before their original
storage/trace body. Names already finish outside that body; no missing-endpoint
write/delete/trace is added, and existing targets/name effects survive. Other8
public writer bodies, including valid root entry/IPOS fallback, remain exact.
No new state/frame/helper/domain/schema or validator weakening. Current15 native/
separate clean+seeded7healthy8RED ->15pass; ordinary15 groups8RED ->15pass. Writer15/
name-write17/complete marks2 pass34 groups and Contracts syntax. Seven healthy
full semantic records and all metadata unchanged. All15 emitted payloads change;
original15 modules replay30 calls with original outcomes/errors/warnings and v2
accepted: regenerate affected emitted parsers. Warning eval ordinals normalize;
raw host error text excluded only with typed fields, full raw channels retained.
Packet perl-writer-absence-intake.json.gz retains closure. New normal canonical
selection23.4.1/independent49.2-.5/48/45/full admission remain separate.
