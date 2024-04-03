# If the ENC (External Node Classifier) identifies a host, it sets the 'stype'
# top-scope variable to dictate the server's role. In cases where 'stype' is
# not defined (indicating an unrecognized host), the script defaults to
# checking whether the host's IP matches the Puppet server's IP ('$::serverip').
# If there's a match, the 'role::puppet::master' class is applied. This
# mechanism ensures that only recognized hosts or the Puppet server itself are
# configured accordingly. This strategy helps prevent the accidental
# configuration of critical roles on unintended hosts. For guidance on Puppet's
# built-in variables and facts, see:
# https://www.puppet.com/docs/puppet/8/lang_facts_builtin_variables#lang_facts_builtin_variables-server-facts
# lint:ignore:top_scope_facts
if defined('$::stype') {
  include "role::${::stype}"
}
elsif $::serverip == $facts['networking']['ip'] {
  include role::puppet::master
}
# lint:endignore
