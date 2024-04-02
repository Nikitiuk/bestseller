## Bestseller Technical assignment

This repository contains my solution for the Betseller Technical assignment

The Terraform code implements all the necessary network components, role, security groups, policies, load balancer, autoscale group and everything needed by those components

#### Requirements

To run the terraform code it's necessary:
- To have the AWS credentials configured in the desktop;
- That the user have enough privileges to create the components
- To set the variables' default on terraform/variables.tf to reflect the intended values

#### Configuration Overview

Overview of the components implemented by the Terraform code:

- **VPC:** Network where all the components will be placed;
- **Subnets:** Private and Public subnets;
- **Internet Gateway:** Necessary for the resources in the Public subnet to access Internet;
- **NAT Gateway and EIP:** Necessary for the resources in the Private subnet to access Internet;
- **IAM Role and IAM Policy:** To allow the ASG Instances to access S3;
- **Security Groups:** To allow HTTP traffic to the Load Balancer from Internet;
- **Target Group:** To redirect the traffic from the Load Balancer to the ASG Instances
- **Load Balancer:** To redirect the HTTP traffic to the instances in the Target Group
- **Autoscale Group:** To scale up or down the number of instances to process the HTTP requests
- **Autoscaling policies:** To scale up the number of the ASG instances when it reaches 80% of CPU usage and scale down when it goes under 60% of CPU usage
- **Cloudwatch Metric Alarms:** To trigger the Autoscaling policies

#### Running the code

It was tested with Terraform version 1.2.8 and aws provider version 5.43.0

Initialize the terraform environment with: ***terraform init***

Verify the changes before apply, using: ***terraform plan***

If the changes are approved, apply it using: ***terraform apply*** and confirm typing *yes* when requested

#### Security considerations

The Policy to allow access to S3 is allowing access to all S3 buckets. It would be safer to restrict to the specific bucket(s) it needs access to