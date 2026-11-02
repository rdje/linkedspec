#!/usr/bin/env python3
from task_narrative import verify

if __name__ == '__main__':
    try:
        print(f'task-narrative: PASS exact source reconstruction and retained contracts for {verify()} predecessor IDs')
    except (ValueError, OSError) as error:
        raise SystemExit('task-narrative: FAIL ' + str(error))
