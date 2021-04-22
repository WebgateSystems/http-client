# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WS::HttpClient::Response do
  %i(body headers status).each do |attr|
    it "has reader attribute #{attr}" do
      have_attr_reader attr
    end
  end
end
