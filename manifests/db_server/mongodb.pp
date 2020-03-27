class puppet_metadata_service::db_server::mongodb(
  Optional[Boolean] $ipv6 = false,
  Optional[Integer] $port = 27017,
  Optional[String] $admuser = 'puppetadm',
  Optional[String] $admpass = 'puppetadm',
) {

  class { 'mongodb::globals':
    manage_package_repo => true,
    version             => '4.2',
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
  }

  if $facts['os']['family'] == 'RedHat' {
    class { 'mongodb::client':
      require => Class['mongodb::server'],
    }
  }

  mogodb::db { 'puppet':
    user     => 'puppet',
    password => 'puppet',
    require  => Class['mongodb::server'],
  }
}
