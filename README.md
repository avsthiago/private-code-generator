# private-code-generator

## Description
You can use this project to host a coge generator like GitHub Copilot privately on AWS.

## How to use

1. Build the docker image
```bash
make build
```

1.1. if you want to test the docker image locally, you can run the following command
```bash
make run
```

You can then access the code generator at http://localhost:8080. You can test it by sending a POST request to http://localhost:8080/invocations like in the following example:
``` bash
curl -X POST http://localhost:8080/invocations -d '{"inputs": "def ", "parameters": {"max_new_tokens": ""}}'
```

2. Bootstrap the infrastructure

2.0. Prerequisites:

Export the ID of your AWS account as an environment variable:

```bash
export AWS_ACCOUNT_ID=
```

2.1. Setup the access to your AWS account:

Before you can bootstrap the infrastructure, you need to configure the access to your AWS account. You can find more information about how to do that [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html). 

2.2. Setup terraform:
You also need to have terraform installed. You can find more information about how to do that [here](https://learn.hashicorp.com/tutorials/terraform/install-cli). For my terraform setup I used tfswitch. You can find more information about how to do that [here](https://tfswitch.warrensbox.com/Install/). If you are also using tfswitch, you just need to go inside the `account_bootstrap` folder and run `tfswitch` to install the correct terraform version.

2.3. Configure the terraform variables:
You can configure the terraform variables by changing the `terraform.tfvars` file inside the `account_bootstrap` folder.

2.4. Bootstrap the infrastructure:
Once you have configured the access to your AWS account, installed terraform and setup the `tfvars`, you can bootstrap the infrastructure by running the following command:
```bash
make bootstrap
```

3. Build the docker image

Before building the image, you can change the image name and tag inside the `Makefile` file. You can then build the image by running the following command:

```bash
make build
```

4. Push the docker image to ECR

Before pushing the image, set the ID of your AWS account and the region where you want to push the image inside the `Makefile` file. You can then push the image by running the following command:

```bash
make login
make push
```

The make login will use the docker login command under the hood. You can find more information about how to configure the docker login [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry_auth.html).

5. Deploy the code generator

```bash
make setup-endpoint
```





