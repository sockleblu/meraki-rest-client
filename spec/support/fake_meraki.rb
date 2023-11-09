# frozen_string_literal: true

require 'sinatra'

class FakeMeraki < Sinatra::Base
    ## Device Reponses
    # Get Devices
    get '/api/v0/networks/:network_id/devices' do
        json_response 200, 'devices.json'
    end

    # Get Device
    get '/api/v0/networks/:network_id/devices/:serial' do
        json_response 200, 'device.json'
    end

    # Update Attributes of Device
    put '/api/v0/networks/:network_id/devices/:serial' do
        json_response 200, 'device.json'
    end

    # Claim a Device into a network
    post '/api/v0/networks/:network_id/devices/claim' do
        201
    end

    # Remove a Single Device
    post '/api/v0/networks/:network_id/devices/:serial/remove' do
        204
    end

    # Get MX Cellular Firewall Rules
    get '/api/v0/networks/:network_id/cellularFirewallRules' do
        json_response 200, 'mx_cellular_rules.json'
    end

    # Update MX Cellular Firewall Rules
    put '/api/v0/networks/:network_id/cellularFirewallRules' do
        json_response 200, 'mx_cellular_rules.json'
    end

    # Get MX L3 Firewall Rules
    get '/api/v0/networks/:network_id/l3FirewallRules' do
        json_response 200, 'mx_l3_rules.json'
    end

    # Update MX L3 Firewall Rules
    put '/api/v0/networks/:network_id/l3FirewallRules' do
        json_response 200, 'mx_l3_rules.json'
    end

    ## L3 Firewall Rules
    # Return L3 rules for SSID
    get '/api/v0/networks/:network_id/ssids/:ssid/l3FirewallRules' do
        json_response 200, 'l3_rules.json'
    end

    # Update L3 rules for SSID
    put '/api/v0/networks/:network_id/ssids/:ssid/l3FirewallRules' do
        json_response 200, 'l3_rules.json'
    end

    ## Network Responses
    # Get Network
    get '/api/v0/networks/:network_id' do
        json_response 200, 'network.json'
    end

    # Get Networks
    get '/api/v0/organizations/:org_id/networks' do
        json_response 200, 'networks.json'
    end

    # Update a Network
    put '/api/v0/networks/:network_id' do
        json_response 200, 'network.json'
    end

    # Create a Network
    post '/api/v0/organizations/:org_id/networks' do
        json_response 201, 'network.json'
    end

    # Delete a Network
    delete '/api/v0/networks/:network_id' do
        204
    end

    # Bind a Network to a Template
    post '/api/v0/networks/:network_id/bind' do
        200
    end

    # Unbind a Nework from a Template
    post '/api/v0/networks/:network_id/unbind' do
        200
    end

    # Return Site-to-Site VPN
    get '/api/v0/networks/:network_id/siteToSiteVpn' do
        json_response 200, 's2sVPN.json'
    end

    # Update Site-to-Site VPN
    put '/api/v0/networks/:network_id/siteToSiteVpn' do
        json_response 200, 's2sVPN.json'
    end

    ## Organizations
    # List organizations
    get '/api/v0/organizations' do
        json_response 200, 'organizations.json'
    end

    # Return an organization
    get '/api/v0/organizations/:id' do
        json_response 200, 'organization.json'
    end

    # Update an organization
    put '/api/v0/organizations/:id' do
        json_repsonse 200, 'organization.json'
    end

    # Create a new organization
    post '/api/v0/organizations' do
        json_response 201, 'organization.json'
    end

    # Create a new organization by cloning
    post '/api/v0/organizations/:id/clone' do
        json_response 201, 'organization.json'
    end

    # Claim a device/license key/order in org
    post '/api/v0/organizations/:id/claim' do
        200
    end

    # Return the license state for org
    get '/api/v0/organizations/:id/licenseState' do
        json_response 200, 'license.json'
    end

    # Return the inventory for an org
    get '/api/v0/organizations/:id/inventory' do
        json_response 200, 'inventory.json'
    end

    # Return the SNMP settings for an organization
    get '/api/v0/organizations/:id/snmp' do
        json_response 200, 'snmp.json'
    end

    # Update the SNMP settings for an organization
    put '/api/v0/organizations/:id/snmp' do
        json_response 200, 'snmp.json'
    end

    # Return the third party VPN peers for an org
    get '/api/v0/organizations/:id/thirdPartyVPNPeers' do
        json_response 200, '3rdPartyVPN.json'
    end

    # Update the SNMP settings for an organization
    put '/api/v0/organizations/:id/thirdPartyVPNPeers' do
        json_repsonse 200, '3rdPartyVPN.json'
    end

    ## SSIDs
    # List SSIDs on a network
    get '/api/v0/networks/:network_id/ssids' do
        json_response 200, 'ssids.json'
    end

    # Return a single SSID on a network
    get '/api/v0/networks/:network_id/ssids/:ssid' do
        json_response 200, 'ssid.json'
    end

    # Update the attributes of an SSID
    put '/api/v0/networks/:network_id/ssids/:ssid' do
        json_response 200, 'ssid.json'
    end

    ## Static Routes
    # List static routes for network
    get '/api/v0/networks/:network_id/staticRoutes' do
        json_response 200, 'static_routes.json'
    end

    # Return a  static route for a given network
    get '/api/v0/networks/:network_id/staticRoutes/:route_id' do
        json_response 200, 'static_route.json'
    end

    # Update a static route
    put '/api/v0/networks/:network_id/staticRoutes/:route_id' do
        json_response 200, 'static_route.json'
    end

    # Add a static route
    post '/api/v0/networks/:network_id/staticRoutes' do
        json_response 201, 'static_route.json'
    end

    # Delete a static route
    delete '/api/v0/networks/:network_id/staticRoute/:route_id' do
        json_response 204
    end

    def json_response(response_code, file_name)
        content_type :json
        status response_code
        File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
    end
end
