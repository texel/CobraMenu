require 'test/unit'

#require 'ruby_file_to_test'

class SimpleTest < Test::Unit::TestCase
  def setup
    puts 'setup called'
  end
  
  def teardown
    puts 'teardown called'
  end
  
  def test_fail
    assert true, 'Assertion was false.'
  end
end