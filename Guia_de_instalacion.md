# 🔧 Guía de Instalación Completa

## 📋 Tabla de Contenidos

1. [Instalación en Ubuntu/Debian/Kali](#ubuntu-debian-kali)
2. [Instalación en Arch/Manjaro](#arch-manjaro)
3. [Instalación en Termux (Android)](#termux-android)
4. [Instalación de Google Chrome](#google-chrome)
5. [Configuración del Entorno Python](#entorno-python)
6. [Verificación de Instalación](#verificación)
7. [Problemas Comunes](#problemas-comunes)

---

## Ubuntu / Debian / Kali

### 1. Actualizar sistema
```bash
sudo apt update && sudo apt upgrade -y
2. Instalar dependencias base
bash
sudo apt install -y \
    php php-cli php-sqlite3 php-curl \
    python3 python3-pip python3-venv \
    openssh-client curl wget git \
    qrencode sqlite3 xclip jq xxd
```
3. Instalar Google Chrome

```bash
# Descargar
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Instalar
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt install -f -y

# Verificar
google-chrome --version
4. Configurar Python
bash
cd AdvancedPhishingFramework
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
Arch / Manjaro
bash
# Instalar dependencias
sudo pacman -Syu
sudo pacman -S \
    php php-sqlite python python-pip \
    openssh curl wget git \
    qrencode sqlite3 xclip jq
```

# Instalar Chrome (AUR)
```
yay -S google-chrome

# Configurar Python
cd AdvancedPhishingFramework
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
Termux (Android)
bash
# Actualizar paquetes
pkg update && pkg upgrade

# Instalar dependencias
pkg install \
    php python openssh curl wget \
    qrencode sqlite git

# Instalar dependencias Python
pip install requests beautifulsoup4 colorama

# Nota: Selenium NO funciona en Termux
# Usar solo modo Bash del clonador
```

Google Chrome
Si falla la instalación con dpkg:
```bash
# Método alternativo 1: Desde repositorio
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install google-chrome-stable

# Método alternativo 2: Chromium (open source)
sudo apt install chromium-browser
# Luego crear enlace simbólico
sudo ln -s /usr/bin/chromium-browser /usr/bin/google-chrome
```
Entorno Python
Si aparece "externally-managed-environment":
```bash
# Opción 1: Usar entorno virtual (RECOMENDADO)
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Opción 2: Usar pipx
sudo apt install pipx
pipx install selenium
pipx install webdriver-manager

# Opción 3: Forzar (NO RECOMENDADO)
pip install --break-system-packages -r requirements.txt
```
Si Selenium no encuentra ChromeDriver:
```bash
# Instalar webdriver-manager (lo descarga automáticamente)
pip install webdriver-manager

# O descargar manualmente
CHROME_VERSION=$(google-chrome --version | awk '{print $3}')
wget "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip"
unzip chromedriver-linux64.zip
sudo mv chromedriver-linux64/chromedriver /usr/local/bin/
sudo chmod +x /usr/local/bin/chromedriver
Verificación
```
Ejecutar script de diagnóstico:
```bash
cd AdvancedPhishingFramework
./advanced_phisher.sh --check
Deberías ver:
text
✅ PHP: 8.x.x
✅ Python: 3.x.x
✅ SSH: OpenSSH_x.x
✅ cURL: 7.x.x
✅ qrencode: 4.x.x
✅ SQLite3: 3.x.x
✅ Selenium: Disponible
✅ Chrome: Google Chrome 1xx.x
✅ Plataformas instaladas: 10
```

Probar el clonador:

```bash
source venv/bin/activate
python -c "from selenium import webdriver; print('✅ Selenium OK')"
Problemas Comunes
Problema	Solución
php: command not found	sudo apt install php php-cli
pip: command not found	sudo apt install python3-pip
externally-managed-environment	Usar python3 -m venv venv
Chrome binary not found	Instalar Google Chrome
chromedriver not found	pip install webdriver-manager
Permission denied	chmod +x advanced_phisher.sh
Tunnel muestra "login"	PHP server no está corriendo
✅ Instalación Completada
Después de seguir estos pasos, el framework estará listo para usar:
```
```bash
./advanced_phisher.sh
```
¡Disfruta! 🎉
