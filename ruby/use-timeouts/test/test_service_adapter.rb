require_relative '../lib/http_service_adapter'
require 'test/unit'

class TestHTTPServiceAdapter < Test::Unit::TestCase
  def setup
    @test_uri_string = 'https://github.com'
  end

  def test_default_options
    instance = HTTPServiceAdapter.new(@test_uri_string)
    default_options = instance.options
    assert_equal(instance.options[:max_retries], 0)
    assert_equal(instance.options[:timeout], 5)
  end

  def test_options
    instance = HTTPServiceAdapter.new(@test_uri_string, max_retries: 2, timeout: 2)
    assert_equal(instance.options[:max_retries], 2)
    assert_equal(instance.options[:timeout], 2)
  end

  def test_get
    instance = HTTPServiceAdapter.new(@test_uri_string)
    assert_kind_of(Net::HTTPResponse, instance.get('/'))
  end

  def test_configure
    instance = HTTPServiceAdapter.new(@test_uri_string)
    instance.configure(max_retries: 2, timeout: 2)
    assert_equal(instance.options[:max_retries], 2)
    assert_equal(instance.options[:timeout], 2)
  end

  def test_raises_for_net_open_timeout_error
    assert_raise(HTTPServiceAdapter::TimeoutError) do
      HTTPServiceAdapter.new(@test_uri_string, timeout: 0.01)
    end
  end

  def test_raises_for_net_read_timeout_error
    instance = HTTPServiceAdapter.new(@test_uri_string, timeout: 0.05)
    assert_raise(HTTPServiceAdapter::TimeoutError) { instance.get('/') }
  end

  # TODO somehow recreate the conditions for this error
  def test_raises_for_net_write_timeout_error
    pend
  end
end
