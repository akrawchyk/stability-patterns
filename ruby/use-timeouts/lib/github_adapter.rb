require 'json'
require_relative './service_adapter'

class GithubAdapter < ServiceAdapter
  def initialize(options)
    super('https://api.github.com', options)
  end

  def repositories
    body = get('/repositories').read_body
    JSON.parse(body)
  rescue TimeoutError => e
    puts e.message
    []
  end
end
