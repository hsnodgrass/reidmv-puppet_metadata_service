#!/opt/puppetlabs/puppet/bin/ruby

require_relative "../../ruby_task_helper/files/task_helper.rb"
require_relative '../../puppet_metadata_service/files/metadata_client.rb'
require 'json'
require 'open3'
require 'socket'
require 'set'

class ShowNode < TaskHelper
  def task(certname:, **kwargs)
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
        statement = session.prepare('SELECT * FROM nodedata WHERE certname=?').bind([certname])
        result    = session.execute(statement)
        data = result.first
        # Convert the Ruby Set object into an array
        data['classes'] = data.delete('classes').to_a unless data['classes'].nil?
        {'node' => data }
  end
end

if __FILE__ == $0
    ShowNode.run
end
