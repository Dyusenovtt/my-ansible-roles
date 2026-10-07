# Домашнее задание к занятию 4 «Работа с ролями»

Данный репозиторий содержит основную конфигурацию проекта (Infrastructure as Code) для развертывания аналитического стека в Yandex Cloud. Проект разделен на часть подготовки инфраструктуры (Terraform) и конфигурации серверов (Ansible).

## Ссылки на репозитории

Согласно заданию, монолитный плейбук переработан и разбит на отдельные роли. Код распределен по следующим репозиториям:

1. **Основной репозиторий (Плейбук и Инфраструктура):** 
   * [my-ansible-roles](https://github.com/Dyusenovtt/my-ansible-roles)
2. **Кастомная роль Vector (v1.0.0):** 
   * [vector-role](https://github.com/Dyusenovtt/vector-role)
3. **Кастомная роль Lighthouse (v1.0.0):** 
   * [lighthouse-role](https://github.com/Dyusenovtt/lighthouse-role)

*Примечание: Роль ClickHouse импортируется из публичного репозитория `AlexeySetevoi/ansible-clickhouse`.*

---

## Структура проекта

```text
.
├── ansible/
│   ├── inventory/          # Файлы инвентаризации (prod.yml)
│   ├── requirements.yml    # Зависимости для скачивания всех трех ролей
│   └── site.yml            # Главный плейбук оркестрации
├── terraform/
│   ├── main.tf             # Описание ВМ и провайдера Yandex Cloud
│   └── (прочие файлы .tf)
└── README.md               # Документация проекта
```
<img width="974" height="414" alt="image" src="https://github.com/user-attachments/assets/54a95df0-3c09-47e7-ae3c-908e6a00d986" />
<img width="974" height="1156" alt="image" src="https://github.com/user-attachments/assets/c0dae7db-c1b7-418d-8a7e-4a1b10e1b652" />
<img width="974" height="681" alt="image" src="https://github.com/user-attachments/assets/2c143691-4e2f-42a2-a3ce-e29cc1fafb19" />
<img width="974" height="696" alt="image" src="https://github.com/user-attachments/assets/53220cbc-d19d-4a6f-8f27-efcf22f4f8f6" />
<img width="974" height="273" alt="image" src="https://github.com/user-attachments/assets/cc8a6469-7c03-43a5-9dfa-c6906c45820c" />

# Инструкция по развертыванию

### 1. Подготовка инфраструктуры (Terraform)
Перейдите в директорию `terraform`, инициализируйте провайдера и разверните виртуальные машины:

```bash
cd terraform
terraform init
terraform apply -auto-approve
Важно: Для корректной установки ClickHouse используется увеличенный загрузочный диск.
После выполнения скопируйте полученные публичные IP-адреса серверов.

2. Настройка инвентаря (Ansible)
Откройте файл ansible/inventory/prod.yml и внесите актуальные IP-адреса, выданные Terraform:

YAML
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: <IP_CLICKHOUSE>
vector:
  hosts:
    vector-01:
      ansible_host: <IP_VECTOR>
lighthouse:
  hosts:
    lighthouse-01:
      ansible_host: <IP_LIGHTHOUSE>
3. Загрузка ролей
Перейдите в директорию ansible и скачайте роли с помощью ansible-galaxy. Команда автоматически вытянет ClickHouse, Vector и Lighthouse из соответствующих репозиториев согласно тегам:

Bash
cd ../ansible
ansible-galaxy install -r requirements.yml -p roles
4. Запуск оркестрации
Запустите главный плейбук для конфигурации всех серверов. Для корректной работы задач требуется повышение привилегий (настроено в site.yml):

Bash
ansible-playbook -i inventory/prod.yml site.yml
Особенности конфигурации
Идемпотентность: Повторный запуск плейбука не вносит изменений в готовую систему (changed=0).

ClickHouse GPG: В связи с недоступностью ключей в rpm-репозиториях ClickHouse, в параметрах установки применен патч для обхода проверки подписей GPG (disable_gpg_check: true).






