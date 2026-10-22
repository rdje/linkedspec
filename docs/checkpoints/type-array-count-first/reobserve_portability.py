"""Execute the current summary producer against the same three real Phase0 roots."""
import common as c
import phase0


if __name__ == '__main__':
    phase0.observe('phase0-portable')
    result = c.load('phase0-portable-result.json')
    assert result == c.load('phase0-candidate-result.json')
    assert result['summary']['loaded_method_lowering'] == c.SOURCES[1]
    print('Current observer emits the same passing observations with a relative loader path')
