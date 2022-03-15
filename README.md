# ECS Website project

This is a terraform project in which a website counter was containerised and 
provisioned as IaC. 

The first step for our terraform project was architect our solution

## Terraform QuickStart

1. Install providers and modules
    ```shell
    terraform init
    ``` 

2. Plan Terraform changes
    ```shell
    terraform plan
    ``` 

3. Apply Terraform changes 
    ```shell
    terraform apply 
    ```

## Docker QuickStart

1. get authentication
    ```shell
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 517586233148.dkr.ecr.us-east-1.amazonaws.com
    ```

2. Build image (make sure you are in same directory as counter)
    ```shell
    docker build . -t 517586233148.dkr.ecr.us-east-1.amazonaws.com/counter
    ```

3. Push image to ecr
   ```shell
   docker push 517586233148.dkr.ecr.us-east-1.amazonaws.com/counter
   ```