resource "local_file" "foo" {
    content     = "${var.webapp_possible_outbound_ip_addresses}"
    filename = "${path.module}/webapp_possible_outbound_ip_addresses.txt"
}
