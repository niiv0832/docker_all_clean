#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

LANGUAGE=""
DRY_RUN=0
USE_COLOR=1

show_usage() {
    cat <<EOF
Usage: $(basename "$0") [--lang ru|en] [--dry-run] [--no-color]

Options:
  --lang ru|en    Choose interface language.
  --dry-run       Preview what would be removed without deleting anything.
  --preview       Alias for --dry-run.
  --no-color      Disable ANSI colors.
  -h, --help      Show this help.

Environment:
  NO_COLOR=1      Disable ANSI colors.

Examples:
  ./docker_all_clean.sh --lang en
  ./docker_all_clean.sh --lang ru --dry-run
  NO_COLOR=1 ./docker_all_clean.sh --lang en --dry-run
EOF
}

setup_colors() {
    if [ "$USE_COLOR" -eq 1 ] && [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
        return
    fi

    RED=''
    GREEN=''
    YELLOW=''
    CYAN=''
    NC=''
}

show_language_prompt() {
    while true; do
        echo "1) English"
        echo "2) Русский"
        echo "0) Exit / Выход"
        echo -ne "Select language / Выберите язык (0-2): "
        read -r lang_choice
        case "$lang_choice" in
            1)
                LANGUAGE="en"
                return
                ;;
            2)
                LANGUAGE="ru"
                return
                ;;
            0)
                exit 0
                ;;
            *)
                printf '%s\n' "Invalid choice / Неверный выбор."
                ;;
        esac
    done
}

msg() {
    case "${LANGUAGE:-en}:$1" in
        en:shell_error) printf '%s' "Error: this script requires Bash." ;;
        ru:shell_error) printf '%s' "Ошибка: этому скрипту требуется Bash." ;;
        en:shell_help) printf '%s' "Please run it with:" ;;
        ru:shell_help) printf '%s' "Пожалуйста, запустите его командой:" ;;
        en:docker_not_found) printf '%s' "Error: Docker was not found in PATH." ;;
        ru:docker_not_found) printf '%s' "Ошибка: Docker не найден в PATH." ;;
        en:docker_unavailable) printf '%s' "Error: Docker is unavailable or you do not have access to the Docker API." ;;
        ru:docker_unavailable) printf '%s' "Ошибка: Docker недоступен или нет доступа к Docker API." ;;
        en:current_context) printf '%s' "Docker context:" ;;
        ru:current_context) printf '%s' "Docker context:" ;;
        en:current_endpoint) printf '%s' "Docker endpoint:" ;;
        ru:current_endpoint) printf '%s' "Docker endpoint:" ;;
        en:docker_command_failed) printf '%s' "Error: Docker command failed:" ;;
        ru:docker_command_failed) printf '%s' "Ошибка: команда Docker завершилась с ошибкой:" ;;
        en:menu_title) printf '%s' "Docker Interactive Cleanup Menu" ;;
        ru:menu_title) printf '%s' "Интерактивное меню очистки Docker" ;;
        en:dry_run_mode) printf '%s' "Dry-run mode: nothing will be deleted." ;;
        ru:dry_run_mode) printf '%s' "Режим предпросмотра: ничего не будет удалено." ;;
        en:menu_item_1) printf '%s' "Show ALL containers and manage one container" ;;
        ru:menu_item_1) printf '%s' "Показать ВСЕ контейнеры и управлять одним контейнером" ;;
        en:menu_item_2) printf '%s' "Clean stopped containers" ;;
        ru:menu_item_2) printf '%s' "Очистить остановленные контейнеры" ;;
        en:menu_item_3) printf '%s' "Clean unused images" ;;
        ru:menu_item_3) printf '%s' "Очистить неиспользуемые образы" ;;
        en:menu_item_4) printf '%s' "Clean unused networks" ;;
        ru:menu_item_4) printf '%s' "Очистить неиспользуемые сети" ;;
        en:menu_item_5) printf '%s' "Clean unused volumes" ;;
        ru:menu_item_5) printf '%s' "Очистить неиспользуемые volumes" ;;
        en:menu_item_6) printf '%s' "Clean builder cache" ;;
        ru:menu_item_6) printf '%s' "Очистить кэш сборщика" ;;
        en:menu_item_7) printf '%s' "Full Docker wipe" ;;
        ru:menu_item_7) printf '%s' "Полностью очистить Docker" ;;
        en:menu_item_0) printf '%s' "Exit script" ;;
        ru:menu_item_0) printf '%s' "Выход из скрипта" ;;
        en:prompt_action) printf '%s' "Select an action (0-7): " ;;
        ru:prompt_action) printf '%s' "Выберите действие (0-7): " ;;
        en:list_title) printf '%s' "List of all containers" ;;
        ru:list_title) printf '%s' "Список всех контейнеров" ;;
        en:list_headers) printf '%s' "No.\tID\t\tNAME\t\tSTATUS" ;;
        ru:list_headers) printf '%s' "№\tID\t\tИМЯ\t\tСТАТУС" ;;
        en:no_containers) printf '%s' "No containers found." ;;
        ru:no_containers) printf '%s' "Контейнеры не найдены." ;;
        en:submenu_title) printf '%s' "What do you want to do?" ;;
        ru:submenu_title) printf '%s' "Что вы хотите сделать?" ;;
        en:submenu_stop) printf '%s' "Stop a container" ;;
        ru:submenu_stop) printf '%s' "Остановить контейнер" ;;
        en:submenu_remove) printf '%s' "Remove a container (force)" ;;
        ru:submenu_remove) printf '%s' "Удалить контейнер (принудительно)" ;;
        en:submenu_remove_volumes) printf '%s' "Remove a container and its anonymous volumes" ;;
        ru:submenu_remove_volumes) printf '%s' "Удалить контейнер и его anonymous volumes" ;;
        en:submenu_back) printf '%s' "Back to main menu" ;;
        ru:submenu_back) printf '%s' "Назад в главное меню" ;;
        en:prompt_subchoice) printf '%s' "Select a sub-option (11, 12, 13, or 0): " ;;
        ru:prompt_subchoice) printf '%s' "Выберите подпункт (11, 12, 13 или 0): " ;;
        en:prompt_container_number) printf '%s' "Enter the container NUMBER from the list: " ;;
        ru:prompt_container_number) printf '%s' "Введите НОМЕР контейнера из списка: " ;;
        en:invalid_number) printf '%s' "Canceled: invalid number entered." ;;
        ru:invalid_number) printf '%s' "Отменено: введен неверный номер." ;;
        en:invalid_choice) printf '%s' "Error: invalid choice." ;;
        ru:invalid_choice) printf '%s' "Ошибка: неверный выбор." ;;
        en:action_canceled) printf '%s' "Action canceled." ;;
        ru:action_canceled) printf '%s' "Действие отменено." ;;
        en:done) printf '%s' "Done!" ;;
        ru:done) printf '%s' "Готово!" ;;
        en:preview_title) printf '%s' "Preview" ;;
        ru:preview_title) printf '%s' "Предпросмотр" ;;
        en:preview_none) printf '%s' "Nothing to remove." ;;
        ru:preview_none) printf '%s' "Нечего удалять." ;;
        en:preview_reclaim) printf '%s' "Potential reclaimed space:" ;;
        ru:preview_reclaim) printf '%s' "Потенциально освобождаемое место:" ;;
        en:preview_stopped_containers) printf '%s' "Stopped containers" ;;
        ru:preview_stopped_containers) printf '%s' "Остановленные контейнеры" ;;
        en:preview_all_containers) printf '%s' "All containers" ;;
        ru:preview_all_containers) printf '%s' "Все контейнеры" ;;
        en:preview_images) printf '%s' "Images" ;;
        ru:preview_images) printf '%s' "Образы" ;;
        en:preview_networks) printf '%s' "Networks" ;;
        ru:preview_networks) printf '%s' "Сети" ;;
        en:preview_volumes) printf '%s' "Volumes" ;;
        ru:preview_volumes) printf '%s' "Volumes" ;;
        en:preview_builder) printf '%s' "Builder cache" ;;
        ru:preview_builder) printf '%s' "Кэш сборщика" ;;
        en:confirm_stop) printf '%s' "Type STOP to stop this container: " ;;
        ru:confirm_stop) printf '%s' "Введите ОСТАНОВИТЬ, чтобы остановить контейнер: " ;;
        en:confirm_remove) printf '%s' "Type REMOVE to remove this container: " ;;
        ru:confirm_remove) printf '%s' "Введите УДАЛИТЬ, чтобы удалить контейнер: " ;;
        en:confirm_remove_with_volumes) printf '%s' "Type REMOVE to remove this container and anonymous volumes: " ;;
        ru:confirm_remove_with_volumes) printf '%s' "Введите УДАЛИТЬ, чтобы удалить контейнер и anonymous volumes: " ;;
        en:confirm_images) printf '%s' "Type REMOVE IMAGES to remove these images: " ;;
        ru:confirm_images) printf '%s' "Введите УДАЛИТЬ ОБРАЗЫ, чтобы удалить эти образы: " ;;
        en:confirm_networks) printf '%s' "Type REMOVE NETWORKS to remove these networks: " ;;
        ru:confirm_networks) printf '%s' "Введите УДАЛИТЬ СЕТИ, чтобы удалить эти сети: " ;;
        en:confirm_volumes) printf '%s' "Type REMOVE VOLUMES to remove these volumes: " ;;
        ru:confirm_volumes) printf '%s' "Введите УДАЛИТЬ VOLUMES, чтобы удалить эти volumes: " ;;
        en:confirm_cache) printf '%s' "Type REMOVE CACHE to remove builder cache: " ;;
        ru:confirm_cache) printf '%s' "Введите УДАЛИТЬ КЭШ, чтобы удалить кэш сборщика: " ;;
        en:confirm_full_wipe) printf '%s' "Type WIPE ALL to stop and remove everything: " ;;
        ru:confirm_full_wipe) printf '%s' "Введите УДАЛИТЬ ВСЕ, чтобы остановить и удалить всё: " ;;
        en:word_stop) printf '%s' "STOP" ;;
        ru:word_stop) printf '%s' "ОСТАНОВИТЬ" ;;
        en:word_remove) printf '%s' "REMOVE" ;;
        ru:word_remove) printf '%s' "УДАЛИТЬ" ;;
        en:word_images) printf '%s' "REMOVE IMAGES" ;;
        ru:word_images) printf '%s' "УДАЛИТЬ ОБРАЗЫ" ;;
        en:word_networks) printf '%s' "REMOVE NETWORKS" ;;
        ru:word_networks) printf '%s' "УДАЛИТЬ СЕТИ" ;;
        en:word_volumes) printf '%s' "REMOVE VOLUMES" ;;
        ru:word_volumes) printf '%s' "УДАЛИТЬ VOLUMES" ;;
        en:word_cache) printf '%s' "REMOVE CACHE" ;;
        ru:word_cache) printf '%s' "УДАЛИТЬ КЭШ" ;;
        en:word_wipe) printf '%s' "WIPE ALL" ;;
        ru:word_wipe) printf '%s' "УДАЛИТЬ ВСЕ" ;;
        en:volumes_warning) printf '%s' "WARNING: removing volumes can cause data loss even if no container is using them now." ;;
        ru:volumes_warning) printf '%s' "ВНИМАНИЕ: удаление volumes может привести к потере данных, даже если контейнеры сейчас их не используют." ;;
        en:full_wipe_warning) printf '%s' "WARNING: this will stop and remove containers, images, networks, volumes, and builder cache." ;;
        ru:full_wipe_warning) printf '%s' "ВНИМАНИЕ: будут остановлены и удалены контейнеры, образы, сети, volumes и кэш сборщика." ;;
        en:container_stopped) printf '%s' "Container stopped." ;;
        ru:container_stopped) printf '%s' "Контейнер остановлен." ;;
        en:container_removed) printf '%s' "Container removed." ;;
        ru:container_removed) printf '%s' "Контейнер удален." ;;
        en:exit) printf '%s' "Exiting script. Goodbye!" ;;
        ru:exit) printf '%s' "Выход из скрипта. До свидания!" ;;
        *) printf '%s' "$1" ;;
    esac
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --lang)
                shift
                if [ $# -eq 0 ]; then
                    printf '%s\n' "Missing value for --lang / Не указан язык для --lang"
                    exit 1
                fi
                case "$1" in
                    ru|en)
                        LANGUAGE="$1"
                        ;;
                    *)
                        printf '%s\n' "Invalid --lang value. Use ru or en / Неверное значение --lang. Используйте ru или en"
                        exit 1
                        ;;
                esac
                ;;
            --lang=ru|--lang=en)
                LANGUAGE="${1#--lang=}"
                ;;
            --dry-run|--preview)
                DRY_RUN=1
                ;;
            --no-color)
                USE_COLOR=0
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                printf '%s\n' "Unknown argument / Неизвестный аргумент: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
}

require_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        printf '%s\n' "${RED}$(msg docker_not_found)${NC}"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        printf '%s\n' "${RED}$(msg docker_unavailable)${NC}"
        exit 1
    fi

    current_context="$(docker context show 2>/dev/null || true)"
    if [ -n "$current_context" ]; then
        printf '%s %s\n' "$(msg current_context)" "$current_context"
        current_endpoint="$(docker context inspect "$current_context" --format '{{.Endpoints.docker.Host}}' 2>/dev/null || true)"
        if [ -n "$current_endpoint" ]; then
            printf '%s %s\n' "$(msg current_endpoint)" "$current_endpoint"
        fi
    fi
}

run_docker() {
    if "$@"; then
        return 0
    fi

    printf '%s %s\n' "$(msg docker_command_failed)" "$*"
    return 1
}

confirm_action() {
    prompt_key="$1"
    word_key="$2"
    expected="$(msg "$word_key")"
    echo -ne "${RED}$(msg "$prompt_key")${NC}"
    read -r confirm_value
    [ "$confirm_value" = "$expected" ]
}

collect_preview_rows() {
    rows=()
    while IFS= read -r row; do
        if [ -n "$row" ]; then
            rows+=("$row")
        fi
    done < <("$@")
}

preview_action() {
    title_key="$1"
    shift
    collect_preview_rows "$@"

    echo -e "${CYAN}$(msg preview_title): $(msg "$title_key")${NC}"
    if [ "${#rows[@]}" -eq 0 ]; then
        echo -e "${GREEN}$(msg preview_none)${NC}"
        return 1
    fi

    for row in "${rows[@]}"; do
        printf ' - %s\n' "$row"
    done
    return 0
}

preview_stopped_containers() {
    preview_action preview_stopped_containers docker ps -a \
        --filter status=created \
        --filter status=exited \
        --filter status=dead \
        --format "{{.ID}}\t{{.Names}}\t{{.Status}}"
}

preview_all_containers() {
    preview_action preview_all_containers docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Status}}"
}

preview_images() {
    preview_action preview_images docker images -a --format "{{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}"
}

preview_networks() {
    preview_action preview_networks docker network ls --filter type=custom --format "{{.ID}}\t{{.Name}}\t{{.Driver}}"
}

preview_volumes() {
    preview_action preview_volumes docker volume ls -qf dangling=true
}

preview_builder_cache() {
    echo -e "${CYAN}$(msg preview_title): $(msg preview_builder)${NC}"
    if docker buildx version >/dev/null 2>&1; then
        docker buildx du 2>/dev/null || echo -e "${GREEN}$(msg preview_none)${NC}"
    else
        echo -e " - $(msg preview_builder)"
    fi
}

show_reclaim_info() {
    echo -e "${YELLOW}$(msg preview_reclaim)${NC}"
    docker system df -v 2>/dev/null || true
}

preview_full_wipe() {
    preview_all_containers || true
    preview_images || true
    preview_networks || true
    preview_volumes || true
    preview_builder_cache
    show_reclaim_info
}

clean_stopped_containers() {
    if [ "$DRY_RUN" -eq 1 ]; then
        preview_stopped_containers || true
        show_reclaim_info
        return
    fi

    preview_stopped_containers || true
    if run_docker docker container prune -f; then
        echo -e "${GREEN}$(msg "done")${NC}"
    fi
}

clean_images() {
    if ! preview_images; then
        return
    fi
    show_reclaim_info
    if [ "$DRY_RUN" -eq 1 ]; then
        return
    fi
    if confirm_action confirm_images word_images && run_docker docker image prune -a -f; then
        echo -e "${GREEN}$(msg "done")${NC}"
    else
        echo -e "${GREEN}$(msg action_canceled)${NC}"
    fi
}

clean_networks() {
    if ! preview_networks; then
        return
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
        return
    fi
    if confirm_action confirm_networks word_networks && run_docker docker network prune -f; then
        echo -e "${GREEN}$(msg "done")${NC}"
    else
        echo -e "${GREEN}$(msg action_canceled)${NC}"
    fi
}

clean_volumes() {
    echo -e "${YELLOW}$(msg volumes_warning)${NC}"
    if ! preview_volumes; then
        return
    fi
    show_reclaim_info
    if [ "$DRY_RUN" -eq 1 ]; then
        return
    fi
    if confirm_action confirm_volumes word_volumes && run_docker docker volume prune -f; then
        echo -e "${GREEN}$(msg "done")${NC}"
    else
        echo -e "${GREEN}$(msg action_canceled)${NC}"
    fi
}

clean_builder_cache() {
    preview_builder_cache
    if [ "$DRY_RUN" -eq 1 ]; then
        return
    fi
    if ! confirm_action confirm_cache word_cache; then
        echo -e "${GREEN}$(msg action_canceled)${NC}"
        return
    fi

    cache_rc=0
    if docker buildx version >/dev/null 2>&1; then
        run_docker docker buildx prune -a -f || cache_rc=$?
    else
        run_docker docker builder prune -a -f || cache_rc=$?
    fi
    if [ "$cache_rc" -eq 0 ]; then
        echo -e "${GREEN}$(msg "done")${NC}"
    fi
}

full_wipe() {
    echo -e "${RED}$(msg full_wipe_warning)${NC}"
    preview_full_wipe
    if [ "$DRY_RUN" -eq 1 ]; then
        return
    fi
    if ! confirm_action confirm_full_wipe word_wipe; then
        echo -e "${GREEN}$(msg action_canceled)${NC}"
        return
    fi

    running_ids=()
    while IFS= read -r id; do
        running_ids+=("$id")
    done < <(docker ps -q)
    if [ "${#running_ids[@]}" -gt 0 ]; then
        run_docker docker stop "${running_ids[@]}" || return
    fi

    all_ids=()
    while IFS= read -r id; do
        all_ids+=("$id")
    done < <(docker ps -a -q)
    if [ "${#all_ids[@]}" -gt 0 ]; then
        run_docker docker rm -f "${all_ids[@]}" || return
    fi

    image_ids=()
    while IFS= read -r id; do
        image_ids+=("$id")
    done < <(docker images -a -q | sort -u)
    if [ "${#image_ids[@]}" -gt 0 ]; then
        run_docker docker rmi -f "${image_ids[@]}" || return
    fi

    run_docker docker system prune -a --volumes -f || return
    if docker buildx version >/dev/null 2>&1; then
        run_docker docker buildx prune -a -f || return
    else
        run_docker docker builder prune -a -f || return
    fi
    echo -e "${GREEN}$(msg "done")${NC}"
}

show_containers_menu() {
    container_rows=()
    while IFS= read -r row; do
        container_rows+=("$row")
    done < <(docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Status}}")

    if [ "${#container_rows[@]}" -eq 0 ]; then
        echo -e "${YELLOW}$(msg no_containers)${NC}"
        return
    fi

    echo -e "\n${CYAN}--- $(msg list_title) ---${NC}"
    echo -e "$(msg list_headers)"
    index=1
    while IFS=$'\t' read -r container_id container_name container_status; do
        echo -e "${YELLOW}$index)${NC}\t${container_id}\t${container_name}\t${container_status}"
        ((index++))
    done < <(printf '%s\n' "${container_rows[@]}")

    echo -e "\n${CYAN}$(msg submenu_title)${NC}"
    echo -e "${YELLOW}11)${NC} $(msg submenu_stop)"
    echo -e "${YELLOW}12)${NC} $(msg submenu_remove)"
    echo -e "${YELLOW}13)${NC} ${RED}$(msg submenu_remove_volumes)${NC}"
    echo -e "${YELLOW}0)${NC} $(msg submenu_back)"
    echo -ne "${YELLOW}$(msg prompt_subchoice)${NC}"
    read -r sub_choice

    case "$sub_choice" in
        11|12|13)
            echo -ne "${YELLOW}$(msg prompt_container_number)${NC}"
            read -r container_number
            if ! [[ "$container_number" =~ ^[0-9]+$ ]] || [ "$container_number" -lt 1 ] || [ "$container_number" -gt "${#container_rows[@]}" ]; then
                echo -e "${RED}$(msg invalid_number)${NC}"
                return
            fi

            target_row="${container_rows[$((container_number-1))]}"
            IFS=$'\t' read -r target_id _target_name _target_status <<< "$target_row"
            case "$sub_choice" in
                11)
                    if confirm_action confirm_stop word_stop && run_docker docker stop "$target_id"; then
                        echo -e "${GREEN}$(msg container_stopped)${NC}"
                    else
                        echo -e "${GREEN}$(msg action_canceled)${NC}"
                    fi
                    ;;
                12)
                    if confirm_action confirm_remove word_remove && run_docker docker rm -f "$target_id"; then
                        echo -e "${GREEN}$(msg container_removed)${NC}"
                    else
                        echo -e "${GREEN}$(msg action_canceled)${NC}"
                    fi
                    ;;
                13)
                    if confirm_action confirm_remove_with_volumes word_remove && run_docker docker rm -f -v "$target_id"; then
                        echo -e "${GREEN}$(msg container_removed)${NC}"
                    else
                        echo -e "${GREEN}$(msg action_canceled)${NC}"
                    fi
                    ;;
            esac
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}$(msg invalid_choice)${NC}"
            ;;
    esac
}

show_main_menu() {
    while true; do
        if [ "$DRY_RUN" -eq 1 ]; then
            echo -e "${YELLOW}$(msg dry_run_mode)${NC}"
        fi

        echo -e "\n${CYAN}=== $(msg menu_title) ===${NC}"
        echo -e "${YELLOW}1)${NC} $(msg menu_item_1)"
        echo -e "${YELLOW}2)${NC} $(msg menu_item_2)"
        echo -e "${YELLOW}3)${NC} $(msg menu_item_3)"
        echo -e "${YELLOW}4)${NC} $(msg menu_item_4)"
        echo -e "${YELLOW}5)${NC} ${RED}$(msg menu_item_5)${NC}"
        echo -e "${YELLOW}6)${NC} $(msg menu_item_6)"
        echo -e "${YELLOW}7)${NC} ${RED}$(msg menu_item_7)${NC}"
        echo -e "${YELLOW}0)${NC} $(msg menu_item_0)"
        echo -e "${CYAN}=========================================${NC}"

        echo -ne "${YELLOW}$(msg prompt_action)${NC}"
        read -r choice
        case "$choice" in
            1) show_containers_menu ;;
            2) clean_stopped_containers ;;
            3) clean_images ;;
            4) clean_networks ;;
            5) clean_volumes ;;
            6) clean_builder_cache ;;
            7) full_wipe ;;
            0)
                echo -e "\n${GREEN}$(msg exit)${NC}"
                exit 0
                ;;
            *)
                echo -e "\n${RED}$(msg invalid_choice)${NC}"
                ;;
        esac
    done
}

parse_args "$@"
setup_colors

if [ -z "$LANGUAGE" ]; then
    show_language_prompt
fi

if [ -z "${BASH_VERSION:-}" ]; then
    printf '%s\n' "${RED}$(msg shell_error)${NC}"
    printf '%s\n\n' "$(msg shell_help)"
    printf '%s\n\n' "${YELLOW}    bash $0${NC}"
    exit 1
fi

require_docker
show_main_menu
