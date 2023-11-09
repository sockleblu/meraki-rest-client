Meraki ReST Client
==================

A ReST client built against Cisco Meraki ReST API interface

# Table of Contents
------------------------------

* [How to Install](#how-to-install-gems)
* [How to Use Library](#how-to-use-library)
* [Available Methods](#available-methods)
    * [Clients](#clients)
    * [Configuration Templates](#config-templates)
    * [Devices](#devices)
    * [L3 Firewall Rules](#l3-firewall-rules)
    * [Networks](#networks)
    * [Organizations](#organizations)
    * [SSIDs](#ssids)
    * [Static Routes](#static-routes)
    * [Switch Ports](#switch-ports)
    * [VLANs](#vlans)
    * [Additional Methods](#additional-methods)
* [Script Daisy-Chaining](#script-daisy-chaining)

# How to Install Gems
------------------------

From top directory (with bundler gem installed):

`bundle install`

# How to Use Library
---------------------

First require the library and then instantiate it like any other Ruby object

`require '/path/to/library/'`

`meraki = MerakiProvisions.new`
`meraki.get_networks`


# Available Methods
----------------------

This is a list of all built out modules for the Meraki ReST API. The methods that are passed json do rudemantary checks to see if it's valid json, but otherwise assumes that the caller knows what kind of json object is needed for the job. The naming conventions try to adhear as closely as possible to the Meraki API documentation, however the names try to stay consistent among eachother so there may be discrepancies.

## Clients
----------
List the clients of a device, up to a maximum of a month ago. The usage of each client is returned in kilobytes. If the device is a switch, the switchport is returned; otherwise the switchport field is null.

### Get Clients
Parameters:
  * serial
  * timespan (will be set to 86400 by default)
  
`meraki.get_clients(serial: :serial)`

## Config Templates
-------------------
Operate on the configuration templates for an organization

### Get Configuration Templates
Parameters:
  * None
  
`meraki.get_config_templates`

### Remove a Configuration Template
Parameters:
  * temp_id

`meraki.remove_config_template(temp_id: :temp_id)`

## Devices
----------
Operate on the devices on a given network

### Get Device
Parameters:
  * network_id
  * serial

`meraki.get_device(network_id: :network_id,
                  serial: :serial)`

### Get Devices
Parameters:
  * network_id

`meraki.get_devices(network_id: :network_id)`

### Get Device Uplink
Parameters:
  * network_id
  * serial

`meraki.get_device_uplink(network_id: :network_id,
                         serial: :serial)`

### Update Device
Parameters:
  * network_id
  * serial
  * json
    * name:    String
    * tags:    String
    * lat:     Int
    * long:    Int
    * address: String

`meraki.update_device(network_id: :network_id,
                     serial: :serial,
		     json: :json)`

### Claim a Device into Network
Parameters:
  * network_id
  * json
    * serial: String

`meraki.claim_device(network_id: :network_id,
                    serial: :serial)`

### Remove Device
Parameters:
  * network_id
  * serial

`meraki.remove_device(network_id: :network_id,
                     serial: :serial)`

## L3 Firewall Rules
--------------------
Operates on the L3 Firewall Rules for an SSID

### Get L3 Rules
Parameters:
  * network_id
  * ssid

`meraki.get_l3_rules(network_id: :network_id,
                    ssid: :ssid)`

### Update L3 Rules
Parameters:
  * network_id
  * ssid
  * json
    * rules: Array of JSON objects
      * policy: 'allow' or 'deny'
      * protocol: 'tcp', 'udp', 'icmp', or 'any'
      * destPort: 'any' or range from 1-65535
      * destCidr: 'any' or destination IP or CIDR subnet
      * comment: String
    * allowLanAccess: Boolean

`meraki.update_l3_rules(network_id: :network_id,
                       ssid: :ssid,
		       json: :json)`

## Networks
-----------
Operates on the networks of an organization

### Get Networks
Parameters:
  * None

`meraki.get_networks`

### Get Network
Parameters:
  * network_id

`meraki.get_network(network_id: :network_id)`

### Update Network
Parameters:
  * network_id
  * json
    * name: String
    * timeZone: String
    * tags: String

`meraki.update_network(network_id: :network_id,
                      json: :json)`

### Create Network
Parameters:
  * network_id
  * json
    * name: String
    * type: 'wireless', 'switch', 'appliance', 'phone', or space seperated list for combined
    * timeZone: String
    * tags: String

`meraki.create_network(network_id: :network_id,
                      json: :json)`

### Delete Network
Parameters:
  * network_id

`meraki.delete_network(network_id: :network_id)`

### Bind Network to Template
Parameters:
  * network_id
  * json
    * configTemplateId: String
    * autoBind: Boolean - Defaults to False

`meraki.bind_net_to_template(network_id: :network_id,
                            json: :json)`

### Unbind Network from Template
Parameters:
  * network_id

`meraki.unbind_net_from_template(network_id: :network_id,
                                json: :json)`

### Return site-to-site VPN settings
Parameters:
  * network_id

`meraki.get_site2site_vpn(network_id: :network_id,
                         json: :json)`

### Update site-to-site VPN
Parameters:
  * network_id
  * json
    * mode: 'hub', 'spoke', or 'none'
    * hubs: Array of JSON objects
      * hubId: String - The networkId of the hub
      * useDefaultRoute: Boolean - only used in 'spoke' mode
    * subnets: String
      * localSubnet: String - CIDR notation of subnet
      * useVpn: Boolean

`meraki.update_site2site_vpn(network_id: :network_id,
                            json: :json)`

### Return MS network access policies
Parameters:
  * network_id

`meraki.get_access_policies(network_id: :network_id,
                           json: :json)`

## Organizations
----------------

### Return Organiziatons
Parameters:
  * id - Optional

`meraki.get_organizations(id: :id)`

### Update an Organization
Parameters:
  * id
  * json
    * id: String
    * name: String

`meraki.update_organization(id: :id,
                           json: :json)`

### Create a New Organization
Parameters:
  * json
    * name: String

`meraki.create_organization(json: :json)`

### Clone an Organization
Parameters:
  * id
  * json
    * name: String - Name of new clone

`meraki.clone_organization(id: :id,
                          json: :json)`

### Claim a Device, license key, or order into an Organization
a device, license key, or order into an organization. When claiming by order, all devices and licenses in the order will be claimed; licenses will be added to the organization and devices will be placed in the organization's inventory. These three types of claims are mutually exclusive and cannot be performed in one request.

Parameters:
  * id
  * json
    * 'order', 'serial', or 'licenseKey' : String
    * licenseMode: 'renew', or 'addDevices' - See Meraki Doc for use

`meraki.claim_for_organization(id: :id,
                              json: :json)`

### Return the License State for an Organization
Parameters:
  * id

`meraki.get_license_state(id: :id)`

### Return Organization Inventory
Parameters:
  * id

`meraki.get_organization_inventory(id: :id)`

### Return Organization SNMP settings
Parameters:
  * id

`meraki.get_organization_snmp(id: :id,
                             json: :json)`

### Update an Organizations SNMP settings
Parameters:
  * id
  * json
    * v2cEnabled: Boolean
    * v3cEnabled: Boolean
    * v3AuthMode: 'MD5' or 'SHA'
    * v3AuthPass: String
    * v3PrivMode: 'DES' or 'AES128'
    * v3PrivPass: String
    * peerIps: String - list of IPv4 addresses seperated by semi-colons

`meraki.update_organization_snmp(id: :id,
                                json: :json)`

### Return Third-Party VPN Peers for an Organization
Parameters:
  * id

`meraki.get_3rd_party_vpn(id: :id)`

### Update Third-Party VPN Peers for an Organization
Parameters:
  * id
  * json
    * name: String
    * publicIp: String
    * privateSubnets: Array of Strings
    * secret: String

`meraki.update_3rd_party_vpn(id: :id,
                            json: :json)`

## SSIDs
--------

### Return SSIDs for a Network
Parameters:
  * network_id

`meraki.get_ssids(network_id: :network_id)`

### Return an SSID for a Network
Parameters:
  * network_id
  * ssid

`meraki.get_ssid(network_id: :network_id,
                ssid: :ssid)`

### Update an SSID for a Network
Parameters:
  * network_id
  * ssid
  * json
    * Check the Meraki API docs

`meraki.update_ssid(network_id: :network_id)`

## Static Routes
----------------

### Return Static Routes for a Network
Parameters:
  * network_id

`meraki.get_static_routes(network_id: :network_id)`

### Return a Static Route for a Network
Parameters:
  * network_id
  * route_id

`meraki.get_static_route(network_id: :network_id,
                        route_id: :route_id)`

### Update a Static Route for a Network
Parameters:
  * network_id
  * route_id
  * json
    * name: String
    * subnet: String
    * gatewayIp: String
    * enabled: Boolean
    * fixedIpAssignments: JSON object
    * reservedIpRanges: Array of JSON objects

`meraki.update_static_route(network_id: :network_id,
                           json: :json)`

### Create a Static Route for a Network
Parameters:
  * network_id
  * json
    * name: String
    * subnet: String

`meraki.create_static_route(network_id: :network_id,
                           json: :json)`

### Delete a Static Routes for a Network
Parameters:
  * network_id
  * route_id

`meraki.delete_static_route(network_id: :network_id,
                           route_id: :route_id)`

## VLANs
--------

### Return the VLANs for a Network
Parameters:
  * network_id

`meraki.get_vlans(network_id: :network_id)`

### Return a VLAN for a Network
Parameters:
  * network_id
  * vlad_id

`meraki.get_vlan(network_id: :network_id,
                vlan_id: :vlan_id)`

### Update a VLAN on a Network
Parameters:
  * network_id
  * vlan_id
  * json
    * name: String
    * subnet: String
    * applianceIp: String
    * fixedIpAssignments: JSON object
    * reservedIpRanges: Array of JSON objects
    * vpnNatSubnet: String
    * dnsNameservers: String

`meraki.update_vlan(network_id: :network_id,
                   vlan_id: :vlan_id,
		   json: :json)`

### Create a VLAN for Network
Parameters:
  * network_id
  * json
    * id: String - Number between 1 and 4094
    * name: String
    * subnet: String
    * applianceIp: String

`meraki.create_vlan(network_id: :network_id,
                   json: :json)`

### Remove a VLAN from Network
Parameters:
  * network_id
  * vlan_id

`meraki.delete_vlan(network_id: :network_id,
                   vlan_id: :vlan_id)`

## Additional Methods
---------------------

### Query the ReST API with a given url
Parameters:
  * url

`meraki.query_by_url(url: :url)`

# Script Daisy-Chaining
---------------------

Many of the scripts are built to use file streams as input, allowing them to be daisy chained together like many unix utilities. Here are some useful command examples:

### To find network id's from network names
`./query_network_by_name z591 c041 c042 | ruby -ne 'puts eval($_)["id"]'`

### To pull multiple pieces of info from line
`cat ~/MX_with_internal | ruby -ne 'net = eval($_); print "#{net["networkId"]} "; \
   puts "#{net["serial"]}"'`

### To create a hash on the commandline
`cat ~/MX_with_internal \
   | ruby -ne 'net = eval($_); print "\'{\"#{net["networkId"]}\" => "; \
   puts "\"#{net["serial"]}\"}"\''`

### Piping queries together
`./query_network_by_name z591 | ruby -ne 'net = eval($_); puts net["id"]' | \
   ./query_network_for_devices`

### Grab uplink info for given store name
`./query_network_by_name z591 \
   | ruby -ne 'net = eval($_); puts net["id"]' \
   | ./query_network_for_devices \
   | ./coll_uplink_info`

### Piping with conditional
`./query_network_by_name z577 \
   | ruby -ne 'puts eval($_)["id"]' \
   | ./query_network_for_devices \
   | ruby -ne 'net = eval($_); puts net["serial"] if net["model"].match(/^MX.*$/)' \
   | ./query_serial_for_clients`

### Construct URL and send
`./query_network_by_name z577 \
   | ruby -ne 'puts eval($_)["id"]' \
   | ./query_network_for_devices \
   | ruby -ne 'net = eval($_); \
   puts "https://n11.meraki.com/api/v0/networks/#{net["networkId"]}/devices/#{net["serial"]}/uplink"\
     if net["model"].match(/^MX.*$/)' \
   | ./query_by_url`

### Authored by:
  **John Arnett**
  **Kyle Kennedy**