"""Retain the original read-only permission comparison failure before correction."""
import subprocess
import common as c
import context

PATH = 'noncore/AmbiTiming.pm'
READER = c.PREFIX + 'read.py'


def main():
    original=c.read(READER)
    assert original == c.load('input-controls-inputs.json.gz')['reader']
    log=c.read('.linkedspec-data/verification/literal-kinds-review1.log')
    assert b'AssertionError: noncore/AmbiTiming.pm' in c.decode(log['base64'])
    epoch=context.snapshot()
    accepted=subprocess.check_output(['git','show',c.BASE+':'+PATH],cwd=c.ROOT)
    item=c.load('activation-inputs.json.gz')['context']['inputs'][PATH]
    assert item['sha256'] == c.sha(accepted) and item['mode'] == 0o640
    tree=subprocess.check_output(['git','ls-tree',c.BASE,'--',PATH],cwd=c.ROOT).decode().strip()
    assert tree.startswith('100644 blob ')
    namespace=dict(__file__=str(c.ROOT/READER),__name__='literal_original_mode_diagnostic')
    exec(compile(c.decode(original['base64']),namespace['__file__'],'exec'),namespace)
    probe=namespace['Sources'].__new__(namespace['Sources'])
    probe.tree={PATH:(0o644,tree.split()[2])};probe.hashes={PATH:c.sha(accepted)}
    probe.small={PATH:accepted};probe.identities={}
    try:
        probe.recover(dict(inputs={PATH:item},overrides={}),PATH)
    except AssertionError as error:
        reason=str(error)
    else:
        raise AssertionError('original equality unexpectedly admitted actual modes')
    assert reason == PATH
    c.write_new('reader-mode-qualification.json.gz',dict(context=epoch,producer=c.read(c.PREFIX+'qualify_reader_mode.py'),
        original_reader=original,original_log=log,original_exit=1,existing_fact=c.read('docs/knowledge/project-root-evidence-filesystem-modes.md'),
        path=PATH,captured_filesystem=item,accepted_git=dict(tree_row=tree,sha256=c.sha(accepted),base64=c.encode(accepted)),
        actual_original_predicate_rejection=reason,
        qualification='Original full readonly-command pre-census was not captured. Its exact unchanged reader is retained in the earlier input-control epoch; this later full epoch and actual original-method diagnostic establish the false permission equality. No semantic review completion or product RED credit is claimed. No source permission is changed.'))
    assert c.unchanged(epoch['inputs'])
    print('Original reader permission mismatch retained: identical bytes, filesystem0640 versus Git100644; no chmod.',flush=True)


if __name__ == '__main__':
    main()
