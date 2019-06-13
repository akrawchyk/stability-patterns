.PHONY: ruby

ruby:
	find ./ruby -name '*.rb' -path '*/test/*' -print0 | xargs -0 -n1 ruby
