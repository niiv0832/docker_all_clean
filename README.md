# Docker Interactive Cleanup Script

[Русская версия](#русская-версия) | [English Version](#english-version)

---

## Русская версия

Интерактивный Bash-скрипт для просмотра и безопасной очистки локальных Docker-ресурсов. Скрипт проверяет доступность Docker, показывает текущий Docker context, поддерживает предпросмотр через `--dry-run` и требует явного подтверждения перед опасными операциями.

### Возможности

* Один билингвальный скрипт: `docker_all_clean.sh`.
* Выбор языка при старте или через `--lang ru|en`.
* Раздельная очистка контейнеров, образов, сетей, volumes и builder cache.
* Предпросмотр через `--dry-run` / `--preview` без удаления данных.
* Отключение цветов через `--no-color`, `NO_COLOR=1` или автоматически при выводе не в терминал.
* Проверки качества через `scripts/check.sh` и GitHub Actions.

### Меню

```text
1) Показать ВСЕ контейнеры и управлять одним контейнером
2) Очистить остановленные контейнеры
3) Очистить неиспользуемые образы
4) Очистить неиспользуемые сети
5) Очистить неиспользуемые volumes
6) Очистить кэш сборщика
7) Полностью очистить Docker
0) Выход из скрипта
```

### Использование

```bash
git clone https://github.com/niiv0832/docker_all_clean.git
cd docker_all_clean
chmod +x docker_all_clean.sh
./docker_all_clean.sh
```

Запуск с явным языком:

```bash
./docker_all_clean.sh --lang ru
./docker_all_clean.sh --lang en
```

Предпросмотр без удаления:

```bash
./docker_all_clean.sh --lang ru --dry-run
```

Отключение цветов:

```bash
./docker_all_clean.sh --no-color
NO_COLOR=1 ./docker_all_clean.sh
```

Справка:

```bash
./docker_all_clean.sh --help
```

### Проверки

```bash
./scripts/check.sh
```

Команда запускает:

```bash
bash -n docker_all_clean.sh
shellcheck docker_all_clean.sh
```

### Отказ от ответственности

Используйте с осторожностью. Full wipe принудительно останавливает и удаляет контейнеры, образы, сети, volumes и builder cache. Перед удалением volumes и full wipe скрипт показывает предпросмотр и требует явного подтверждения.

---

## English Version

An interactive Bash script for inspecting and safely cleaning local Docker resources. The script checks Docker availability, prints the current Docker context, supports preview mode with `--dry-run`, and requires explicit confirmation before dangerous operations.

### Features

* One bilingual script: `docker_all_clean.sh`.
* Language selection at startup or via `--lang ru|en`.
* Separate cleanup actions for containers, images, networks, volumes, and builder cache.
* Preview mode with `--dry-run` / `--preview` without deleting data.
* Color control via `--no-color`, `NO_COLOR=1`, or automatic non-TTY detection.
* Quality checks via `scripts/check.sh` and GitHub Actions.

### Menu

```text
1) Show ALL containers and manage one container
2) Clean stopped containers
3) Clean unused images
4) Clean unused networks
5) Clean unused volumes
6) Clean builder cache
7) Full Docker wipe
0) Exit script
```

### Usage

```bash
git clone https://github.com/niiv0832/docker_all_clean.git
cd docker_all_clean
chmod +x docker_all_clean.sh
./docker_all_clean.sh
```

Run with an explicit language:

```bash
./docker_all_clean.sh --lang en
./docker_all_clean.sh --lang ru
```

Preview without deleting anything:

```bash
./docker_all_clean.sh --lang en --dry-run
```

Disable colors:

```bash
./docker_all_clean.sh --no-color
NO_COLOR=1 ./docker_all_clean.sh
```

Help:

```bash
./docker_all_clean.sh --help
```

### Checks

```bash
./scripts/check.sh
```

The command runs:

```bash
bash -n docker_all_clean.sh
shellcheck docker_all_clean.sh
```

### Disclaimer

Use with caution. Full wipe forcefully stops and removes containers, images, networks, volumes, and builder cache. Before removing volumes or running full wipe, the script shows a preview and requires explicit confirmation.
