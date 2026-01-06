CPU_NAME=$(lscpu | grep "Model name" | sed 's/Model name:\s*//')
CPU_SPEED=$(lscpu | grep "CPU max MHz" | sed 's/CPU max MHz:\s*//' | awk -F',' '{print $1}')

RAM_SIZE=$(free -m | awk '/^Mem:/ { printf "%.0f\n", $2 / 1024 }')
OS=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')

echo "cpu_name,cpu_speed,ram_size,os"
echo "\"$CPU_NAME\",$CPU_SPEED,$RAM_SIZE,\"$OS\""