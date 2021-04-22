# frozen_string_literal: true

RSpec.shared_examples 'connection' do |verb|
  let(:http_verb) { verb }

  it 'correctly calls method on Faraday::Connection' do
    args = [base_url + endpoint, request_body, request_headers]

    if http_verb == :options
      faraday_method = 'run_request'
      args.unshift(:options)
    else
      faraday_method = http_verb
    end

    expect_any_instance_of(Faraday::Connection)
      .to receive(faraday_method).with(*args).and_return(Faraday::Response.new)
    call
  end

  it 'returns an instance of WS::HttpClient::Response' do
    expect(call).to be_kind_of(WS::HttpClient::Response)
  end

  it 'returns the correct response headers' do
    expect(call.headers).to eq(response_headers)
  end

  it 'returns the correct response status code' do
    expect(call.status).to eq(response_status_code)
  end

  it 'returns content-type: application/json as Hash' do
    expect(call.body).to be_kind_of(Hash)
  end

  it 'returns the correct response body' do
    expect(call.body).to eq(response_body)
  end
end
