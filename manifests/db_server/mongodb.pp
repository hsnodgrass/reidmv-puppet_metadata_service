class puppet_metadata_service::db_server::mongodb(
  Optional[Boolean] $ipv6 = false,
  Optional[Integer] $port = 27017,
  Optional[String] $admuser = 'puppetadm',
  Optional[String] $admpass = 'puppetadm',
) {

  # Manage the version in Hiera with mongodb::repo::version
  # See https://github.com/voxpupuli/puppet-mongodb/issues/578
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
    class { 'mongodb::client': }
  }

  mongodb::db { 'puppet':
    user     => 'puppet',
    password => 'puppet',
    require  => Class['mongodb::server'],
  }
}
