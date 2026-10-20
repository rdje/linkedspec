"""Run the exact selector with its real EmitContext initialization consumer.

The first focused attempt skipped that ordinary prerequisite and died before
assertions. Its raw exit255 remains phase0-before, never a behavior RED claim.
"""
import capture_check

capture_check.PLAN['selected'].insert(0,dict(number=476,
    name='emit_context_lowers_method_contracts_for_capture_and_structured_return_values'))

if __name__ == '__main__':
    capture_check.main()
