# Terraform EC2 + Docker Demo

## Descripción
Este proyecto despliega una **instancia EC2 con Ubuntu 24.04** utilizando Terraform, instala **Docker** y levanta un contenedor **Nginx** mediante `user_data`.  

El script `start.sh` es **idempotente**, maneja errores y deja **logs** en `/var/log/user_data.log`.  
El objetivo es demostrar despliegue automatizado, buenas prácticas de DevOps y el uso de Terraform con AWS.

**Tecnologías utilizadas:**
- Terraform 1.x
- AWS (EC2, Security Groups, Key Pair)
- Ubuntu 24.04 LTS
- Docker + Nginx

---

## Requisitos
- Terraform >= 1.5
- AWS CLI configurado con credenciales (Access Key / Secret)
- Cuenta AWS (compatible con Free Tier)
- Sistema operativo: macOS o Linux para ejecutar Terraform

---

## Estructura del proyecto

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
terraform init
terraform plan
terraform apply
curl http://<instance_public_ip>
terraform destroy

## Validación 
curl http://<instance_public_ip>
ssh -i ~/.ssh/terraform_ec2 ubuntu@<instance_public_ip>

