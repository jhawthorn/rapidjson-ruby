# frozen_string_literal: true

require "test_helper"

class TestAllocations < Minitest::Test
  def test_integer
    assert_encode_allocations 1, [1, 2, 3, 4, 5]
  end

  def test_boolean
    assert_encode_allocations 1, [true, false, true, false, true, false]
  end

  def test_float
    # FIXME: ideally would not allocate
    assert_encode_allocations 6, [1.0, 2.0, 3.0, 4.0, 5.0]
  end

  def test_symbol
    assert_encode_allocations 1, %i[foo bar baz quux]
  end

  def test_string
    assert_encode_allocations 1, %w[foo bar baz quux]
  end

  def test_array
    assert_encode_allocations 1, [[], [], [], [], []]
  end

  def test_hash
    assert_encode_allocations 1, {foo: 1, bar: 2, baz: 3, quux: 4}
  end

  def assert_encode_allocations(expected, data)
    allocations = measure_allocations { RapidJSON.encode(data) }
    assert_equal expected, allocations
  end

  def measure_allocations
    i = 0
    while i < 2
      before = allocations
      yield
      after = allocations
      i += 1
    end
    after - before
  end

  def allocations
    GC.stat(:total_allocated_objects)
  end
end
