"""One-shot closed admission input manifest, excluding later review observations."""
import admission_common as a


def main():
    names = sorted(file.name for file in (a.ROOT/a.PREFIX).iterdir() if file.is_file())
    assert 'publication.json' not in names
    a.save('publication.json', dict(version=1,
        inputs={name: a.identity(a.PREFIX+name) for name in names},
        scope='Closed dated capture/producer inputs, including this seal and the read-only reviewer. Subsequent actual review/input-control observations and the combined claim bind this manifest separately; no self-referential or mutable runtime binding. Installed tools, accepted Git objects and prepared public dependency products are declared prerequisites.'))
    print('Closed admission inputs:', len(names))


if __name__ == '__main__':
    main()
