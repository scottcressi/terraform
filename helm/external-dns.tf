resource "kubernetes_namespace" "external-dns" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "external-dns"
  }
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "3.3.0"
  namespace  = "external-dns"

  depends_on = [kubernetes_namespace.external-dns]

  values = [<<EOF
rbac:
  create: true
publishInternalServices: true
domainFilters: ["${var.environment}.${var.zone}.com"]
replicas: 2
metrics:
  enabled: true
aws:
  credentials:
    accessKey: aws_iam_access_key.external_dns.id
    secretKey: aws_iam_access_key.external_dns.encrypted_secret
EOF
  ]

}

resource "aws_iam_access_key" "external_dns" {
  user    = aws_iam_user.external_dns.name
}

resource "aws_iam_user" "external_dns" {
  name = "loadbalancer"
  path = "/system/"
}

resource "aws_iam_user_policy" "external_dns" {
  name = "test"
  user = aws_iam_user.external_dns.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

output "external_dns_secret" {
  value = aws_iam_access_key.external_dns.encrypted_secret
}
