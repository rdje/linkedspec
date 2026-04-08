# File And Path Map

The most important FSMGen-related paths in this repository are:

## Core implementation

- `perl/FSMGen.pm`
  - Main FSMGen Perl module.

## Plugin layer

- `plugin/fsmgen.plg`
  - FSMGen plugin helpers and adapter functions.

## Supporting configuration

- `perl/env.conf`
  - Environment/program config surface that includes the `fsmgen` program profile.
- `conf/vhdl_template.conf`
  - VHDL-template-related config that references FSMGen context-clause material.
- `conf/xif.conf`
  - Additional config with FSMGen-related context-clause references.

## Upstream/foundation dependencies visible from current code

- `perl/LinkedSpec.pm`
- `perl/Lispish.pm`
- `perl/RTLUtils.pm`
- `perl/Table.pm`
- `perl/Table2SS.pm`

## Existing top-level documentation

The broader repository documentation still matters:

- `README.md`
- `ROADMAP.md`
- `USER_GUIDE.md`
- `ARCHITECTURE_STATE.md`
- `DEVELOPMENT_NOTES.md`
- `CHANGES.md`
- `MEMORY.md`

This mdBook is the dedicated FSMGen book, not a replacement for every broader project document.
