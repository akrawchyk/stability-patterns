require 'net/http'

class HTTPServiceAdapter
  OPTION_DEFAULTS = {
    max_retries: 0,
    timeout: 5
  }.freeze

  attr_reader :uri, :options

  def initialize(uri_string, options = {})
    @uri = URI(uri_string)
    @options = OPTION_DEFAULTS.merge(options)
    @http = connection 
    configure
  end

  def configure(updated_options = {})
    @http.finish if @http.started?
    @options.merge!(updated_options)
    @http = connection
    start
  end

  def get(path = '/')
    request(Net::HTTP::Get.new(path))
  end

  private

  def connection
    http = Net::HTTP.new(uri.host, uri.port)
    http.max_retries = options[:max_retries]
    http.open_timeout = options[:timeout]
    http.read_timeout = options[:timeout]
    http.write_timeout = options[:timeout]
    http.use_ssl = true if ssl?
    http
  end

  def ssl?
    uri.scheme == 'https' || uri.port == 443
  end

  def start
    @http.start
  rescue Net::OpenTimeout
    raise TimeoutError, "Unable to connect to #{uri} #{timeout_outro_msg}"
  end

  def request(request_obj)
    @http.request(request_obj)
  rescue Net::ReadTimeout
    raise TimeoutError, "#{uri}#{request_obj.path} unreachable #{timeout_outro_msg}"
  rescue Net::WriteTimeout
    raise TimeoutError, "#{uri}#{request_obj.path} #{timeout_outro_msg}"
  end

  def timeout_outro_msg
    "after #{options[:timeout]} seconds"
  end

  class TimeoutError < StandardError; end
end
