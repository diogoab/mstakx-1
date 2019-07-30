#!/bin/bash
cd ../../data-kubernetes && \
aws s3 cp --recursive ca s3://data-kubernetes/ca/ && \
aws s3 cp --recursive etcd s3://data-kubernetes/etcd/ && \
aws s3 cp --recursive apiserver s3://data-kubernetes/apiserver/ && \
aws s3 cp --recursive worker s3://data-kubernetes/worker/ && \
aws s3 cp --recursive bastion s3://data-kubernetes/bastion/
