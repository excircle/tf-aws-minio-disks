resource "aws_ebs_volume" "minio_disks" {
  for_each = { for v in local.ebs_volumes : v.unique_key => v }

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
  for_each = aws_ebs_volume.minio_disks

  device_name = format("/dev/%s", each.value.tags.Drive) # Device name based on the "Drive" tag
  volume_id   = each.value.id                            # The EBS volume ID
  instance_id = each.value.tags.ID                       # EC2 instance ID (from "tags.ID")
}
