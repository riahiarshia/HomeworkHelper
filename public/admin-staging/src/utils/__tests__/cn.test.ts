import { cn } from '../cn';

describe('cn utility function', () => {
  it('combines class names correctly', () => {
    const result = cn('class1', 'class2', 'class3');
    expect(result).toBe('class1 class2 class3');
  });

  it('handles empty strings', () => {
    const result = cn('class1', '', 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles undefined values', () => {
    const result = cn('class1', undefined, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles null values', () => {
    const result = cn('class1', null, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles boolean values', () => {
    const result = cn('class1', true, 'class2', false);
    expect(result).toBe('class1 class2');
  });

  it('handles mixed types', () => {
    const result = cn('class1', '', undefined, null, true, false, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles single class name', () => {
    const result = cn('single-class');
    expect(result).toBe('single-class');
  });

  it('handles no arguments', () => {
    const result = cn();
    expect(result).toBe('');
  });

  it('handles array of class names', () => {
    const result = cn(['class1', 'class2', 'class3']);
    expect(result).toBe('class1 class2 class3');
  });

  it('handles nested arrays', () => {
    const result = cn(['class1', ['class2', 'class3']]);
    expect(result).toBe('class1 class2 class3');
  });

  it('handles objects with boolean values', () => {
    const result = cn({
      'class1': true,
      'class2': false,
      'class3': true
    });
    expect(result).toBe('class1 class3');
  });

  it('handles mixed arrays and objects', () => {
    const result = cn('class1', ['class2', 'class3'], {
      'class4': true,
      'class5': false
    });
    expect(result).toBe('class1 class2 class3 class4');
  });

  it('handles complex nested structures', () => {
    const result = cn([
      'class1',
      {
        'class2': true,
        'class3': false
      },
      'class4'
    ]);
    expect(result).toBe('class1 class2 class4');
  });

  it('handles deeply nested arrays', () => {
    const result = cn([
      'class1',
      [
        'class2',
        [
          'class3',
          'class4'
        ]
      ],
      'class5'
    ]);
    expect(result).toBe('class1 class2 class3 class4 class5');
  });

  it('handles objects with nested arrays', () => {
    const result = cn({
      'class1': true,
      'class2': ['class3', 'class4'],
      'class5': false
    });
    expect(result).toBe('class1 class3 class4');
  });

  it('handles objects with nested objects', () => {
    const result = cn({
      'class1': true,
      'class2': {
        'class3': true,
        'class4': false
      },
      'class5': false
    });
    expect(result).toBe('class1 class3');
  });

  it('handles empty arrays', () => {
    const result = cn('class1', [], 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles empty objects', () => {
    const result = cn('class1', {}, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles objects with all false values', () => {
    const result = cn({
      'class1': false,
      'class2': false,
      'class3': false
    });
    expect(result).toBe('');
  });

  it('handles objects with all true values', () => {
    const result = cn({
      'class1': true,
      'class2': true,
      'class3': true
    });
    expect(result).toBe('class1 class2 class3');
  });

  it('handles mixed boolean and string values in objects', () => {
    const result = cn({
      'class1': true,
      'class2': 'string-value',
      'class3': false
    });
    expect(result).toBe('class1 string-value');
  });

  it('handles numeric values', () => {
    const result = cn('class1', 0, 'class2', 1);
    expect(result).toBe('class1 class2');
  });

  it('handles function values', () => {
    const result = cn('class1', () => {}, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles symbol values', () => {
    const result = cn('class1', Symbol('test'), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles date values', () => {
    const result = cn('class1', new Date(), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles regex values', () => {
    const result = cn('class1', /test/, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles error values', () => {
    const result = cn('class1', new Error('test'), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles promise values', () => {
    const result = cn('class1', Promise.resolve(), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles set values', () => {
    const result = cn('class1', new Set(['test']), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles map values', () => {
    const result = cn('class1', new Map([['key', 'value']]), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles weakset values', () => {
    const result = cn('class1', new WeakSet(), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles weakmap values', () => {
    const result = cn('class1', new WeakMap(), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles arraybuffer values', () => {
    const result = cn('class1', new ArrayBuffer(8), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles dataview values', () => {
    const result = cn('class1', new DataView(new ArrayBuffer(8)), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles typedarray values', () => {
    const result = cn('class1', new Uint8Array(8), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles bigint values', () => {
    const result = cn('class1', BigInt(123), 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles infinity values', () => {
    const result = cn('class1', Infinity, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles nan values', () => {
    const result = cn('class1', NaN, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles negative zero values', () => {
    const result = cn('class1', -0, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles positive zero values', () => {
    const result = cn('class1', +0, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles negative infinity values', () => {
    const result = cn('class1', -Infinity, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles very large numbers', () => {
    const result = cn('class1', Number.MAX_SAFE_INTEGER, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles very small numbers', () => {
    const result = cn('class1', Number.MIN_SAFE_INTEGER, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles very large positive numbers', () => {
    const result = cn('class1', Number.MAX_VALUE, 'class2');
    expect(result).toBe('class1 class2');
  });

  it('handles numeric values by converting them to strings', () => {
    const result = cn('class1', 42, 'class2');
    expect(result).toBe('class1 42 class2');
  });

  it('handles zero values', () => {
    const result = cn('class1', 0, 'class2');
    expect(result).toBe('class1 0 class2');
  });

  it('handles negative numbers', () => {
    const result = cn('class1', -5, 'class2');
    expect(result).toBe('class1 -5 class2');
  });
});