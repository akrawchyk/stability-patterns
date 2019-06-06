require 'json'
require_relative './lib/http_circuit_breaker'

if $PROGRAM_NAME == __FILE__
  require 'pry'

  configured_timeout = ARGV[0].to_f
  configured_failure_threshold = ARGV[1].to_i

  options = {}
  options[:timeout] = configured_timeout if configured_timeout.positive?
  options[:failure_threshold] = configured_failure_threshold if configured_failure_threshold.positive?
  repos_service = HTTPCircuitBreaker.new('https://api.github.com', options)

  repo_names = begin
                 res = repos_service.get('/repositories')
                 repos_json = JSON.parse(res.read_body)
                 repos_json.map { |repo| repo['name'] }
               rescue HTTPCircuitBreaker::TimeoutError
                 []
               end

  puts(repo_names)
end
