#Partners Access v1.0 - Jeremy CANALE


provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "active_directory" {
  cidr_block = "${var.vpc_active_directory_cidr}"
}

resource "aws_vpc" "workspaces" {
  cidr_block = "${var.vpc_workspaces_cidr}"
}

resource "aws_subnet" "subnet_workspaces_1a" {
  vpc_id            = "${aws_vpc.workspaces.id}"
  availability_zone = "eu-west-1a"
  cidr_block        = "${var.vpc_workspaces_subnet1a}"
}

resource "aws_subnet" "subnet_workspaces_1b" {
  vpc_id            = "${aws_vpc.workspaces.id}"
  availability_zone = "eu-west-1b"
  cidr_block        = "${var.vpc_workspaces_subnet1b}"
}

resource "aws_subnet" "subnet_active_directory_1a" {
  vpc_id            = "${aws_vpc.active_directory.id}"
  availability_zone = "eu-west-1a"
  cidr_block        = "${var.vpc_active_directory_subnet1a}"
}

resource "aws_subnet" "subnet_active_directory_1b" {
  vpc_id            = "${aws_vpc.active_directory.id}"
  availability_zone = "eu-west-1b"
  cidr_block        = "${var.vpc_active_directory_subnetba}"
}

resource "aws_directory_service_directory" "partners_access" {
  name     = "partners.thalesgroup.com"
  password = "SuperSecretPassw0rd"
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = "${aws_vpc.active_directory.id}"
    subnet_ids = ["${aws_subnet.vpc_active_directory_subnet1a.id}", "${aws_subnet.vpc_active_directory_subnet1b.id}"]
  }
}

//Peering
//Requester: TPA-PRZ (VPC Workspaces) vers TPA-PRZ (vpc ActiveDirectory)
//(meme account)
resource "aws_vpc_peering_connection" "peering_intra" {
  peer_owner_id = "${var.source_account_id}"
  peer_vpc_id   = "${aws_vpc.active_directory.id}"
  vpc_id        = "${aws_vpc.workspaces.id}"
  auto_accept   = true

  tags {
    Name = "VPC Peering between TPA-Workspaces and TPA-AD"
  }
}

//Peering
//Requester: TPA-PRZ (VPC Workspaces) vers HZ-PRZ (vpc netscaler)
//(cross account)
resource "aws_vpc_peering_connection" "peering_requester" {
  provider      = "aws.requester"
  peer_owner_id = "${var.source_account_id}"
  peer_vpc_id   = "${var.hz_netscaler_vpc}"
  vpc_id        = "${aws_vpc.workspaces.id}"

  tags {
    Name = "VPC Peering between TPA-Workspaces and HZ-PRZ"
  }
}

//Peering
// Accepter: HZ-PRZ (VPC netscaler) venant de TPA-PRZ (Workspaces)
//(cross account)
resource "aws_vpc_peering_connection_accepter" "peering_acceptor" {
  provider                  = "aws.acceptor"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering_requester.id}"

  tags {
    Name = "VPC Peering between HZ-PRZ and TPA-Workspaces "
  }
}

//Creation table de routage pour VPC TPA-WorkSpaces
resource "aws_route_table" "tableWorkspaces" {
  vpc_id = "${aws_vpc.workspaces.id}"
}

//Creation table de routage pour VPC TPA-Active Directory
resource "aws_route_table" "tableActiveDirectory" {
  vpc_id = "${aws_vpc.active_directory.id}"
}

//route entre VPC WorkSpaces (TPA-PRZ) et Netscaler (HZ-PRZ)
resource "aws_route" "peering_requester_acceptor" {
  provider                  = "aws.requester"
  route_table_id            = "${data.aws_route_table.tableWorkspaces.id}"
  destination_cidr_block    = "${var.hz_netscaler_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering_requester.id}"
}

//route entre  Netscaler (HZ-PRZ) et VPC WorkSpaces (TPA-PRZ)
resource "aws_route" "peering_acceptor_requester" {
  provider                  = "aws.acceptor"
  route_table_id            = "${var.hz_route_table}"
  destination_cidr_block    = "${var.vpc_workspaces_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering_acceptor.id}"
}

//route entre VPC WorkSpaces (TPA-PRZ) et VPC Active Directory (TPA-PRZ)
resource "aws_route" "workspacesToactive" {
  route_table_id            = "${data.aws_route_table.tableWorkspaces.id}"
  destination_cidr_block    = "${var.vpc_active_directory_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering_intra.id}"
}

//route entre VPC Active Directory (TPA-PRZ) et VPC Active Directory (TPA-PRZ)
resource "aws_route" "activeToworkspaces" {
  route_table_id            = "${data.aws_route_table.tableActiveDirectory.id}"
  destination_cidr_block    = "${var.vpc_workspaces_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering_intra.id}"
}
