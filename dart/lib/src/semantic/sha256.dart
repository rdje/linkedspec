import 'dart:typed_data';

const _mask32 = 0xFFFFFFFF;

const _roundConstants = <int>[
  0x428A2F98,
  0x71374491,
  0xB5C0FBCF,
  0xE9B5DBA5,
  0x3956C25B,
  0x59F111F1,
  0x923F82A4,
  0xAB1C5ED5,
  0xD807AA98,
  0x12835B01,
  0x243185BE,
  0x550C7DC3,
  0x72BE5D74,
  0x80DEB1FE,
  0x9BDC06A7,
  0xC19BF174,
  0xE49B69C1,
  0xEFBE4786,
  0x0FC19DC6,
  0x240CA1CC,
  0x2DE92C6F,
  0x4A7484AA,
  0x5CB0A9DC,
  0x76F988DA,
  0x983E5152,
  0xA831C66D,
  0xB00327C8,
  0xBF597FC7,
  0xC6E00BF3,
  0xD5A79147,
  0x06CA6351,
  0x14292967,
  0x27B70A85,
  0x2E1B2138,
  0x4D2C6DFC,
  0x53380D13,
  0x650A7354,
  0x766A0ABB,
  0x81C2C92E,
  0x92722C85,
  0xA2BFE8A1,
  0xA81A664B,
  0xC24B8B70,
  0xC76C51A3,
  0xD192E819,
  0xD6990624,
  0xF40E3585,
  0x106AA070,
  0x19A4C116,
  0x1E376C08,
  0x2748774C,
  0x34B0BCB5,
  0x391C0CB3,
  0x4ED8AA4A,
  0x5B9CCA4F,
  0x682E6FF3,
  0x748F82EE,
  0x78A5636F,
  0x84C87814,
  0x8CC70208,
  0x90BEFFFA,
  0xA4506CEB,
  0xBEF9A3F7,
  0xC67178F2,
];

/// Return the lowercase SHA-256 digest for exact bytes.
///
/// This small package-internal implementation keeps the production Dart
/// package dependency-free, which is required by generated callers that run
/// against a fresh offline package cache.
String sha256Hex(List<int> bytes) {
  final bitLength = bytes.length * 8;
  final paddedLength = ((bytes.length + 9 + 63) ~/ 64) * 64;
  final padded = Uint8List(paddedLength)..setRange(0, bytes.length, bytes);
  padded[bytes.length] = 0x80;
  for (var index = 0; index < 8; index += 1) {
    padded[paddedLength - 1 - index] = (bitLength >> (index * 8)) & 0xFF;
  }

  final state = <int>[
    0x6A09E667,
    0xBB67AE85,
    0x3C6EF372,
    0xA54FF53A,
    0x510E527F,
    0x9B05688C,
    0x1F83D9AB,
    0x5BE0CD19,
  ];
  final words = List<int>.filled(64, 0);

  for (var block = 0; block < padded.length; block += 64) {
    for (var index = 0; index < 16; index += 1) {
      final offset = block + index * 4;
      words[index] =
          (padded[offset] << 24) |
          (padded[offset + 1] << 16) |
          (padded[offset + 2] << 8) |
          padded[offset + 3];
    }
    for (var index = 16; index < 64; index += 1) {
      final left = words[index - 15];
      final right = words[index - 2];
      final sigma0 =
          _rotateRight(left, 7) ^ _rotateRight(left, 18) ^ (left >>> 3);
      final sigma1 =
          _rotateRight(right, 17) ^ _rotateRight(right, 19) ^ (right >>> 10);
      words[index] =
          (words[index - 16] + sigma0 + words[index - 7] + sigma1) & _mask32;
    }

    var a = state[0];
    var b = state[1];
    var c = state[2];
    var d = state[3];
    var e = state[4];
    var f = state[5];
    var g = state[6];
    var h = state[7];

    for (var index = 0; index < 64; index += 1) {
      final sum1 =
          _rotateRight(e, 6) ^ _rotateRight(e, 11) ^ _rotateRight(e, 25);
      final choose = (e & f) ^ ((~e) & g);
      final temporary1 =
          (h + sum1 + choose + _roundConstants[index] + words[index]) & _mask32;
      final sum0 =
          _rotateRight(a, 2) ^ _rotateRight(a, 13) ^ _rotateRight(a, 22);
      final majority = (a & b) ^ (a & c) ^ (b & c);
      final temporary2 = (sum0 + majority) & _mask32;

      h = g;
      g = f;
      f = e;
      e = (d + temporary1) & _mask32;
      d = c;
      c = b;
      b = a;
      a = (temporary1 + temporary2) & _mask32;
    }

    state[0] = (state[0] + a) & _mask32;
    state[1] = (state[1] + b) & _mask32;
    state[2] = (state[2] + c) & _mask32;
    state[3] = (state[3] + d) & _mask32;
    state[4] = (state[4] + e) & _mask32;
    state[5] = (state[5] + f) & _mask32;
    state[6] = (state[6] + g) & _mask32;
    state[7] = (state[7] + h) & _mask32;
  }

  return state.map((word) => word.toRadixString(16).padLeft(8, '0')).join();
}

int _rotateRight(int value, int amount) =>
    ((value >>> amount) | (value << (32 - amount))) & _mask32;
