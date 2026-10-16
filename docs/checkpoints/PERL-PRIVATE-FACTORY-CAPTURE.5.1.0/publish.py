"""Current readonly-default route; first failed publisher source stays in repair02 custody."""
from pathlib import Path
import runpy

runpy.run_path(str(Path(__file__).with_name('publish-final.py')), run_name='__main__')
