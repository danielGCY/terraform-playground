variable "bucket_name" {
  description = "Name of bucket"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Tags to set on the bucket"
  type        = map(string)
  default     = {}
}
