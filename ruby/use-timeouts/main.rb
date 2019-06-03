require './lib/service_adapter'

class GithubAdapter < ServiceAdapter
  # TODO json mixin

  def initialize
    super('https://api.github.com')
  end

  def repositories
    get('/repositories')
  end
end
