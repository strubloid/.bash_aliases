# WSL localhost mapping to Windows host
export WSL_HOST=$(ip route show | grep default | awk '{print $3}')

# Function to automatically map localhost to Windows host for curl
curl() {
  local url="$1"
  if [[ "$url" == *"localhost"* ]]; then
    url="${url/localhost/$WSL_HOST}"
    echo "WSL: Mapping localhost to Windows host: $WSL_HOST"
  fi
  command curl "$url" "${@:2}"
}