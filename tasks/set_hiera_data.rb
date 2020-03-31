#!/opt/puppetlabs/puppet/bin/ruby

require_relative "../../ruby_task_helper/files/task_helper.rb"
require_relative '../../puppet_metadata_service/files/metadata_client.rb'
require 'json'
require 'open3'
require 'socket'

class SetHieraData < TaskHelper
  def task(level:,
           data:,
           **kwargs)

    # Grab metadata_service facts
    cmd = ['/opt/puppetlabs/puppet/bin/facter',
      '-p',
      '--json',
      'metadata_service']
    stdout, stderr, status = Open3.capture3(*cmd)
    raise "Exit #{status.exitstatus} running #{cmd.join(' ')}: #{stderr}" if status != 0
    mds_facts = JSON.parse(stdout)['metadata_service']
    db_type = mds_facts['db_type']

    # Get our DB client based on the db_type fact
    client = PuppetMetadataClient.for(db_type: db_type, hosts: [Socket.gethostname], **kwargs)

    case $db_type
    when 'cassandra'
      session = client.new_session
      statement = session.prepare(<<-CQL)
        INSERT INTO puppet.hieradata (level, key, value)
        VALUES (?, ?, ?);
      CQL

      futures = data.map do |key,value|
        session.execute_async(statement, arguments: [level, key.to_s, value.to_json])
      end

      { 'upserted' => futures.map(&:join).size }
    when 'mongodb'
      _data = Array.new
      data.each { |key, value|
        _data.push({ level: level, key: key.to_s, value: value.to_json })
      }
      client.new_session do | session |
        session.with_transaction do
          collection = client[:heiradata]
          result = collection.insert_many(_data, session: session)
        end
      end
      { 'upserted' => result.inserted_count }
    else
      raise "DB type #{db_type} not supported!"
    end
  end
end

if __FILE__ == $0
    SetHieraData.run
end
