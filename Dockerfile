FROM ubuntu:18.04

RUN echo "UTC" > /etc/localtime
RUN apt-get update && apt-get install -y curl openssl unzip openssh-client git jq awscli

WORKDIR /opt
RUN curl https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && mv terraform /usr/local/bin/ && rm -f terraform.zip

COPY ./base-kubernetes ./base-kubernetes/
COPY ./data-kubernetes ./data-kubernetes/
COPY ./terraform ./terraform/
COPY ./key ./key/
ADD ./scripts ./
