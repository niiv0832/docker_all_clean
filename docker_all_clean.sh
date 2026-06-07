#!/usr/bin/env bash

# --- Определение цветов ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (сброс цвета)

# --- Проверка оболочки (защита от запуска в sh/zsh) ---
if [ -z "${BASH_VERSION:-}" ]; then
    printf "${RED}Ошибка: Этот скрипт использует функции, доступные только в оболочке Bash.${NC}\n"
    printf "Пожалуйста, запустите его командой:\n\n"
    printf "${YELLOW}    bash %s${NC}\n\n" "$0"
    exit 1
fi

# Запускаем бесконечный цикл для главного меню
while true; do
    echo -e "\n${CYAN}=== Интерактивное меню очистки Docker ===${NC}"
    echo -e "${YELLOW}1)${NC} Показать ВСЕ контейнеры (с действиями: остановить/удалить)"
    echo -e "${YELLOW}2)${NC} Очистить только остановленные контейнеры"
    echo -e "${YELLOW}3)${NC} Очистить неиспользуемые образы, volumes, сети (без удаления работающих)"
    echo -e "${YELLOW}4)${NC} Очистить только кэш сборщика (Builder cache)"
    echo -e "${YELLOW}5)${NC} ${RED}Полностью очистить Docker (остановка и удаление ВСЕГО)${NC}"
    echo -e "${YELLOW}0)${NC} Выход из скрипта"
    echo -e "${CYAN}=========================================${NC}"

    echo -ne "${YELLOW}Выберите действие (0-5): ${NC}"
    read choice

    case "$choice" in
        1)
            # Получаем массивы ID и Имен ВСЕХ контейнеров (включая остановленные)
            CONTAINER_IDS=($(docker ps -a -q))
            CONTAINER_NAMES=($(docker ps -a --format '{{.Names}}'))

            if [ ${#CONTAINER_IDS[@]} -eq 0 ]; then
                echo -e "${YELLOW}Нет контейнеров (ни работающих, ни остановленных).${NC}"
            else
                echo -e "\n${CYAN}--- Список всех контейнеров ---${NC}"
                echo -e "№\tID\t\tИМЯ\t\tСТАТУС"
                
                # Выводим пронумерованный список
                i=1
                while IFS= read -r line; do
                    echo -e "${YELLOW}$i)${NC}\t$line"
                    ((i++))
                done < <(docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Status}}")

                echo -e "\n${CYAN}Что вы хотите сделать?${NC}"
                echo -e "${YELLOW}11)${NC} Остановить контейнер"
                echo -e "${YELLOW}12)${NC} Удалить контейнер (принудительно)"
                echo -e "${YELLOW}13)${NC} ${RED}Удалить контейнер и очистить его данные (volumes)${NC}"
                echo -e "${YELLOW}0)${NC} Назад в главное меню"
                
                echo -ne "${YELLOW}Выберите подпункт (11, 12, 13 или 0): ${NC}"
                read sub_choice
                
                case "$sub_choice" in
                    11)
                        echo -ne "${YELLOW}Введите НОМЕР контейнера из списка для ОСТАНОВКИ: ${NC}"
                        read c_num
                        if [[ "$c_num" =~ ^[0-9]+$ ]] && [ "$c_num" -ge 1 ] && [ "$c_num" -le "${#CONTAINER_IDS[@]}" ]; then
                            target_id="${CONTAINER_IDS[$((c_num-1))]}"
                            target_name="${CONTAINER_NAMES[$((c_num-1))]}"
                            
                            echo -ne "${RED}Подтвердите остановку [${target_name}], написав слово '${YELLOW}ОСТАНОВИТЬ${RED}': ${NC}"
                            read confirm_stop
                            if [ "$confirm_stop" == "ОСТАНОВИТЬ" ]; then
                                docker stop "$target_id"
                                echo -e "${GREEN}Контейнер $target_name остановлен.${NC}"
                            else
                                echo -e "${GREEN}Действие отменено.${NC}"
                            fi
                        else
                            echo -e "${RED}Отменено: введен неверный номер.${NC}"
                        fi
                        ;;
                    12)
                        echo -ne "${YELLOW}Введите НОМЕР контейнера из списка для УДАЛЕНИЯ: ${NC}"
                        read c_num
                        if [[ "$c_num" =~ ^[0-9]+$ ]] && [ "$c_num" -ge 1 ] && [ "$c_num" -le "${#CONTAINER_IDS[@]}" ]; then
                            target_id="${CONTAINER_IDS[$((c_num-1))]}"
                            target_name="${CONTAINER_NAMES[$((c_num-1))]}"

                            echo -ne "${RED}Подтвердите удаление [${target_name}], написав слово '${YELLOW}УДАЛИТЬ${RED}': ${NC}"
                            read confirm_del
                            if [ "$confirm_del" == "УДАЛИТЬ" ]; then
                                docker rm -f "$target_id"
                                echo -e "${GREEN}Контейнер $target_name удален.${NC}"
                            else
                                echo -e "${GREEN}Действие отменено.${NC}"
                            fi
                        else
                            echo -e "${RED}Отменено: введен неверный номер.${NC}"
                        fi
                        ;;
                    13)
                        echo -ne "${YELLOW}Введите НОМЕР контейнера для УДАЛЕНИЯ и ОЧИСТКИ volumes: ${NC}"
                        read c_num
                        if [[ "$c_num" =~ ^[0-9]+$ ]] && [ "$c_num" -ge 1 ] && [ "$c_num" -le "${#CONTAINER_IDS[@]}" ]; then
                            target_id="${CONTAINER_IDS[$((c_num-1))]}"
                            target_name="${CONTAINER_NAMES[$((c_num-1))]}"

                            echo -ne "${RED}Подтвердите полное удаление [${target_name}], написав слово '${YELLOW}УДАЛИТЬ${RED}': ${NC}"
                            read confirm_del
                            if [ "$confirm_del" == "УДАЛИТЬ" ]; then
                                docker rm -f -v "$target_id"
                                echo -e "${GREEN}Контейнер $target_name и его связанные тома (volumes) удалены.${NC}"
                            else
                                echo -e "${GREEN}Действие отменено.${NC}"
                            fi
                        else
                            echo -e "${RED}Отменено: введен неверный номер.${NC}"
                        fi
                        ;;
                    0)
                        echo -e "${GREEN}Возвращаемся в главное меню...${NC}"
                        ;;
                    *)
                        echo -e "${RED}Неверный выбор подпункта.${NC}"
                        ;;
                esac
            fi
            ;;
        2)
            echo -e "\n${CYAN}=== Очистка остановленных контейнеров ===${NC}"
            docker container prune -f
            echo -e "${GREEN}Готово!${NC}"
            ;;
        3)
            echo -e "\n${CYAN}=== Очистка неиспользуемых образов, сетей и томов ===${NC}"
            echo -e "${RED}Удаление сетей...${NC}"
            docker network prune -f
            echo -e "${RED}Удаление томов (Volumes)...${NC}"
            docker volume prune -f
            echo -e "${RED}Удаление неиспользуемых образов (Dangling & Unused)...${NC}"
            docker image prune -a -f
            echo -e "${GREEN}Готово!${NC}"
            ;;
        4)
            echo -e "\n${CYAN}=== Очистка кэша сборщика ===${NC}"
            if docker buildx version >/dev/null 2>&1; then
                docker buildx prune -a -f
            else
                docker builder prune -a -f 2>/dev/null
            fi
            echo -e "${GREEN}Готово!${NC}"
            ;;
        5)
            echo -e "\n${RED}ВНИМАНИЕ! Это действие полностью остановит и удалит ВСЕ контейнеры, образы, сети и тома!${NC}"
            echo -ne "${RED}Для подтверждения введите фразу '${YELLOW}УДАЛИТЬ ВСЕ${RED}' (заглавными буквами): ${NC}"
            read confirm_wipe
            
            if [ "$confirm_wipe" == "УДАЛИТЬ ВСЕ" ]; then
                echo -e "${RED}=== Запуск полной очистки Docker ===${NC}"
                if [ -n "$(docker ps -q)" ]; then
                    echo -e "${YELLOW}Остановка запущенных контейнеров...${NC}"
                    docker stop $(docker ps -q)
                else
                    echo -e "${GREEN}Нет запущенных контейнеров.${NC}"
                fi

                if [ -n "$(docker ps -a -q)" ]; then
                    echo -e "${RED}Удаление всех контейнеров...${NC}"
                    docker rm -f $(docker ps -a -q)
                else
                    echo -e "${GREEN}Контейнеры для удаления отсутствуют.${NC}"
                fi

                if [ -n "$(docker images -q)" ]; then
                    echo -e "${RED}Удаление Docker-образов...${NC}"
                    docker rmi -f $(docker images -a -q)
                else
                    echo -e "${GREEN}Образы для удаления отсутствуют.${NC}"
                fi

                echo -e "${RED}Глобальная очистка неиспользуемых объектов системы...${NC}"
                docker system prune -a --volumes -f

                echo -e "${YELLOW}Очистка кэша сборщика...${NC}"
                if docker buildx version >/dev/null 2>&1; then
                    docker buildx prune -a -f
                else
                    docker builder prune -a -f 2>/dev/null
                fi
                echo -e "${GREEN}=== Очистка успешно завершена! ===${NC}"
            else
                echo -e "${GREEN}Операция полной очистки отменена. Ваши данные в безопасности.${NC}"
            fi
            ;;
        0)
            echo -e "\n${GREEN}Выход из скрипта. До свидания!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Ошибка: Неверный выбор. Пожалуйста, введите число от 0 до 5.${NC}"
            ;;
    esac
done
