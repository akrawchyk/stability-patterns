require_relative './lib/github_adapter'

if __FILE__ == $0
  configured_timeout = ARGV[0].to_f

  github = GithubAdapter.new
  github.configure(all_timeout: configured_timeout) if configured_timeout > 0

  repos = github.repositories
  puts repos.map { |r| r['name'] }
end
