-- Package-internal, dependency-free SHA-256 shared by Lua semantic source
-- identity and invocation-local runtime observation. This implementation uses
-- only arithmetic available in both PUC Lua 5.4 and LuaJIT's Lua 5.1 surface.

local M = {}

local UINT32 = 4294967296
local UINT32_MASK = UINT32 - 1
local HEX_DIGITS = "0123456789abcdef"

local XOR_NIBBLE = {}
local AND_NIBBLE = {}
for left = 0, 15 do
  local xor_row = {}
  local and_row = {}
  for right = 0, 15 do
    local left_value = left
    local right_value = right
    local xor_value = 0
    local and_value = 0
    local place = 1
    for _ = 1, 4 do
      local left_bit = left_value % 2
      local right_bit = right_value % 2
      if left_bit ~= right_bit then xor_value = xor_value + place end
      if left_bit == 1 and right_bit == 1 then and_value = and_value + place end
      left_value = math.floor(left_value / 2)
      right_value = math.floor(right_value / 2)
      place = place * 2
    end
    xor_row[right + 1] = xor_value
    and_row[right + 1] = and_value
  end
  XOR_NIBBLE[left + 1] = xor_row
  AND_NIBBLE[left + 1] = and_row
end

local function bitwise_nibbles(left, right, lookup)
  local result = 0
  local place = 1
  for _ = 1, 8 do
    local left_digit = left % 16
    local right_digit = right % 16
    result = result + lookup[left_digit + 1][right_digit + 1] * place
    left = math.floor(left / 16)
    right = math.floor(right / 16)
    place = place * 16
  end
  return result
end

local function band(left, right)
  return bitwise_nibbles(left, right, AND_NIBBLE)
end

local function bxor(left, right)
  return bitwise_nibbles(left, right, XOR_NIBBLE)
end

local function bxor3(first, second, third)
  return bxor(bxor(first, second), third)
end

local function bnot(value)
  return UINT32_MASK - value
end

local function rshift(value, amount)
  return math.floor(value / (2 ^ amount))
end

local function rotate_right(value, amount)
  local divisor = 2 ^ amount
  return math.floor(value / divisor) + (value % divisor) * (2 ^ (32 - amount))
end

local function add32(first, second, third, fourth, fifth)
  return (first + second + (third or 0) + (fourth or 0) + (fifth or 0)) % UINT32
end

local SHA256_INITIAL = {
  0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A,
  0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19,
}

local SHA256_ROUND = {
  0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5,
  0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5,
  0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3,
  0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174,
  0xE49B69C1, 0xEFBE4786, 0x0FC19DC6, 0x240CA1CC,
  0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA,
  0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7,
  0xC6E00BF3, 0xD5A79147, 0x06CA6351, 0x14292967,
  0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13,
  0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85,
  0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3,
  0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070,
  0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5,
  0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3,
  0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208,
  0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2,
}

local function word_byte(value, shift)
  return math.floor(value / (2 ^ shift)) % 256
end

local function padded_message(source)
  local bit_length = #source * 8
  local high = math.floor(bit_length / UINT32)
  local low = bit_length % UINT32
  local zero_count = (56 - ((#source + 1) % 64)) % 64
  return source .. string.char(0x80) .. string.rep("\0", zero_count) .. string.char(
    word_byte(high, 24), word_byte(high, 16), word_byte(high, 8), word_byte(high, 0),
    word_byte(low, 24), word_byte(low, 16), word_byte(low, 8), word_byte(low, 0)
  )
end

local function hex_word(value)
  local characters = {}
  for index = 8, 1, -1 do
    local digit = value % 16
    characters[index] = HEX_DIGITS:sub(digit + 1, digit + 1)
    value = math.floor(value / 16)
  end
  return table.concat(characters)
end

function M.hex(source)
  if type(source) ~= "string" then error("sha256 source must be a string", 0) end
  local hash = {}
  for index = 1, 8 do hash[index] = SHA256_INITIAL[index] end
  local message = padded_message(source)

  for block_start = 1, #message, 64 do
    local words = {}
    for index = 0, 15 do
      local position = block_start + index * 4
      words[index + 1] = message:byte(position) * 0x1000000 +
        message:byte(position + 1) * 0x10000 +
        message:byte(position + 2) * 0x100 +
        message:byte(position + 3)
    end
    for index = 17, 64 do
      local left = words[index - 15]
      local right = words[index - 2]
      local small_0 = bxor3(rotate_right(left, 7), rotate_right(left, 18), rshift(left, 3))
      local small_1 = bxor3(rotate_right(right, 17), rotate_right(right, 19), rshift(right, 10))
      words[index] = add32(words[index - 16], small_0, words[index - 7], small_1)
    end

    local a, b, c, d = hash[1], hash[2], hash[3], hash[4]
    local e, f, g, h = hash[5], hash[6], hash[7], hash[8]
    for index = 1, 64 do
      local large_1 = bxor3(rotate_right(e, 6), rotate_right(e, 11), rotate_right(e, 25))
      local choose = bxor(band(e, f), band(bnot(e), g))
      local temporary_1 = add32(h, large_1, choose, SHA256_ROUND[index], words[index])
      local large_0 = bxor3(rotate_right(a, 2), rotate_right(a, 13), rotate_right(a, 22))
      local majority = bxor3(band(a, b), band(a, c), band(b, c))
      local temporary_2 = add32(large_0, majority)
      h = g
      g = f
      f = e
      e = add32(d, temporary_1)
      d = c
      c = b
      b = a
      a = add32(temporary_1, temporary_2)
    end

    hash[1] = add32(hash[1], a)
    hash[2] = add32(hash[2], b)
    hash[3] = add32(hash[3], c)
    hash[4] = add32(hash[4], d)
    hash[5] = add32(hash[5], e)
    hash[6] = add32(hash[6], f)
    hash[7] = add32(hash[7], g)
    hash[8] = add32(hash[8], h)
  end

  local parts = {}
  for index = 1, 8 do parts[index] = hex_word(hash[index]) end
  return table.concat(parts)
end

return M
