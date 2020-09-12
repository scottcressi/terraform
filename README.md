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
cd helm
terraform init
terraform plan
terraform apply
```

TODO:
fix prometheus storage for local and ec2
fix thanos
fix logging to work with local and non local
