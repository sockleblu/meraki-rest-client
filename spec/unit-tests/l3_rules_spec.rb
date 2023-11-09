# frozen_string_literal: true

require 'webmock/rspec'
require 'rspec'
require_relative '../../lib/meraki_provisions'

describe MerakiProvisions do
    fixtures = "#{File.dirname(__FILE__)}/../support/fixtures"

    before :all do
        @meraki = MerakiProvisions.new
        @l3_rules = File.read("#{fixtures}/l3_rules.json")
    end

    describe '#getL3Rules' do
        context 'when network id and ssid valid' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:get_l3_rules).and_return(response)

                rep = @meraki.get_l3_rules(network_id: :good_id,
                                           ssid: :good_ssid)

                expect(rep.code).to eq 200
            end

            it 'retrieves a valid json object of L3 rules' do
                response = double

                allow(response).to receive(:body).and_return(@l3_rules)
                allow(@meraki).to receive(:get_l3_rules).and_return(response)
                rep = @meraki.get_l3_rules(network_id: :good_id,
                                           ssid: :good_ssid)

                expect(@meraki.valid_json?(@l3_rules)).to eq true
                expect(rep.body).to eq @l3_rules
            end
        end

        context 'when network id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:get_l3_rules).and_return(response)

                rep = @meraki.get_l3_rules(network_id: :bad_id,
                                           ssid: :ssid)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without providing network id' do
            it 'responds with ArgumentError' do
                expect { @meraki.get_l3_rules }.to raise_exception(ArgumentError)
            end
        end

        context 'when called without providing ssid' do
            it 'responds with ArgumentError' do
                expect { @meraki.get_l3_rules(networ_id: :good_id) }.to raise_exception(ArgumentError)
            end
        end

        context 'when called with proper network id and ssid' do
            it 'does not respond with ArgumentError' do
                allow(@meraki).to receive(:get_l3_rules).and_return(@l3_rules)
                expect do
                    @meraki.get_l3_rules(network_id: :id,
                                         ssid: :ssid)
                end.to_not raise_exception
            end
        end
    end

    describe '#updateL3Rules' do
        context 'when network id, ssid, and json valid' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:update_l3_rules).and_return(response)

                rep = @meraki.update_l3_rules(network_id: :good_id,
                                              ssid: :good_id,
                                              json: :good_json)

                expect(rep.code).to eq 200
            end

            it 'returns a valid json object of updated rules set' do
                response = double

                json = JSON.parse(@l3_rules)
                expect(json[0].key?('policy')).to eq true
                expect(json[0].key?('comment')).to eq true
                expect(json[0].key?('protocol')).to eq true
                expect(json[0].key?('destPort')).to eq true
                expect(json[0].key?('destCidr')).to eq true

                allow(response).to receive(:body).and_return(@l3_rules)
                allow(@meraki).to receive(:update_l3_rules).and_return(response)
                rep = @meraki.update_l3_rules(network_id: :good_id,
                                              ssid: :good_id,
                                              json: :good_json)

                expect(@meraki.valid_json?(rep.body)).to eq true
                expect(rep.body).to eq @l3_rules
            end
        end

        context 'when network id or ssid is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:update_l3_rules).and_return(response)

                rep = @meraki.update_l3_rules(network_id: :bad_id,
                                              ssid: :bad_id,
                                              json: @l3_rules)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without network id, ssid, and valid json' do
            it 'responds with ArgumentError' do
                expect { @meraki.update_l3_rules }.to raise_exception(ArgumentError)
                expect { @meraki.update_l3_rules(network_id: :id) }.to raise_exception(ArgumentError)
                expect do
                    @meraki.update_l3_rules(network_id: :id,
                                            route_id: :route)
                end.to raise_exception(ArgumentError)
                expect do
                    @meraki.update_l3_rules(network_id: :id,
                                            json: @l3_rules)
                end.to raise_exception(ArgumentError)
                allow(@meraki).to receive(:update_l3_rules).and_return(@l3_rules)
                expect do
                    @meraki.update_l3_rules(network_id: :id,
                                            ssid: :ssid,
                                            json: @l3_rules)
                end.to_not raise_exception
            end
        end
    end
end
