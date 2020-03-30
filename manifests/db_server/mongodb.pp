class puppet_metadata_service::db_server::mongodb(
  Optional[Boolean] $ipv6 = false,
  Optional[Integer] $port = 27017,
  Optional[String] $admuser = 'puppetadm',
  Optional[String] $admpass = 'puppetadm',
) {

  class { 'mongodb::globals':
    server_package_name => 'mongodb-org-server',
    user                => 'mongod',
    group               => 'mongod',
    before              => Class['mongodb::server'],
  }

  class { 'mongodb::server':
    ensure         => present,
    ipv6           => $ipv6,
    bind_ip        => [ $::ipaddress ],
    port           => $port,
    auth           => true,
    create_admin   => true,
    admin_username => $admuser,
    admin_password => $admpass,
    store_creds    => true,
  }

  if $facts['os']['family'] == 'RedHat' {
    class { 'mongodb::client':
      ensure       => present,
      package_name => 'mongodb-org-shell',
    }
  }

  mongodb_replset { 'pmdsmain':
    ensure  => present,
    members => ["${::ipaddress}:${port}"],
    require => Class['mongodb::server'],
  }
}
