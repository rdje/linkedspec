# Generated Handlers and Dispatch

LinkedSpec generates rule handlers dynamically, but the project has been moving away from opaque, repeatedly-evaled behavior toward a cleaner and more attributable runtime model.

## Important themes

- generated handlers are attributed to rule labels and variants
- top-level parser invocation keeps structured entrypoint identity
- dispatch uses compiled dependency regexes explicitly
- runtime failures are normalized into structured error channels

## Why this matters

Dynamic generation is powerful, but without structure it becomes hard to trust.

LinkedSpec’s current direction is to keep the flexibility of generated handlers while making them:

- more inspectable
- more attributable
- more deterministic
- and less fragile
