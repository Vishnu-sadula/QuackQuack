variable "access_key" {
    
}

variable "secret_key" {
    
}

variable "frontend_url" {
  type    = string
  default = "http://localhost:8000"
}

variable "mongo_uri" {
  type    = string
  default = ""
}

variable "instance_name" {
  type    = string
  default = "zapier"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "key_name" {
  type    = string
  default = "zapier"
} 