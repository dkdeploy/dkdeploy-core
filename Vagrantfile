unless Vagrant.has_plugin?('vagrant-berkshelf')
  puts "Please install vagrant plugin vagrant-berkshelfs first\n"
  puts " vagrant plugin install vagrant-berkshelf\n\n"
  puts "Exit vagrant\n\n"
  abort
end

Vagrant.require_version '~> 2.0'

Vagrant.configure(2) do |config|
  chef_version = '13.6.4'
  domain = 'dkdeploy-core.test'
  ip_address = '192.168.156.180'

  # Search boxes at https://atlas.hashicorp.com/search.
  config.vm.box = 'bento/ubuntu-16.04'
  config.vm.box_check_update = false
  config.berkshelf.enabled = true

  config.vm.define('dkdeploy-core', primary: true) do |master_config|
    master_config.vm.network 'private_network', ip: ip_address
    master_config.vm.hostname = domain

    # Chef settings
    master_config.vm.provision :chef_solo do |chef|
      chef.install = true
      chef.channel = 'stable'
      chef.version = chef_version
      chef.log_level = :warn
      chef.add_recipe 'dkdeploy-core'
    end

    # Memory limit and name of Virtualbox
    master_config.vm.provider 'virtualbox' do |virtualbox|
      virtualbox.name = domain
      virtualbox.gui = ENV['ENABLE_GUI_MODE'] && ENV['ENABLE_GUI_MODE'] =~ /^(true|yes|y|1)$/i
      virtualbox.customize [
                              'modifyvm', :id,
                              '--natdnsproxy1', 'off',
                              '--natdnshostresolver1', 'on',
                              '--memory', '1024',
                              '--audio', 'none'
                           ]
    end
  end

  unless Vagrant.has_plugin?('vagrant-hostsupdater')
    master_config.vm.post_up_message = <<-HEREDOC
        Add following entries to your host file or install vagrant plugin vagrant-hostsupdater ("vagrant plugin install vagrant-hostsupdater") and restart virtual box
          #{ip_address} #{domain}
    HEREDOC
  end
end
