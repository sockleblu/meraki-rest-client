# frozen_string_literal: true

require 'webmock/rspec'
require 'rspec'
require_relative '../../lib/meraki_provisions'

describe MerakiProvisions do
    before :all do
        @meraki = MerakiProvisions.new
        @device = File.read("#{File.dirname(__FILE__)}/../support/fixtures/device.json")
        @devices = File.read("#{File.dirname(__FILE__)}/../support/fixtures/devices.json")
    end

# Maybe think about the http verbs and their uses in this method?

=begin
  describe '::callMeraki' do
    context 'when call is successfull' do
      it 'responds with 200 ' do
        response = double
        response.stub(:code) { 200 }

        allow(@meraki).to receive(:call_meraki).and_return( response )

        rep = @meraki.call_meraki

        expect(rep.code).to eq 200
      end
    end

    context 'when account password has expired' do
      it 'raises ForbiddenError exception' do
        response = double
        response.stub(:code) { 403 }
        allow(@meraki.call_meraki).to receive(:call_meraki).and_return( response )

        #        expect { @meraki.call_meraki() }.to raise_exception(ForbiddenError)
        expect(@meraki).to receive(:call_meraki).and_return(ForbiddenError)

      end
    end
  end
=end
end
