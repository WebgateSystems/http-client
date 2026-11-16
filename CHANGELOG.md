## [Unreleased]

- Log request and response traces at debug. Without Rails, `VERBOSE=1` turns them on.
- Load RuboCop Rake and RSpec cops.
- Parse line coverage from the GitLab RSpec log so the coverage badge can show a percentage.

## [2.0.0] - 2026-11-16

- Require Ruby 3.3 or newer. The locked prism build installs only on 3.3 and above, so the test matrix is 3.3, 3.4, and 4.0.
- Require Faraday 2.14.3 or newer, below 3.
- Run RuboCop, Fasterer, bundler-audit, Brakeman, and RSpec on GitLab and GitHub. The pipelines have no build stage and no deploy stage.
- Join the base URL and the endpoint without dropping or doubling slashes. An absolute endpoint is rejected.
- Use the configured open timeout for `open_timeout`. The default read timeout stays 5 seconds and the default open timeout stays 7 seconds.
- Log each request once, without bodies, and redact `Authorization` header values.
- Load on Ruby 4.0 without libraries that Ruby 4 removed from the default set.
- Raise `TimeoutError` and `ConnectionError` instead of Faraday transport errors. The original Faraday error stays available as `cause`.
- `UnexpectedStatusError` carries the status and the response. An HTTP 4xx or 5xx answer is not a transport error.

## [1.0.0] - 2021-04-22

- Initial release.
