# MongoDB Atlas Infrastructure Deployment with Terraform

This project demonstrates how to provision MongoDB Atlas infrastructure using Terraform. 
The deployment includes creating a MongoDB Atlas Project, Cluster, Database User, and IP Access List.

---

# Prerequisites

Before running this project, ensure that you have:

- A MongoDB Atlas account
- Terraform installed (`terraform version`)
- Permissions to create resources within your MongoDB Atlas Organization

---

# 1. Bootstrap MongoDB Atlas

Terraform requires an existing MongoDB Atlas Organization and API credentials before it can manage Atlas resources.

## 1.1 Create a MongoDB Atlas Account

Create an account or sign in to MongoDB Atlas:

https://www.mongodb.com/products/platform/atlas-database

---

## 1.2 Create an Organization

If you do not already have an Organization, create one from the MongoDB Atlas dashboard.

---

## 1.3 Generate an Organization API Key

Navigate to:

```
Organizations
    └── You_Organizations_name
           └── Identity & Access
                  └── Applications
                       └── API Keys
                             └── Add New -> Api Key
```
<img width="1913" height="259" alt="image" src="https://github.com/user-attachments/assets/7036e016-057b-4d5a-b487-a8f036b055f2" />

Create a new API Key with **Organization Owner** permissions.

Save the following values (the Private Key is displayed only once):

- Public Key
- Private Key

---

## 1.4 Find the Organization ID

Navigate to:

```
Organization Settings
```

Copy the value of:

```
Organization ID
```

Example:

```
69fdf573760dddcdbc075cb2f
```

---

## 1.5 Configure Network Access

Navigate to:

```
Security
    └── Network Access
```

Click:

```
Add IP Address
```

For testing purposes select:

```
Allow Access From Anywhere
```

This creates the following rule:

```
0.0.0.0/0
```

> **Note:** Allowing access from anywhere should only be used for development or laboratory environments.

---

## 1.5 Configure Atlas Administration API Access

By default, the Atlas Administration API may require requests to originate from an IP address included in the IP Access List. This can prevent Terraform from authenticating successfully.

Navigate to:

```
Organization Settings
```

Locate the option:

```
Require IP Access List for the Atlas Administration API
```

Disable (uncheck) this option.

> **Note:** This setting is recommended only for development or laboratory environments. In production environments, it is recommended to keep this option enabled and explicitly allow only trusted IP addresses.

---

# 2. Prepare the Terraform Project

Create a working directory:

```bash
mkdir myproject
cd myproject
```

Copy the following files into the project directory:

```
main.tf
terraform.tfvars
variables.tf
```

After copying, your project structure should look similar to:

```text
myproject/
├── main.tf
├── terraform.tfvars
└── variables.tf
```

---

# 3. Configure Terraform Variables

There are two supported ways to provide credentials.

## Option 1 (Recommended): terraform.tfvars

Open `terraform.tfvars` and replace the placeholder values:

```hcl
MONGODB_ATLAS_PUBLIC_KEY      = "<your_public_key>"
MONGODB_ATLAS_PRIVATE_KEY     = "<your_private_key>"
MONGODB_ATLAS_ORGANIZATION_ID = "<your_organization_id>"
```

Terraform automatically loads variables from this file.

---

## Option 2: Environment Variables

If Terraform does not load variables from `terraform.tfvars`, or you do not want to store credentials in a file, export them as environment variables.

```bash
export TF_VAR_MONGODB_ATLAS_PUBLIC_KEY="<your_public_key>"
export TF_VAR_MONGODB_ATLAS_PRIVATE_KEY="<your_private_key>"
export TF_VAR_MONGODB_ATLAS_ORGANIZATION_ID="<your_organization_id>"
```

Verify the variables:

```bash
echo $TF_VAR_MONGODB_ATLAS_PUBLIC_KEY
echo $TF_VAR_MONGODB_ATLAS_ORGANIZATION_ID
```

Terraform automatically maps environment variables prefixed with `TF_VAR_` to variables declared in `variables.tf`.

---

# 4. Review variables.tf

The `variables.tf` file only declares the required Terraform variables.

```hcl
variable "MONGODB_ATLAS_ORGANIZATION_ID" {
  type = string
}

variable "MONGODB_ATLAS_PUBLIC_KEY" {
  type = string
}

variable "MONGODB_ATLAS_PRIVATE_KEY" {
  type = string
}
```

Normally, this file does not need to be modified.

---

# 5. Update the Database User

Before deploying the infrastructure, open `main.tf` and update the database user credentials.

Locate the following resource:

```hcl
resource "mongodbatlas_database_user" "bob" {
  username           = "your_username"
  password           = "YourStrongPassword123!"
  project_id         = mongodbatlas_project.myproject.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "admin"
  }
}
```

Replace:

- `your_username`
- `YourStrongPassword123!`

with your own database credentials.

---

# 6. Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

Terraform downloads the required MongoDB Atlas Provider.

---

# 7. Review the Execution Plan

Before creating resources, review the execution plan:

```bash
terraform plan
```

Terraform will display the resources that will be created.

---

# 8. Deploy Infrastructure

Create the MongoDB Atlas infrastructure:

```bash
terraform apply
```

Confirm the deployment by typing:

```
yes
```

Terraform will automatically create:

- MongoDB Atlas Project
- MongoDB Atlas Cluster
- Database User
- IP Access List

---

# 9. Connect to Your MongoDB Cluster

After deployment completes successfully, connect to your database.

## Option 1 – MongoDB Atlas

1. Open your Project.
2. Select your Cluster.
3. Click **Connect**.
4. Choose **MongoDB Compass** or **Shell (mongosh)**.
5. Copy the generated connection string.

Example:

```text
mongodb+srv://your_username:your_password@cluster0.xxxxx.mongodb.net/
```

---

## Option 2 – mongosh

Install `mongosh` if it is not already installed.

Connect using:

```bash
mongosh "mongodb+srv://your_username:your_password@cluster0.xxxxx.mongodb.net/"
```

or

```bash
mongosh "mongodb+srv://cluster0.xxxxx.mongodb.net/" --username your_username
```

Enter the password that you configured in `main.tf` when prompted.

---

# 10. Destroy Infrastructure

To remove all resources created by Terraform:

```bash
terraform destroy
```

Confirm by typing:

```
yes
```

Terraform will delete all managed resources from MongoDB Atlas.

---

# Project Workflow

```
Create MongoDB Atlas Account
        │
        ▼
Create Organization
        │
        ▼
Generate Organization API Key
        │
        ▼
Copy main.tf, variables.tf and terraform.tfvars
        │
        ▼
Configure credentials
(terraform.tfvars or TF_VAR_* variables)
        │
        ▼
Update database username/password
        │
        ▼
terraform init
        │
        ▼
terraform plan
        │
        ▼
terraform apply
        │
        ▼
Connect to MongoDB Atlas Cluster
```
