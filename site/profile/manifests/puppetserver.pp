# profile::puppet::server
#
# Description
#     Puppet server installation (Puppet Server only without PuppetDB)
#
# @param platform_name
#   Which Puppet platform to use - either Puppet 6 (puppet6), Puppet 7 (puppet7) or Puppet 8 (puppet8)
#
# @param sameca
#   Whether to use this servers as Puppet CA
#
class profile::puppetserver (
  String $platform_name = 'puppet8',
  Boolean $sameca = true,
  Stdlib::Host $ca_server = 'puppet',
  Stdlib::Host $puppetdb_server = 'puppetdb',
) {
  class { 'puppet::profile::puppet':
    platform_name   => $platform_name,

    puppetserver    => true,
    server          => 'puppet',

    hosts_update    => true,

    sameca          => $sameca,
    ca_server       => $ca_server,

    use_common_env  => true,

    puppetdb_local  => false,
    use_puppetdb    => true,
    puppetdb_server => $puppetdb_server,
  }

  include profile::puppet::deploy

  Class['profile::puppet::deploy'] -> Class['puppet::profile::puppet']
}
