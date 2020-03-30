#!/opt/puppetlabs/puppet/bin/ruby

if __FILE__ == $0
  begin
    require 'json'
    require 'yaml'
    require_relative './metadata_client'

    config = YAML.load_file('/etc/puppetlabs/puppet/metadata_service/puppet-metadata-service.yaml')
    
    hosts_by_db_type = Hash.new

    config['hosts'].each { |key,value|
      if hosts_by_db_type.has_key?(value['db_type'])
        hosts_by_db_type[value['db_type']] << key
      else
        hosts_by_db_type[value['db_type']] = Array.new
        hosts_by_db_type[value['db_type']] << key
    }

    case hosts_by_db_type
    when hosts_by_db_type.length == 1 && hosts_by_db_type.has_key?('cassandra')
      client = PuppetMetadataClient.for(db_type: 'cassandra', hosts: hosts_by_db_type['cassandra'])
    when hosts_by_db_type.length == 1 && hosts_by_db_type.has_key?('mongodb')
      client = PuppetMetadataClient.for(db_type: 'mongodb', hosts: hosts_by_db_type['mongodb'])
    else
      puts "Mixing database types is not yet supported!"
      exit(0)
    end

    data = client.get_nodedata(certname: ARGV[0])
    puts data.to_json
  rescue StandardError => exception
    puts exception
    exit(0)
  end
end