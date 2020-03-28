#!/opt/puppetlabs/puppet/bin/ruby

if __FILE__ == $0
  begin
    require 'json'
    require 'yaml'
    require_relative './metadata_client'

    config = YAML.load_file('/etc/puppetlabs/puppet/metadata_service/puppet-metadata-service.yaml')

    client = PuppetMetadataClient.for(db_type: config['hosts'][1], hosts: config['hosts'][0])
    data = client.get_nodedata(certname: ARGV[0])

    puts data.to_json
  rescue StandardError => exception
    puts exception
    exit(0)
  end
end