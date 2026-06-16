# The LinkedSpec Book

This book is the public-facing, living explanation of LinkedSpec.

LinkedSpec is a multi-backend system. The `.spec` language is the one universal contract; each backend is simply an execution platform that runs the same `.spec` files with the same semantics — no per-backend dialects. The Perl implementation is the **reference backend** (the canonical behavioral oracle); further backends (such as Rust) execute the same contracts identically. This book therefore describes `.spec` syntax, semantics, and helper contracts in backend-neutral terms; where a concrete API call is shown, it is the Perl reference backend's surface unless stated otherwise.

It exists to answer four questions clearly:

- What is LinkedSpec?
- What problem is it trying to solve?
- How does it work today?
- Why is it designed this way?

This is not meant to be a crash log or a commit-by-commit diary. The repository already has internal continuity docs for that. This book is the version of LinkedSpec that should make sense to readers outside the implementation loop.

## What this book aims to cover

The target is broad and explicit:

- the user-facing mental model of `.spec` files
- the public runtime and parser-building APIs
- the helper/action surface and the ActionIR direction
- the compiler and runtime pipeline
- diagnostics, traceability, and validation
- architecture and module ownership
- shipped specs, corpora, and regression expectations
- the rationale behind major design choices

## How to read it

- Start with the overview chapters if you are new to LinkedSpec.
- Jump to the user-model and public-API chapters if you want to use it.
- Read the compiler/runtime and architecture chapters if you want to understand the internals.
- Use the development chapters when you are contributing or evaluating the project as a maintained system.

## Living-book policy

This book should evolve alongside the project.

When LinkedSpec changes in a way that alters what users, contributors, or outside readers need to understand, the book should move with it. The point is not just accuracy. The point is clarity.
