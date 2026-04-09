# Pipeline Overview

At a high level, LinkedSpec’s compile/runtime flow looks like this:

1. validate and prepare the compile pipeline
2. bootstrap-parse the `.spec` source into parsed entries
3. build compiled rule-table state
4. build dependency-regex state
5. build compiled descriptor state
6. validate the generated descriptor state
7. project the outward descriptor or build the runtime parser wrapper

## Why the pipeline matters

Understanding the pipeline helps explain:

- where failures happen
- why diagnostics have stages
- how runtime/context metadata is preserved
- why internal state models exist

It also makes clear that LinkedSpec is no longer best understood as one giant monolithic `LinkedSpec.pm` script.
