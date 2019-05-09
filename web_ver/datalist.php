<?php 
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
            
        $fp=@fopen('./log/datalist_log.txt', 'a')or die("ファイル取得できません");
            if(flock($fp,LOCK_EX)){
                fwrite($fp,$log);
            }
            flock($fp,LOCK_UN);

        setcookie("test1",1,time()+1);
    }

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
        echo $php_json;

    }  catch(PDOException $e) {
        echo $e->getMessage();
        die();
    }

    $dbh = null;
    $mysqli->close();
         
 ?>
