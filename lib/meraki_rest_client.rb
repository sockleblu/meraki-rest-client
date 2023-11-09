# frozen_string_literal: true

# $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../bin")

require 'rest_client'
require 'json'
require 'uri'

# Wrapper of the Rest Client library for use with Meraki Rest API
class MerakiRestClient
    attr_accessor :hostname, :connection_data, :api_key, :url

    def initialize
        @connection_data = JSON.parse(File.read("#{File.dirname(__FILE__)}/client_data.json"))['meraki']
        @hostname = @connection_data['endpoint']
        @api_key = @connection_data['key']
    end

    def inspect
        "#<MerakiRestClient:#{object_id}>"
    end

=begin
  class ForbiddenError < StandardError
    attr_accessor :code, :headers, :body, :request

    def initialize(e)
      @code = e.response.code
      @headers = e.response.headers
      @body = e.response.body
      @request = e.response.request
    end
  end
=end

    def call_meraki(opts = {})
        method = opts[:method] || :get
        json = opts[:json]

        # Uncomment this line to check what URL is being sent with call
        #    puts @url
        sleep 10
        headers = { 'X-Cisco-Meraki-API-Key': @api_key,
                    content_type: :json,
                    accept: :json }

        begin
            response = RestClient::Request.execute(
                method: method,
                url: @url,
                headers: headers,
                payload: json
            )
        rescue RestClient::ExceptionWithResponse => e
            #      puts "Response Code: #{e.response.code}"
            #      puts "Response Headers: #{e.response.headers}"
            #      puts "Response Body: #{e.response.body}"
            #      puts "Response Object: #{e.response.request.inspect}"
            raise e
            #      raise MerakiRestClient::ForbiddenError.new(e) if e.response.code == 403
        end

        begin
            JSON.parse(response.body) unless response.nil? || response.body == ''
        rescue JSON::ParserError => e
            puts e
        end
    end

    def valid_json?(json)
        JSON.parse(json)
        true
    rescue JSON::ParserError
        false
    end

    ## Admins

    def get_clients(opts = {})
        # https://dashboard.meraki.com/api/v0/devices/[serial]/clients?timespan=86400
        serial = opts[:serial]
        raise ArgumentError, 'Please provide serial' if serial.nil?

        timespan = opts[:timespan] || 86_400

        @url = "#{@hostname}/devices/#{serial}/clients?timespan=#{timespan}"
        call_meraki
    end

    ## The rest of Clients

    def get_config_templates
        # https://n11.meraki.com/api/v0/organizations/[organizationId]/configTemplates
        @url = "#{@hostname}/organizations/#{@connection_data['org_id']}/configTemplates"
        call_meraki
    end

    def remove_config_template(opts = {})
        # https://n11.meraki.com/api/v0/organizations/[organizationId]/configTemplates/[temp_id]
        id = opts[:template_id]
        raise ArgumentError, 'Please provide template_id' if id.nil?

        @url = "#{@hostname}/organizations/#{@connection_data['org_id']}/configTemplates/#{id}"
        call_meraki(method: :delete)
    end

    # Device Calls
    def get_device(opts = {})
        # https://dashboard.meraki.com/api/v0/networks/[networkId]/devices/[serial]
        raise ArgumentError, 'Wrong number of arguments' unless opts.size == 2

        network_id = opts[:network_id]
        serial = opts[:serial]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide serial' if serial.nil?

        @url = "#{@hostname}/networks/#{network_id}/devices/#{serial}"
        call_meraki
    end

    def get_devices(opts = {})
        # https://dashboard.meraki.com/api/v0/networks/[networkId]/devices
        network_id = opts[:network_id]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/devices"
        call_meraki
    end

    def get_device_uplink(opts = {})
        # https://dashboard.meraki.com/api/v0/networks/[networkId]/devices/[serial]/uplink
        network_id = opts[:network_id]
        serial = opts[:serial]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide serial' if serial.nil?

        @url = "#{@hostname}/networks/#{network_id}/devices/#{serial}/uplink"
        call_meraki
    end

    def update_device(opts = {})
        # curl  -H 'X-Cisco-Meraki-API-Key: <key>' -X PUT -H 'Content-Type: application/json'
        # --data-binary '{"name":"Your AP", "lat":37.4180951010362, "lng":-122.098531723022,
        # "serial":"Q2XX-XXXX-XXXX", "mac":"00:11:22:33:44:55:66", "tags":" recently-added "}'
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/devices/[serial]'
        network_id = opts[:network_id]
        serial = opts[:serial]
        json = opts[:json]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide serial' if serial.nil?

        @url = "#{@hostname}/networks/#{network_id}/devices/#{serial}"

        json = get_device(network_id, serial) if json.nil?
        raise ArgumentError, 'Could not find device' if json.nil?

        call_meraki(method: :put, json: json)
    end

    def claim_device(opts = {})
        # curl  -H 'X-Cisco-Meraki-API-Key: <key>' -X POST -H'Content-Type: application/json'
        # --data-binary '{"serial":"Q2XX-XXXX-XXXX"}'
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/devices/claim'
        network_id = opts[:network_id]
        json = opts[:json]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide json object' if json.nil?
        raise ArgumentError, 'Provide a valid json object' unless valid_json? json

        @url = "#{@hostname}/networks/#{network_id}/devices/claim"
        call_meraki(method: :post, json: json)
    end

    def remove_device(opts = {})
        # curl  -H 'X-Cisco-Meraki-API-Key: <key>' -X POST -H'Content-Type: application/json'
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/devices/[serial]/remove'
        network_id = opts[:network_id]
        serial = opts[:serial]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide serial' if serial.nil?

        @url = "#{@hostname}/networks/#{network_id}/devices/#{serial}/remove"
        call_meraki(method: :post)
    end

    # MX Cellular Firewall
    def get_mx_cellular_rules(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -H 'Content-Type: application/json' -X GET
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/ssids/[number]/l3FirewallRules'
        network_id = opts[:network_id]

        raise ArgumentError, 'Please provide network_id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/cellularFirewallRules"

        call_meraki
    end

    def update_mx_cellular_rules(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -X PUT -H'Content-Type: application/json'
        #--data-binary '{"rules":[{"comment":"a note about the rule",
        #                          "policy":"deny",
        #                          "protocol":"tcp",
        #                          "destPort":"any",
        #                          "destCidr":"192.168.1.0/24"}],
        #                "allowLanAccess":true}'
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/l3FirewallRules'
        network_id = opts[:network_id]
        json = opts[:json]

        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        rules = JSON.parse(json)['rules']

        rules.each do |rule|
            raise ArgumentError, "Please provide the comment attribute in rule: #{rule}" unless
              rule.key?('comment')

            raise ArgumentError, "Please provide the policy attribute in rule: #{rule}" unless
              rule.key?('policy')

            raise ArgumentError, "Please provide the protocol attribute in rule: #{rule}" unless
              rule.key?('protocol')

            raise ArgumentError, "Please provide the source port in rule: #{rule}" unless
              rule.key?('srcPort')

            raise ArgumentError, "Please provide the srcCidr in rule: #{rule}" unless
              rule.key?('srcCidr')

            raise ArgumentError, "Please provide the destPort attribute in rule: #{rule}" unless
              rule.key?('destPort')

            raise ArgumentError, "Please provide the destCidr attribute in rule: #{rule}" unless
              rule.key?('destCidr')
        end

        @url = "#{@hostname}/networks/#{network_id}/cellularFirewallRules"

        call_meraki(method: :put, json: json)
    end

    # MX L3 Firewall
    def get_mx_l3_rules(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -H 'Content-Type: application/json' -X GET
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/ssids/[number]/l3FirewallRules'
        network_id = opts[:network_id]

        raise ArgumentError, 'Please provide network_id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/l3FirewallRules"

        call_meraki
    end

    def update_mx_l3_rules(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -X PUT -H'Content-Type: application/json'
        #--data-binary '{"rules":[{"comment":"a note about the rule",
        #                          "policy":"deny",
        #                          "protocol":"tcp",
        #                          "destPort":"any",
        #                          "destCidr":"192.168.1.0/24"}],
        #                "allowLanAccess":true}'
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/l3FirewallRules'
        network_id = opts[:network_id]
        json = opts[:json]

        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        rules = JSON.parse(json)['rules']

        rules.each do |rule|
            raise ArgumentError, "Please provide the comment attribute in rule: #{rule}" unless
              rule.key?('comment')

            raise ArgumentError, "Please provide the policy attribute in rule: #{rule}" unless
              rule.key?('policy')

            raise ArgumentError, "Please provide the protocol attribute in rule: #{rule}" unless
              rule.key?('protocol')

            raise ArgumentError, "Please provide the source port in rule: #{rule}" unless
              rule.key?('srcPort')

            raise ArgumentError, "Please provide the srcCidr in rule: #{rule}" unless
              rule.key?('srcCidr')

            raise ArgumentError, "Please provide the destPort attribute in rule: #{rule}" unless
              rule.key?('destPort')

            raise ArgumentError, "Please provide the destCidr attribute in rule: #{rule}" unless
              rule.key?('destCidr')
        end

        @url = "#{@hostname}/networks/#{network_id}/l3FirewallRules"

        call_meraki(method: :put, json: json)
    end

    # Network Calls
    def get_network(opts = {})
        # https://dashboard.meraki.com/api/v0/networks/[id]
        network_id = opts[:network_id]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}"
        call_meraki
    end

    def get_networks
        # https://dashboard.meraki.com/api/v0/organizations/[organizationId]/networks
        @url = "#{@hostname}/organizations/#{@connection_data['org_id']}/networks"
        call_meraki
    end

    def update_network(opts = {})
        # curl  -H 'X-Cisco-Meraki-API-Key: <key>' -X PUT -H'Content-Type: application/json'
        # --data-binary '{"id":"N_1234","organizationId":1234,"name":"My network", "tags":"tag1 tag2"}'
        # 'https://dashboard.meraki.com/api/v0/networks/[id]'
        network_id = opts[:network_id]
        json = opts[:json]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide a valid json object' if json.nil?

        @url = "#{@hostname}/networks/#{network_id}"

        call_meraki(method: :put, json: json)
    end

    def create_network(opts = {})
        # curl  -H 'X-Cisco-Meraki-API-Key: <key>' -X POST -H'Content-Type: application/json'
        # --data-binary '{"name":"My network", "type":"wireless", "tags":"tag1 tag2"}'
        # 'https://dashboard.meraki.com/api/v0/organizations/[organizationId]/networks'
        json = opts[:json]
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        @url = "#{@hostname}/organizations/#{@connection_data['org_id']}/networks"
        call_meraki(method: :post, json: json)
    end

    def delete_network(opts = {})
        # curl  -H 'X-Cisco-Meraki-API-Key: <key>' -X DELETE -H'Content-Type: application/json'
        # 'https://dashboard.meraki.com/api/v0/networks/[id]'
        network_id = opts[:network_id]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}"

        call_meraki(method: :delete)
    end

    def bind_net_to_template(opts = {})
        # curl -H 'X-Cisco-Meraki-API-Key: <key>' -X POST -H'Content-Type: application/json'
        # --data-binary '{"configTemplateId":"N_1234", "autoBind":false}'
        # 'https://dashboard.meraki.com/api/v0/networks/N_2345/bind'
        network_id = opts[:network_id]
        json = opts[:json]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        verify_hash = JSON.parse(json)
        raise ArgumentError, 'Please provide configTemplateId in json' unless
          verify_hash.key?('configTemplateId')

        @url = "#{@hostname}/networks/#{network_id}/bind"

        call_meraki(method: :post, json: json)
    end

    def unbind_net_from_template(opts = {})
        # curl -H 'X-Cisco-Meraki-API-Key: <key>' -X POST -H'Content-Type: application/json'
        # 'https://dashboard.meraki.com/api/v0/networks/N_2345/unbind'
        network_id = opts[:network_id]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/unbind"

        call_meraki(method: :post)
    end

    def get_site2site_vpn(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -X GET -H'Content-Type: application/json'
        # 'https://dashboard.meraki.com/api/v0/networks/[id]/siteToSiteVpn'
        network_id = opts[:network_id]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/siteToSiteVpn"

        call_meraki
    end

    def update_site2site_vpn(opts = {})
        network_id = opts[:network_id]
        json = opts[:json]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        verify_hash = JSON.parse(json)
        raise ArgumentError, 'Please provide the mode attribute (hub, spoke, or none) in json' unless
          verify_hash.key?('mode')
        raise ArgumentError, 'Please provide the hubs attribute in json' unless
          verify_hash.key?('hubs')
        raise ArgumentError, 'Please provide the subnet attribute in json' unless
          verify_hash.key?('subnets')

        @url = "#{@hostname}/networks/#{network_id}/siteToSiteVpn"

        call_meraki(method: :put, json: json)
    end

    # TODO
    # Traffic Analysis Method

    def get_access_policies(opts = {})
        network_id = opts[:network_id]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/accessPolices"
        call_meraki
    end

    # Organization
    def get_organizations(opts = {})
        @url =
            if opts[:id].nil?
                "#{@hostname}/organizations"
            else
                "#{@hostname}/organizations/#{opts[:id]}"
            end

        call_meraki
    end

    def update_organization(opts = {})
        id = opts[:id]
        json = opts[:json]
        raise ArgumentError, 'Please provide an organization id' if id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        @url = "#{@hostname}/organizations/#{id}"

        call_meraki(method: put, json: json)
    end

    def create_organization(opts = {})
        json = opts[:json]
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        @url = "#{hostname}/organizations"

        call_meraki(method: post, json: json)
    end

    def clone_organization(opts = {})
        id = opts[:id]
        json = opts[:json]
        raise ArgumentError, 'Please provide an organization id' if id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        # Check json for name attribute

        @url = "#{@hostname}/organizations/#{id}/clone"

        call_meraki(method: post, json: json)
    end

    def claim_for_organization(opts = {})
        id = opts[:id]
        json = opts[:json]
        raise ArgumentError, 'Please provide an organization id' if id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        @url = "#{@hostname}/organizations/#{id}/claim"

        call_meraki(method: post, json: json)
    end

    def get_license_state(opts = {})
        id = opts[:id]
        raise ArgumentError, 'Please provide an organization id' if id.nil?

        @url = "#{@hostname}/organizations/#{id}/licenseState"

        call_meraki
    end

    def get_organization_inventory(opts = {})
        id = opts[:id]
        raise ArgumentError, 'Please provide an organization id' if id.nil?

        @url = "#{@hostname}/organizations/#{id}/inventory"

        call_meraki
    end

    def get_organization_snmp(opts = {})
        id = opts[:id]
        raise ArgumentError, 'Please provide an organization id' if id.nil?

        @url = "#{@hostname}/organizations/#{id}/snmp"

        call_meraki
    end

    def update_organization_snmp(opts = {})
        id = opts[:id]
        json = opts[:json]
        raise ArgumentError, 'Please provide an organization id' if id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        # Check for required snmp attributes

        @url = "#{@hostname}/organizations/#{id}/snmp"

        call_meraki(method: put, json: json)
    end

    def get_3rd_party_vpn(opts = {})
        id = opts[:id]
        raise ArgumentError, 'Please provide an organization id' if id.nil?

        @url = "#{@hostname}/organizations/#{id}/thirdPartyVPNPeers"

        call_meraki
    end

    def update_3rd_party_vpn(opts = {})
        id = opts[:id]
        json = opts[:json]
        raise ArgumentError, 'Please provide an organization id' if id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        # Check for required vpn attributes

        @url = "#{@hostname}/organizations/#{id}/thirdPartyVPNPeers"

        call_meraki(method: put, json: json)
    end

    # SSIDs
    def get_ssids(opts = {})
        # curl  -H 'X-Cisco-Meraki-API-Key: <key>' -X GET -H'Content-Type: application/json'
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/ssids'
        network_id = opts[:network_id]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/ssids"
        call_meraki
    end

    def get_ssid(opts = {})
        # curl  -H 'X-Cisco-Meraki-API-Key: <key>' -X GET -H'Content-Type: application/json'
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/ssids/[number]'
        network_id = opts[:network_id]
        ssid = opts[:ssid]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide ssid' if ssid.nil?

        @url = "#{@hostname}/networks/#{network_id}/ssids/#{ssid}"
        call_meraki
    end

    def update_ssid(opts = {})
        network_id = opts[:network_id]
        ssid = opts[:ssid]
        json = opts[:json]
        raise ArgumentError, 'Please provide network id' if network_id.nil?
        raise ArgumentError, 'Please provide ssid' if ssid.nil?
        raise ArgumentError, 'Please provide valid json object' if json.nil?

        @url = "#{@hostname}/networks/#{network_id}/ssids/#{ssid}"
        call_merkai(method: :put, json: json)
    end

    def get_static_routes(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -H 'Content-Type: application/json'
        #-X GET 'https://dashboard.meraki.com/api/v0/networks/[networkId]/staticRoutes'
        network_id = opts[:network_id]
        raise ArgumentError, 'Please provide network id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/staticRoutes"

        call_meraki
    end

    def get_static_route(opts = {})
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/staticRoutes/[srId]'
        network_id = opts[:network_id]
        route_id = opts[:route_id]
        raise ArgumentError, 'Please provide network id' if network_id.nil?
        raise ArgumentError, 'Please provide route id' if route_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/staticRoutes/#{route_id}"

        call_meraki
    end

    def update_static_route(opts = {})
        network_id = opts[:network_id]
        route_id = opts[:route_id]
        json = opts[:json]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide route_id' if route_id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        verify_hash = JSON.parse(json)
        raise ArgumentError, 'Please provide the name attribute in json' unless
          verify_hash.key?('name')

        @url = "#{@hostname}/networks/#{network_id}/staticRoutes/#{route_id}"

        call_meraki(method: :put, json: json)
    end

    def create_static_route(opts = {})
        network_id = opts[:network_id]
        json = opts[:json]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        verify_hash = JSON.parse(json)
        raise ArgumentError, 'Please provide the name attribute in json' unless
          verify_hash.key?('name')
        raise ArgumentError, 'Please provide the subnet attribute in json' unless
          verify_hash.key?('subnet')

        @url = "#{@hostname}/networks/#{network_id}/staticRoutes"

        call_meraki(method: :post, json: json)
    end

    def delete_static_route(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -H 'Content-Type: application/json'-X DELETE
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/staticRoutes/[srId]'
        network_id = opts[:network_id]
        route_id = opts[:route_id]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide route_id' if route_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/staticRoutes/#{route_id}"

        call_meraki(method: :delete)
    end

    def get_l3_rules(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -H 'Content-Type: application/json' -X GET
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/ssids/[number]/l3FirewallRules'
        network_id = opts[:network_id]
        ssid = opts[:ssid]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide ssid' if ssid.nil?

        @url = "#{@hostname}/networks/#{network_id}/ssids/#{ssid}/l3FirewallRules"

        call_meraki
    end

    def update_l3_rules(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -X PUT -H'Content-Type: application/json'
        #--data-binary '{"rules":[{"comment":"a note about the rule",
        #                          "policy":"deny",
        #                          "protocol":"tcp",
        #                          "destPort":"any",
        #                          "destCidr":"192.168.1.0/24"}],
        #                "allowLanAccess":true}'
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/ssids/[number]/l3FirewallRules'
        network_id = opts[:network_id]
        ssid = opts[:ssid]
        json = opts[:json]

        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide ssid' if ssid.nil?
        raise ArgumentError, 'Please provide valid json object' if
          json.nil? || (valid_json?(json) == false)

        rules = JSON.parse(json)['rules']

        rules.each do |rule|
            raise ArgumentError, "Please provide the comment attribute in rule: #{rule}" unless
              rule.key?('comment')

            raise ArgumentError, "Please provide the policy attribute in rule: #{rule}" unless
              rule.key?('policy')

            raise ArgumentError, "Please provide the protocol attribute in rule: #{rule}" unless
              rule.key?('protocol')

            raise ArgumentError, "Please provide the destPort attribute in rule: #{rule}" unless
              rule.key?('destPort')

            raise ArgumentError, "Please provide the destCidr attribute in rule: #{rule}" unless
              rule.key?('destCidr')
        end

        @url = "#{@hostname}/networks/#{network_id}/ssids/#{ssid}/l3FirewallRules"

        call_meraki(method: :post, json: json)
    end

    # TODO
    ## Phone Assignments
    ## Phone Contacts
    ## Phone Numbers
    ## SAML Roles
    ## SM
    ## Switch Ports

    # Does this overwrite current rules? In which case we may need to retrieve then
    # VLANs
    def get_vlans(opts = {})
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/vlans'
        network_id = opts[:network_id]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/vlans"
        call_meraki
    end

    def get_vlan(opts = {})
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/vlans/[vlanId]'
        network_id = opts[:network_id]
        vlan_id = opts[:vlan_id]
        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide vlan_id' if vlan_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/vlans/#{vlan_id}"
        call_meraki
    end

    # Not currently sure where the vlan_id is used in the POST call...
    def create_vlan(opts = {})
        # curl -H 'X-Cisco-Meraki-API-Key: <key>' -H 'Content-Type: application/json' -X POST
        #--data-binary '{"name":"VOIP","applianceIp":"192.168.10.1","subnet":"192.168.10.0/24"}'
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/vlans

        network_id = opts[:network_id]
        json = opts[:json]

        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide valid JSON' if json.nil?

        @url = "#{@hostname}/networks/#{network_id}/vlans"
        call_meraki(method: :post, json: json)
    end

    def update_vlan(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -H 'Content-Type: application/json' -X PUT
        #--data-binary '{"name":"VOIP","applianceIp":"192.168.10.1","subnet":"192.168.10.0/24",
        # {}"fixedIpAssignments":{"13:37:de:ad:be:ef":{"ip":"192.168.10.5","name":"fixed"}},"reservedIpRanges":
        # [{"start":"192.168.10.20","end":"192.168.10.30","comment":"reserved"}],"dnsNameservers":"google_dns"}'
        # https://dashboard.meraki.com/api/v0/networks/[networkId]/vlans/[vlanId]'

        network_id = opts[:network_id]
        vlan_id = opts[:vlan_id]
        json = opts[:json]

        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide vlan_id' if vlan_id.nil?
        raise ArgumentError, 'Please provide JSON' if json.nil?
        raise ArgumentError, 'Please provide valide JSON' unless valid_json?(json)

=begin
           raise ArgumentError, "Please provide the name attribute in rule: #{rule}" unless
               rule.has_key?("name")
           raise ArgumentError, "Please provide the subnet attribute in rule: #{rule}" unless
               rule.has_key?("subnet")
           raise ArgumentError, "Please provide the applianceIP attribute in rule: #{rule}" unless
               rule.has_key?("applianceIP")
           raise ArgumentError, "Please provide the fixedIpAssignments attribute in rule: #{rule}" unless
               rule.has_key?("fixedIpAssignments")
           raise ArgumentError, "Please provide the reservedIpRanges attribute in rule: #{rule}" unless
               rule.has_key?("reservedIpRanges")
           raise ArgumentError, "Please provide the vpnNatSubnet attribute in rule: #{rule}" unless
               rule.has_key?("vpnNatSubnet")
           raise ArgumentError, "Please provide the dnsNameservers attribute in rule: #{rule}" unless
               rule.has_key?("dnsNameservers")
=end
        @url = "#{@hostname}/networks/#{network_id}/vlans/#{vlan_id}"
        call_meraki(method: :put, json: json)
    end

    def delete_vlan(opts = {})
        # curl -L -H 'X-Cisco-Meraki-API-Key: <key>' -H 'Content-Type: application/json' -X DELETE
        # 'https://dashboard.meraki.com/api/v0/networks/[networkId]/vlans/[id]'

        network_id = opts[:network_id]
        vlan_id = opts[:vlan_id]

        raise ArgumentError, 'Please provide network_id' if network_id.nil?
        raise ArgumentError, 'Please provide vlan_id' if vlan_id.nil?

        @url = "#{@hostname}/networks/#{network_id}/vlans/#{vlan_id}"
        call_meraki(method: :delete)
    end

    def query_by_url(opts = {})
        # Given a url this method will directly query the API
        raise ArgumentError, 'Please provide valid url' if
          opts[:url].nil? && (opts[:url] !~ /\A#{URI::DEFAULT_PARSER.make_regexp}\z/)

        @url = opts[:url]

        call_meraki
    end
end
