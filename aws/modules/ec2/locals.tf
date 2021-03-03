locals {
  instance-userdata = <<EOF
#!/bin/bash
echo foo > /tmp/foo.txt
sudo yum install -y nmap-ncat
sudo yum install -y https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm
sudo yum install -y puppet-agent
EOF
}
