### The Ansible inventory file
output "inventory" {
value = <<INVENTORY
{ "_meta": {
        "hostvars": {
    %{ for index, name in yandex_compute_instance.gitlab-ci-vm[*].name ~}
           "${name}": {
             "host_name": "${yandex_compute_instance.gitlab-ci-vm[index].name}",
             "host_ext_ip": "${yandex_compute_instance.gitlab-ci-vm[index].network_interface.0.nat_ip_address}" 
           },  
    %{ endfor ~}
           "dummy": { } 
        }
    
    },
  "gitlab-ci-vm": { 
    "hosts": [
       "${join("\",\"", yandex_compute_instance.gitlab-ci-vm.*.name)}"
              ]
  }

}
    INVENTORY
}
#output "App_ip_address" {
#  value = "${formatlist(
#    "id = %s: ext ip = %s, int ip = %s",
#    yandex_compute_instance.docker-host[*].id,
#    yandex_compute_instance.docker-host[*].network_interface.0.nat_ip_address,
#    yandex_compute_instance.docker-host[*].network_interface.0.ip_address
#  )}"
#}

