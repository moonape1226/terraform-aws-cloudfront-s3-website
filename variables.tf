variable "domain_name" {
  description = "domain name (or application name if no domain name available)"
}

variable "website_index" {
  type        = string
  default     = "index.html"
  description = "S3 > Properties > Static website hosting > index document"
}

variable "website_error" {
  type        = string
  default     = null
  description = "S3 > Properties > Static website hosting > error document"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "tags for all the resources, if any"
}

variable "hosted_zone" {
  default     = null
  description = "Route53 hosted zone"
}

variable "acm_certificate_domain" {
  default     = null
  description = "Domain of the ACM certificate"
}

variable "price_class" {
  default     = "PriceClass_100" // Only US,Canada,Europe
  description = "CloudFront distribution price class"
}

variable "use_default_domain" {
  default     = false
  description = "Use CloudFront website address without Route53 and ACM certificate"
}

variable "upload_sample_file" {
  default     = false
  description = "Upload sample html file to s3 bucket"
}

variable "extra_origin" {
  description = "One or more extra origins for this distribution (multiples allowed)."
  type        = any
  default     = []
}

variable "ordered_cache_behavior" {
  description = "An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
  type        = any
  default     = []
}

variable "cache_policy_id" {
  type    = string
  default = null
}

variable "origin_request_policy_id" {
  type    = string
  default = null
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
  default = 0
  type    = number
}

variable "max_ttl" {
  default = 0
  type    = number
}

variable "forward_query_string" {
  type        = bool
  default     = false
  description = "Enable query string cache in default cache behavior"
}

variable "query_string_cache_keys" {
  default     = []
  description = "Which query strings will be cached in default cache behavior"
}

variable "forward_header_values" {
  default     = []
  description = "Which headers will be cached in default cache behavior"
}

variable "forward_cookies" {
  default     = "none"
  description = "Which cookies will be cached in default cache behavior"
}

variable "forward_cookies_whitelist_name" {
  default     = []
  description = "Which cookies will be cached in default cache behavior if forward_cookies value is whitelist"
}

variable "viewer_protocol_policy" {
  type    = string
  default = "redirect-to-https"
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
