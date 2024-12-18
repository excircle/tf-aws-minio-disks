locals {
  minio_hosts = var.minio_hosts

  ebs_volumes = flatten([
    for host_key, host_info in local.minio_hosts : [
      for disk in var.disk_names : {
        unique_key        = format("%s__%s__%s", host_info.id, host_info.availability_zone, disk)
        id                = host_info.id
        availability_zone = host_info.availability_zone
        disk_name         = disk
      }
    ]
  ])
}
