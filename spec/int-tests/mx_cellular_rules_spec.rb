# frozen_string_literal: true

require_relative '../spec_helper'

describe MerakiProvisions do
    before :all do
        @meraki = MerakiProvisions.new
        @fixed_loc = File.dirname(__FILE__) + '/../support/fixtures/'
    end

    feature 'Get a networks cellular firewall rules' do
        it 'queries Meraki for a single network by ID' do
            response = @meraki.get_mx_cellular_rules(network_id: 'L_569142402908947018')

            expect(response.class).to eq Array

            expect(response[0]['destCidr']).to eq '10.1.33.0/24'
        end
    end

    feature 'Update the attributes of a network' do
        it 'updates the attributes of a networks using json' do
            json = File.open(@fixed_loc + 'mx_cellular_update.json').read

            response = @meraki.update_mx_cellular_rules(network_id: 'L_569142402908947018',
                                                        json: json)

            expect(response[0]['comment']).to match(/^Allow.*$/)
        end
    end
end
