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
      'client_addr'      => '0.0.0.0',
      'datacenter' => 'laptop',
      'log_level'  => 'INFO',
      'enable_syslog' => true,
#      'node_name'  => 'agent',
      'retry_join' => ['172.16.32.10','172.16.32.11','172.16.32.12' ],
      'ui_dir'           => '/opt/consul/ui',
    }
  }

  ::consul::service { 'web_ui':
    checks => [{
        script   => 'curl -I 127.0.0.1:8500/ui/',
        interval => '10s'
      }
      ],
    port   => 8500,
    tags   => ['web']
  }
}

class consul_check::puppet {
  $puppet_mon_script = 'https://raw.githubusercontent.com/ripienaar/monitoring-scripts/master/puppet/check_puppet.rb'
  
  exec { 'fetch puppet monitoring script':
    cwd     => '/usr/local/bin',
    command => "wget $puppet_mon_script",
    path    => ['/usr/bin'],
    creates => '/usr/local/bin/check_puppet.rb',
  } ->
  file { '/usr/local/bin/check_puppet.rb':
    mode  => '755',
    alias => 'check_puppet',
  }

  ::consul::check { 'check_puppet_resources':
    interval => '30s',
    script   => '/usr/local/bin/check_puppet.rb -f -c 1 -w 1',
    require  => File['check_puppet'],
  }

  ::consul::check { 'check_puppet_time':
    interval => '30s',
    script   => '/usr/local/bin/check_puppet.rb -c 360 -w 360',
    require  => File['check_puppet'],
  }
}

