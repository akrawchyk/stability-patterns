require 'pry'
require 'json'
require_relative '../use-timeouts/lib/http_service_adapter.rb'

class HTTPCircuitBreaker < HTTPServiceAdapter
  OPTION_DEFAULTS = {
    failure_threshold: 5,
    failure_timeout: 5
  }.freeze

  def initialize(uri_string, options = {})
    @options = OPTION_DEFAULTS.merge(options)
    super(uri_string, @options)
    @failure_count = 0
    @last_failure_time = nil
  end

  def request(*args)
    case state
    when :closed, :half_open
      begin
        response = super
        reset
        response
      rescue HTTPServiceAdapter::TimeoutError # TODO: handle Errno::ECONNREFUSED
        @failure_count += 1
        @last_failure_time = Time.now
      end
    when :open
      raise 'CircuitBreaker::Open'
    else raise "Unexpected state: #{state}"
    end
  end

  def state
    case
    when (@failure_count >= @options[:failure_threshold]) && (Time.now - @last_failure_time) > @options[:failure_timeout]
      :half_open
    when (@failure_count >= @options[:failure_threshold])
      :open
    else
      :closed
    end
  end

  def reset
    @failure_count = 0
  end
end

if $PROGRAM_NAME == __FILE__
  require 'pry'
  configured_timeout = ARGV[0].to_f
  configured_failure_threshold = ARGV[1].to_i

  options = {}
  options[:timeout] = configured_timeout if configured_timeout.positive?
  options[:failure_threshold] = configured_failure_threshold if configured_failure_threshold.positive?
  repos_service = HTTPCircuitBreaker.new('https://api.github.com/repositories', options)

  binding.pry

  res = repos_service.get
  repos_json = JSON.parse(res.read_body)
  repo_names = repos_json.map { |repo| repo['name'] }

  puts(repo_names)
end
