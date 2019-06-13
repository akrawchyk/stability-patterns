# Stability Patterns

Example implementations of the stability patterns in _Release It!: Design and Deploy Production-Ready Software_ by Michael Nygard.

## Patterns

* Use Timeouts
* Circuit Breaker
* Bulkheads
* Steady State
* Fail Fast
* Handshaking
* Test Harness
* Decoupling Middleware

## Tests

Start the test server for simulating timeouts:

```
ruby ./test_server.rb 8000
```

Run the tests in another shell:

```
find . -name '*.rb' -path '*/test/*' -print0 | xargs -0 -n1 ruby 
```
