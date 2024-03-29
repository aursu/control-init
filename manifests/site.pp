# ENC script for unknown hosts returns "production" environment, therefore
# puppet agent will install Puppet server on unknown host. To prevent this, add
# condition
# https://www.puppet.com/docs/puppet/8/lang_facts_builtin_variables#lang_facts_builtin_variables-server-facts
if $::serverip == $facts['networking']['ip'] {
  include role::puppet::master
}
