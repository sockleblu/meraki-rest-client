# frozen_string_literal: true

require 'webmock/rspec'
require 'rspec'
require_relative '../../lib/meraki_provisions'

describe MerakiProvisions do
    fixtures = "#{File.dirname(__FILE__)}/../support/fixtures"

    before :all do
        @meraki = MerakiProvisions.new
        @device = File.read("#{fixtures}/device.json")
        @devices = File.read("#{fixtures}/devices.json")
        @uplinks = File.read("#{fixtures}/uplinks.json")
        @serial = File.read("#{fixtures}/serial.json")
    end

    describe '#getDevice' do
        context 'when network id and serial are valid' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:get_device).and_return(response)

                rep = @meraki.get_device(network_id: :good_id, serial: :good_serial)

                expect(rep.code).to eq 200
            end

            it 'retrieves a valid json object of device' do
                response = double

                allow(response).to receive(:body).and_return(@device)
                allow(@meraki).to receive(:get_device).and_return(response)
                rep = @meraki.get_device(network_id: :good_id, serial: :good_serial)

                expect(@meraki.valid_json?(rep.body)).to eq true
                expect(rep.body).to eq @device
            end
        end

        context 'when network id or serial are invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:get_device).and_return(response)

                rep = @meraki.get_device(network_id: :bad_id, serial: :good_serial)

                expect(rep.code).to eq 404
            end
        end

        context 'when called with number of args not equal to two' do
            it 'responds with ArgumentError' do
                expect { @meraki.get_device }.to raise_exception(ArgumentError)
                expect do
                    @meraki.get_device(network_id: :id,
                                       serial: :serial)
                end.to_not raise_exception
                expect do
                    @meraki.get_device(network_id: :id,
                                       serial: :serial,
                                       bad_param: :param)
                end.to raise_exception(ArgumentError)
                expect { @meraki.get_device(serial: :serial) }.to raise_exception(ArgumentError)
            end
        end
    end

    describe '#getDevices' do
        context 'when network id is valid' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:get_devices).and_return(response)

                rep = @meraki.get_devices(network_id: :good_id)

                expect(rep.code).to eq 200
            end

            it 'retrieves a valid json object of device' do
                response = double

                allow(response).to receive(:body).and_return(@devices)
                allow(@meraki).to receive(:get_devices).and_return(response)
                rep = @meraki.get_devices(network_id: :good_id)

                expect(@meraki.valid_json?(rep.body)).to eq true
                expect(rep.body).to eq @devices
            end
        end

        context 'when network id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:get_devices).and_return(response)

                rep = @meraki.get_devices(network_id: :bad_id)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without network id' do
            it 'responds with ArgumentError' do
                expect { @meraki.get_devices }.to raise_exception(ArgumentError)
                expect { @meraki.get_devices(network_id: :id) }.to_not raise_exception
            end
        end
    end

    describe '#getDeviceUplink' do
        context 'when called with valid network_id and serial' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:get_device_uplink).and_return(response)

                rep = @meraki.get_device_uplink(network_id: :good_id,
                                                serial: :serial)

                expect(rep.code).to eq 200
            end

            it 'retrieves a valid json object of device' do
                response = double

                allow(response).to receive(:body).and_return(@uplinks)
                allow(@meraki).to receive(:get_device_uplink).and_return(response)
                rep = @meraki.get_device_uplink(network_id: :good_id,
                                                serial: :good_serial)

                expect(@meraki.valid_json?(rep.body)).to eq true
                expect(JSON.parse(rep.body).size).to eq 2
                expect(rep.body).to eq @uplinks
            end
        end

        context 'when network id or serial is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:get_device_uplink).and_return(response)

                rep = @meraki.get_device_uplink(network_id: :bad_id,
                                                serial: :good_serial)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without network id' do
            it 'responds with ArgumentError' do
                expect { @meraki.get_device_uplink }.to raise_exception(ArgumentError)
                expect { @meraki.get_device_uplink(network_id: :id) }.to raise_exception(ArgumentError)
            end
        end

        context 'when called with proper parameters' do
            it 'does NOT raise an ArgumentError' do
                allow(@meraki).to receive(:get_device_uplink).and_return(@uplinks)
                expect do
                    @meraki.get_device_uplink(network_id: :id,
                                              serial: :serial)
                end.to_not raise_exception
            end
        end
    end

    describe '#updateDevice' do
        context 'when network id and serial are valid' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:update_device).and_return(response)

                rep = @meraki.update_device(network_id: :good_id)

                expect(rep.code).to eq 200
            end

            it 'returns a valid json object of updated device' do
                response = double

                allow(response).to receive(:body).and_return(@device)
                allow(@meraki).to receive(:update_device).and_return(response)
                rep = @meraki.update_device(network_id: :good_id,
                                            serial: :good_serial)

                expect(@meraki.valid_json?(rep.body)).to eq true
                expect(rep.body).to eq @device
            end
        end

        context 'when network id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:update_device).and_return(response)

                rep = @meraki.update_device(network_id: :bad_id,
                                            serial: :serial,
                                            json: @device)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without network id' do
            it 'responds with ArgumentError' do
                expect { @meraki.update_device }.to raise_exception(ArgumentError)
                expect { @meraki.update_device(network_id: :id) }.to raise_exception(ArgumentError)
                expect do
                    @meraki.update_device(network_id: :id,
                                          serial: :serial)
                end.to raise_exception(ArgumentError)
                expect do
                    @meraki.update_device(network_id: :id,
                                          serial: :serial,
                                          json: @device)
                end.to_not raise_exception
            end
        end
    end

    describe '#claimDevice' do
        context 'when network id and json are valid' do
            it 'responds with 201' do
                response = double

                allow(response).to receive(:code).and_return(201)
                allow(@meraki).to receive(:claim_device).and_return(response)

                rep = @meraki.claim_device(network_id: :good_id)

                expect(rep.code).to eq 201
            end
        end

        context 'when passed invalid json' do
            it 'responds with an ArgumentError' do
                bad_json = 'Not a real json object'

                expect do
                    @meraki.claim_device(network_id: :id,
                                         json: bad_json)
                end.to raise_exception(ArgumentError)
            end
        end

        context 'when network id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:claim_device).and_return(response)

                rep = @meraki.claim_device(network_id: :bad_id,
                                           json: @device)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without network id' do
            it 'responds with ArgumentError' do
                expect { @meraki.claim_device }.to raise_exception(ArgumentError)
                expect { @meraki.claim_device(network_id: :id) }.to raise_exception(ArgumentError)
                expect do
                    @meraki.claim_device(network_id: :id,
                                         json: @device)
                end.to_not raise_exception
            end
        end
    end

    describe '#removeDevice' do
        context 'when network id and serial are valid' do
            it 'responds with 204 ' do
                response = double

                allow(response).to receive(:code).and_return(204)
                allow(@meraki).to receive(:remove_device).and_return(response)

                rep = @meraki.remove_device(network_id: :good_id)

                expect(rep.code).to eq 204
            end
        end

        context 'when network id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:remove_device).and_return(response)

                rep = @meraki.remove_device(network_id: :bad_id,
                                            serial: :serial)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without network id' do
            it 'responds with ArgumentError' do
                expect { @meraki.remove_device }.to raise_exception(ArgumentError)
                expect { @meraki.remove_device(network_id: :id) }.to raise_exception(ArgumentError)
                expect do
                    @meraki.remove_device(network_id: :id,
                                          serial: :serial)
                end.to_not raise_exception
            end
        end
    end
end
