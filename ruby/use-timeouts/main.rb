require_relative './lib/github_adapter'

if $PROGRAM_NAME == __FILE__
  configured_timeout = ARGV[0].to_f

  options = {}
  options[:timeout] = configured_timeout if configured_timeout.positive?
  github = GithubAdapter.new(options)

  repo_names = github.repositories.map { |repo| repo['name'] }

  puts(repo_names)
end
