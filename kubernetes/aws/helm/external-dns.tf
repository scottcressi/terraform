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
replicas: 2
metrics:
  enabled: true
aws:
  credentials:
    accessKey: ${aws_iam_access_key.external_dns.id}
    secretKey: ${aws_iam_access_key.external_dns.secret}
EOF
  ]

}

resource "aws_iam_access_key" "external_dns" {
  user = aws_iam_user.external_dns.name
}

resource "aws_iam_user" "external_dns" {
  name = "external-dns"
}

resource "aws_iam_user_policy" "external_dns" {
  name = "test"
  user = aws_iam_user.external_dns.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/${var.environment}.${var.zone}.com"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
