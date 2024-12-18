variable "minio_hosts" {
  type = map(object({
    id                 = string
    availability_zone  = string
  }))
}

variable "disk_names" {
  description = "Disk names"
  type        = list(string)
}

variable "ebs_storage_volume_size" {
  description = "Root Block Device Size"
  type        = number
}