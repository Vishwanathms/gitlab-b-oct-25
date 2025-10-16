variable "controller_vm" {
  type = object({
    count  = number
    name   = string
    cpus   = number
    memory = number
  })
  default = {
    count  = 1
    name   = "openstack-controller"
    cpus   = 4
    memory = 8192
  }
}
variable "compute_count" {
  type = number
  default = 1
}
variable "compute_cpus" {
  type = number
  default = 4
}
variable "compute_memory" {
  type = number
  default = 8192
}
variable "controller_ip_add" {
    type = list
}
variable "compute_ip_add" {
    type = list
}
variable "vcenter_user" {}
variable "vcenter_password" {}
variable "access_key" {}
variable "secret_key" {}
# variable "dynamodb_table" {}
variable "ubuntu_password_hash" {
  default = "$6$rounds=4096$hYn5J264F5NJYLoh$ZKHire7EAPHOrPbc3G4i3NDV0997.j5z6gq/kKIo4nVwzWtuAkTplfc/3Knr51shnD19MVu1/LkTh9kp/bJ7o1"
}
variable "ssh_key" {
  description = "SSH key for the ubuntu user"
  type        = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPXnCMxKETYtAGriigIJ4fULx53hw4Ahej2H3FQ9Afze4B0vMy/ODxBYCM4juvNrXp/q49A38zxfCc0EPF9FK7ucLt9w4f2rMdGUBtU9LjGoA1vjfJltiTG+8F1ltL710GbldH7TiGVsbj2fH3lz+OPXVduqDR5tzHB/7DbLx6QtpFNDZo1BLUVPgC1AF9HHbQ7suguXhT9yFhN1zai026N2yVoBpE6Z6qxffKWcxFKpW7hD14fH/8a0pB5U8fiH30ApTpFvlATPJiDOe2st45jyVBbWJ4L51ahuMrbaWMVJ3nzbldhqCA5/ZqCfQeWpI2mNFWwoAVYlwOhKhq5eEkc6KOgFfRbe4a2O0n8WfO0Z3hOLP818p4VY/+7kimSRJrERbNk8TRmpqQDd87CGf1hNEEx+lOA91bytkdTX8V/xuYCQHkv++8BJjovgYHR+PnXopzZP5p80Ffv974MpnG97+1EmoRwxocDCNeyVDQ0jxw1VLDxsg2CLxZQCN2LMk= admin@DESKTOP-O7MI7ID"
}
variable "env" {}
variable "private_key_path" {
  description = "Path to the private key for SSH access"
  type        = string
  default     = "~/.ssh/id_rsa"
}