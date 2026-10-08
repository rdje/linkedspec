"""Create the corrected trace producer without changing the initial traces."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('corrected-trace-prepare.py')


def main():
    relative = Path(PREFIX).relative_to(ROOT).as_posix()
    source = Path(PREFIX + 'trace.pl').read_text()
    assert source.count("'" + relative + "'") == 1
    target = Path(PREFIX + 'corrected-trace.pl'); assert not target.exists()
    target.write_text(source.replace("'" + relative + "'", "'" + relative + "corrected-'"))
    target = Path(PREFIX + 'corrected-trace-capture.py'); assert not target.exists()
    target.write_bytes(Path(PREFIX + 'trace-capture.py').read_bytes())
    print('Corrected valid-cat traces prepared; all initial channels preserved')


if __name__ == '__main__':
    main()
