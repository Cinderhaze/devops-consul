# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = 'example.com'

puppet_box = "mayflower/trusty64-puppet3"
nodes = [
  {:hostname => 'host-1', :ip => '172.16.32.10', :box => puppet_box, :fwdhost => 8500, :fwdguest => 8500, :ram => 512},
  {:hostname => 'host-2', :ip => '172.16.32.11', :box => puppet_box },
  {:hostname => 'host-3', :ip => '172.16.32.12', :box => puppet_box },
  {:hostname => 'host-4', :ip => '172.16.32.13', :box => puppet_box },
]

Vagrant.configure("2") do |config|
  nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box]
      node_config.vm.box_url = 'http://files.vagrantup.com/' + node_config.vm.box + '.box'
      node_config.vm.hostname = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]

      if node[:fwdhost]
        node_config.vm.network :forwarded_port, guest: node[:fwdguest], host: node[:fwdhost]
      end

      memory = node[:ram] ? node[:ram] : 256;
      node_config.vm.provider :virtualbox do |vb|
        vb.customize [
          'modifyvm', :id,
          '--name', node[:hostname],
          '--memory', memory.to_s
        ]
      end

      node_config.vm.provision "shell",
         inline: <<EOF
apt-get update
rmdir /etc/puppet/modules
ln -s /vagrant/puppet/modules /etc/puppet/modules
rmdir /etc/puppet/manifests
ln -s /vagrant/puppet/manifests /etc/puppet/manifests
EOF

      node_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = 'puppet/manifests'
        puppet.module_path = 'puppet/modules'
      end
    end
  end
end
