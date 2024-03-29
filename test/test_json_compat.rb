# This file is generated by tool/generate_json_compat_test.rb

require "test_helper"

class JSONCompatTest < Minitest::Test
  def test_array_arraysWithSpaces
    expected = [[]]
    json = "[[]   ]"
    assert_json expected, json
  end

  def test_array_empty_string
    expected = [""]
    json = "[\"\"]"
    assert_json expected, json
  end

  def test_array_empty
    expected = []
    json = "[]"
    assert_json expected, json
  end

  def test_array_ending_with_newline
    expected = ["a"]
    json = "[\"a\"]"
    assert_json expected, json
  end

  def test_array_false
    expected = [false]
    json = "[false]"
    assert_json expected, json
  end

  def test_array_heterogeneous
    expected = [nil, 1, "1", {}]
    json = "[null, 1, \"1\", {}]"
    assert_json expected, json
  end

  def test_array_null
    expected = [nil]
    json = "[null]"
    assert_json expected, json
  end

  def test_array_with_1_and_newline
    expected = [1]
    json = "[1\n]"
    assert_json expected, json
  end

  def test_array_with_leading_space
    expected = [1]
    json = " [1]"
    assert_json expected, json
  end

  def test_array_with_several_null
    expected = [1, nil, nil, nil, 2]
    json = "[1,null,null,null,2]"
    assert_json expected, json
  end

  def test_array_with_trailing_space
    expected = [2]
    json = "[2] "
    assert_json expected, json
  end

  def test_number
    expected = [1.23e+67]
    json = "[123e65]"
    assert_json expected, json
  end

  def test_number_0e_1
    expected = [0.0]
    json = "[0e+1]"
    assert_json expected, json
  end

  def test_number_0e1
    expected = [0.0]
    json = "[0e1]"
    assert_json expected, json
  end

  def test_number_after_space
    expected = [4]
    json = "[ 4]"
    assert_json expected, json
  end

  def test_number_double_close_to_zero
    expected = [-1.0e-78]
    json = "[-0.000000000000000000000000000000000000000000000000000000000000000000000000000001]\n"
    assert_json expected, json
  end

  def test_number_int_with_exp
    expected = [200.0]
    json = "[20e1]"
    assert_json expected, json
  end

  def test_number_minus_zero
    expected = [0]
    json = "[-0]"
    assert_json expected, json
  end

  def test_number_negative_int
    expected = [-123]
    json = "[-123]"
    assert_json expected, json
  end

  def test_number_negative_one
    expected = [-1]
    json = "[-1]"
    assert_json expected, json
  end

  def test_number_negative_zero
    expected = [0]
    json = "[-0]"
    assert_json expected, json
  end

  def test_number_real_capital_e
    expected = [1.0e+22]
    json = "[1E22]"
    assert_json expected, json
  end

  def test_number_real_capital_e_neg_exp
    expected = [0.01]
    json = "[1E-2]"
    assert_json expected, json
  end

  def test_number_real_capital_e_pos_exp
    expected = [100.0]
    json = "[1E+2]"
    assert_json expected, json
  end

  def test_number_real_exponent
    expected = [1.23e+47]
    json = "[123e45]"
    assert_json expected, json
  end

  def test_number_real_fraction_exponent
    expected = [1.23456e+80]
    json = "[123.456e78]"
    assert_json expected, json
  end

  def test_number_real_neg_exp
    expected = [0.01]
    json = "[1e-2]"
    assert_json expected, json
  end

  def test_number_real_pos_exponent
    expected = [100.0]
    json = "[1e+2]"
    assert_json expected, json
  end

  def test_number_simple_int
    expected = [123]
    json = "[123]"
    assert_json expected, json
  end

  def test_number_simple_real
    expected = [123.456789]
    json = "[123.456789]"
    assert_json expected, json
  end

  def test_object
    expected = {"asd"=>"sdf", "dfg"=>"fgh"}
    json = "{\"asd\":\"sdf\", \"dfg\":\"fgh\"}"
    assert_json expected, json
  end

  def test_object_basic
    expected = {"asd"=>"sdf"}
    json = "{\"asd\":\"sdf\"}"
    assert_json expected, json
  end

  def test_object_duplicated_key
    expected = {"a"=>"c"}
    json = "{\"a\":\"b\",\"a\":\"c\"}"
    assert_json expected, json
  end

  def test_object_duplicated_key_and_value
    expected = {"a"=>"b"}
    json = "{\"a\":\"b\",\"a\":\"b\"}"
    assert_json expected, json
  end

  def test_object_empty
    expected = {}
    json = "{}"
    assert_json expected, json
  end

  def test_object_empty_key
    expected = {""=>0}
    json = "{\"\":0}"
    assert_json expected, json
  end

  def test_object_escaped_null_in_key
    expected = {"foo\u0000bar"=>42}
    json = "{\"foo\\u0000bar\": 42}"
    assert_json expected, json
  end

  def test_object_extreme_numbers
    expected = {"min"=>-1.0e+28, "max"=>1.0e+28}
    json = "{ \"min\": -1.0e+28, \"max\": 1.0e+28 }"
    assert_json expected, json
  end

  def test_object_long_strings
    expected = {"x"=>[{"id"=>"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}], "id"=>"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}
    json = "{\"x\":[{\"id\": \"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\"}], \"id\": \"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\"}"
    assert_json expected, json
  end

  def test_object_simple
    expected = {"a"=>[]}
    json = "{\"a\":[]}"
    assert_json expected, json
  end

  def test_object_string_unicode
    expected = {"title"=>"Полтора Землекопа"}
    json = "{\"title\":\"\\u041f\\u043e\\u043b\\u0442\\u043e\\u0440\\u0430 \\u0417\\u0435\\u043c\\u043b\\u0435\\u043a\\u043e\\u043f\\u0430\" }"
    assert_json expected, json
  end

  def test_object_with_newlines
    expected = {"a"=>"b"}
    json = "{\n\"a\": \"b\"\n}"
    assert_json expected, json
  end

  def test_string_1_2_3_bytes_UTF_8_sequences
    expected = ["`Īካ"]
    json = "[\"\\u0060\\u012a\\u12AB\"]"
    assert_json expected, json
  end

  def test_string_accepted_surrogate_pair
    expected = ["𐐷"]
    json = "[\"\\uD801\\udc37\"]"
    assert_json expected, json
  end

  def test_string_accepted_surrogate_pairs
    expected = ["😹💍"]
    json = "[\"\\ud83d\\ude39\\ud83d\\udc8d\"]"
    assert_json expected, json
  end

  def test_string_allowed_escapes
    expected = ["\"\\/\b\f\n\r\t"]
    json = "[\"\\\"\\\\\\/\\b\\f\\n\\r\\t\"]"
    assert_json expected, json
  end

  def test_string_backslash_and_u_escaped_zero
    expected = ["\\u0000"]
    json = "[\"\\\\u0000\"]"
    assert_json expected, json
  end

  def test_string_backslash_doublequotes
    expected = ["\""]
    json = "[\"\\\"\"]"
    assert_json expected, json
  end

  def test_string_comments
    expected = ["a/*b*/c/*d//e"]
    json = "[\"a/*b*/c/*d//e\"]"
    assert_json expected, json
  end

  def test_string_double_escape_a
    expected = ["\\a"]
    json = "[\"\\\\a\"]"
    assert_json expected, json
  end

  def test_string_double_escape_n
    expected = ["\\n"]
    json = "[\"\\\\n\"]"
    assert_json expected, json
  end

  def test_string_escaped_control_character
    expected = ["\u0012"]
    json = "[\"\\u0012\"]"
    assert_json expected, json
  end

  def test_string_escaped_noncharacter
    expected = ["\uFFFF"]
    json = "[\"\\uFFFF\"]"
    assert_json expected, json
  end

  def test_string_in_array
    expected = ["asd"]
    json = "[\"asd\"]"
    assert_json expected, json
  end

  def test_string_in_array_with_leading_space
    expected = ["asd"]
    json = "[ \"asd\"]"
    assert_json expected, json
  end

  def test_string_last_surrogates_1_and_2
    expected = ["\u{10FFFF}"]
    json = "[\"\\uDBFF\\uDFFF\"]"
    assert_json expected, json
  end

  def test_string_nbsp_uescaped
    expected = ["new line"]
    json = "[\"new\\u00A0line\"]"
    assert_json expected, json
  end

  def test_string_nonCharacterInUTF_8_U_10FFFF
    expected = ["\u{10FFFF}"]
    json = "[\"\u{10FFFF}\"]"
    assert_json expected, json
  end

  def test_string_nonCharacterInUTF_8_U_FFFF
    expected = ["\uFFFF"]
    json = "[\"\uFFFF\"]"
    assert_json expected, json
  end

  def test_string_null_escape
    expected = ["\u0000"]
    json = "[\"\\u0000\"]"
    assert_json expected, json
  end

  def test_string_one_byte_utf_8
    expected = [","]
    json = "[\"\\u002c\"]"
    assert_json expected, json
  end

  def test_string_pi
    expected = ["π"]
    json = "[\"π\"]"
    assert_json expected, json
  end

  def test_string_reservedCharacterInUTF_8_U_1BFFF
    expected = ["\u{1BFFF}"]
    json = "[\"\u{1BFFF}\"]"
    assert_json expected, json
  end

  def test_string_simple_ascii
    expected = ["asd "]
    json = "[\"asd \"]"
    assert_json expected, json
  end

  def test_string_space
    expected = " "
    json = "\" \""
    assert_json expected, json
  end

  def test_string_surrogates_U_1D11E_MUSICAL_SYMBOL_G_CLEF
    expected = ["𝄞"]
    json = "[\"\\uD834\\uDd1e\"]"
    assert_json expected, json
  end

  def test_string_three_byte_utf_8
    expected = ["ࠡ"]
    json = "[\"\\u0821\"]"
    assert_json expected, json
  end

  def test_string_two_byte_utf_8
    expected = ["ģ"]
    json = "[\"\\u0123\"]"
    assert_json expected, json
  end

  def test_string_u_2028_line_sep
    expected = ["\u2028"]
    json = "[\"\u2028\"]"
    assert_json expected, json
  end

  def test_string_u_2029_par_sep
    expected = ["\u2029"]
    json = "[\"\u2029\"]"
    assert_json expected, json
  end

  def test_string_uEscape
    expected = ["aクリス"]
    json = "[\"\\u0061\\u30af\\u30EA\\u30b9\"]"
    assert_json expected, json
  end

  def test_string_uescaped_newline
    expected = ["new\nline"]
    json = "[\"new\\u000Aline\"]"
    assert_json expected, json
  end

  def test_string_unescaped_char_delete
    expected = ["\u007F"]
    json = "[\"\u007F\"]"
    assert_json expected, json
  end

  def test_string_unicode
    expected = ["ꙭ"]
    json = "[\"\\uA66D\"]"
    assert_json expected, json
  end

  def test_string_unicodeEscapedBackslash
    expected = ["\\"]
    json = "[\"\\u005C\"]"
    assert_json expected, json
  end

  def test_string_unicode_2
    expected = ["⍂㈴⍂"]
    json = "[\"⍂㈴⍂\"]"
    assert_json expected, json
  end

  def test_string_unicode_U_10FFFE_nonchar
    expected = ["\u{10FFFE}"]
    json = "[\"\\uDBFF\\uDFFE\"]"
    assert_json expected, json
  end

  def test_string_unicode_U_1FFFE_nonchar
    expected = ["\u{1FFFE}"]
    json = "[\"\\uD83F\\uDFFE\"]"
    assert_json expected, json
  end

  def test_string_unicode_U_200B_ZERO_WIDTH_SPACE
    expected = ["​"]
    json = "[\"\\u200B\"]"
    assert_json expected, json
  end

  def test_string_unicode_U_2064_invisible_plus
    expected = ["⁤"]
    json = "[\"\\u2064\"]"
    assert_json expected, json
  end

  def test_string_unicode_U_FDD0_nonchar
    expected = ["\uFDD0"]
    json = "[\"\\uFDD0\"]"
    assert_json expected, json
  end

  def test_string_unicode_U_FFFE_nonchar
    expected = ["\uFFFE"]
    json = "[\"\\uFFFE\"]"
    assert_json expected, json
  end

  def test_string_unicode_escaped_double_quote
    expected = ["\""]
    json = "[\"\\u0022\"]"
    assert_json expected, json
  end

  def test_string_utf8
    expected = ["€𝄞"]
    json = "[\"€𝄞\"]"
    assert_json expected, json
  end

  def test_string_with_del_character
    expected = ["a\u007Fa"]
    json = "[\"a\u007Fa\"]"
    assert_json expected, json
  end

  def test_structure_lonely_false
    expected = false
    json = "false"
    assert_json expected, json
  end

  def test_structure_lonely_int
    expected = 42
    json = "42"
    assert_json expected, json
  end

  def test_structure_lonely_negative_real
    expected = -0.1
    json = "-0.1"
    assert_json expected, json
  end

  def test_structure_lonely_null
    expected = nil
    json = "null"
    assert_json expected, json
  end

  def test_structure_lonely_string
    expected = "asd"
    json = "\"asd\""
    assert_json expected, json
  end

  def test_structure_lonely_true
    expected = true
    json = "true"
    assert_json expected, json
  end

  def test_structure_string_empty
    expected = ""
    json = "\"\""
    assert_json expected, json
  end

  def test_structure_trailing_newline
    expected = ["a"]
    json = "[\"a\"]\n"
    assert_json expected, json
  end

  def test_structure_true_in_array
    expected = [true]
    json = "[true]"
    assert_json expected, json
  end

  def test_structure_whitespace_array
    expected = []
    json = " [] "
    assert_json expected, json
  end

  def test_number_9223372036854775808_1
    expected = [-9223372036854775808]
    json = "[-9223372036854775808]\n"
    assert_json expected, json
  end

  def test_number_1_0
    expected = [1.0]
    json = "[1.0]\n"
    assert_json expected, json
  end

  def test_number_1_000000000000000005
    expected = [1.0]
    json = "[1.000000000000000005]\n"
    assert_json expected, json
  end

  def test_number_1000000000000000
    expected = [1000000000000000]
    json = "[1000000000000000]\n"
    assert_json expected, json
  end

  def test_number_10000000000000000999
    expected = [10000000000000000999]
    json = "[10000000000000000999]\n"
    assert_json expected, json
  end

  def test_number_1e_999
    expected = [0.0]
    json = "[1E-999]\n"
    assert_json expected, json
  end

  def test_number_1e6
    expected = [1000000.0]
    json = "[1E6]\n"
    assert_json expected, json
  end

  def test_number_9223372036854775807
    expected = [9223372036854775807]
    json = "[9223372036854775807]\n"
    assert_json expected, json
  end

  def test_number_9223372036854775808_2
    expected = [9223372036854775808]
    json = "[9223372036854775808]\n"
    assert_json expected, json
  end

  def test_object_key_nfc_nfd
    expected = {"é"=>"NFC", "é"=>"NFD"}
    json = "{\"é\":\"NFC\",\"é\":\"NFD\"}"
    assert_json expected, json
  end

  def test_object_key_nfd_nfc
    expected = {"é"=>"NFD", "é"=>"NFC"}
    json = "{\"é\":\"NFD\",\"é\":\"NFC\"}"
    assert_json expected, json
  end

  def test_object_same_key_different_values
    expected = {"a"=>2}
    json = "{\"a\":1,\"a\":2}"
    assert_json expected, json
  end

  def test_object_same_key_same_value
    expected = {"a"=>1}
    json = "{\"a\":1,\"a\":1}"
    assert_json expected, json
  end

  def test_object_same_key_unclear_values
    expected = {"a"=>0}
    json = "{\"a\":0, \"a\":-0}\n"
    assert_json expected, json
  end

  def test_string_1_invalid_codepoint
    expected = ["\xED\xA0\x80"]
    json = "[\"\xED\xA0\x80\"]"
    assert_json expected, json
  end

  def test_string_2_invalid_codepoints
    expected = ["\xED\xA0\x80\xED\xA0\x80"]
    json = "[\"\xED\xA0\x80\xED\xA0\x80\"]"
    assert_json expected, json
  end

  def test_string_3_invalid_codepoints
    expected = ["\xED\xA0\x80\xED\xA0\x80\xED\xA0\x80"]
    json = "[\"\xED\xA0\x80\xED\xA0\x80\xED\xA0\x80\"]"
    assert_json expected, json
  end

  def test_string_with_escaped_NULL
    expected = ["A\u0000B"]
    json = "[\"A\\u0000B\"]"
    assert_json expected, json
  end

  private

  def assert_json(expected, json)
    actual = RapidJSON.parse(json)
    if expected.nil?
      assert_nil actual
    else
      assert_equal expected, actual
    end
  end
end
