# profile::puppet::master
#
# Description
#     Puppet single host installation (Puppet Agent/Server/PuppetDB)
#
class profile::puppet::master {
  include profile::puppet::deploy

  class { 'puppet::profile::puppet':
    platform_name  => 'puppet7',

    puppetserver   => true,
    server         => 'puppet',

    hosts_update   => true,

    sameca         => true,
    ca_server      => 'puppet',

    use_common_env => true,

    puppetdb_local => false,
    use_puppetdb   => false,
  }

  Class['profile::puppet::deploy'] -> Class['puppet::profile::puppet']
}
