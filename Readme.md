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

## AWS 
El usuario tendra que tener los permisos minimos para poder ejecutar terraform 
-  https://github.com/MarioAran/terraform-aws-ec2-provisioning/blob/main/terraform/minimum-permission.json
En caso de solo querer probar su funcionamiento en dev se puede usar 

```bash 
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": [
                "*"
            ]
        }
}

```

Se tiene que tener en cuenta que esto permitira todas las acciones que ec2 proporciona incluyendo la eliminacion de discos, terminar instancias y liberar IPs Elasticas. 

Para negarlos puede agregar esto 

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllEC2",
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*"
        },
        {
            "Sid": "DenyDangerousActions",
            "Effect": "Deny",
            "Action": [
                "ec2:DeleteVolume",
                "ec2:TerminateInstances",
                "ec2:ReleaseAddress"
            ],
            "Resource": "*"
        }
    ]
}
```
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
└── terraform
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── security_groups.tf
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



