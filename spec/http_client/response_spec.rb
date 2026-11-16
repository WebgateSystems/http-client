# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WS::HttpClient::Response do
  subject(:response) do
    described_class.new(
      body: { 'rb_key' => 'rb_value' },
      status: 200,
      headers: { 'content-type' => 'application/json' }
    )
  end

  it 'exposes the body' do
    expect(response.body).to eq('rb_key' => 'rb_value')
  end

  it 'exposes the status' do
    expect(response.status).to eq(200)
  end

  it 'exposes the headers' do
    expect(response.headers).to eq('content-type' => 'application/json')
  end
end
