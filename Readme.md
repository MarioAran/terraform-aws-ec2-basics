# Terraform EC2 + Docker Demo

## Descripción
Este proyecto despliega una **instancia EC2 con Ubuntu 24.04** utilizando Terraform y ansible que actualiza el apt e instala **Docker**, **Docker-Compose** 

**Tecnologías utilizadas:**
- Terraform 1.x
- Ansible 2.x 
- AWS (EC2, Security Groups, Key Pair)
- Ubuntu 24.04 LTS
- Docker + Docker compose

---

## Requisitos
- Terraform >= 1.5
- Ansible >=2.19
- AWS CLI configurado con credenciales (Access Key / Secret)
- Cuenta AWS (compatible con Free Tier)
- Sistema operativo: macOS o Linux para ejecutar Terraform

---

## Estructura del proyecto
```plaintext
.
├── Readme.md
├── ansible
│   ├── hosts.ini
│   ├── playbook.yml
│   ├── roles
│   │   └── app
│   │       └── tasks
│   │           └── main.yml
│   └── terraform.tfstate
└── terraform
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── security_groups.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    └── variables.tf
```
---

## Variables
| Variable       | Descripción                  | Default   |
|----------------|------------------------------|-----------|
| instance_type  | Tipo de instancia EC2        | t2.micro  |

---

## Outputs
| Output              | Descripción                           |
|--------------------|---------------------------------------|
| instance_id         | ID de la instancia EC2                |
| instance_private_ip | IP privada de la instancia EC2        |
| instance_public_ip  | IP pública de la instancia EC2        |

---

## Cómo desplegar
1. Inicializar Terraform:
```bash
## Iniciar instancia EC2
terraform init
terraform plan
terraform apply
curl http://<instance_public_ip>
terraform destroy
## Configurar servidor EC2
## Primero tendremos que actualizar la direccion ip del host.ini 
## [ip-ec2] ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/terraform_ec2
## primero verificaremos que ansible tenga conexion con el servidor ec2 tras la confirmacion 
ansible-playbook -i hosts.ini playbook.yml

## Validación 
curl http://<instance_public_ip>:5000
ssh -i ~/.ssh/terraform_ec2 ubuntu@<instance_public_ip>



