# bootstrap vault with secrets
1. run secrets.sh
```
bash secrets.sh
```

# run terraform
1. run terraform in any sub directory
```
cd eks
terraform init
terraform plan
terraform apply
```

TODO:
fix prometheus storage for local and ec2
fix thanos
fix logging to work with local and non local
