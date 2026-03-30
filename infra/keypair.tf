# Generate a 4096-bit RSA private key locally
resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register the public key as an EC2 Key Pair
resource "aws_key_pair" "jenkins_keypair" {
  key_name   = "jenkins-keypair"
  public_key = tls_private_key.jenkins_key.public_key_openssh
}

# Save the private key to a local .pem file
resource "local_file" "private_key" {
  content         = tls_private_key.jenkins_key.private_key_pem
  filename        = "${path.module}/jenkins-keypair.pem"
  file_permission = "0400"   # chmod 400 — SSH requires this
}