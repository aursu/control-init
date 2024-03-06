class profile::puppet::deploy {
  class { 'puppet::server::bootstrap::globals':
    access_data => lookup({ name => 'profile::puppet::deploy::access', default_value => [] }),
    ssh_config  => lookup({ name => 'profile::puppet::deploy::ssh_config', default_value => [] }),
  }

  contain puppet::server::bootstrap::ssh
}
