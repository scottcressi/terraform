# bootstrap vault with secrets
1. run secrets.sh
```
bash secrets.sh
```

# download local charts
1. run charts.sh
```
bash charts.sh
```

# setup local kubernetes cluster (optional)
1. run kind
```
kind create cluster
```

# run terraform
1. run terraform in any sub directory
```
cd kubernetes
terraform init
terraform plan
terraform apply
```

# TODO:
```
fix thanos or deprecate in favor of metricbeat
fix logging to work out local vs non local for full testing, possibly minio
fix istio telemetry and policy
fix kubeconfig
fix prom variable storage spec
```
