# frozen_string_literal: true

require 'spec_helper'
require_relative '../shared_examples/connection_examples'

RSpec.describe WS::HttpClient::Connection do
  let(:base_url) { 'http://localhost/' }
  let(:endpoint) { '/test-endpoint' }

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
        expect(Faraday).to receive(:new).with(faraday_options)

        described_class.new(base_url, faraday_options)
      end
    end
  end

  context 'no connection_options given' do
    let(:call) do
      described_class
        .new(base_url)
        .send(http_verb, endpoint, request_body, request_headers, request_options)
    end

    let(:request_query) { request_body.to_query }

    let(:response_headers) { { 'content-type' => 'application/json' } }
    let(:response_body) { { 'rb_key' => 'rb_value' } }
    let(:response_status_code) { 200 }

    context 'HTTP verbs with a query' do
      before do
        stub_request(http_verb, "#{base_url}#{endpoint}?#{request_query}")
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
    end

    context 'HTTP methods with a body' do
      before do
        stub_request(http_verb, "#{base_url}#{endpoint}")
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

        context 'option timeout_open' do
          let(:timeout_open) { 5 }
          let(:request_options) { { timeout_open: timeout_open } }
          it 'assigns option open_timeout' do
            expect_any_instance_of(Faraday::RequestOptions)
              .to receive(:open_timeout=).with(timeout_open)
            call
          end
        end

        context 'option timeout_read' do
          let(:timeout_read) { 5 }
          let(:request_options) { { timeout_read: timeout_read } }
          it 'assigns option timeout' do
            expect_any_instance_of(Faraday::RequestOptions)
              .to receive(:timeout=).with(timeout_read)
            call
          end
        end

        context 'option expected_statuses does not match received status code' do
          let(:request_options) { { expected_statuses: 202 } }
          it('raises') { expect { call }.to raise_error(WS::HttpClient::UnexpectedStatusError) }
        end

        context 'option expected_statuses not given, or does match received status code' do
          context 'expected status code given as integer' do
            let(:request_options) { { expected_statuses: 422 } }
            it('does not raise') { expect { call }.to_not raise_error }
          end

          context 'expected status code given as array' do
            let(:request_options) { { expected_statuses: [422] } }
            it('does not raise') { expect { call }.to_not raise_error }
          end

          context 'expected status code given as range' do
            let(:request_options) { { expected_statuses: [421..424] } }
            it('does not raise') { expect { call }.to_not raise_error }
          end

          context 'expected status code not given' do
            let(:request_options) { {} }
            it('does not raise') { expect { call }.to_not raise_error }
          end
        end
      end
    end
  end
end
