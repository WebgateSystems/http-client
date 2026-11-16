# frozen_string_literal: true

require 'spec_helper'
require_relative '../shared_examples/connection_examples'

RSpec.describe WS::HttpClient::Connection do
  let(:base_url) { 'http://localhost/' }
  let(:endpoint) { '/test-endpoint' }
  let(:request_url) { 'http://localhost/test-endpoint' }

  let(:request_headers) { { 'x-request-headers' => 'example_value' } }
  let(:request_options) { {} }
  let(:request_body) { { rb_key: 'rb_value' } }

  describe '#initialize' do
    let(:http_verb) { :get }

    before { stub_request(:any, /^.*$/) }

    context 'with connection_options' do
      let(:headers) { { some_header_key: 'some_header_value' } }
      let(:ssl_verify) { true }
      let(:ssl_ca_file) { '/path_to_specific/ca.crt' }
      let(:faraday_options) do
        {
          headers: headers,
          ssl: {
            verify: ssl_verify,
            ca_file: ssl_ca_file
          }
        }
      end

      let(:call) do
        described_class
          .new(base_url, faraday_options)
          .send(http_verb, endpoint, request_body, request_headers, request_options)
      end

      it 'passes the correct options to the Faraday initializer' do
        allow(Faraday).to receive(:new).and_call_original

        described_class.new(base_url, faraday_options)

        expect(Faraday).to have_received(:new).with(faraday_options)
      end
    end
  end

  context 'without connection options' do
    let(:call) do
      described_class
        .new(base_url)
        .send(http_verb, endpoint, request_body, request_headers, request_options)
    end

    let(:request_query) { request_body.to_query }

    let(:response_headers) { { 'content-type' => 'application/json' } }
    let(:response_body) { { 'rb_key' => 'rb_value' } }
    let(:response_status_code) { 200 }

    context 'with a query' do
      before do
        stub_request(http_verb, "#{request_url}?#{request_query}")
          .with(headers: request_headers)
          .to_return(
            status: response_status_code, headers: response_headers, body: response_body.to_json
          )
      end

      describe '#get' do
        it_behaves_like 'connection', :get
      end

      describe '#head' do
        it_behaves_like 'connection', :head
      end

      describe '#delete' do
        it_behaves_like 'connection', :delete
      end

      describe '#trace' do
        it_behaves_like 'connection', :trace
      end
    end

    context 'with a body' do
      before do
        stub_request(http_verb, request_url)
          .with(body: request_body, headers: request_headers)
          .to_return(
            status: response_status_code, headers: response_headers, body: response_body.to_json
          )
      end

      describe '#options' do
        it_behaves_like 'connection', :options
      end

      describe '#patch' do
        it_behaves_like 'connection', :patch
      end

      describe '#post' do
        it_behaves_like 'connection', :post
      end

      describe '#put' do
        it_behaves_like 'connection', :put
      end

      describe 'Per-request options' do
        let(:http_verb) { :post }
        let(:response_status_code) { 422 }

        context 'without per-request timeouts' do
          it 'uses the read timeout for timeout and the open timeout for open_timeout' do
            expect_any_instance_of(Faraday::RequestOptions).to receive(:timeout=).with(5).and_call_original
            expect_any_instance_of(Faraday::RequestOptions).to receive(:open_timeout=).with(7).and_call_original
            call
          end
        end

        context 'with timeout_open' do
          let(:timeout_open) { 5 }
          let(:request_options) { { timeout_open: timeout_open } }

          it 'assigns option open_timeout' do
            expect_any_instance_of(Faraday::RequestOptions)
              .to receive(:open_timeout=).with(timeout_open)
            call
          end
        end

        context 'with timeout_read' do
          let(:timeout_read) { 5 }
          let(:request_options) { { timeout_read: timeout_read } }

          it 'assigns option timeout' do
            expect_any_instance_of(Faraday::RequestOptions)
              .to receive(:timeout=).with(timeout_read)
            call
          end
        end

        context 'when the received status is not expected' do
          let(:request_options) { { expected_statuses: 202 } }

          it('raises') { expect { call }.to raise_error(WS::HttpClient::UnexpectedStatusError) }
        end

        context 'when the status is expected or no status was given' do
          context 'with an integer expected status' do
            let(:request_options) { { expected_statuses: 422 } }

            it('does not raise') { expect { call }.not_to raise_error }
          end

          context 'with an array of expected statuses' do
            let(:request_options) { { expected_statuses: [422] } }

            it('does not raise') { expect { call }.not_to raise_error }
          end

          context 'with a range of expected statuses' do
            let(:request_options) { { expected_statuses: [421..424] } }

            it('does not raise') { expect { call }.not_to raise_error }
          end

          context 'without an expected status' do
            let(:request_options) { {} }

            it('does not raise') { expect { call }.not_to raise_error }
          end
        end
      end
    end
  end

  describe 'URL joining' do
    def joined_url(base, endpoint)
      described_class.new(base).send(:build_url, endpoint)
    end

    it 'keeps a single slash when the base ends with / and the endpoint starts with /' do
      expect(joined_url('http://localhost/', '/test-endpoint')).to eq('http://localhost/test-endpoint')
    end

    it 'inserts a slash when neither side has one' do
      expect(joined_url('http://localhost/api', 'v1/users')).to eq('http://localhost/api/v1/users')
    end

    it 'drops a trailing base slash and a leading endpoint slash' do
      expect(joined_url('http://localhost/api/', '/v1/users')).to eq('http://localhost/api/v1/users')
    end

    it 'keeps the query string that belongs to the base URL' do
      expect(joined_url('http://localhost/api?x=1', 'users')).to eq('http://localhost/api/users?x=1')
    end

    it 'rejects an absolute endpoint' do
      expect { joined_url('http://localhost', 'https://evil.test/x') }
        .to raise_error(ArgumentError, 'Absolute URL not allowed')
    end

    it 'rejects a protocol-relative endpoint' do
      expect { joined_url('http://localhost', '//evil.test/x') }
        .to raise_error(ArgumentError, 'Absolute URL not allowed')
    end
  end

  describe 'logging' do
    let(:secret) { 'super-secret-password' }
    let(:token) { 'super-secret-token' }
    let(:request_headers) { { 'Authorization' => "Bearer #{token}" } }

    def post_with_secret
      described_class.new(base_url).post(endpoint, { password: secret }, request_headers)
    end

    it 'stays quiet unless VERBOSE is set' do
      original = ENV.fetch('VERBOSE') { nil }
      ENV.delete('VERBOSE')
      stub_request(:post, request_url).to_return(status: 200, body: '{}')

      expect { post_with_secret }.not_to output(/request:/).to_stderr
    ensure
      ENV['VERBOSE'] = original if original
    end

    context 'with VERBOSE set' do
      around do |example|
        original = ENV.fetch('VERBOSE') { nil }
        ENV['VERBOSE'] = '1'
        example.run
      ensure
        original.nil? ? ENV.delete('VERBOSE') : ENV['VERBOSE'] = original
      end

      it 'logs the request once and leaves secrets out of the log' do
        stub_request(:post, request_url).to_return(
          status: 200,
          headers: { 'content-type' => 'application/json' },
          body: { password: secret }.to_json
        )

        expect { post_with_secret }.to output(satisfy { |text|
          text.scan(request_url).size == 1 &&
            text.include?('[FILTERED]') &&
            text.exclude?(secret) &&
            text.exclude?(token)
        }).to_stderr
      end
    end
  end
end
