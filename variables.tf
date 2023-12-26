variable "domain_name" {
  default     = null
  description = "domain name (or application name if no domain name available)"
  type        = string
}

variable "alias_name" {
  default     = null
  description = "alias name"
  type        = list(string)
}

variable "website_index" {
  default     = "index.html"
  description = "S3 > Properties > Static website hosting > index document"
  type        = string
}

variable "website_error" {
  default     = null
  description = "S3 > Properties > Static website hosting > error document"
  type        = string
}

variable "tags" {
  default     = {}
  description = "tags for all the resources, if any"
  type        = map(string)
}

variable "hosted_zone" {
  default     = null
  description = "Route53 hosted zone"
  type        = string
}

variable "acm_certificate_domain" {
  default     = null
  description = "Domain of the ACM certificate"
  type        = string
}

variable "price_class" {
  default     = "PriceClass_100" // Only US,Canada,Europe
  description = "CloudFront distribution price class"
  type        = string
}

variable "use_default_domain" {
  default     = false
  description = "Use CloudFront website address without Route53 and ACM certificate"
  type        = bool
}

variable "minimum_protocol_version" {
  default     = "TLSv1"
  description = "Minimum SSL protocol version"
  type        = string
}

variable "upload_sample_file" {
  default     = false
  description = "Upload sample html file to s3 bucket"
  type        = bool
}

variable "extra_origin" {
  default     = []
  description = "One or more extra origins for this distribution (multiples allowed)."
  type        = any
}

variable "ordered_cache_behavior" {
  default     = []
  description = "An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
  type        = any
}

variable "cache_policy_id" {
  default = null
  type    = string
}

variable "origin_request_policy_id" {
  default = null
  type    = string
}

variable "allowed_methods" {
  default = ["GET", "HEAD"]
  type    = list(string)
}

variable "cached_methods" {
  default = ["GET", "HEAD"]
  type    = list(string)
}

variable "min_ttl" {
  default = 0
  type    = number
}

variable "default_ttl" {
  default = 86400
  type    = number
}

variable "max_ttl" {
  default = 31536000
  type    = number
}

variable "forward_query_string" {
  default     = false
  description = "Enable query string cache in default cache behavior"
  type        = bool
}

variable "query_string_cache_keys" {
  default     = []
  description = "Which query strings will be cached in default cache behavior"
  type        = list(string)
}

variable "forward_header_values" {
  default     = []
  description = "Which headers will be cached in default cache behavior"
  type        = list(string)
}

variable "forward_cookies" {
  default     = "none"
  description = "Which cookies will be cached in default cache behavior"
  type        = string
}

variable "forward_cookies_whitelist_name" {
  default     = []
  description = "Which cookies will be cached in default cache behavior if forward_cookies value is whitelist"
  type        = list(string)
}

variable "viewer_protocol_policy" {
  default = "redirect-to-https"
  type    = string
}

variable "s3_cors_allowed_headers" {
  default = ["*"]
  type    = list(string)
}

variable "s3_cors_allowed_methods" {
  default = ["GET"]
  type    = list(string)
}

variable "s3_cors_allowed_origins" {
  default = ["*"]
  type    = list(string)
}

variable "s3_cors_expose_headers" {
  default = ["ETag"]
  type    = list(string)
}

variable "s3_cors_max_age_seconds" {
  default = 3000
  type    = number
}

variable "s3_public_accessible" {
  default = false
  type    = bool
}

variable "custom_s3_bucket_policy" {
  default = null
  type    = string
}

variable "custom_header" {
  default = []
  type    = any
}

variable "custom_error_response_path" {
  default = "/index.html"
  type    = string
}
