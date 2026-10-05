"""Archive the consumed failed canonical job without claiming a rerun or pass."""
from pathlib import Path
import subprocess,gzip,hashlib,json
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('canonical-archive.py')
raw=subprocess.check_output(['git','diff','--cached','--binary','--full-index','--no-ext-diff','HEAD'],cwd=ROOT)
assert hashlib.sha256(raw).hexdigest()=='262f71643e1fe39837bb81ec6c5345e68d0d5e0f018270a33c8f03f73946d1b0'
Path(PREFIX+'canonical-first-candidate.diff.gz').write_bytes(gzip.compress(raw,mtime=0))
log=(ROOT/'.linkedspec-data/scratch/split-source-metadata-canonical.log').read_bytes()
Path(PREFIX+'canonical-first-output.log.gz').write_bytes(gzip.compress(log,mtime=0))
record={'base_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip(),'candidate_diff_sha256':hashlib.sha256(raw).hexdigest(),'candidate_diff_bytes':len(raw),'merged_output_sha256':hashlib.sha256(log).hexdigest(),'merged_output_bytes':len(log),'command':"set -o pipefail; bash tools/run_ci_local.sh 2>&1 | tee .linkedspec-data/scratch/split-source-metadata-canonical.log",'exit_observed_from_exec_session':1,'exec_session':54033,'archive_instrument_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'scope':'Original failed canonical execution, complete merged stdout/stderr bytes and exact staged binary diff retained before restaging. Exit1 observed when original exec session completed; archival operation did not execute CI or claim a completed canonical pass. Recover candidate from base Git revision and binary diff; unchanged CI producer comes from that candidate. External host/toolchain reads are not reconstructed by this archive.'}
Path(PREFIX+'canonical-first-failure.json').write_text(json.dumps(record,indent=2)+'\n')
print('Original canonical failure and exact staged candidate archived')
