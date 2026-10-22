"""Close the corrected limit diagnosis without changing helper behavior or policy."""
import common as c


def main():
    proof = c.load('task-limit-review.json.gz')
    assert proof['inputs_unchanged'] and proof['old_guard']['rejected']
    assert proof['collection']['returncode'] == proof['metadata']['returncode'] == 0
    paths = ['docs/tasks/TYPE-REFERENCE-BOOK.md',c.PREFIX+'README.md']
    before = {path:c.read(path) for path in paths}
    task = c.decode(before[paths[0]]['base64']).decode()
    old = 'Verify the physical above-guard tree through the real checker and preserve the rejected guard; the count/first repair order stays unchanged.'
    new = 'task-limit-review.json.gz retains the actual capture-guard RED and production collection/metadata GREEN on the same above-guard source. The incorrect capacity warning is closed; count/first scope/order stays unchanged.'
    assert task.count(old) == 1
    book = c.decode(before[paths[1]]['base64']).decode()
    old_book = 'Verify the above-guard\nphysical source against the actual gate before closing this diagnostic issue.'
    new_book = 'task-limit-review.json.gz\nretains the old assertion RED and actual collection/metadata GREEN on the same\nabove-guard physical source. This diagnostic issue is corrected and closed.'
    assert book.count(old_book) == 1
    for path,value in ((paths[0],task.replace(old,new,1)),(paths[1],book.replace(old_book,new_book,1))):
        c.source(path).write_text(value)
        c.source(path).chmod(before[path]['mode'])
    c.write_new('task-limit-close.json.gz',dict(before=before,after={path:c.read(path) for path in paths},
        proof='task-limit-review.json.gz',scope='Correct the erroneous warning; no new containment activity or ceiling change.'))
    print('Limit diagnosis closed; count/first repair scope unchanged')


if __name__ == '__main__':
    main()
