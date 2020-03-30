#!/opt/puppetlabs/puppet/bin/ruby

require_relative "../../ruby_task_helper/files/task_helper.rb"
require_relative '../files/metadata_client.rb'
require 'socket'
require 'json'
require 'open3'

class DeleteHieraData < TaskHelper
  def task(level:,
           keys:,
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
    
    case db_type
    when 'cassandra'
      session = client.new_session
      statement = client.prepare(<<-CQL)
        DELETE FROM puppet.hieradata WHERE level = ? AND key = ?;
      CQL

      futures = keys.map do |key|
        client.execute_async(statement, arguments: [level, key.to_s])
      end

      { 'applied' => futures.map(&:join).size }
    when 'mongodb'
      client.new_session do | session |
        session.with_transaction do
          collection = client[:hieradata]
          result = 0
          keys.each do |_key|
            _result = collection.find({:level => level, :key => _key}, session: session).delete_one
            result += _result.deleted_count
          end
        end
      end
      { 'applied' => result }
    else
      raise "DB type #{db_type} not supported!"
    end
  end
end

if __FILE__ == $0
    DeleteHieraData.run
end
