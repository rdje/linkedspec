# Perl Count rejection through logical producers

Owner: `TYPE-REFERENCE-BOOK.1.2.23.3.73.6.6`.
Activation: `deaf32ab1df4521bfc4efaa3269b21ed8b699212`.

The authored normal `t/count_logical_source_composition.t` consumes
`tests/fixtures/count_logical_source_cases.json`: the four frozen assessment
controls plus or/not, with/no-with, copied source, intermediate Boolean rejection,
eager error, source snapshot, malformed shape and function distinctions.
The unchanged fourteen inputs/normal produce seven expected rejection REDs before
the repair and fourteen passing groups afterward. Both phases actually build and
execute native and freshly loaded emitted source, with separate context/error,
load, metadata and warning checks. Numeric zero and legitimate null retain their
behavior; logical results retain real Boolean kind. Needed operand errors prove
that valid eager calls still evaluate an RHS after a false Count source.

`capture.sh before|after` is a one-shot historical producer. Each phase retains
the actual owner/fixture/normal, raw TAP/stderr/exit, interpreter configuration,
public substitution output and full emitted modules saved before fresh loading.
`lowering.pl` uses the public substitution probe. The rest of the SDK is
recoverable from the activation Git tree. Complete transitive/native/toolchain
custody remains23.4.2-owned; general isolation, registration and full23.4 remain
separate. The original assessment and P2 long receiver/copy concern73.7 are
unchanged. Never replay acquisition writers over retained phase directories.

Current behavioral re-verification:

```sh
source tools/project_data_env.sh
perl -Iperl t/count_logical_source_composition.t
```

The capsule's `review.py` only reads frozen evidence. `seal.sh` losslessly
compresses selected raw files and verifies decompressed equality before removing
their redundant plaintext copies.
