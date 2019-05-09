<?php 
	// create log
    if(empty($_COOKIE['test1']))
        {
            $time=date("Y/m/d H:i:s");
            $requestUrl=$_SERVER['REQUEST_URI'];
            $requestMethod=$_SERVER['REQUEST_METHOD'];
            $requestbrowser=$_SERVER['HTTP_USER_AGENT'];
            $requestIp=$_SERVER['REMOTE_ADDR'];
            $hostName=@gethostbyaddr($requestIp);
            $httpReferer=$_SERVER['HTTP_REFERER'];
            $log=$time.", ".$requestUrl.", ".$requestMethod.", ".$requestbrowser.", ".$requestIp.", ".$hostName.", ".$httpReferer."\r\n";
            
            $fp=@fopen('./log/delete_log.txt', 'a')or die("ファイル取得できません");
                if(flock($fp,LOCK_EX)){
                    fwrite($fp,$log);
                }
                flock($fp,LOCK_UN);

            setcookie("test1",1,time()+1);
        }

	$delete_id = htmlspecialchars($_GET['id'], ENT_QUOTES, "UTF-8");
	// echo $delete_id;

	// connect server
	$mysqli = new mysqli("", "", "", "");
    if ($mysqli->connect_error)
    {
        echo $mysqli->connect_error;
        exit();
    } 
    else
    {
        $mysqli->set_charset("utf8");
    }

	
	try 
    {
        $delete_id = htmlspecialchars($delete_id);
        $delete_id = (int) $delete_id;
        echo $delete_id;

        $sql = "UPDATE vending_machine_data 
        		SET alive = 0 
        		WHERE id = ".$delete_id;

        $res = $mysqli->query($sql);
        $mysqli->close();
    } 
    catch ( Exception $ex ) 
    {
        echo $ex;
    }    

?>


<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>自動販売機Map</title>
</head>

<body>
    <!-- <h1>おくってみた</h1> -->
    <p>協力ありがとう！</p>
    <p>削除したぜ</p>
    <a href="index.php">戻る</a>
    
</body>
</html>
