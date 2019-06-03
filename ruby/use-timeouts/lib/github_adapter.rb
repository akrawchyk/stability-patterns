require 'json'
require_relative './service_adapter'

class GithubAdapter < ServiceAdapter
  def initialize
    super('https://api.github.com')
  end

  def repositories
    JSON.parse(get('/repositories').read_body)
  rescue
    []
  end
end
