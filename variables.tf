variable "region" {
  default = "ap-southeast-2"
  type = string
}

variable "port" {
  default = 5000
  type = number
  description = "The port to access to the server in our instance"
}