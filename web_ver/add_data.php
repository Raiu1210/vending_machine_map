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
            
            $fp=@fopen('./log/add_log.txt', 'a')or die("ファイル取得できません");
                if(flock($fp,LOCK_EX)){
                    fwrite($fp,$log);
                }
                flock($fp,LOCK_UN);

            setcookie("test1",1,time()+1);
        }


    // check inputs from this site
    // (1) check latitude
    $latitude = 0.0;
    $longitude = 0.0;
    $memo = htmlspecialchars($_GET['memo'], ENT_QUOTES, "UTF-8");

    // check input
    try 
    {
        $latitude = (double) $_GET['latitude'];
        if($latitude < -90 || $latitude > 90 || $latitude == 0)
        {
            exit('それ緯度ちゃうんやん');
        }

        $longitude = (double) $_GET['longitude'];
        if($longitude < -180 || $longitude > 180 || $longitude == 0)
        {
            exit('それ経度ちゃうんやん');
        }

        if(mb_strlen($memo) > 100)
        {
            exit('長すぎー、もっと要約しなよwww');
        }
    } 
    catch ( Exception $ex ) 
    {
        echo $ex;
    }

    // connect to DB
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

    // write to DB
    $sql = "INSERT INTO vending_machine_data (
                latitude, 
                longitude, 
                memo, 
                alive
        )   VALUES (
                '$latitude',
                '$longitude',
                '$memo',
                1
        )";

    $res = $mysqli->query($sql);
    var_dump($res);
    $mysqli->close();
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
    <a href="index.php">戻る</a>
    
    <script>
        Hello();
    </script>
</body>
</html>
