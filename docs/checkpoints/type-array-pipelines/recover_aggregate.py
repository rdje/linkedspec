"""Run the accepted aggregate chunk reader in its own import namespace."""
from pathlib import Path
import sys

root=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(root/'docs/checkpoints/type-aggregate-codeblocks'))
import large_inputs
large_inputs.ensure_all()
print('Accepted aggregate logical inputs verified/recovered from tracked chunks')
