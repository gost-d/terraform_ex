variable ips {
   
    default = {ip_addrs = ["0.0.0.0", "8.8.8.8", "127.0.0.1"], port=8080}
}

resource "local_file" "file3" {
    content  = templatefile("template.templ", var.ips)
        filename = "backend-${random_string.name[count.index].result}"
    count = 3
}

resource "random_string" "name" {
    length = 3
    count = 3
    special = false
} 
