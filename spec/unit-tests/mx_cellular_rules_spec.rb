# frozen_string_literal: true

require 'webmock/rspec'
require 'rspec'
require_relative '../../lib/meraki_provisions'

describe MerakiProvisions do
    fixtures = "#{File.dirname(__FILE__)}/../support/fixtures"

    before :all do
        @meraki = MerakiProvisions.new
        @mx_cellular_rules = File.read("#{fixtures}/mx_cellular_rules.json")
    end

    describe '#getMXCellularRules' do
        context 'when network id' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:get_mx_cellular_rules).and_return(response)

                rep = @meraki.get_mx_cellular_rules(network_id: :good_id)

                expect(rep.code).to eq 200
            end

            it 'retrieves a valid json object of cellular rules' do
                response = double

                allow(response).to receive(:body).and_return(@mx_cellular_rules)
                allow(@meraki).to receive(:get_mx_cellular_rules).and_return(response)
                rep = @meraki.get_mx_cellular_rules(network_id: :good_id)

                expect(@meraki.valid_json?(@mx_cellular_rules)).to eq true
                expect(rep.body).to eq @mx_cellular_rules
            end
        end

        context 'when network id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:get_mx_cellular_rules).and_return(response)

                rep = @meraki.get_mx_cellular_rules(network_id: :bad_id)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without providing network id' do
            it 'responds with ArgumentError' do
                expect { @meraki.get_mx_cellular_rules }.to raise_exception(ArgumentError)
            end
        end

        context 'when called with proper network id' do
            it 'does not respond with ArgumentError' do
                allow(@meraki).to receive(:get_mx_cellular_rules).and_return(@mx_cellular_rules)
                expect do
                    @meraki.get_mx_cellular_rules(network_id: :id)
                end.to_not raise_exception
            end
        end
    end

    describe '#updateMXCellularRules' do
        context 'when network id and json valid' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:update_mx_cellular_rules).and_return(response)

                rep = @meraki.update_mx_cellular_rules(network_id: :good_id,
                                                       json: :good_json)

                expect(rep.code).to eq 200
            end

            it 'returns a valid json object of updated rules set' do
                response = double

                json = JSON.parse(@mx_cellular_rules)
                expect(json[0].key?('policy')).to eq true
                expect(json[0].key?('comment')).to eq true
                expect(json[0].key?('protocol')).to eq true
                expect(json[0].key?('destPort')).to eq true
                expect(json[0].key?('destCidr')).to eq true

                allow(response).to receive(:body).and_return(@mx_cellular_rules)
                allow(@meraki).to receive(:update_mx_cellular_rules).and_return(response)
                rep = @meraki.update_mx_cellular_rules(network_id: :good_id,
                                                       json: :good_json)

                expect(@meraki.valid_json?(rep.body)).to eq true
                expect(rep.body).to eq @mx_cellular_rules
            end
        end

        context 'when network id or ssid is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:update_mx_cellular_rules).and_return(response)

                rep = @meraki.update_mx_cellular_rules(network_id: :bad_id,
                                                       json: @mx_l3_rules)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without network id and valid json' do
            it 'responds with ArgumentError' do
                expect { @meraki.update_mx_cellular_rules }.to raise_exception(ArgumentError)
                expect { @meraki.update_mx_cellular_rules(network_id: :id) }
                    .to raise_exception(ArgumentError)
                expect do
                    @meraki.update_mx_cellular_rules(network_id: :id,
                                                     route_id: :route)
                end.to raise_exception(ArgumentError)

                allow(@meraki).to receive(:update_mx_cellular_rules).and_return(@mx_cellular_rules)
                expect do
                    @meraki.update_mx_cellular_rules(network_id: :id,
                                                     json: @mx_l3_rules)
                end.to_not raise_exception
            end
        end
    end
end
