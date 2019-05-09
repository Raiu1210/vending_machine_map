
var map;
var marker = [];
var infoWindow = [];
// var center = {
// 	lat: 35.698379,
// 	lng: 139.773102
// };

var center = {
    lat: 40.5885,
    lng: 140.473
};


// alert(geo_data[0]["latitude"]);
// alert(Object.keys(geo_data).length);



function initMap() {
    map = new google.maps.Map(document.getElementById('g_map'), { 
        center: center,
        zoom: 19 // 地図のズームを指定
    });

    for(var i=0; i<Object.keys(geo_data).length; i++)
    {
        var id = parseInt(geo_data[i]["id"]);
        var latitude = parseFloat(geo_data[i]["latitude"]);
        var longitude = parseFloat(geo_data[i]["longitude"]);
        var updated = geo_data[i]["updated"];
        var memo = geo_data[i]["memo"];

        // alert(latitude);

        pin_on_map(i, id, latitude, longitude, updated, memo, map);
        // Hello();
        // pin_on_map(1, 40.588558197021484, 140.47332763671875, "2019-04-10 15:02:48", "３階：人文、理工の連絡通路の人文側。魔剤あり", map);
    }

    // pin_on_map(1, 40.588558197021484, 140.47332763671875, "2019-04-10 15:02:48", "３階：人文、理工の連絡通路の人文側。魔剤あり", map);
}


function pin_on_map(index, id, latitude, longitude, updated, memo, map) {
    var pin_position = {
        lat: latitude,
        lng: longitude
    };

    marker[index] = new google.maps.Marker({
        position: pin_position,
        map: map
    });

    infoWindow[index] = new google.maps.InfoWindow({ // 吹き出しの追加
        content: '<div class="sample">' + memo + '</div><br><form action="delete_data.php" method="get"><input type="hidden" name="id" value="' + String(id) + '"><input type="submit" value="削除" /></form>' // 吹き出しに表示する内容
    });

    marker[index].addListener('click', function() { // マーカーをクリックしたとき
        infoWindow[index].open(map, marker[index]); // 吹き出しの表示
    });
}


function Hello()
{
    alert("Hello");
}


        