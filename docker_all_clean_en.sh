#!/usr/bin/env bash

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color (reset)

# --- Shell Check (protection against running in sh/zsh) ---
if [ -z "${BASH_VERSION:-}" ]; then
    printf "${RED}Error: This script uses features only available in the Bash shell.${NC}\n"
    printf "Please run it with the command:\n\n"
    printf "${YELLOW}    bash %s${NC}\n\n" "$0"
    exit 1
fi

# Infinite loop for the main menu
while true; do
    echo -e "\n${CYAN}=== Docker Interactive Cleanup Menu ===${NC}"
    echo -e "${YELLOW}1)${NC} Show ALL containers (with actions: stop/remove)"
    echo -e "${YELLOW}2)${NC} Clean only stopped containers"
    echo -e "${YELLOW}3)${NC} Clean unused images, volumes, networks (without affecting running ones)"
    echo -e "${YELLOW}4)${NC} Clean only builder cache"
    echo -e "${YELLOW}5)${NC} ${RED}Fully clean Docker (stop and remove EVERYTHING)${NC}"
    echo -e "${YELLOW}0)${NC} Exit script"
    echo -e "${CYAN}=========================================${NC}"

    echo -ne "${YELLOW}Select an action (0-5): ${NC}"
    read choice

    case "$choice" in
        1)
            # Get arrays of IDs and Names of ALL containers
            CONTAINER_IDS=($(docker ps -a -q))
            CONTAINER_NAMES=($(docker ps -a --format '{{.Names}}'))

            if [ ${#CONTAINER_IDS[@]} -eq 0 ]; then
                echo -e "${YELLOW}No containers found (neither running nor stopped).${NC}"
            else
                echo -e "\n${CYAN}--- List of all containers ---${NC}"
                echo -e "No.\tID\t\tNAME\t\tSTATUS"
                
                # Output numbered list
                i=1
                while IFS= read -r line; do
                    echo -e "${YELLOW}$i)${NC}\t$line"
                    ((i++))
                done < <(docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Status}}")

                echo -e "\n${CYAN}What do you want to do?${NC}"
                echo -e "${YELLOW}11)${NC} Stop a container"
                echo -e "${YELLOW}12)${NC} Remove a container (force)"
                echo -e "${YELLOW}13)${NC} ${RED}Remove a container and clean its data (volumes)${NC}"
                echo -e "${YELLOW}0)${NC} Back to main menu"
                
                echo -ne "${YELLOW}Select a sub-option (11, 12, 13, or 0): ${NC}"
                read sub_choice
                
                case "$sub_choice" in
                    11)
                        echo -ne "${YELLOW}Enter the container NUMBER from the list to STOP: ${NC}"
                        read c_num
                        if [[ "$c_num" =~ ^[0-9]+$ ]] && [ "$c_num" -ge 1 ] && [ "$c_num" -le "${#CONTAINER_IDS[@]}" ]; then
                            target_id="${CONTAINER_IDS[$((c_num-1))]}"
                            target_name="${CONTAINER_NAMES[$((c_num-1))]}"
                            
                            echo -ne "${RED}Confirm stopping [${target_name}], by typing the word '${YELLOW}STOP${RED}': ${NC}"
                            read confirm_stop
                            if [ "$confirm_stop" == "STOP" ]; then
                                docker stop "$target_id"
                                echo -e "${GREEN}Container $target_name stopped.${NC}"
                            else
                                echo -e "${GREEN}Action canceled.${NC}"
                            fi
                        else
                            echo -e "${RED}Canceled: invalid number entered.${NC}"
                        fi
                        ;;
                    12)
                        echo -ne "${YELLOW}Enter the container NUMBER from the list to REMOVE: ${NC}"
                        read c_num
                        if [[ "$c_num" =~ ^[0-9]+$ ]] && [ "$c_num" -ge 1 ] && [ "$c_num" -le "${#CONTAINER_IDS[@]}" ]; then
                            target_id="${CONTAINER_IDS[$((c_num-1))]}"
                            target_name="${CONTAINER_NAMES[$((c_num-1))]}"

                            echo -ne "${RED}Confirm removal of [${target_name}], by typing the word '${YELLOW}REMOVE${RED}': ${NC}"
                            read confirm_del
                            if [ "$confirm_del" == "REMOVE" ]; then
                                docker rm -f "$target_id"
                                echo -e "${GREEN}Container $target_name removed.${NC}"
                            else
                                echo -e "${GREEN}Action canceled.${NC}"
                            fi
                        else
                            echo -e "${RED}Canceled: invalid number entered.${NC}"
                        fi
                        ;;
                    13)
                        echo -ne "${YELLOW}Enter the container NUMBER to REMOVE and CLEAN volumes: ${NC}"
                        read c_num
                        if [[ "$c_num" =~ ^[0-9]+$ ]] && [ "$c_num" -ge 1 ] && [ "$c_num" -le "${#CONTAINER_IDS[@]}" ]; then
                            target_id="${CONTAINER_IDS[$((c_num-1))]}"
                            target_name="${CONTAINER_NAMES[$((c_num-1))]}"

                            echo -ne "${RED}Confirm full removal of [${target_name}], by typing the word '${YELLOW}REMOVE${RED}': ${NC}"
                            read confirm_del
                            if [ "$confirm_del" == "REMOVE" ]; then
                                docker rm -f -v "$target_id"
                                echo -e "${GREEN}Container $target_name and its associated volumes were removed.${NC}"
                            else
                                echo -e "${GREEN}Action canceled.${NC}"
                            fi
                        else
                            echo -e "${RED}Canceled: invalid number entered.${NC}"
                        fi
                        ;;
                    0)
                        echo -e "${GREEN}Returning to the main menu...${NC}"
                        ;;
                    *)
                        echo -e "${RED}Invalid sub-option choice.${NC}"
                        ;;
                esac
            fi
            ;;
        2)
            echo -e "\n${CYAN}=== Cleaning stopped containers ===${NC}"
            docker container prune -f
            echo -e "${GREEN}Done!${NC}"
            ;;
        3)
            echo -e "\n${CYAN}=== Cleaning unused images, networks, and volumes ===${NC}"
            echo -e "${RED}Removing networks...${NC}"
            docker network prune -f
            echo -e "${RED}Removing volumes...${NC}"
            docker volume prune -f
            echo -e "${RED}Removing unused images (Dangling & Unused)...${NC}"
            docker image prune -a -f
            echo -e "${GREEN}Done!${NC}"
            ;;
        4)
            echo -e "\n${CYAN}=== Cleaning builder cache ===${NC}"
            if docker buildx version >/dev/null 2>&1; then
                docker buildx prune -a -f
            else
                docker builder prune -a -f 2>/dev/null
            fi
            echo -e "${GREEN}Done!${NC}"
            ;;
        5)
            echo -e "\n${RED}WARNING! This action will completely stop and remove ALL containers, images, networks, and volumes!${NC}"
            echo -ne "${RED}To confirm, type the phrase '${YELLOW}WIPE ALL${RED}' (in uppercase): ${NC}"
            read confirm_wipe
            
            if [ "$confirm_wipe" == "WIPE ALL" ]; then
                echo -e "${RED}=== Starting full Docker wipe ===${NC}"
                if [ -n "$(docker ps -q)" ]; then
                    echo -e "${YELLOW}Stopping running containers...${NC}"
                    docker stop $(docker ps -q)
                else
                    echo -e "${GREEN}No running containers.${NC}"
                fi

                if [ -n "$(docker ps -a -q)" ]; then
                    echo -e "${RED}Removing all containers...${NC}"
                    docker rm -f $(docker ps -a -q)
                else
                    echo -e "${GREEN}No containers to remove.${NC}"
                fi

                if [ -n "$(docker images -q)" ]; then
                    echo -e "${RED}Removing Docker images...${NC}"
                    docker rmi -f $(docker images -a -q)
                else
                    echo -e "${GREEN}No images to remove.${NC}"
                fi

                echo -e "${RED}Global prune of unused system objects...${NC}"
                docker system prune -a --volumes -f

                echo -e "${YELLOW}Cleaning builder cache...${NC}"
                if docker buildx version >/dev/null 2>&1; then
                    docker buildx prune -a -f
                else
                    docker builder prune -a -f 2>/dev/null
                fi
                echo -e "${GREEN}=== Cleanup successfully completed! ===${NC}"
            else
                echo -e "${GREEN}Full wipe operation canceled. Your data is safe.${NC}"
            fi
            ;;
        0)
            echo -e "\n${GREEN}Exiting script. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Error: Invalid choice. Please enter a number from 0 to 5.${NC}"
            ;;
    esac
done
