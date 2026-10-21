"""Retain the actual metadata pressure failure stream with its exact source packet."""
import common as c

def main():
    log=c.read('.linkedspec-data/verification/type-pipeline-metadata-pressure.log')
    assert b'AssertionError: (3842, 3796)' in c.decode(log['base64'])
    c.write_new('metadata-pressure-run.json.gz',dict(log=log,proposal=c.identity(c.PREFIX+'metadata-pressure.json.gz'),
        producer=c.read(c.PREFIX+'retain_pressure.py'),scope='Actual failed proposal stream, separate from the first writer whose exact source/pre-write failure is retained. No tracked writer output existed before the final bounded consolidation.'))

if __name__=='__main__':main()
