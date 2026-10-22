"""Adopt bounded readonly custody and artifact validators for this selection leaf."""
import common as c


def main():
    origin = 'docs/checkpoints/type-sort-copy-kinds/'
    custody = c.source(origin+'custody.py').read_text()
    custody = custody.replace('TYPE-REFERENCE-BOOK.1.2.9.json','TYPE-REFERENCE-BOOK.1.2.13.json')
    custody = custody.replace('accepted9-images','accepted13-images')
    with (c.ROOT/c.PREFIX/'custody.py').open('x') as output:
        output.write(custody)
    with (c.ROOT/c.PREFIX/'artifacts.py').open('xb') as output:
        output.write(c.source(origin+'artifacts.py').read_bytes())
    print('Readonly custody and actual publication-validator controls adopted')


if __name__ == '__main__':
    main()
