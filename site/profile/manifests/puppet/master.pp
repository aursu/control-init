# profile::puppet::master
#
# Description
#     Puppet single host installation (Puppet Agent/Server/PuppetDB)
#
class profile::puppet::master (
  String $platform_name = 'puppet8',
  Boolean $puppetdb_local = true,
  Stdlib::Host $puppetdb_server = 'puppet',
) {
  class { 'puppet::profile::puppet':
    platform_name   => $platform_name,

    puppetserver    => true,
    server          => 'puppet',

    hosts_update    => true,

    sameca          => true,
    ca_server       => 'puppet',

    use_common_env  => true,

    use_puppetdb    => true,
    puppetdb_local  => $puppetdb_local,
    puppetdb_server => $puppetdb_server,
  }

  include profile::puppet::deploy

  Class['profile::puppet::deploy'] -> Class['puppet::profile::puppet']
}
