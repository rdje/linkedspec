"""Deliberately bounded literal three-argument open grammar."""
from pathlib import PurePosixPath
import re

PATTERN = re.compile(r'''\A\s*(?:CORE::)?open\s*(?P<left>\()?\s*(?:my\s+)?(?P<handle>\$[A-Za-z_]\w*|STDOUT|STDERR)\s*,\s*(?P<mq>['"])(?P<mode>[<>](?::raw|:encoding\(UTF-8\))?)(?P=mq)\s*,\s*(?P<pq>['"])(?P<path>[A-Za-z0-9_./-]+)(?P=pq)\s*(?P<right>\))?\s+or\s+die\b[\s\S]*;\s*\Z''')


def literal(site):
    if site.get('word') != 'open' or site.get('class') != 'PPI::Token::Word':
        return None
    if site.get('context_hint', '').startswith(('member-name', 'subroutine declaration', 'fat-comma')):
        return None
    match = PATTERN.fullmatch(site.get('statement_content') or '')
    if not match or bool(match['left']) != bool(match['right']):
        return None
    path = PurePosixPath(match['path'])
    if path.is_absolute() or '..' in path.parts or not path.parts:
        return None
    return dict(path=str(path), source_path=match['path'], mode=match['mode'], handle=match['handle'],
        role='literal-input-read' if match['mode'].startswith('<') else 'declared-output-write')


def inventory(output):
    matched, remainder = [], []
    for document in output['documents']:
        for site in document['sites']:
            if site.get('word') != 'open':
                continue
            row = dict(parent=document['path'], source_sha256=document['source_sha256'],
                ordinal=site['ordinal'], location=site['location'], expression=site['statement_content'])
            found = literal(site)
            if found:
                matched.append(dict(**row, **found))
            else:
                remainder.append(dict(**row, context_hint=site['context_hint'],
                    role='unmatched open candidate; variable/scalar/generated/helper/callee meaning requires follow-up'))
    return matched, remainder
