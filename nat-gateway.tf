resource "aws_nat_gateway" "ngw" {
  count         = length(aws_subnet.public_subnets)
  allocation_id = aws_eip.ngw_ip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "ngw_${count.index + 1}"
  }
}

resource "aws_eip" "ngw_ip" {
  count      = length(aws_subnet.public_subnets)
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "ngw_ip_${count.index + 1}"
  }
}