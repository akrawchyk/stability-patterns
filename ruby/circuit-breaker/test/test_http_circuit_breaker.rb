require_relative '../lib/http_circuit_breaker'
require 'test/unit'

class TestHTTPCircuitBreaker < Test::Unit::TestCase
  def setup
    @test_uri_string = 'https://github.com'
  end

  def test_default_options
    instance = HTTPCircuitBreaker.new(@test_uri_string)
    assert_equal(instance.options[:failure_threshold], 5)
    assert_equal(instance.options[:failure_timeout], 5)
  end

  def test_get
    instance = HTTPCircuitBreaker.new(@test_uri_string)
    assert_kind_of(Net::HTTPResponse, instance.get('/'))
  end
end
