# HttpClient

Thin wrapper around Faraday. It joins a base URL with a path, returns one response object, and raises its own errors for timeouts, connection failures, and unexpected statuses.

## Requirements

Ruby 3.3 or newer. The test matrix is Ruby 3.3, 3.4, and 4.0.

Faraday 2.14.3 or newer, below 3.

## Installation

Add the gem to the application's Gemfile:

```ruby
gem 'http_client', git: 'https://github.com/WebgateSystems/http-client.git'
```

Then run `bundle install`.

## Configuration

```ruby
require 'http_client'

client = WS::HttpClient::Connection.new(
  'https://api.example.com',
  headers: { 'Accept' => 'application/json' },
  ssl: { verify: true, ca_file: '/path/to/ca.crt' }
)
```

`headers` are sent on every request from this client. `ssl.verify` and `ssl.ca_file` are passed through to Faraday.

When `Rails` is defined, logs go to `Rails.logger`. Otherwise they go to `$stderr`.

When `Settings` is defined, timeouts are read from `Settings.faraday[:timeout][:read]` and `Settings.faraday[:timeout][:open]`. Without `Settings`, the read timeout is 5 seconds and the open timeout is 7 seconds.

The request body is JSON unless the connection `Content-Type` header includes `urlencoded`. A JSON response (`content-type` containing `json`) is parsed into a `Hash`. An empty JSON body becomes `nil`.

## Usage

```ruby
response = client.get('/users', { active: true })
response.status  # 200
response.headers
response.body    # Hash when the response content type is JSON

client.post(
  '/payments',
  { amount: 10 },
  { 'Authorization' => 'Bearer token' },
  expected_statuses: 201,
  timeout_read: 5,
  timeout_open: 2
)
```

The public methods are `get`, `head`, `delete`, `trace`, `options`, `post`, `put`, `patch`, and `connect`.

| Argument | Role |
| --- | --- |
| endpoint | Path joined onto the base URL |
| second argument | Query for `get`, `head`, `delete`, and `trace`. Body for `post`, `put`, `patch`, and `options` |
| headers | Headers for this request |
| options | `expected_statuses`, `timeout_read`, `timeout_open` |

An endpoint has to be a path. `https://…` and `//…` are rejected, so a caller cannot replace the configured base. A trailing slash on the base and a leading slash on the endpoint collapse into one slash. A query string already present on the base URL is kept. Request parameters are not concatenated into the URL by hand; Faraday sends them.

`expected_statuses` accepts an integer, an array, or a range. When it is omitted, any status the server returns is accepted, including 4xx and 5xx. Those statuses are not connection failures.

`timeout_read` and `timeout_open` override the configured timeouts for one request.

`connect` is declared for callers that already use it. Faraday 2 does not implement the CONNECT method, so calling it raises `NoMethodError`.

Request and response traces are debug logs from one Faraday logger. They stay hidden unless the logger level is debug. Without Rails, set `VERBOSE=1` to turn that level on. Bodies are not logged. `Authorization` and `Proxy-Authorization` values are replaced with `[FILTERED]`, as are `password`, `token`, and `api_key` query parameters. An unexpected status is still logged at error level.

## Errors

```ruby
begin
  client.get('/users/1', {}, {}, expected_statuses: 200)
rescue WS::HttpClient::TimeoutError => error
  error.cause # Faraday::TimeoutError
rescue WS::HttpClient::ConnectionError => error
  error.cause # Faraday::ConnectionFailed
rescue WS::HttpClient::UnexpectedStatusError => error
  error.status
  error.response.body
end
```

`TimeoutError` and `ConnectionError` are `RequestError`s. Faraday reports a read timeout as `Faraday::TimeoutError` and an open timeout (`Net::OpenTimeout`) as `Faraday::ConnectionFailed`, and those two classes are mapped as above.

`UnexpectedStatusError` is not a `RequestError`. The server answered, and the status was outside `expected_statuses`. The exception message is `Unexpected HTTP status: <status>` and does not include the body.

## Development

From a checkout of this repository:

```bash
bundle install
bundle exec rake
```

`rake` runs RSpec and RuboCop. The specs require 100% line coverage. These are the same checks the pipelines run:

```bash
bundle exec rubocop
bundle exec fasterer
bundle exec bundler-audit check --update
bundle exec brakeman --force-scan --quiet --no-pager --exit-on-warn --exit-on-error
bundle exec rspec
```

Fasterer reads `.fasterer.yml` and skips vendored gems, coverage, logs, tmp, and pkg.

## Continuous integration

A green pipeline has no build stage and no deploy stage. It means RuboCop, Fasterer, bundler-audit, Brakeman, and RSpec all passed. RSpec runs on Ruby 3.3, 3.4, and 4.0.6. The other jobs run on Ruby 4.0.6.

| Host | Workflow |
| --- | --- |
| GitHub | [`.github/workflows/ci.yml`](.github/workflows/ci.yml), on every push and pull request |
| GitLab | [`.gitlab-ci.yml`](.gitlab-ci.yml), on merge requests and on branch pipelines that do not already have an open merge request |

Both installs use Bundler 2.4.10 and a frozen `Gemfile.lock`.

## License

Released under the MIT license. See [LICENSE](LICENSE).
