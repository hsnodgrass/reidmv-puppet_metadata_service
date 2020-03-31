#!/opt/puppetlabs/puppet/bin/ruby

require_relative "../../ruby_task_helper/files/task_helper.rb"
require_relative '../../puppet_metadata_service/files/metadata_client.rb'
require 'json'
require 'open3'
require 'socket'
require 'set'

class SetNodeData < TaskHelper
  def task(certname:,
           environment:,
           release:,
           classes: [ ],
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
      statement = session.prepare(<<-CQL).bind([certname, environment, release, classes.to_set])
        INSERT INTO puppet.nodedata (certname, environment, release, classes) 
        VALUES (?, ?, ?, ?);
      CQL

      session.execute(statement)

      # If we get this far, it worked!
      { 'upserted' => 1 }
    when 'mongodb'
      client.new_session do | session |
        session.with_transaction do
          collection = client[:nodedata]
          collection.insertOne(
            {
              certname: certname,
              environment: environment,
              release: release,
              classes: classes.to_set
            },
            session: session
          )
        end
      end
      { 'upserted' => 1 }
    else
      raise "DB type #{db_type} not supported!"
    end
  end
end

if __FILE__ == $0
    SetNodeData.run
end
