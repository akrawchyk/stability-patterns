require 'net/http'

class ServiceAdapter
  DEFAULT_TIMEOUT = 5

  def initialize(uri_string)
    @uri = URI(uri_string)
    @http = Net::HTTP.new(@uri.host, @uri.port)
    configure
  end

  def configure(max_retries: 0, all_timeout: DEFAULT_TIMEOUT)
    @http.finish if @http.started?

    @http.max_retries = max_retries
    @http.open_timeout = all_timeout
    @http.read_timeout = all_timeout
    @http.write_timeout = all_timeout
    @http.use_ssl = true if @uri.scheme == 'https'

    @http.start
  rescue Net::OpenTimeout
    raise "Connection timeout: #{@uri} unreachable"
  end

  def get(path)
    request(Net::HTTP::Get.new(path))
  end

  private
  
  def request(request_obj)
    @http.request(request_obj)
  rescue Net::ReadTimeout
    raise "Timed out: #{@uri}#{request_obj.path} unreachable"
  rescue Net::WriteTimeout
    raise "Timed out: #{@uri}#{request_obj.path} broken pipe"
  end
end
