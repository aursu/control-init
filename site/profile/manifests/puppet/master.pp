# profile::puppet::master
#
# Description
#     Puppet single host installation (Puppet Agent/Server/PuppetDB)
#
# Parameters:
#
# [*manage_postgres_dbserver*]
# Boolean. Default is true. If set then class Puppetdb will use puppetlabs/postgresql
# for Postgres database server management and PuppetDB database setup
#
class profile::puppet::master (
  Boolean $manage_postgres_dbserver = true,
  Puppet::Platform
          $platform_name            = 'puppet7',
  Stdlib::Host
          $server                   = 'puppet',
) {
  class { 'puppet::profile::server':
    platform_name  => $platform_name,
    server         => $server,
    postgres_local => $manage_postgres_dbserver,
  }
}
