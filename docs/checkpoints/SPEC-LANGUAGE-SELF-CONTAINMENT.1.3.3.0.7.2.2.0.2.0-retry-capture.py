"""Host remeasurement invokes the unchanged declared capture producer."""
from pathlib import Path
import importlib.util
import sys

PREFIX = __file__.removesuffix('retry-capture.py')
spec = importlib.util.spec_from_file_location('unchanged_membership_capture', Path(PREFIX + 'capture.py'))
capture = importlib.util.module_from_spec(spec); spec.loader.exec_module(capture)
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'after')
capture.main(sys.argv[1])
