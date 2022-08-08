resource "local_file" "file" {
    content  = "przykładowytekst\n"
    filename = "file1.txt"
    file_permission = "0644"
}
