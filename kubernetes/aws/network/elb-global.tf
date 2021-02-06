resource "aws_globalaccelerator_accelerator" "example" {
  name            = "Example"
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled   = false
    flow_logs_s3_bucket = "example-bucket"
    flow_logs_s3_prefix = "flow-logs/"
  }
}

resource "aws_globalaccelerator_listener" "example" {
  accelerator_arn = aws_globalaccelerator_accelerator.example.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

#resource "aws_globalaccelerator_endpoint_group" "example" {
#  listener_arn = aws_globalaccelerator_listener.example.id
#
#  endpoint_configuration {
#    endpoint_id = aws_lb.example.arn
#    weight      = 100
#  }
#}
