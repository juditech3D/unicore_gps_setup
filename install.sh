#!/bin/bash

echo "📥 Téléchargement du script GPS Unicore..."
curl -sSL https://raw.githubusercontent.com/juditech3D/unicore-gps-setup/main/setup_gps_unicore.sh -o setup_gps_unicore.sh

echo "🔐 Attribution des droits d’exécution..."
chmod +x setup_gps_unicore.sh

echo "🚀 Lancement du script..."
./setup_gps_unicore.sh
