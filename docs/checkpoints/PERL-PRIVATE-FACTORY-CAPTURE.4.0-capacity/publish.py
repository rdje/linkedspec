"""Current readonly entrypoint; original finite producer is retained in eof-original-inputs.json.gz."""
from pathlib import Path
import runpy

runpy.run_path(str(Path(__file__).with_name('publish-final.py')), run_name='__main__')
