class puppet_metadata_service::db_server::install(
  Enum['cassandra', 'mongodb'] $db_type = 'cassandra'
) {

  file { '/etc/puppetlabs/facter':
    ensure => directory,
    mode   => '0755',
  }

  file { '/etc/puppetlabs/facter/facter.d':
    ensure => directory,
    mode   => '0755',
  }

  # External facts for reference by tasks
  file { '/etc/puppetlabs/facter/facts.d/metadata_service.yaml':
    ensure  => file,
    mode    => '0644',
    content => epp('puppet_metadata_service/metadata_service.yaml.epp', {
      db_type => $db_type
    })
  }

  case $db_type {
    'cassandra': { include puppet_metadata_service::db_server::cassandra }
    'mongodb': { include puppet_metadata_service::db_server::mongodb }
    default: { fail("Database ${db_type} not supported by Puppet Metadata Service!") }
  }
}
