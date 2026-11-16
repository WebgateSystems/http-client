# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WS::HttpClient::Connection do
  let(:base_url) { 'http://localhost' }
  let(:endpoint) { '/test-endpoint' }
  let(:request_url) { 'http://localhost/test-endpoint' }
  let(:call) { described_class.new(base_url).get(endpoint) }

  describe 'transport failures' do
    it 'raises TimeoutError and keeps the Faraday error as the cause' do
      # Faraday reports Net::OpenTimeout (WebMock's to_timeout) as ConnectionFailed.
      # A read timeout arrives as Timeout::Error and becomes Faraday::TimeoutError.
      stub_request(:get, request_url).to_raise(Timeout::Error.new('execution expired'))

      expect { call }.to raise_error(WS::HttpClient::TimeoutError) { |error|
        expect(error.cause).to be_a(Faraday::TimeoutError)
      }
    end

    it 'raises ConnectionError and keeps the Faraday error as the cause' do
      stub_request(:get, request_url).to_raise(Errno::ECONNREFUSED)

      expect { call }.to raise_error(WS::HttpClient::ConnectionError) { |error|
        expect(error.cause).to be_a(Faraday::ConnectionFailed)
      }
    end
  end

  describe 'unexpected status' do
    let(:body) { { 'rb_key' => 'rb_value' } }

    before do
      stub_request(:get, request_url).to_return(
        status: 422,
        headers: { 'content-type' => 'application/json' },
        body: body.to_json
      )
    end

    it 'exposes the status and the response without treating it as a transport error' do
      expect { described_class.new(base_url).get(endpoint, {}, {}, expected_statuses: 200) }
        .to raise_error(WS::HttpClient::UnexpectedStatusError) { |error|
          expect(error).not_to be_a(WS::HttpClient::RequestError)
          expect(error.status).to eq(422)
          expect(error.response).to be_a(WS::HttpClient::Response)
          expect(error.response.body).to eq(body)
          expect(error.message).to eq('Unexpected HTTP status: 422')
        }
    end

    it 'accepts a 4xx status when it is expected' do
      response = described_class.new(base_url).get(endpoint, {}, {}, expected_statuses: 422)

      expect(response.status).to eq(422)
    end

    it 'does not raise when no expected status was given' do
      expect { call }.not_to raise_error
    end
  end

  describe 'empty response' do
    it 'returns a response with an empty JSON body' do
      stub_request(:get, request_url).to_return(
        status: 204,
        headers: { 'content-type' => 'application/json' },
        body: ''
      )

      response = call

      expect(response.status).to eq(204)
      expect(response.body).to be_nil
    end
  end
end
