# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

# Define variables for AWS CLI authentication from host
aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']

# Define variables for path to SSH public & private keys for AWS from host
aws_keypair_pub_key_path = "~/.ssh/id_rsa.pub"
aws_keypair_pri_key_path = "~/.ssh/id_rsa"

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

# Copy SSH public & private keys for AWS to guest
  config.vm.provision "file", source: "#{aws_keypair_pub_key_path}", destination: "/home/vagrant/.ssh/id_rsa.pub"
  config.vm.provision "file", source: "#{aws_keypair_pri_key_path}", destination: "/home/vagrant/.ssh/id_rsa"

# Write AWS CLI authentication ENV variables to ~/.profile on guest | Warn if variables are not set on host
if ENV['AWS_ACCESS_KEY_ID']
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    echo "export AWS_ACCESS_KEY_ID=#{aws_access_key_id}" >>~/.profile
    echo "export AWS_SECRET_ACCESS_KEY=#{aws_secret_access_key}" >>~/.profile
  SHELL
else
  config.vm.post_up_message = "AWS API credential variables not found on host; You must set them manually on guest"
end

# Run the provision-vagrant.sh script
  config.vm.provision "shell", privileged: false, path: "scripts/provision-vagrant.sh"

# Set path at login to /vagrant/
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    echo "cd /vagrant/" >> /home/vagrant/.bashrc
  SHELL

end