require_relative './lib/github_adapter'

if $PROGRAM_NAME == __FILE__
  configured_timeout = ARGV[0].to_f
  configured_failure_threshold = ARGV[1].to_i

  options = {}
  options[:timeout] = configured_timeout if configured_timeout.positive?
  options[:failure_threshold] = configured_failure_threshold if configured_failure_threshold.positive?
  github = GithubAdapter.new('https://api.github.com', options)

  repo_names = github.repositories.map { | repo| repo['name'] }

  puts(repo_names)
end
