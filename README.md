# Akashi - Build infrastructure on VPC

## Introduction
```
$ bundle install --without development
$ cp config/aws.yml.exapmle config/aws.yml
$ vi config/aws.yml
Describe credentials and region of AWS
```

## Usage
```
$ bundle exec bin/akashi <action> <application> <environment>
action choose from build, destroy (destroy action not implemented yet)
```

## Configurations
### VPC
10.0.0.0/16

### Roles
|Role|Cidr block
|---|---|
|Load Balancer|10.0.0.0/19|
|SSH Gateway|10.0.32.0/19|
|Database|10.0.64.0/19|
|Web Server|10.0.96.0/19|

#### Allowed input
|Role|Protocol|Port|Source|
|---|---|---|---|
|Load Balancer|TCP|443|0.0.0.0/0|
|SSH Gateway|TCP|9922|0.0.0.0/0|
||ICMP|-|0.0.0.0/0|
|Database|TCP|3306|10.0.96.0/19|
|Web Server|TCP|80|10.0.0.0/19|
||TCP|9922|10.0.32.0/19|
||ICMP|-|10.0.32.0/19|

### Subnets
Cidr is 24. Create subnet every availability zone from cidr block of role.  
Example of Load Balancer: 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24...
