
# Define the MongoDB Atlas Provider
terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
  required_version = "~> 1.15"
}

provider "mongodbatlas" {
  public_key  = var.MONGODB_ATLAS_PUBLIC_KEY
  private_key = var.MONGODB_ATLAS_PRIVATE_KEY
}


# Create a Project
resource "mongodbatlas_project" "myproject" {
  name   = "My Project"
  org_id = var.MONGODB_ATLAS_ORGANIZATION_ID
}


# Create an Atlas Cluster
resource "mongodbatlas_cluster" "mycluster" {
  project_id   = mongodbatlas_project.myproject.id
  name         = "my-cluster"
  cluster_type = "REPLICASET"

  provider_name               = "TENANT"
  backing_provider_name       = "AWS"
  provider_instance_size_name = "M0"
  provider_region_name        = "EU_CENTRAL_1"
}


# Create a Database User
resource "mongodbatlas_database_user" "your_username" {
  username           = "your_username"
  password           = "your_pass"
  project_id         = mongodbatlas_project.myproject.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "db"
  }

  depends_on = [mongodbatlas_cluster.mycluster]
}
# cidr_block_list and IP Access List
locals {
  cidr_block_list = [
    "0.0.0.0/1",
    "128.0.0.0/1"
  ]
}

resource "mongodbatlas_project_ip_access_list" "cidr" {
  for_each = toset(local.cidr_block_list)

  project_id = mongodbatlas_project.myproject.id
  cidr_block = each.value

  depends_on = [mongodbatlas_cluster.mycluster]
}
