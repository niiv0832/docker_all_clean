# 🐳 Docker Interactive Cleanup Script

[Русская версия](#русская-версия) | [English Version](#english-version)

---

## Русская версия

Этот репозиторий содержит удобный интерактивный bash-скрипт для управления и безопасной очистки ресурсов Docker на вашем локальном компьютере или сервере.

### ✨ Возможности

* **Интерактивное меню:** Понятный интерфейс с цветовой подсветкой.
* **Управление контейнерами:** Вывод списка всех контейнеров в виде таблицы и возможность их остановки/удаления по порядковому номеру.
* **Умная очистка:** Выбор точечной очистки (только остановленные контейнеры, неиспользуемые образы/тома или кэш сборщика Builder/Buildx).
* **Безопасность:** Встроенная защита от случайных действий ("защита от дурака") — для критических операций (например, полное удаление) требуется ручной ввод подтверждающего слова.
* **Универсальность:** Скрипт проверяет оболочку (требуется `bash`) и корректно работает на macOS и Linux.

### 🚀 Использование

1. Склонируйте репозиторий или скачайте файл скрипта:
   ```bash
   git clone https://github.com/niiv0832/docker_all_clean.git
   cd docker_all_clean
   ```

2. Выдайте скрипту права на выполнение:
   ```bash
   chmod +x docker_all_clean.sh
   ```

3. Запустите скрипт:
   ```bash
   ./docker_all_clean.sh
   ```

*(Или используйте команду `bash docker_all_clean.sh`)*

---

## English Version

This repository provides a convenient and interactive bash script for managing and safely cleaning up Docker resources on your local machine or server.

### ✨ Features

* **Interactive Menu:** User-friendly interface with colorized output.
* **Container Management:** Displays a table of all containers and allows stopping or removing them by selecting their sequence number.
* **Targeted Cleanup:** Choose what to clean (only stopped containers, dangling images/volumes, or Builder/Buildx cache).
* **Safety First:** Built-in safeguards against accidental clicks. Critical operations (like a complete system wipe) require typing a confirmation word.
* **Compatibility:** The script checks for the correct shell environment (`bash`) and works smoothly on both macOS and Linux.

### 🚀 Usage

1. Clone the repository or download the script file:
   ```bash
   git clone https://github.com/niiv0832/docker_all_clean.git
   cd docker_all_clean
   ```

2. Make the script executable:
   ```bash
   chmod +x docker_all_clean_en.sh
   ```

3. Run the script:
   ```bash
   ./docker_all_clean_en.sh
   ```

*(Alternatively, run it with `bash docker_all_clean_en.sh`)*

---

### ⚠️ Disclaimer

**Use with caution.** The "Full Wipe" option (Option 5) will forcefully stop and delete ALL containers, networks, images, and volumes. Make sure you do not have any unsaved critical data in your local Docker environment before running it.
* **Safety First:** Built-in safeguards against accidental clicks. Critical operations (like a complete system wipe) require typing a confirmation word.
* **Compatibility:** The script checks for the correct shell environment (`bash`) and works smoothly on both macOS and Linux.

### 🚀 Usage

1. Clone the repository or download the script file:
```bash
git clone [https://github.com/niiv0832/docker_all_clean.git](https://github.com/niiv0832/docker_all_clean.git)
cd docker_all_clean

```


2. Make the script executable:
```bash
chmod +x docker_all_clean_en.sh

```


3. Run the script:
```bash
./docker_all_clean_en.sh

```



*(Alternatively, run it with `bash docker_all_clean_en.sh`)*

---

### ⚠️ Disclaimer

**Use with caution.** The "Full Wipe" option (Option 5) will forcefully stop and delete ALL containers, networks, images, and volumes. Make sure you do not have any unsaved critical data in your local Docker environment before running it.

```

```
