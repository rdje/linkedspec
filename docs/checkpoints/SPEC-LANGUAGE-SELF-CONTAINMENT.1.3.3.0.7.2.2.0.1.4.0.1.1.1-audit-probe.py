"""Replay the registered recovery producer with the retained original auditor."""
from pathlib import Path
import importlib.util

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('audit-probe.py')
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
spec = importlib.util.spec_from_file_location('original_recovery_proof', ROOT / PROOF)
proof = importlib.util.module_from_spec(spec)
spec.loader.exec_module(proof)
# Only the auditor input changes; restoration, denial guards and original logs
# remain under the unchanged registered producer's authority.
proof.AUDITOR = Path(PREFIX + 'audit-before.py').relative_to(ROOT).as_posix()
proof.main()
