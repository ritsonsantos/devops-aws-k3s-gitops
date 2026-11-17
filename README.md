# DevOps AWS K3s GitOps

Projeto prático de DevOps que implementa infraestrutura como código na AWS, provisionamento de Kubernetes com K3s e automação de CI/CD utilizando GitHub Actions.

O objetivo é demonstrar conhecimentos em Cloud Computing, Infrastructure as Code, containers, Kubernetes, automação de deploy e segurança na AWS.

## Arquitetura do projeto

A infraestrutura utiliza uma VPC com sub-redes públicas e privadas distribuídas em duas zonas de disponibilidade.

A instância EC2 que executa o K3s fica em uma sub-rede privada, sem endereço IP público. O acesso administrativo é realizado pelo AWS Systems Manager (SSM), sem necessidade de SSH ou exposição da instância à internet.

### Componentes da arquitetura

- **AWS VPC:** rede isolada com CIDR `10.0.0.0/16`.
- **Sub-redes:** duas públicas e duas privadas, distribuídas em duas zonas de disponibilidade.
- **EC2:** instância `t3.small` executando Amazon Linux 2023 e K3s.
- **IAM:** permissões específicas para os serviços e automações.
- **AWS SSM:** gerenciamento remoto da instância sem SSH.
- **VPC Endpoints:** comunicação privada com SSM.
- **Amazon S3:** armazenamento dos artefatos de instalação e manifestos Kubernetes.
- **Terraform:** provisionamento automatizado da infraestrutura.

## Tecnologias utilizadas

| Tecnologia | Utilização |
|---|---|
| AWS | Infraestrutura em nuvem |
| Terraform | Infrastructure as Code |
| EC2 | Execução do K3s |
| VPC | Isolamento de rede |
| IAM | Gerenciamento de permissões |
| SSM | Administração remota |
| S3 | Armazenamento de artefatos |
| K3s | Kubernetes leve |
| Docker | Preparação da imagem da aplicação |
| Kubernetes | Orquestração de containers |
| GitHub Actions | Automação de CI/CD |
| AWS OIDC | Autenticação segura do GitHub Actions |
| Kubeconform | Validação de manifestos Kubernetes |

## Pipeline CI/CD

O projeto utiliza GitHub Actions para automatizar validação e deploy.

### CI — Integração contínua

Arquivo: `.github/workflows/ci.yml`

Executado em eventos de push e pull request para a branch `main`.

Etapas:
1. Checkout do repositório.
2. Instalação do Kubeconform.
3. Validação dos manifestos Kubernetes.
4. Verificação de conformidade dos arquivos YAML.

### CD — Entrega contínua

Arquivo: `.github/workflows/cd.yml`

O deploy é executado manualmente ou após alterações nos manifestos Kubernetes na branch `main`.

Etapas:
1. Checkout do repositório.
2. Validação dos manifestos com Kubeconform.
3. Autenticação na AWS utilizando OIDC.
4. Empacotamento dos manifestos Kubernetes.
5. Envio dos arquivos para o Amazon S3.
6. Execução remota através do AWS Systems Manager.
7. Aplicação dos manifestos no cluster K3s.

### Fluxo de deploy

```text
GitHub
   |
   v
GitHub Actions
   |
   v
Kubeconform
   |
   v
AWS OIDC
   |
   v
Amazon S3
   |
   v
AWS Systems Manager
   |
   v
EC2 privada
   |
   v
K3s / Kubernetes
   |
   v
Nginx
```

## Aplicação Kubernetes

Foi realizado o deploy de uma aplicação Nginx no cluster K3s.

Recursos criados:

- Deployment: `nginx-demo`
- Réplicas: 2
- Imagem: `nginx:1.27`
- Service: `nginx-demo-svc`
- Tipo de Service: `ClusterIP`
- Porta: `80/TCP`

A imagem do Nginx foi preparada e importada no cluster para permitir a execução em ambiente privado, sem depender de download direto do Docker Hub durante o deploy.

## Segurança

O projeto aplica algumas práticas importantes de segurança:

- Instância EC2 sem IP público.
- Acesso administrativo via AWS Systems Manager.
- Autenticação GitHub Actions com OIDC, sem armazenar chaves AWS de longa duração no GitHub.
- IAM com permissões específicas para as operações de deploy.
- Criptografia do volume EBS.
- IMDSv2 obrigatório na instância EC2.
- Terraform State armazenado em bucket S3 com criptografia e versionamento.
- Arquivos de estado e credenciais excluídos do Git.

## Resultados e validações

Até o momento, foram realizados os seguintes testes:

- Infraestrutura AWS provisionada com Terraform.
- Instância EC2 privada acessível pelo SSM.
- Cluster K3s instalado e operacional.
- Deployment Nginx com duas réplicas em estado `Running`.
- Service Kubernetes criado e funcional.
- Pipeline CI executada com sucesso.
- Autenticação OIDC do GitHub Actions validada.
- Pipeline CD executada com sucesso.
- Aplicação dos manifestos via SSM.
- Teste HTTP retornando `200 OK`.

Resposta HTTP validada:

```text
HTTP/1.1 200 OK
Server: nginx/1.27.5
Content-Type: text/html
```

## Estrutura do repositório

```text
devops-aws-k3s-gitops/
├── .github/
│   └── workflows/
│       ├── aws-oidc-test.yml
│       ├── ci.yml
│       └── cd.yml
├── artifacts/
├── kubernetes/
│   └── apps/
│       └── nginx/
│           ├── deployment.yaml
│           └── service.yaml
├── terraform/
│   ├── artifacts.tf
│   ├── backend.tf
│   ├── ec2.tf
│   ├── endpoints.tf
│   ├── iam.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── routes.tf
│   ├── security.tf
│   ├── state.tf
│   ├── subnets.tf
│   └── variables.tf
├── .gitignore
└── README.md
```

## Aprendizados

Durante o desenvolvimento foram trabalhados conceitos de:

- Infrastructure as Code com Terraform.
- Arquitetura de rede na AWS.
- Administração de instâncias Linux.
- Kubernetes e K3s.
- Containers e imagens Docker.
- Automação de pipelines CI/CD.
- Autenticação federada com AWS OIDC.
- Gerenciamento remoto com SSM.
- Segurança e princípio do menor privilégio.
- Troubleshooting de infraestrutura e aplicações.

## Autor

**GitHub:** [ritsonsantos](https://github.com/ritsonsantos)

**Repositório:** [devops-aws-k3s-gitops](https://github.com/ritsonsantos/devops-aws-k3s-gitops)

---

Projeto desenvolvido para fins de estudo e portfólio profissional na área de DevOps e Cloud Computing.
