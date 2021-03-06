#
# default.pp - defines all puppet nodes
#
node 'host-1' {
  include ::consul_check::puppet
  
  class { '::consul':
    extra_options => "-bind $::ipaddress_eth1",
    pretty_config => true,
    config_hash => {
      'bootstrap_expect' => 3,
      'data_dir'         => '/opt/consul',
      'datacenter'       => 'laptop',
      'log_level'        => 'INFO',
      'enable_syslog' => true,
#      'node_name'        => 'server',
      'server'           => true,
      'retry_join'       => ['172.16.32.11', '172.16.32.12'],
      'ui_dir'           => '/opt/consul/ui',
      'client_addr'      => '0.0.0.0',
    }
  }
  ::consul::service { 'web_ui':
    checks => [{
        name     => 'HTTP API on port 8500 for Consul UI',
        http     => 'http://127.0.0.1:8500/ui/',
        interval => '10s'
        timeout  => '1s'
      }
      ],
    port   => 8500,
    tags   => ['web']
  }
}

node 'host-2' {
  include ::consul_check::puppet
  
  class { '::consul':
    extra_options => "-bind $::ipaddress_eth1",
    pretty_config => true,
    config_hash => {
      'bootstrap_expect' => 3,
      'data_dir'         => '/opt/consul',
      'datacenter'       => 'laptop',
      'log_level'        => 'INFO',
      'enable_syslog' => true,
#      'node_name'        => 'server',
      'server'           => true,
      'retry_join'       => ['172.16.32.10', '172.16.32.12'],
    }
  }

  class { 'nginx': }
  nginx::resource::vhost { 'example':
    ensure => present,
    server_name => $hostname,
    listen_port => 8140,
    www_root = '/vagrant/www/',
  }
}

node 'host-3' {
  include ::consul_check::puppet
  
  class { '::consul':
    extra_options => "-bind $::ipaddress_eth1",
    pretty_config => true,
    config_hash => {
      'bootstrap_expect' => 3,
      'data_dir'         => '/opt/consul',
      'datacenter'       => 'laptop',
      'log_level'        => 'INFO',
      'enable_syslog' => true,
#      'node_name'        => 'server',
      'server'           => true,
      'retry_join'       => ['172.16.32.10', '172.16.32.11'],
    }
  }
}

node 'host-4' {
  include ::consul_check::puppet 
  
  class { '::consul':
    extra_options => "-bind $::ipaddress_eth1",
    pretty_config => true,
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'laptop',
      'log_level'  => 'INFO',
      'enable_syslog' => true,
#      'node_name'  => 'agent',
      'retry_join' => ['172.16.32.10','172.16.32.11','172.16.32.12' ],
    }
  }

}

class consul_check::puppet {
  # script from https://raw.githubusercontent.com/ripienaar/monitoring-scripts/master/puppet/check_puppet.rb
  
  ::consul::check { 'check_puppet_resources':
    interval => '30s',
    script   => '/vagrant/scripts/check_puppet.rb -f -c 1 -w 1',
  }

#  ::consul::check { 'check_puppet_time':
#    interval => '30s',
#    script   => '/vagrant/scripts/check_puppet.rb -c 360 -w 360',
#  }
}

