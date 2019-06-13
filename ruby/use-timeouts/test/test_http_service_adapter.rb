require_relative '../lib/http_service_adapter'
require 'test/unit'

class TestHTTPServiceAdapter < Test::Unit::TestCase
  def setup
    @service_uri_string = 'https://github.com'
    @timeout_uri_string = 'http://localhost:8000'
  end

  def test_default_options
    instance = HTTPServiceAdapter.new(@service_uri_string)
    assert_equal(instance.options[:max_retries], 0)
    assert_equal(instance.options[:timeout], 5)
  end

  def test_options
    instance = HTTPServiceAdapter.new(@service_uri_string, max_retries: 2, timeout: 2)
    assert_equal(instance.options[:max_retries], 2)
    assert_equal(instance.options[:timeout], 2)
  end

  def test_get
    instance = HTTPServiceAdapter.new(@service_uri_string)
    assert_kind_of(Net::HTTPResponse, instance.get('/'))
  end

  def test_configure
    instance = HTTPServiceAdapter.new(@service_uri_string)
    instance.configure(max_retries: 2, timeout: 2)
    assert_equal(instance.options[:max_retries], 2)
    assert_equal(instance.options[:timeout], 2)
  end

  def test_raises_for_net_open_timeout_error
    assert_raise(HTTPServiceAdapter::TimeoutError) do
      HTTPServiceAdapter.new(@service_uri_string, timeout: 0.01)
    end
  end

  def test_raises_for_net_read_timeout_error
    instance = HTTPServiceAdapter.new(@timeout_uri_string, timeout: 0.5)
    assert_raise(HTTPServiceAdapter::TimeoutError) { instance.get('/timeout?s=1') }
  end

  # TODO somehow recreate the conditions for this error
  def test_raises_for_net_write_timeout_error
    pend
  end
end
