"""Author the new acceptance reviewer before grading any fresh observations."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review-prepare.py')
PARENT = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2-'
GROUPED = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-'


def main():
    target = Path(PREFIX + 'review.py'); assert not target.exists()
    text = (ROOT / (PARENT + 'review.py')).read_text()
    def replace(old, new):
        nonlocal text
        assert text.count(old) == 1, 'exact predecessor reviewer anchor'
        text = text.replace(old, new, 1)
    replace("REVISION = '0f31461d696186775585e19355a0bc5c41849dfb'",
            "REVISION = '5b4a9a8ca2203f651d3c9d3a36cc9836c30a5375'")
    replace("CALLABLE = REPAIR + 'probe.pl'", "CALLABLE = REPAIR + 'probe.pl'\n"
        "GROUPED = '" + GROUPED + "'\nGROUPED_PROBE = '" + PARENT + "cause-probe.pl'\n"
        "DEFAULT_PROBE = GROUPED + 'default-probe.pl'")
    replace("'callable_codeblock_literal_contract', 'phase0_regression')]",
        "'callable_codeblock_literal_contract', 'phase0_regression',\n"
        "    'multiline_helper_pattern_validation', 'phase0_validation_fuzz',\n"
        "    'inter_match_gap_capture_perl_contract', 'duplicate_regex_slot_identity_perl_contract',\n"
        "    'sparse_and_action_slots_perl_regression', 'uniform_binding_contract')]")
    replace('corrected-membership-acceptance', 'complete-membership-acceptance')
    replace("        'callable signature delimiters preserve original executable return origins']",
        "        'callable signature delimiters preserve original executable return origins',\n"
        "        'callable helper roles preserve grouped-pattern occurrence ownership']")
    replace("    population += [('consumers', 0)]", "    population += [('grouped', s) for s in (0, 1, 42)]\n"
        "    population += [('default', 0), ('consumers', 0)]")
    replace("    consumer_before = next(r for r in corrected['runs'] if r['kind'] == 'consumers')",
        "    grouped = load_grouped_reviewer()\n"
        "    grouped_corrected = json.loads(committed(GROUPED + 'after-observations.json'))\n"
        "    grouped_original = json.loads(committed('" + PARENT + "grouped-cause.json'))\n"
        "    grouped_original = {r['seed']: json.loads(decode(r['stdout'])) for r in grouped_original['runs']}\n"
        "    default_original = decode(next(r for r in grouped_corrected['runs'] if r['kind'] == 'default-query')['stdout'])\n"
        "    consumer_before = next(r for r in grouped_corrected['runs'] if r['kind'] == 'consumers')")
    replace("            signature.compiler_tap(stdout, 'after')", "            grouped.compiler_tap(stdout, 'after', row['seed'])")
    replace("        else:\n            name = row['kind'].removeprefix('public:')",
        "        elif row['kind'] == 'grouped':\n"
        "            tail = ['perl', '-Iperl', GROUPED_PROBE]\n"
        "            rows = json.loads(stdout); grouped.public(rows, 'after', grouped_original[row['seed']])\n"
        "            baseline = next(r for r in grouped_corrected['runs'] if r['kind'] == 'public' and r['seed'] == row['seed'])\n"
        "            assert rows == json.loads(decode(baseline['stdout'])), 'complete corrected grouped source/origin/metadata/public channels'\n"
        "        elif row['kind'] == 'default':\n"
        "            tail = ['perl', '-Iperl', DEFAULT_PROBE]\n"
        "            assert stdout == default_original, 'all72 original default query/view/numeric/syntactic channels'\n"
        "            rows = json.loads(stdout); cases72 = json.loads(committed(GROUPED + 'cases.json'))\n"
        "            assert [(r['id'], r['source']) for r in rows] == [(r['id'], r['source']) for r in cases72], 'complete72 source population'\n"
        "        else:\n            name = row['kind'].removeprefix('public:')")
    replace("            'callable_route_values': callable_count * 2,",
        "            'callable_route_values': callable_count * 2,\n"
        "            'grouped_source_seed_pairs': 18, 'grouped_route_values': 36,\n"
        "            'default_query_sources': 72, 'grouped_assertions_per_seed': 789,")
    replace("    controls = []\n    variants = [", "    grouped = load_grouped_reviewer()\n"
        "    original_grouped = json.loads(committed(GROUPED + 'before-observations.json'))\n"
        "    summary['historical_grouped_red'] = [dict(grouped.compiler_tap(decode(r['stdout']), 'before', r['seed']), seed=r['seed'])\n"
        "        for r in original_grouped['runs'] if r['kind'] == 'compiler-tap']\n"
        "    controls = []\n    variants = [")
    replace("        ('renamed consumer group',", "        ('lost grouped assertion789', lambda r: r['runs'][0].update(stdout=envelope(re.sub(\n"
        "            br'(?m)^    ok 789 - .+\\n', b'', decode(r['runs'][0]['stdout']), count=1)))),\n"
        "        ('lost grouped command', lambda r: r['runs'].pop(-5)),\n"
        "        ('lost actual grouped origins', lambda r: change_grouped(r, 'source_origins', [])),\n"
        "        ('retained false grouped metadata', lambda r: change_grouped(r, 'metadata',\n"
        "            json.loads(decode(next(x for x in original_grouped['runs'] if x['kind'] == 'public')['stdout']))[0]['metadata'])),\n"
        "        ('changed grouped AST', lambda r: change_grouped(r, 'ast', {})),\n"
        "        ('forged grouped fresh', lambda r: change_grouped(r, 'fresh', {'value': 'forged'})),\n"
        "        ('lost default command', lambda r: r['runs'].pop(-2)),\n"
        "        ('changed default query channel', change_default),\n"
        "        ('lost final consumer reach', lambda r: r['runs'][-1].update(stdout=envelope(re.sub(\n"
        "            br'(?m)^ok 12 - .+\\n', b'', decode(r['runs'][-1]['stdout']), count=1)))),\n"
        "        ('renamed consumer group',")
    replace("if __name__ == '__main__':", "def load_grouped_reviewer():\n"
        "    spec = importlib.util.spec_from_file_location('committed_grouped_oracles', ROOT / (GROUPED + 'review.py'))\n"
        "    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)\n"
        "    return module\n\n\n"
        "def change_grouped(report, key, value):\n"
        "    row = next(r for r in report['runs'] if r['kind'] == 'grouped')\n"
        "    rows = json.loads(decode(row['stdout'])); rows[0][key] = value\n"
        "    row['stdout'] = envelope(json.dumps(rows).encode())\n\n\n"
        "def change_default(report):\n"
        "    row = next(r for r in report['runs'] if r['kind'] == 'default')\n"
        "    rows = json.loads(decode(row['stdout'])); rows[0]['default_structural_view'] = 'changed default view'\n"
        "    row['stdout'] = envelope(json.dumps(rows).encode())\n\n\n"
        "if __name__ == '__main__':")
    target.write_text(text)
    print('Prepared complete source/channel/population and historical RED reviewer')


if __name__ == '__main__':
    main()
