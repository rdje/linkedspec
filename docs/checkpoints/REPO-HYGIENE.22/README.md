# Dated artifact retention review

Owner: REPO-HYGIENE.22. Clean activation:
d6446ce991c6141838a9fa80396e3890bce274e0.

The observation covers parent .log/.bin/.DS_Store metadata, six explicit
root/crate Rust locations, and the retained Dart/Julia/Lua conventions. It
excludes other repositories, Gitlinks, symlinks, other volumes, managed runs,
reusable caches and hygiene fixtures before traversal. It grants no content
ownership, disposability, liveness, recovery/purge or concurrent-adversarial
filesystem guarantee. The disposition is retention; no artifact removal.

Two actual census commands retain both channels. Independent per-file lstat
checks sizes and boundaries, while a separate scandir walker checks the complete
declared parent and Rust populations. Actual corrupted-record commands reject
aggregate inflation, balanced size changes, coherent population omission,
failed channels and altered producers. Healthy/restored commands pass.

The snapshot retains the complete bounded metadata producer/wrapper sources,
actual Gitlink enumeration and all dated metadata inputs. Artifact contents do
not produce path/size metadata and are not claimed or captured. The public book
has its own complete supplied configuration/source/include packet and actual
healthy/missing-example renders. The preflight retains all original claim
records and their shared-document intersection census; no old claim changes.

Read-only verification:

```bash
bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.22/review.py
bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.22/publish.py
```

Preflight, capture, book rendering, documentation updates and publication
`--capture` are one-shot writers. Do not rerun them. Default readers validate
retained evidence and source identities; they do not recapture current filesystem
state, rerun historical producers or remove artifacts.
