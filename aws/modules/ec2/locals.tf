locals {
  instance-userdata = <<EOF
#!/bin/bash
echo foo > /tmp/foo.txt
sudo yum install -y telnet
EOF
}
