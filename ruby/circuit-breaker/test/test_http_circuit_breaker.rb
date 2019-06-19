require_relative '../lib/http_circuit_breaker'
require 'test/unit'

class TestHTTPCircuitBreaker < Test::Unit::TestCase
  def setup
    @service_uri_string = 'https://github.com'
    @timeout_uri_string = 'http://localhost:8000'
  end

  def test_default_options
    instance = HTTPCircuitBreaker.new(@service_uri_string)
    assert_equal(instance.options[:failure_threshold], 5)
    assert_equal(instance.options[:failure_timeout], 5)
  end

  def test_get
    instance = HTTPCircuitBreaker.new(@service_uri_string)
    assert_kind_of(Net::HTTPResponse, instance.get('/'))
  end

  def test_raises_timeout_error
    instance = HTTPCircuitBreaker.new(@timeout_uri_string, timeout: 0.5)
    assert_raise(HTTPServiceAdapter::TimeoutError) do
      instance.get('/timeout?s=1')
    end
  end

  def test_raises_open_error
    instance = HTTPCircuitBreaker.new(@timeout_uri_string, timeout: 0.5, failure_threshold: 1)
    assert_raise(HTTPServiceAdapter::TimeoutError) do
      instance.get('/timeout?s=1')
    end
    assert_raise(HTTPCircuitBreaker::OpenError) do
      instance.get('/timeout?s=1')
    end
  end

  def test_resets_after_failure_timeout
    instance = HTTPCircuitBreaker.new(@timeout_uri_string, timeout: 0.5, failure_threshold: 1, failure_timeout: 1)
    assert_raise(HTTPServiceAdapter::TimeoutError) do
      instance.get('/timeout?s=1')
    end
    assert_raise(HTTPCircuitBreaker::OpenError) do
      instance.get('/timeout?s=1')
    end
    sleep(2)
    assert_kind_of(Net::HTTPResponse, instance.get('/timeout?s=0'))
  end

  def test_stays_open_after_another_failure
    instance = HTTPCircuitBreaker.new(@timeout_uri_string, timeout: 0.5, failure_threshold: 1, failure_timeout: 2)
    assert_raise(HTTPServiceAdapter::TimeoutError) do
      instance.get('/timeout?s=1')
    end
    assert_raise(HTTPCircuitBreaker::OpenError) do
      instance.get('/timeout?s=1')
    end
    sleep(1)
    assert_raise(HTTPCircuitBreaker::OpenError) do
      instance.get('/timeout?s=0')
    end

    def test_records_failure_count
      instance = HTTPCircuitBreaker.new(@timeout_uri_string, timeout: 0.5, failure_threshold: 1, failure_timeout: 2)
      assert_raise(HTTPServiceAdapter::TimeoutError) do
        instance.get('/timeout?s=1')
      end
      assert_equal(instance.failure_count, 1)
    end

    def test_records_last_failure_time
      instance = HTTPCircuitBreaker.new(@timeout_uri_string, timeout: 0.5, failure_threshold: 1, failure_timeout: 2)
      assert_raise(HTTPServiceAdapter::TimeoutError) do
        instance.get('/timeout?s=1')
      end
      assert_kindn_of(Time, instance.last_failure_time)
    end
  end
end
