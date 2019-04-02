# Install Jenkins X

## Install Prerequisites

* [Git](https://git-scm.com/download)
    * [GitBash if Windows](https://gitforwindows.org/)
* Kubectl
* Helm
* Public cloud CLI
    * such as [gcloud](https://cloud.google.com/sdk/docs/quickstarts)

!!! Info
    For Windows, we recommend using the [Chocolatey](https://chocolatey.org/) package manager.

!!! Info
    For Linux, we recommend using the [Snap](https://snapcraft.io/) package manager.

!!! Info
    For MacOS we recommend using the [Homebrew](https://brew.sh/) package manager.

### Git

```bash tab="Debian"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git
```

```bash tab="RHEL"
sudo yum upgrade
sudo yum install git
```

```bash tab="Homebrew"
brew install git
```

```bash tab="Windows"
choco install git.install
choco install hub
```

### Kubectl

```bash tab="Snap"
sudo snap install kubectl --classic
kubectl version
```

```bash tab="Debian"
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

```bash tab="RHEL"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl
```

```bash tab="Homebrew"
brew install kubernetes-cli
```

```bash tab="Windows"
choco install kubernetes-cli
```

```bash tab="Curl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

### Helm

```bash tab="Snap"
sudo snap install helm --classic
```

```bash tab="Homebrew"
brew install kubernetes-helm
```

```bash tab="Windows"
choco install kubernetes-helm
```

For other options, [visit the install guide](https://helm.sh/docs/using_helm/#installing-helm).

### Cloud CLI's

#### AWS

```bash tab="Snap"
sudo snap install aws-cli --classic
```

```bash tab="Homebrew"
brew install awscli
```

```bash tab="Windows"
choco install awscli
```

For other options, [visit the install guide]().

##### EKS CTL

```bash tab="Linux"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

```bash tab="Homebrew"
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
```

```bash tab="Windows"
chocolatey install eksctl
```

For other options, [visit the install guide]().

#### Google

```bash tab="Snap"
sudo snap install google-cloud-sdk --classic
```

```bash tab="Homebrew"
brew cask install google-cloud-sdk.
```

```bash tab="Windows"
choco install gcloudsdk
```

For other options, [visit the install guide](https://cloud.google.com/sdk/docs/quickstarts).

#### Azure

```bash tab="Snap"
sudo snap install aws-cli --classic
```

```bash tab="Homebrew"
brew install awscli
```

```bash tab="Windows"
choco install azure-cli
```

For other options, [visit the install guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

## Install JX Binary

The `jx` binary is the main vehicle for Jenkins X to manage anything related to Jenkins X and your applications.

!!! Warning
    It is recommended to *always* update your `jx` binary at the start of your workday. It gets updates and fixes several times a day, so don't stay behind!

!!! Info
    If you are running on Mac OS X, Jenkins X is using Homebrew to install the various CLI. It will install it if not present.

### Install

```bash tab="Linux"
mkdir -p ~/.jx/bin
curl -L https://github.com/jenkins-x/jx/releases/download/v1.3.1068/jx-linux-amd64.tar.gz | tar xzv -C ~/.jx/bin
export PATH=$PATH:~/.jx/bin
echo 'export PATH=$PATH:~/.jx/bin' >> ~/.bashrc
```

```bash tab="RHEL"
sudo yum upgrade
sudo yum install git
```

```bash tab="Homebrew"
brew tap jenkins-x/jx
brew install jx
```

```bash tab="Windows"
choco install jenkins-x
```

## Install JX w/ Cluster

You can install Jenkins X in an existing Kubernetes cluster, or let it install a cluster for you. Below are the examples for installing a cluster via Jenkins X before it installs itself into it.

!!! Info
    For all the installation options, please consult the `jx` CLI.
    `jx create cluster ${clusterType} --help`
    When in doubt, accept the default value!

### Variables

Set these variables in your console, for use with the install commands.

* `CLUSTER_NAME` your desired cluster name (can be anything)
* `PROJECT` is your Google Cloud `project-id`
    * you can retrieve this via your console or via the gcloud CLI: `gcloud config list`

```bash
REGION=us-east1
ZONE=${REGION}-b
PREFIX=jx
MACHINE_TYPE=n1-standard-2
ADMIN_PSW=admin
CLUSTER_NAME=
PROJECT=
```

### Configuration

!!! Warning
    If you are using Java with Maven or Gradle, you'd want to install Nexus.
    Else, you can disable it as per example below.

#### Disable Nexus

Copy below text into a file called `myvalues.yaml`.

```bash
nexus:
  enabled: false
```

### Install

!!! Info
    `EKS` option will download and use the [eksctl](https://eksctl.io/) tool to create a new EKS cluster, then it’ll install Jenkins X on top.

!!! Info
    When you're creating your first cluster with GKE, you will need to login for authorization. If you have authorization taken care of, you can add `--no-login` to prevent the process.

```bash tab="GKE"
jx create cluster gke -n $CLUSTER_NAME -p $PROJECT -z ${ZONE} \
    -m ${MACHINE_TYPE} --min-num-nodes 3 --max-num-nodes 5 \
    --default-admin-password=${ADMIN_PSW} \
    --default-environment-prefix ${PREFIX} --no-tiller
```

```bash tab="EKS"
jx create cluster eks
```

```bash tab="Kops"
jx create cluster aws
```

```bash tab="Azure"
jx create cluster aks
```

For more options and information, [read the documentation](https://jenkins-x.io/getting-started/create-cluster/).

### Test install

```bash
kubectl -n jx get pods
```

## Install Serverless

### Variables

```bash
CLUSTER_NAME=
PROJECT=
ADMIN_PSW=admin
PREFIX=jx
REGION=us-east1
ZONE=${REGION}-a
MACHINE_TYPE=n1-standard-1
```

### Install

```bash tab="GKE"
jx create cluster gke -n $CLUSTER_NAME -p $PROJECT -z ${ZONE} \
    -m n1-standard-2 --min-num-nodes 3 --max-num-nodes 5 \
    --default-admin-password=${ADMIN_PSW} \
    --default-environment-prefix  \
    --prow --tekton --no-tiller
```