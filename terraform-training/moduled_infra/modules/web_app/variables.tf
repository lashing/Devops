variable "web_whitelist" {
  type = list(string)
}
variable "web_ami" {
  type = string
}
variable "web_instance_type" {
  type = string
}
variable "web_desired_capacity" {
  type = number
}
variable "web_max_size" {
  type = number
}
variable "web_min_size" {
  type = number
}
variable  "security_groups" {
  type = list(string)
}
variable  "subnets" {
  type = list(string)
}
variable "web-app" {
  type = string
}
