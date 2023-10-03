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

variable "cors_rules" {
  description = "CORS config for bucket"
  type = list(object({
    id              = optional(string)
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
  validation {
    condition     = alltrue([for rule in var.cors_rules : alltrue([for method in rule.allowed_methods : contains(["GET", "PUT", "HEAD", "POST", "DELETE"], method)])])
    error_message = "Variable `cors_rules.allowed_methods` must only contain \"GET\", \"PUT\", \"HEAD\", \"POST\", or \"DELETE\""
  }
}
