class puppet::params {
    $platform_name       = 'puppet7'
    $os_version          = $::operatingsystemmajrelease
    case $::osfamily {
        'RedHat': {
            case $::operatingsystem {
                'Fedora': {
                    $os_abbreviation = 'fedora'
                }
                default: {
                    $os_abbreviation = 'el'
                }
            }
            $repo_urlbase = "https://yum.puppet.com/${platform_name}"
            $version_codename = "${os_abbreviation}-${os_version}"
            $package_provider = 'rpm'
        }
        'Suse': {
            $repo_urlbase = "https://yum.puppet.com/${platform_name}"
            $os_abbreviation  = 'sles'
            $version_codename = "${os_abbreviation}-${os_version}"
            $package_provider = 'rpm'
        }
        'Debian': {
            $repo_urlbase = 'https://apt.puppetlabs.com'
            $version_codename = $::lsbdistcodename
            $package_provider = 'dpkg'
        }
        default: {
            fail("Not known OS family ${::osfamily}")
        }
    }
    $package_name        = "${platform_name}-release"
    $package_filename    = "${package_name}-${version_codename}.noarch.rpm"
    $platform_repository = "${repo_urlbase}/${package_filename}"
    $agent_package_name  = 'puppet-agent'
    $server_package_name = 'puppetserver'
    $r10k_package_name   = 'r10k'
    $gem_path            = '/opt/puppetlabs/puppet/bin/gem'
    $r10k_path           = '/opt/puppetlabs/puppet/bin/r10k'
    $service_name        = 'puppetserver'
}

class puppet::repo (
    $package_name        = $puppet::params::package_name,
    $package_filename    = $puppet::params::package_filename,
    $package_provider    = $puppet::params::package_provider,
    $platform_repository = $puppet::params::platform_repository,
) inherits puppet::params
{
    exec { 'download-release-package':
        command => "curl ${platform_repository} -s -o ${package_filename}",
        cwd     => '/tmp',
        path    => '/bin:/usr/bin',
        creates => "/tmp/${package_filename}",
    }

    package { 'puppet-repository':
        name          => $package_name,
        provider      => $package_provider,
        source        => "/tmp/${package_filename}",
        allow_virtual => false,
        require       => Exec['download-release-package'],
    }
}

class puppet::agent::install (
    $agent_package_name = $puppet::params::agent_package_name,
) inherits puppet::params
{
    include puppet::repo

    package { 'puppet-agent':
        ensure        => 'latest',
        name          => $agent_package_name,
        allow_virtual => false,
        require       => Package['puppet-repository'],
    }

    host { 'puppet':
        ensure => 'present',
        ip     => '127.0.0.1',
    }
}

class puppet::server::install (
    $server_package_name = $puppet::params::server_package_name,
) inherits puppet::params
{
    require puppet::agent::install

    package { 'puppet-server':
        ensure        => 'latest',
        name          => $server_package_name,
        allow_virtual => false,
        require       => Package['puppet-agent'],
    }
}

class puppet::r10k::install (
    $r10k_package_name = $puppet::params::r10k_package_name,
    $gem_path          = $puppet::params::gem_path,
    $r10k_path         = $puppet::params::r10k_path,
) inherits puppet::params
{
    require puppet::agent::install

    exec { 'r10k-installation':
        command => "${gem_path} install ${r10k_package_name}",
        creates => $r10k_path,
        require => Package['puppet-agent'],
    }
}

class puppet::server::setup (
    $r10k_path         = $puppet::params::r10k_path,
) inherits puppet::params
{
    require puppet::r10k::install

    exec { 'environment-setup':
        command => "${r10k_path} deploy environment -p",
        require => Exec['r10k-installation'],
    }
}

class puppet::service (
    $service_name      = $puppet::params::service_name,
) inherits puppet::params
{
    include puppet::server::install

    service { 'puppet-server':
        ensure  => 'running',
        name    => $service_name,
        enable  => true,
        require => Package['puppet-server'],
    }
}

include puppet::server::setup
include puppet::service
