# Introduction

This book is the dedicated long-form documentation surface for **FSMGen**.

The goal is simple: make FSMGen understandable from three angles at once:

- as a user-facing tool you can run today,
- as a generation pipeline with real internal phases and data structures,
- and as a living subsystem inside this repository that needs durable, interruption-safe documentation.

FSMGen lives inside the broader LinkedSpec repository, but it has its own distinct user-facing surface:

- Perl module entrypoints in `perl/FSMGen.pm`,
- plugin-oriented helpers in `plugin/fsmgen.plg`,
- configuration loaded through the `fsmgen` environment/config profile,
- and generated RTL-oriented outputs assembled from FSM descriptions, hierarchy declarations, and interface mapping rules.

This book is intentionally organized from low-complexity to high-complexity:

1. what FSMGen is,
2. how to run it,
3. what inputs it expects,
4. what it generates,
5. how its internal model works,
6. and where the relevant code lives.

The immediate objective of this first mdBook slice is to give FSMGen a clean, scalable documentation home with:

- navigable chapters,
- search,
- syntax-highlighted examples,
- and a chapter layout that can keep expanding without collapsing back into one giant markdown file.

This book should become the primary place for **complete FSMGen documentation** over time.
