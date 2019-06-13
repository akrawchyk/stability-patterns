require_relative '../../use-timeouts/lib/http_service_adapter.rb'

class HTTPCircuitBreaker < HTTPServiceAdapter
  OPTION_DEFAULTS = {
    failure_threshold: 5,
    failure_timeout: 5
  }.freeze

  def initialize(uri_string, options = {})
    super(uri_string, OPTION_DEFAULTS.merge(options))
    @failure_count = 0
    @last_failure_time = nil
  end

  private

  def request(*args)
    with_breaker do
      response = super
      reset
      response
    rescue HTTPServiceAdapter::TimeoutError
      record_failure
      raise
    end
  end

  def with_breaker
    case state
    when :closed, :half_open
      yield
    when :open
      raise HTTPCircuitBreaker::OpenError
    else
      raise "Unexpected state: #{state}"
    end
  end

  def state
    if try_request_after_cooldown?
      :half_open
    elsif tripped_by_threshold?
      :open
    else
      :closed
    end
  end

  def tripped_by_threshold?
    @failure_count >= options[:failure_threshold]
  end

  def failure_cooldown_done?
    (Time.now - @last_failure_time) > options[:failure_timeout]
  end

  def try_request_after_cooldown?
    tripped_by_threshold? && failure_cooldown_done?
  end

  def record_failure
    @failure_count += 1
    @last_failure_time = Time.now
  end

  def reset
    @failure_count = 0
  end

  class HTTPCircuitBreaker::OpenError < StandardError; end

  class HTTPCircuitBreaker::TimeoutError < StandardError; end
end
