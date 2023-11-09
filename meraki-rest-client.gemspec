# frozen_string_literal: true

require File.expand_path('lib/version', __dir__)

Gem::Specification.new do |s|
    s.name = 'meraki-rest-client'
    s.version           = MerakiRestClient::VERSION
    s.summary           = 'Rest client for use with Meraki SDN'
    s.description       = 'Rest client for use with Meraki SDN within Zumiez'
    s.authors           = ['Kyle Kennedy', 'Kyle Wang']
    s.email             = ['kylek@zumiez.com', 'kylew@zumiez.com']
    s.homepage          = 'https://git.zumiez.com/rubygems/meraki-rest-client'
    s.metadata          = { 'source_code_uri' => 'https://git.zumiez.com/rubygems/meraki-rest-client' }
    s.license = 'Nonstandard'

    s.metadata['allowed_push_host'] = 'http://rubygems.zumiez.com'

    s.files = %w[README.md] + Dir['{lib,templates}/**/*']

    s.add_dependency('rest-client', '~> 2.1', '>= 2.1.0')
    s.add_dependency('rspec', '~> 3.9', '>= 3.9.0')
    s.add_dependency('sinatra', '~> 2.0', '>= 2.0.8')
    s.add_dependency('webmock', '~> 3.7', '>= 3.7.6')
end
