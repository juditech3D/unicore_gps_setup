
#!/bin/bash

BAUD_INITIAL=115200
BAUD_NEW=460800
GPS_PORT=""
USE_USB=false

# Couleurs terminal
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
NC="\033[0m" # No Color

step() { echo -e "${BLUE}🔹 [$1] $2${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

progress_bar() {
  secs=$1
  echo -n "⏳ "
  for ((i=0; i<$secs; i++)); do
    echo -n "█"
    sleep 1
  done
  echo ""
}

send_cmd() {
    echo -ne "$1\r\n" | sudo tee "$GPS_PORT" > /dev/null
    sleep 0.2
}

echo -e "${YELLOW}----------------------------------------"
echo "Configuration du module GPS Unicore"
echo "----------------------------------------${NC}"

# Choix USB ou UART
echo "Quel type de connexion utilise ton GPS ?"
select opt in "USB (ttyUSBx)" "UART4 (GPIO 8/9)"; do
  case $REPLY in
    1) USE_USB=true; break ;;
    2) USE_USB=false; break ;;
    *) echo "Choix invalide";;
  esac
done

# Gestion USB
if [ "$USE_USB" = true ]; then
  echo ""
  step 1 "Liste des ports USB détectés"
  ls /dev/ttyUSB* 2>/dev/null || warn "Aucun GPS USB détecté pour l’instant."
  read -p "➡️ Entre le port GPS USB (ex: /dev/ttyUSB0) : " GPS_PORT

  step 2 "Création règle udev persistante"
  echo "🔍 Recherche du VendorID et ProductID..."
  USB_ID=$(udevadm info -a -n "$GPS_PORT" | grep -m 1 "idVendor" -A 1 | tr -d ' ')

  ID_VENDOR=$(echo "$USB_ID" | grep idVendor | cut -d\" -f2)
  ID_PRODUCT=$(echo "$USB_ID" | grep idProduct | cut -d\" -f2)

  if [ -z "$ID_VENDOR" ] || [ -z "$ID_PRODUCT" ]; then
    error "Impossible d'obtenir VendorID/ProductID automatiquement."
    read -p "🔧 Saisie manuelle - idVendor : " ID_VENDOR
    read -p "🔧 Saisie manuelle - idProduct : " ID_PRODUCT
  fi

  RULE="SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"$ID_VENDOR\", ATTRS{idProduct}==\"$ID_PRODUCT\", SYMLINK+=\"gps\""
  echo "$RULE" | sudo tee /etc/udev/rules.d/99-gps.rules > /dev/null
  sudo udevadm control --reload-rules
  sudo udevadm trigger
  success "Règle udev ajoutée pour GPS USB : /dev/gps → $GPS_PORT"

else
  GPS_PORT="/dev/ttyAMA4"

  step 1 "Activation de l'UART4 si nécessaire"
  CONFIG_PATH=$(find /boot -name config.txt | head -n 1)
  if ! grep -q '^dtoverlay=uart4' "$CONFIG_PATH"; then
    echo "dtoverlay=uart4" | sudo tee -a "$CONFIG_PATH"
    warn "Redémarrage requis pour activer l’UART4."
    read -p "Redémarrer maintenant ? (y/n) : " reboot
    [[ "$reboot" == "y" ]] && sudo reboot && exit 0
  fi

  step 2 "Création du lien /dev/gps → $GPS_PORT"
  sudo ln -sf "$GPS_PORT" /dev/gps
  success "Lien symbolique créé : /dev/gps → $GPS_PORT"
fi

# Paramétrage série initial
step 3 "Configuration initiale à $BAUD_INITIAL bauds"
stty -F "$GPS_PORT" $BAUD_INITIAL raw -echo -echoe -echok
progress_bar 1

step 4 "Envoi des commandes Unicore"
send_cmd '$FRESET'
progress_bar 2

send_cmd 'CONFIG SIGNALGROUP 2'
progress_bar 1
send_cmd 'CONFIG NMEA0183 V411'
send_cmd 'MODE ROVER SURVEY MOW'
send_cmd 'CONFIG PPP ENABLE E6-HAS'
send_cmd 'CONFIG AGNSS DISABLE'
send_cmd 'CONFIG SBAS DISABLE'
send_cmd 'CONFIG RTK RELIABILITY 4 3'
send_cmd 'CONFIG RTK TIMEOUT 600'
send_cmd 'CONFIG PPP TIMEOUT 180'
send_cmd 'CONFIG DGPS TIMEOUT 300'

send_cmd 'GPGGA 0.1'
send_cmd 'GPGSA 1'
send_cmd 'GPGST 1'
send_cmd 'GPGSV 1'
send_cmd 'GPRMC 1'
send_cmd 'GPVTG 1'

step 5 "Changement du débit à $BAUD_NEW"
send_cmd "CONFIG COM1 $BAUD_NEW"
progress_bar 1

stty -F "$GPS_PORT" $BAUD_NEW raw -echo -echoe -echok

step 6 "Envoi de SAVECONFIG"
send_cmd 'SAVECONFIG'

success "Module GPS configuré avec succès !"
success "/dev/gps prêt à être utilisé à $BAUD_NEW bauds."
