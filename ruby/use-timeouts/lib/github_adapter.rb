require 'json'
require_relative './http_service_adapter'

class GithubAdapter < HTTPServiceAdapter
  def initialize(options)
    super('https://api.github.com', options)
  end

  def repositories
    body = get('/repositories').read_body
    JSON.parse(body)
  rescue TimeoutError => error
    puts error.message
    []
  end
end
