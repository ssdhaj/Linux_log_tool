#!/bin/bash

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root or with sudo"
  exit 1
fi

# Show recent login IPs and times
function show_login_ips() {
  echo "Recent login IP list and their latest login times:"
  last -i | grep -v 'wtmp begins' \
    | awk '{printf "%s %s %s %s %s\n", $3, $4, $5, $6, $7}' \
    | grep -Eo '^([0-9]{1,3}\.){3}[0-9]{1,3} .*' \
    | sort | uniq -w15 \
    | while read ip month day time rest; do
        echo "$ip    Last login time: $month $day $time"
      done
}

# Delete login records for specified IPs
function delete_login_log_by_ip() {
  read -p "Enter the IP(s) to delete (separate multiple with semicolon, e.g. 192.168.1.1;10.0.0.2): " ip_input

  if [[ -z "$ip_input" ]]; then
    echo "IP cannot be empty"
    exit 1
  fi

  IFS=';' read -ra ip_list <<< "$ip_input"
  echo "[*] Processing the following IPs: ${ip_list[*]}"

  # Clean /var/log/wtmp
  if [ -f /var/log/wtmp ]; then
    echo "[*] Cleaning records in /var/log/wtmp"
    temp_file=$(mktemp)
    utmpdump /var/log/wtmp > "$temp_file"
    for ip in "${ip_list[@]}"; do
      sed -i "/$ip/d" "$temp_file"
    done
    utmpdump -r "$temp_file" > /var/log/wtmp
    rm -f "$temp_file"
  fi

  # Clean /var/log/secure or /var/log/auth.log
  log_files=("/var/log/secure" "/var/log/auth.log")
  for log_file in "${log_files[@]}"; do
    if [ -f "$log_file" ]; then
      echo "[*] Cleaning records in $log_file"
      for ip in "${ip_list[@]}"; do
        sed -i "/$ip/d" "$log_file"
      done
    fi
  done

  echo "[+] All specified IP login logs have been deleted (no backups or intermediate files kept)"
}

# Main menu
echo "==============================="
echo " Linux Login Log Management Tool"
echo "==============================="
echo "1) View recent login IPs"
echo "2) Delete specified IP(s) (semicolon-separated)"
echo "0) Exit"
echo "==============================="

read -p "Select an option [0-2]: " choice

case "$choice" in
  1)
    show_login_ips
    ;;
  2)
    delete_login_log_by_ip
    ;;
  0)
    echo "Exit"
    ;;
  *)
    echo "Invalid option"
    ;;
esac
