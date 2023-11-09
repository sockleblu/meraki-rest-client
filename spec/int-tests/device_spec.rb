# frozen_string_literal: true

require_relative '../spec_helper'

describe MerakiProvisions do
    before :all do
        @meraki = MerakiProvisions.new
        @fixed_loc = "#{File.dirname(__FILE__)}/../support/fixtures"
    end

    feature 'External get devices from network request' do
        it 'queries Meraki for devices on given network' do
            response = @meraki.get_devices(network_id: 'L_569142402908947018')

            expect(response.class).to eq Array

            expect(response[0]['name']).to eq 'My AP'
        end
    end

    feature 'External get a single device from network request' do
        it 'queries Meraki for a single device on given network' do
            response = @meraki.get_device(network_id: 'L_569142402908947018', serial: '12345')

            expect(response.class).to eq Hash

            expect(response['name']).to eq 'My AP'
        end
    end

    feature 'Update the attributes of a device' do
        it 'updates the attributes of a device on a network and returns it' do
            json = File.open(@fixed_loc + '/device.json').read

            response = @meraki.update_device(network_id: 'L_569142402908947018', serial: '12345', json: json)

            # I can't (for the life of me) get Sinatra to return more than nil...
            expect(response['name']).to eq 'My AP'
        end
    end

    feature 'Claim a device into a network' do
        it 'adds a device to a given network' do
            json = File.open(@fixed_loc + '/serial.json').read

            response = @meraki.claim_device(network_id: 'L_569142402908947018', json: json)

            expect(response).to eq nil
        end
    end

    feature 'Remove a device from a network' do
        it 'removes a given device from a given network' do
            serial = JSON.parse(File.open(@fixed_loc + '/serial.json') \
              .read)['serial']

            response = @meraki.remove_device(network_id: 'L_569142402908947018', serial: serial)

            expect(response).to eq nil
        end
    end
end
