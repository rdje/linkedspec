"""Retain the initial preparation failure and diagnose its module-path cause."""
import json
import common as c
import context

epoch = context.snapshot()
command = ["bash", "tools/project_data_run.sh", "python3", "-c",
    "import sys,json; sys.path.insert(0,'docs/checkpoints/perl-literal-kinds'); import context,booklib,document; print(json.dumps({'document':document.__file__,'updated':hasattr(document,'updated')}))"]
run = c.run(command)
assert run["returncode"] == 0 and not c.decode(run["stderr_base64"])
result = json.loads(c.decode(run["stdout_base64"]))
assert result["document"].endswith("/docs/checkpoints/signed-array-perl/document.py") and result["updated"] is False
assert c.unchanged(epoch["inputs"])
c.write_new("book-import-qualification.json.gz", dict(context=epoch,
    producer=c.read(c.PREFIX + "qualify_book_import.py"), actual_diagnostic=run,
    original_helper=c.read(c.PREFIX + "booklib.py"), original_actor=c.read(c.PREFIX + "contain_book.py"),
    original_log=c.read(".linkedspec-data/verification/literal-kinds-book-contain.log"), original_exit=1,
    source_unchanged=True,
    qualification="Initial setup failed before the actor captured an epoch or edited book sources; its full original pre-command input census is unavailable. This later diagnostic has its own actual epoch and unchanged original helper/actor/log. No product RED or rendered-book credit is claimed. Restore the caller's module search path after importing the historical pure renderer."))
print("Preparation failure and actual wrong-module diagnostic retained; no book source changed.", flush=True)
