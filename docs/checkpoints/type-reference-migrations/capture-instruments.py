"""Retain outer reader failures and their independently supplied native results."""
import common as c

sources = ['history-supplement.py', 'history-supplement-final.py', 'history-current.py',
    'capture-native.py', 'review_native.py', 'prepare-docs.py', 'prepare-docs-final.py',
    'book.py', 'review_book.py', 'capture-instruments.py']
logs = ['type-migrations-native.log', 'type-migrations-book.log']
c.write_new(c.PREFIX + 'instruments.json.gz', dict(
    sources={name: c.read(c.PREFIX + name) for name in sources},
    outer_logs={name: c.read('.linkedspec-data/verification/' + name) for name in logs},
    distinctions=[
        'Original history EOF failure: separate original inner channels unavailable; exact supplied recurrence is retained in history-repair.json.',
        'Separate EOF reader assumes removed callbacks exist; actual distinct ValueError channels precede history-current.py.',
        'Native command exits0 and retains complete channels/inputs before the summary reader fails on diagnostic stdout. review_native.py explicitly separates the final JSON record from its retained prelude.',
        'Original documentation writer stops before its output/write on multiple historical body fields. Exact source/data recurrence precedes the header-only writer; historical body lines remain exact.',
        'Both original complete book builds exit0 and are saved before its entity-specific reader fails. review_book.py checks decoded HTML, current links and native-source equality, and reproduces the original false negative.'
    ], scope='These are distinct actual instrument outcomes, not product failures or refreshed original observations.'), packed=True)
print('Original instrument sources/outer logs and bounded corrections retained')
