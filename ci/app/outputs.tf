output "pwd" {
 value     = random_password.vm.result
 sensitive = true
}