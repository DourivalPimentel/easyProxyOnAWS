# Easy Proxy on AWS using Terraform
## Simple steps to spin up a cheap AWS EC2 Instance as proxy.

#### Beware!! This kind of proxy should be used to access private resources inside AWS or another VPN.
#### This will not work to access prohibit resources outside your country, since AWS IPs are most likely blacklisted.

1. Clone this repo:
    ```sh
    git clone git@github.com:DourivalPimentel/easyProxyOnAWS.git
    ```
2. If you don't have AWS Cli or Terraform setup, follow the tutorials bellow:
    1. Install [Terraform](https://askubuntu.com/questions/983351/how-to-install-terraform-in-ubuntu) to spin up the EC2 from command line
    2. Create a [new AWS account](https://aws.amazon.com/pt/) with [programatic access](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console).
    3. Install [AWS Cli](https://linuxhint.com/install_aws_cli_ubuntu/) to allow access to your AWS account.
3. Go to the projects folder:
    ```
    cd easyProxyOnAWS
    ```
4. Start Terraform:
    ```sh
    terraform init
    ```
5. Deploy as follow:

    If you want to restrict access to your home IP ([find your IP here](https://www.whatismyip.com/)):
    ```sh
    TF_VAR_allowed_cidr=your.ip/32 terraform apply
    ```
    OR if you want to leave it open:
    
    ```sh
    terraform apply -var-file="var.tfvars"
    ```
6. Copy your private key and public key content and paste it onto a file on your .ssh folder:
    ```sh
    sudo rm ~/.ssh/easyProxyKey.pem
    sudo rm ~/.ssh/easyProxyKey
    private_key=$(terraform output ssh_private_key | grep '=' | cut -d '"' -f 4)
    sudo echo -e $private_key > ~/.ssh/easyProxyKey.pem
    chmod 400 ~/.ssh/easyProxyKey.pem
    public_key=$(terraform output ssh_public_key | grep '=' | cut -d '"' -f 4)
    sudo echo -e $public_key > ~/.ssh/easyProxyKey
    chmod 400 ~/.ssh/easyProxyKey
    ```
7. Start a ssh tunnel to the instance:
    ```sh
    ip=$(terraform output instances | grep '=' | cut -d '"' -f 4)
    ssh -N -D 8080 -i  "~/.ssh/easyProxyKey.pem" ec2-user@$ip
    ```
