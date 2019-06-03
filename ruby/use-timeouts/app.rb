require 'net/http'

class ServiceAdapter
  # FIXME: use a URI so we can pull https host and port?
  # see https://docs.ruby-lang.org/en/2.0.0/Net/HTTP.html#class-Net::HTTP-label-HTTPS
  def initialize(host, port = 80)
    @http = Net::HTTP.new(host, port)
    configure
  end

  def configure(max_retries: 0, timeout: 5)
    @http.finish unless @http.started?

    @http.max_retries = max_retries
    @http.open_timeout = timeout
    @http.read_timeout = timeout
    @http.write_timeout = timeout

    # TODO: handle Net::OpenTimeout
    @http.start
  end

  def get(path)
    @http.request_get(path)
  end
end
