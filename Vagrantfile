# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

# require 'fileutils'

# # file operations needs to be relative to this file
# VAGRANT_ROOT = File.dirname(File.expand_path(__FILE__))

# # directory that will contain VDI files
# VAGRANT_DISKS_DIRECTORY = "disks"

# # controller definition
# VAGRANT_CONTROLLER_NAME = "Virtual I/O Device SCSI controller"
# VAGRANT_CONTROLLER_TYPE = "virtio-scsi"

# # define disks
# # The format is filename, size (GB), port (see controller docs)
# local_disks = [
#   { :filename => "disk1", :size => 500, :port => 5 }
# ]


Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    # config.vm.box_version = "20221121.0.0"
    config.vm.disk :disk, size: "500GB", primary: true

    config.vm.box_check_update = false
    config.ssh.insert_key = false
    # insecure_private_key download from https://github.com/hashicorp/vagrant/blob/master/keys/vagrant
    config.ssh.private_key_path = "insecure_private_key"

    my_machines = {
        'hadoop'   => '192.168.22.222',
    }

    my_machines.each do |name, ip|
        config.vm.define name do |machine|
            machine.vm.network "private_network", ip: ip

            machine.vm.hostname = name
            machine.vm.provider :virtualbox do |vb|
                vb.name = name  
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                vb.customize ["modifyvm", :id, "--vram", "64"]
                vb.customize ["modifyvm", :id, "--ioapic", "on"]
                vb.customize ["modifyvm", :id, "--cpus", "4"]
                vb.customize ["modifyvm", :id, "--memory", "16384"]
            end

            # disks_directory = File.join(VAGRANT_ROOT, VAGRANT_DISKS_DIRECTORY, name)

            # # create disks before "up" action
            # machine.trigger.before :up do |trigger|
            #     trigger.name = "Create disks"
            #     trigger.ruby do
            #     unless File.directory?(disks_directory)
            #         puts "Creating disks_directory \"#{disks_directory}\""
            #         FileUtils.mkdir_p(disks_directory)
            #     end
            #     local_disks.each do |local_disk|
            #         local_disk_filename = File.join(disks_directory, "#{local_disk[:filename]}.vdi")
            #         unless File.exist?(local_disk_filename)
            #             puts "Creating \"#{local_disk[:filename]}\" disk"
            #             system("vboxmanage createmedium --filename #{local_disk_filename} --size #{local_disk[:size] * 1024} --format VDI")
            #         end
            #     end
            #     end
            # end

            # # create storage controller on first run
            # unless File.directory?(disks_directory)
            #     machine.vm.provider "virtualbox" do |storage_provider|
            #     storage_provider.customize ["storagectl", :id, "--name", VAGRANT_CONTROLLER_NAME, "--add", VAGRANT_CONTROLLER_TYPE, '--hostiocache', 'off']
            #     end
            # end

            # begin
            #     machine.vm.provider "virtualbox" do |storage_provider|
            #         storage_provider.customize ["storagectl", :id, "--name", VAGRANT_CONTROLLER_NAME, "--add", VAGRANT_CONTROLLER_TYPE, '--hostiocache', 'off']
            #     end
            # ensure # will always get executed
            #     puts 'always try create storage controller on first run'
            # end

            # attach storage devices
            # machine.vm.provider "virtualbox" do |storage_provider|
            #     local_disks.each do |local_disk|
            #     local_disk_filename = File.join(disks_directory, "#{local_disk[:filename]}.vdi")
            #         #unless File.exist?(local_disk_filename)
            #         begin    
            #             puts "attach storage devices \"#{local_disk_filename}\""
            #             storage_provider.customize ['storageattach', :id, '--storagectl', VAGRANT_CONTROLLER_NAME, '--port', local_disk[:port], '--device', 0, '--type', 'hdd', '--medium', local_disk_filename]
            #         end
            #     end
            # end

            # # cleanup after "destroy" action
            # machine.trigger.after :destroy do |trigger|
            #     trigger.name = "Cleanup operation"
            #     trigger.ruby do
            #     # the following loop is now obsolete as these files will be removed automatically as machine dependency
            #     local_disks.each do |local_disk|
            #         local_disk_filename = File.join(disks_directory, "#{local_disk[:filename]}.vdi")
            #         if File.exist?(local_disk_filename)
            #         puts "Deleting \"#{local_disk[:filename]}\" disk"
            #         system("vboxmanage closemedium disk #{local_disk_filename} --delete")
            #         end
            #     end
            #     if File.exist?(disks_directory)
            #         FileUtils.rmdir(disks_directory)
            #     end
            #     end
            # end
            machine.vm.provision "shell", path: "scripts/provision.sh"
            # machine.vm.provision "shell", inline: <<-SHELL
            #     echo "root:vagrant" | sudo chpasswd
            #     timedatectl set-timezone "Asia/Shanghai"
            # SHELL


            #machine.vm.provision :shell, path: "scripts/lvm2-fdisk.sh"
            # machine.vm.provision :shell, path: "scripts/install-docker.sh"

            # machine.vm.provision "shell", inline: <<-SHELL
            #     reboot
            # SHELL

        end
    end




end