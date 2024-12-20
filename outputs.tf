# Generate JSON file containing aws_instance.minio_host disk names for first host
resource "local_file" "disk_info" {
  filename = "disk-info.json"
  content  = jsonencode({
    disks     = var.disk_names
    size      = var.ebs_storage_volume_size
    hostnames = var.minio_hosts
  })
}