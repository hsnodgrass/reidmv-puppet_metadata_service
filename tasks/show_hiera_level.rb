#!/opt/puppetlabs/puppet/bin/ruby

require_relative "../../ruby_task_helper/files/task_helper.rb"
require_relative '../files/metadata_client.rb'
require 'json'
require 'open3'
require 'socket'

class ShowHieraLevel < TaskHelper
  def task(level:, **kwargs)
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
      statement = session.prepare('SELECT * FROM hieradata WHERE level=?').bind([level])
      result    = session.execute(statement)

      hash = result.to_a.map do |row|
        [row['key'], JSON.parse(row['value'])]
      end.to_h

      { 'data' => hash }
    when 'mongodb'
      client.new_session do | session |
        session.with_transaction do
          collection = client[:hieradata]
          results = collection.find(:level => level)
        end
      end
      { 'data' => results }
    else
      raise "DB type #{db_type} not supported!"
    end
  end
end

if __FILE__ == $0
    ShowHieraLevel.run
end
