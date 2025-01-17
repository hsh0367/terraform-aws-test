# terraform-aws-test
terraform aws 사용하는것을 테스트 하기 위한 리포지터리


# Terraform 사용 가이드

## 개요
이 리포지토리는 Terraform을 사용하여 필요한 리소스를 관리합니다.

## 설치 및 요구 사항
- Terraform CLI 설치 필요
- AWS CLI 등 필요한 환경변수 설정

### 변수 세팅 방법
terraform.tfvars로 variables.tf에 정의된 변수들을 세팅

## 사용 방법
기본적인 사용 흐름은 init -> plan -> apply

1. Terraform 초기화  
   ```bash
   terraform init
   ```
2. Terraform 변경 사항 검토
   ```bash
   terraform plan
   ```
3. Terraform 실제 적용  
   ```bash
   terraform apply
   ```

리소스 정리는 terraform destroy 명령으로 가능합니다.
변경 사항 적용 전에는 항상 terraform plan으로 확인이 필요합니다.