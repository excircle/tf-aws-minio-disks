# Terraform Module For Disks Provisioning

This repository was created to house a Terraform module that dynamically handles EBS volumes for AWS EC2 nodes.

# Historical Reference.

This module was created to address an issue with intra-module sourcing of disks.

#### Original Plan

Control number of disks from single-module declaration:

```go
module "minio-cluster" {
 source = "github.com/excircle/tf-aws-minio-cluster"

  application_name          = "minio-cluster"
  system_user               = "ubuntu"
  hosts                     = 2                              // Number of nodes with MinIO installed
  vpc_id                    = module.minio-vpc.vpc_id
  ebs_root_volume_size      = 10
  ebs_storage_volume_size   = 10
  make_private              = false
  ec2_instance_type         = "t2.medium"
  ec2_ami_image             = "ami-0b8c6b923777519db"        
  az_count                  = 2                              
  subnets                   = module.minio-vpc.subnets
  num_disks                 = 4                              // <<<<ISSUE HERE Creates a number of disks
  sshkey                    = var.sshkey                     
  ec2_key_name              = "quick-key"
  package_manager           = "apt"
  bastion_host              = false
}
```

#### Original Implementation

```go
resource "aws_ebs_volume" "minio_disks" {
  depends_on = [ aws_instance.minio_host ]
  for_each          = { for v in local.ebs_volumes : v.unique_key => v }
  availability_zone = each.value.availability_zone
  size              = var.ebs_storage_volume_size
  type              = "gp3"

  tags = {
    Name    = each.key
    ID      = each.value.id
    Drive   = each.value.disk_name
  }
}

resource "aws_volume_attachment" "minio_disk_attachments" {
  for_each    = aws_ebs_volume.minio_disks
  device_name = format("/dev/%s", each.value.tags.Drive)
  volume_id   = each.value.id
  instance_id = each.value.tags.ID
}

resource "aws_instance" "minio_host" {
  for_each = toset(local.host_names) 

  ami                         = var.ec2_ami_image
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.access_key.key_name
  associate_public_ip_address = var.make_private == false ? true : false
  vpc_security_group_ids      = [aws_security_group.main_vpc_sg.id]
  subnet_id = length(var.subnets.private) > 0 ? element([for v in var.subnets.private : v], random_integer.subnet_selector[each.key].result % length(var.subnets.private)) : element([for v in var.subnets.public : v], random_integer.subnet_selector[each.key].result % length(var.subnets.public))

  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name # Attach Profile To allow AWS CLI commands
]

  tags = merge(
    local.tag,
    {
      Name = "${each.key}"
      Purpose = format("%s Cluster Node", var.application_name)
    }
  )
}
```
