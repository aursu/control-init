class profile::puppet::deploy {
  $access_data = lookup({
      name          => 'profile::puppet::deploy::access',
      value_type    => Array[
        Struct[{
            name                  => Stdlib::Fqdn,
            key_data              => String,
            key_prefix            => String,
            Optional[server]      => Stdlib::Fqdn,
            Optional[sshkey_type] => Openssh::KeyID,
            Optional[ssh_options] => Openssh::SshConfig,
        }]
      ],
      default_value => [],
  })

  $ssh_config = lookup({
      name          => 'profile::puppet::deploy::ssh_config',
      value_type    => Array[Openssh::SshConfig],
      default_value => [],
  })

  $access_data.each |$creds| {
    $key_name    = $creds['name']
    $sshkey_type = $creds['sshkey_type'] ? { String => $creds['sshkey_type'], default => 'ed25519' }

    openssh::priv_key { $key_name:
      user_name   => 'root',
      key_prefix  => $creds['key_prefix'],
      sshkey_type => $sshkey_type,
      key_data    => $creds['key_data'],
    }
  }

  $ssh_access_config = $access_data.reduce([]) |$memo, $creds| {
    $key_name    = $creds['name']
    $server      = $creds['server'] ? { String => $creds['server'], default => downcase($key_name) }
    $key_prefix  = $creds['key_prefix']
    $sshkey_type = $creds['sshkey_type'] ? { String => $creds['sshkey_type'], default => 'ed25519' }

    $config      = {
      'Host'                  => $server,
      'StrictHostKeyChecking' => 'no',
      'IdentityFile'          => "~/.ssh/${key_prefix}.id_${sshkey_type}",
    } + $creds['ssh_options']

    $memo + [$config]
  }

  openssh::ssh_config { 'root':
    ssh_config => $ssh_config + $ssh_access_config,
  }
}
