# frozen_string_literal: true

require_relative '../spec_helper'

describe MerakiProvisions do
    before :all do
        @meraki = MerakiProvisions.new
        @fixed_loc = File.dirname(__FILE__) + '/../support/fixtures/'
    end

    feature 'Get a network given an ID' do
        it 'queries Meraki for a single network by ID' do
            response = @meraki.get_network(network_id: 'L_569142402908947018')

            expect(response.class).to eq Hash

            expect(response['name']).to eq 'My network'
        end
    end

    feature 'Get networks from an organization' do
        it 'queries Meraki for networks' do
            response = @meraki.get_networks

            expect(response.class).to eq Array

            expect(response[0]['name']).to eq 'My network'
        end
    end

    feature 'Update the attributes of a network' do
        it 'updates the attributes of a networks using json' do
            json = File.open(@fixed_loc + 'network.json').read

            response = @meraki.update_network(network_id: 'L_569142402908947018', json: json)

            expect(response['id']).to eq 'N_1234'
        end
    end

    feature 'Create a network' do
        it 'adds a network to an organization' do
            json = File.open(@fixed_loc + 'network.json').read

            response = @meraki.create_network(network_id: 'L_569142402908947018', json: json)

            expect(response['id']).to eq 'N_1234'
        end
    end

    feature 'Remove a network from an organization' do
        it 'removes a given device from a given network' do
            response = @meraki.delete_network(network_id: 'L_569142402908947018')

            expect(response).to eq nil
        end
    end

    feature 'Bind a network to template' do
        it 'binds a given network to template' do
            response = @meraki.bind_net_to_template(network_id: 'L_569142402908947018',
                                                    json: '{"configTemplateId":"N_1234"}')

            expect(response).to eq nil
        end
    end

    feature 'Unbind a network from template' do
        it 'unbinds a network from template' do
            response = @meraki.unbind_net_from_template(network_id: 'L_569142402908947018')

            expect(response).to eq nil
        end
    end
end
