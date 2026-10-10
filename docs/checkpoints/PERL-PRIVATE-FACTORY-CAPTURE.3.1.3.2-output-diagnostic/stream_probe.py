"""Bounded stdout producer for recent-output transport semantics; no project runtime."""
import sys
import time

sys.stdout.write('first_chunk\n' * 50)
sys.stdout.flush()
time.sleep(3)
sys.stdout.write('second_chunk\n' * 100)
sys.stdout.flush()
