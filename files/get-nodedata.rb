#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'yaml'
require_relative './metadata_client'

if __FILE__ == $0
  config = YAML.load_file('/etc/puppetlabs/puppet/puppet-metadata-service.yaml')

  client = PuppetMetadataClient.for(database: config['database'], hosts: config['hosts'])
  data = client.get_nodedata(certname: ARGV[0])

  puts data.to_json
end