Parfait ! Voici un **aperçu complet** de ce à quoi ressemblera la **page GitHub principale** de ton dépôt `unicore-gps-setup` une fois publié :

---

# unicore-gps-setup

[![Installer maintenant](https://img.shields.io/badge/Installation-%F0%9F%9A%80%20Script%20GPS%20Unicore-blue?style=for-the-badge)](https://raw.githubusercontent.com/juditech3D/unicore-gps-setup/main/install.sh)
[![Voir sur GitHub](https://img.shields.io/badge/GitHub-juditech3D%2Funicore--gps--setup-black?style=for-the-badge&logo=github)](https://github.com/juditech3D/unicore-gps-setup)
[![Releases](https://img.shields.io/github/v/release/juditech3D/unicore-gps-setup?style=for-the-badge)](https://github.com/juditech3D/unicore-gps-setup/releases)


🎯 Script interactif conçu spécifiquement pour le projet **Mowgli / OpenMower**  
Permet de configurer automatiquement un module **GPS Unicore** :
- ✅ UM980  
- ✅ UM982  
- ✅ UM960 / UM96X  

Compatible **USB** ou **UART4 GPIO** sur **Raspberry Pi**, pour une intégration RTK fiable.

---

## 🧰 Fonctionnalités

- 🔌 Détection automatique du port (USB ou UART4)  
- 🔁 Activation automatique de `UART4` dans `/boot/config.txt` si nécessaire  
- 🔗 Création d’un lien `/dev/gps` :
  - Règle `udev` persistante pour USB (`idVendor`/`idProduct`)
  - Lien symbolique pour UART GPIO
- ⚙️ Configuration du module :
  - Baudrate : 115200 ➜ 460800
  - Mode `ROVER`, `NMEA0183`, `RTK`, etc.
- 🛠️ Compatible avec le firmware **Mowgli** et l’environnement **OpenMower**

---

## 🚀 Installation

### 📦 Méthode manuelle
```bash
git clone https://github.com/juditech3D/unicore-gps-setup.git
cd unicore-gps-setup
chmod +x setup_gps_unicore.sh
./setup_gps_unicore.sh
```

### ⚡ Méthode rapide (installation à distance)
```bash
curl -sSL https://raw.githubusercontent.com/juditech3D/unicore-gps-setup/main/install.sh | bash
```

---

## 🛠️ Exigences

- Raspberry Pi OS, Debian, Ubuntu
- Outils requis : `udevadm`, `stty`, `tee`, `bash`

---

## 🔍 Pour détecter les IDs USB
```bash
lsusb
```
→ récupère `idVendor` et `idProduct` de ton GPS Unicore pour les règles udev.

---

## 📦 À venir

-

---

🛡️ Ce script est développé par **@Juditech3D** pour faciliter l’intégration RTK dans le projet **Mowgli / OpenMower**.  
📚 Plus d’infos : https://github.com/juditech3D
