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
terraform plan -var-file="tfvars.$ENV"
terraform apply -var-file="tfvars.$ENV"
```

# TODO:
```
fix thanos or deprecate in favor of metricbeat
fix logging to work out local vs non local for full testing
change dns auto validation to dns method
fix nginx cert and annotations
fix istio telemetry and policy
fix vault local and shared conditional
fix vault kms uniqueness
```
