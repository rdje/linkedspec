"""Retain exact historical, activation and candidate source images."""
import common as c


def main():
    prior = '691d2d87690ce3f9052c1d032a3e862ee5d76211'
    names = ['rust/Cargo.toml','rust/linkedspec-runtime/src/engine.rs']
    images = {}
    for name in names:
        history = c.run(['git','show',prior+':'+name])
        activation = c.run(['git','show',c.BASE+':'+name])
        assert history['returncode']==activation['returncode']==0
        images[name] = dict(historical=history,activation=activation,current=c.read(name))
    c.save('historical-source-images.json.gz',dict(owner=c.OWNER,activation=c.BASE,
        earlier_source_commit=prior,images=images,
        auditor_before=c.read('tests/language-readiness/verify_objectives.py'),
        ledger_before=c.read('docs/language-readiness/objective-reconciliation.md'),
        producer=c.read(c.PREFIX+'prepare_history.py'),
        limits='Exact candidate images only; passing numeric/runtime and fresh readiness '
            'proofs remain separate. Original immutable source/log/result identities '
            'and the prior signed-selector admission are never rewritten.'))
    print('Historical/activation/candidate images and prior auditor retained before guard evolution.')


if __name__ == '__main__':
    main()
