#!/bin/bash
confluent iam service-account list --output json |
    jq -r '.[].id' |
    xargs confluent iam service-account delete --force
