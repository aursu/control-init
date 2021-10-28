# Installation

1) Enable the Puppet platform repository (example for Puppet 7 on CentOS 7)
```
rpm -Uvh https://yum.puppet.com/puppet7-release-el-7.noarch.rpm
```
2) Install Puppet agent
```
yum -y install puppet-agent
```

3) fork `control-init`, `control-enc` and `control-common` into own repositories

4) in new `control-init` replace `common` environment inside `r10k.yaml`
with newly forked in step 1). For example:

```
  :common:
    remote: "git@gitlab.company.tld:infra/control-common.git"
    basedir: "/etc/puppetlabs/code/environments"
```

5) inside `common` environment in Hiera config `data/global.yaml` define parameter
puppet::common_remote with URL to forked repo `control-common` in order to keep
changes from step 2). For example:

```
puppet::common_remote: git@gitlab.company.tld:infra/control-common.git
```

6) define `r10k::sources` with own environments to deploy during agent run. For
example:

```
r10k::sources:
  production:
    remote: https://github.com/aursu/control-init.git
    basedir: /etc/puppetlabs/code/environments
  common:
    remote: git@gitlab.company.tld:infra/control-common.git
    basedir: /etc/puppetlabs/code/environments
  enc:
    remote: git@gitlab.company.tld:infra/control-enc.git
    basedir: /etc/puppetlabs/code/environments
  web:
    remote: git@gitlab.company.tld:infra/control-web.git
    basedir: /etc/puppetlabs/code/environments
```

7) run command: `puppet apply install.pp`

8) run command: `/opt/puppetlabs/bin/puppet agent --test`
