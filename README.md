# Rails pragmatic logger

Minimalist JSON logger, heavily inspired from lograge and with source code
extractions from rails_semantic_logger.

* Rounds request times to miliseconds.

## Features

[X] Logs Rails ActionController, ActiveRecord & ActionView notifications.

[X] Rails.logger always generate JSON (via custom formatter).

[ ] Log exceptions with complete backtrace and nested cause exceptions.

[ ] Turn on SQL logging statically or dinamically (protected configuration / request param).

[ ] Log all rack requests (ActiveStorage controllers for example).

[ ] Configure request UUID and enable general logging (custom, SQL) tracing.

[ ] Configure Rails logs hooks individually instead of by log level.

[ ] Easily turn on / off additional information.

[ ] Configure threshold value to log SQL Query.

## Log request example

```
{
  "time":"2021-01-30T04:26:40.662Z",
  "type":"INFO",
  "controller":"AppController",
  "action":"index",
  "format":"html",
  "method":"GET",
  "path":"/",
  "status":200,
  "ip":"::1",
  "allocations":5074,
  "view":19,
  "db":0
  "total":20
}
```
