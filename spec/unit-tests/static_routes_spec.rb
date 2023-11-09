# frozen_string_literal: true

require 'webmock/rspec'
require 'rspec'
require_relative '../../lib/meraki_provisions'

describe MerakiProvisions do
    fixtures = "#{File.dirname(__FILE__)}/../support/fixtures"

    before :all do
        @meraki = MerakiProvisions.new
        @routes = File.read("#{fixtures}/static_routes.json")
        @route = File.read("#{fixtures}/static_route.json")
    end

    describe '#getStaticRoutes' do
        context 'when network id is valid' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:get_static_routes).and_return(response)

                rep = @meraki.get_static_routes(network_id: :good_id)

                expect(rep.code).to eq 200
            end

            it 'retrieves a valid json object of a static route' do
                response = double

                allow(response).to receive(:body).and_return(@routes)
                allow(@meraki).to receive(:get_static_routes).and_return(response)
                rep = @meraki.get_static_routes(network_id: :good_id)

                expect(@meraki.valid_json?(rep.body)).to eq true
                expect(rep.body).to eq @routes
            end
        end

        context 'when network id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:get_static_routes).and_return(response)

                rep = @meraki.get_static_routes(network_id: :bad_id)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without providing network id' do
            it 'responds with ArgumentError' do
                expect { @meraki.get_static_routes }.to raise_exception(ArgumentError)
                allow(@meraki).to receive(:get_static_routes).and_return(@routes)
                expect { @meraki.get_static_routes(network_id: :id) }.to_not raise_exception
            end
        end
    end

    describe '#getStaticRoute' do
        context 'when network id and route id valid' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:get_static_route).and_return(response)

                rep = @meraki.get_static_route

                expect(rep.code).to eq 200
            end

            it 'retrieves a valid json object with array of networks' do
                response = double

                allow(response).to receive(:body).and_return(@route)
                allow(@meraki).to receive(:get_static_route).and_return(response)
                rep = @meraki.get_static_route

                expect(@meraki.valid_json?(rep.body)).to eq true
                expect(rep.body).to eq @route
            end
        end
    end

    describe '#updateStaticRoute' do
        context 'when network id, route id, and json valid' do
            it 'responds with 200 ' do
                response = double

                allow(response).to receive(:code).and_return(200)
                allow(@meraki).to receive(:update_static_route).and_return(response)

                rep = @meraki.update_static_route(network_id: :good_id,
                                                  route_id: :good_id,
                                                  json: :good_json)

                expect(rep.code).to eq 200
            end

            it 'returns a valid json object of updated route' do
                response = double

                json = JSON.parse(@route)
                expect(json.key?('name')).to eq true
                expect(json.key?('subnet')).to eq true

                allow(response).to receive(:body).and_return(@route)
                allow(@meraki).to receive(:update_static_route).and_return(response)
                rep = @meraki.update_static_route(network_id: :good_id,
                                                  route_id: :good_id,
                                                  json: :good_json)

                expect(@meraki.valid_json?(rep.body)).to eq true
                expect(rep.body).to eq @route
            end
        end

        context 'when network id or route id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:update_static_route).and_return(response)

                rep = @meraki.update_static_route(network_id: :bad_id,
                                                  route_id: :bad_id,
                                                  json: @route)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without network id, route id, and valid json' do
            it 'responds with ArgumentError' do
                expect { @meraki.update_static_route }.to raise_exception(ArgumentError)
                expect { @meraki.update_static_route(network_id: :id) }.to raise_exception(ArgumentError)
                expect do
                    @meraki.update_static_route(network_id: :id,
                                                route_id: :route)
                end.to raise_exception(ArgumentError)
                expect do
                    @meraki.update_static_route(network_id: :id,
                                                json: @route)
                end.to raise_exception(ArgumentError)
                allow(@meraki).to receive(:update_static_route).and_return(@route)
                expect do
                    @meraki.update_static_route(network_id: :id,
                                                route_id: :route,
                                                json: @route)
                end.to_not raise_exception
            end
        end
    end

    describe '#createStaticRoute' do
        context 'when network id and json are valid' do
            it 'responds with 201' do
                response = double

                json = '{"name":"VOIP","subnet":"192.168.10.0/24"}'
                verify_hash = JSON.parse(json)

                expect(verify_hash.key?('name')).to eq true
                expect(verify_hash.key?('subnet')).to eq true

                allow(response).to receive(:code).and_return(201)
                allow(@meraki).to receive(:create_static_route).and_return(response)

                rep = @meraki.create_static_route(network_id: :good_id,
                                                  json: json)

                expect(rep.code).to eq 201
            end
        end

        context 'when passed invalid json' do
            it 'responds with an ArgumentError' do
                bad_json = 'Not a real json object'

                expect do
                    @meraki.create_static_route(network_id: :id,
                                                json: bad_json)
                end.to raise_exception(ArgumentError)
            end
        end

        context 'when network id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:create_static_route).and_return(response)

                rep = @meraki.create_static_route(network_id: :bad_id,
                                                  json: @route)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without network id' do
            it 'responds with ArgumentError' do
                json = '{"name":"VOIP","subnet":"192.168.10.0/24"}'
                expect { @meraki.create_static_route }.to raise_exception(ArgumentError)
                expect { @meraki.create_static_route(network_id: :id) }.to raise_exception(ArgumentError)
                allow(@meraki).to receive(:create_static_route).and_return(@route)
                expect do
                    @meraki.create_static_route(network_id: :id,
                                                json: json)
                end.to_not raise_exception
            end
        end
    end

    describe '#deleteStaticRoute' do
        context 'when network id and route id are valid' do
            it 'responds with 204 ' do
                response = double

                allow(response).to receive(:code).and_return(204)
                allow(@meraki).to receive(:delete_static_route).and_return(response)

                rep = @meraki.delete_static_route(network_id: :good_id,
                                                  route_id: :good_route)

                expect(rep.code).to eq 204
            end
        end

        context 'when network id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:delete_static_route).and_return(response)

                rep = @meraki.delete_static_route(network_id: :bad_id,
                                                  route_id: :good_id)

                expect(rep.code).to eq 404
            end
        end

        context 'when route id is invalid' do
            it 'responds with 404 code' do
                response = double

                allow(response).to receive(:code) { 404 }
                allow(@meraki).to receive(:delete_static_route).and_return(response)

                rep = @meraki.delete_static_route(network_id: :good_id,
                                                  route_id: :bad_id)

                expect(rep.code).to eq 404
            end
        end

        context 'when called without network id' do
            it 'responds with ArgumentError' do
                expect { @meraki.delete_static_route }.to raise_exception(ArgumentError)
            end
        end

        context 'when called without network id' do
            it 'responds with ArgumentError' do
                allow(@meraki).to receive(:delete_static_route)
                expect do
                    @meraki.delete_static_route(network_id: :id,
                                                route_id: :route)
                end.to_not raise_exception
            end
        end
    end
end
