require 'json'
require_relative './http_circuit_breaker'

class GithubAdapter < HTTPCircuitBreaker
  def initialize(options)
    super('https://api.github.com', options)
  end

  def repositories
    begin
      res = repos_service.get('/repositories')
      repos_json = JSON.parse(res.read_body)
      repos_json.map { |repo| repo['name'] }
    rescue HTTPServiceAdapter::TimeoutError => error
      puts error.message
      []
    rescue HTTPCircuitBreaker::BreakerOpenError => error
      puts error.message
    end
  end
end
