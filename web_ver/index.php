
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
            
            $fp=@fopen('./log/access_log.txt', 'a')or die("ファイル取得できません");
                if(flock($fp,LOCK_EX)){
                    fwrite($fp,$log);
                }
                flock($fp,LOCK_UN);

            setcookie("test1",1,time()+1);
        }

    // connect DB and get geo infomation
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

    // map pins on the map by using data from DB
    try 
    {
        $sql = "SELECT * FROM vending_machine_data";
        $res = $mysqli->query($sql);

        $data = [];

        foreach ($res as $value) 
        {
            $temp = array();
            if($value[alive] == 1)
            {
                $temp = ['id'=>$value[id], 
                         'latitude'=>$value[latitude], 
                         'longitude'=>$value[longitude], 
                         'updated'=>$value[updated], 
                         'memo'=>$value[memo]
                        ];
                $data[] = $temp;
            }
        }

        $php_json = json_encode($data, JSON_UNESCAPED_UNICODE);
        // $geo_data = var_dump($php_json);

    }  catch(PDOException $e) {
        echo $e->getMessage();
        die();
    }

    $dbh = null;
    $mysqli->close();
?>


<!DOCTYPE html>
<html>
<head>
    <!-- Global site tag (gtag.js) - Google Analytics -->
    <script async src=“https://www.googletagmanager.com/gtag/js?id=UA-138497391-1“></script>
    <script>
     window.dataLayer = window.dataLayer || [];
     function gtag(){dataLayer.push(arguments);}
     gtag(‘js’, new Date());

     gtag(‘config’, ‘UA-138497391-1’);
    </script>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="stylesheet" type="text/css" href="./css/stylesheet.css">
    <title>自動販売機Map</title>
</head>

<body>
    <div id="g_map"></div>

    <form action="add_data.php" method="get">
        緯度（10進数）：<br />
        <input type="text" name="latitude" size="30" value="" /><br />
        経度（10進数）：<br />
        <input type="text" name="longitude" size="30" value="" /><br />
        コメント（任意：100文字以内）：<br />
        <textarea name="memo" cols="30" rows="5"></textarea><br />
        <br />
        <input type="submit" value="登録する" />
    </form>

    

    <h1>位置情報取得サンプル</h1>
    <p>現在地の位置情報（緯度：経度）はここから調べてね</p>
    <a href="https://user.numazu-ct.ac.jp/~tsato/webmap/sphere/coordinates/advanced.html">Web地図</a>

    <script type="text/javascript">
        var geo_data = <?php echo $php_json; ?>;
    </script>
    <script type="text/javascript" src="./js/google_map.js"></script>
    <script src="https://maps.googleapis.com/maps/api/js?key='my_key'&callback=initMap"
    async defer></script>
    
    <script type="text/javascript" src="./js/pin_map.js"></script>
</body>
</html>
