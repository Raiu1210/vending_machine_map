//
//  ViewController.swift
//  vending_machine_map_ios
//
//  Created by 石橋龍 on 2019/04/16.
//  Copyright © 2019 Team snake. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation
import SwiftyJSON
import FloatingPanel
import GoogleMobileAds

var update_counter = 0

class CustomPointAnnotation: MKPointAnnotation {
    var type: String!
    var id: String!
    var timestamp: String!
    var memo: String!
    var pinColor: UIColor = UIColor.blue
}



class ViewController: UIViewController, GADBannerViewDelegate {
    
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    @IBOutlet weak var mapView: MKMapView!
    var floatingPanelController: FloatingPanelController!
    let semiModalViewController = SemiModalViewController()
    let data_server = "http://zihankimap.work/datalist"
    var long_tap_pin: CustomPointAnnotation!
    
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    private var myButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        play_banner_ad()
        create_label()
        create_button()
        create_semi_modal_view()
        get_data_from_server(url:data_server)
        configureLocationServices()
        floatingPanelController.hide(animated: true)
        sleep(20)
        play_interstitial_ad()
    }
    
    func play_banner_ad() {
//        at the same time, load interstitial ad
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        interstitial.load(request)
        
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // test unit ID
        bannerView.adUnitID = "ca-app-pub-9410270200655875/1269020610"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        addBannerViewToView(bannerView)
    }
    
    func play_interstitial_ad() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    private func create_label() {
        let background_label = UILabel()
        let title_label = UILabel()
        background_label.frame = CGRect(x: 0,y: 0,width: self.view.frame.width, height: 70)
        background_label.backgroundColor = UIColor.cyan
        
        title_label.frame = CGRect(x: 0,y: 30, width: self.view.frame.width, height: 30)
        title_label.text = "自動販売機Map"
        title_label.font = UIFont(name:"KohinoorTelugu-Medium", size: 24)
        title_label.textAlignment = NSTextAlignment.center

        
        self.view.addSubview(background_label)
        self.view.addSubview(title_label)
    }
    
    private func create_button() {
        let image0 = UIImage(named:"reload_img.png")!
        myButton = UIButton()
        myButton.frame = CGRect(x: 0,y: 0,width: 30,height: 30)
        myButton.layer.position = CGPoint(x: self.view.frame.width-30, y:40)
        myButton.addTarget(self, action: #selector(self.onClick_button(_:)), for: UIControl.Event.touchUpInside)
        myButton.setImage(image0, for:  .normal)
        self.view.addSubview(myButton)
    }
    
    @objc func onClick_button(_ sender:UIButton){
        print("button tapped")
        self.loadView()
        self.viewDidLoad()
        print("reloaded")
    }
    
    func reload_view() {
        self.loadView()
        self.viewDidLoad()
        print("reloaded")
    }
    
    @IBAction func longPressMap(_ sender: UILongPressGestureRecognizer) {
        if(sender.state != UIGestureRecognizer.State.began){
            return
        }
        let location: CGPoint = sender.location(in: mapView)
        let tap_coordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        long_tap_pin = CustomPointAnnotation()
        long_tap_pin.coordinate = tap_coordinate
        long_tap_pin.type = "Add"
        long_tap_pin.id = ""
        long_tap_pin.timestamp = ""
        long_tap_pin.memo = ""
        long_tap_pin.subtitle = ""
//        long_tap_pin.latitude = String(long_tap_pin.coordinate.latitude)
//        long_tap_pin.longitude = String(long_tap_pin.coordinate.longitude)
        mapView.addAnnotation(long_tap_pin)
    }
    
    
    private func configureLocationServices(){
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: locationManager)
        }
        mapView.setCenter(mapView.userLocation.coordinate, animated: false)
    }
    
    private func beginLocationUpdates(locationManager: CLLocationManager){
        mapView.showsUserLocation = true
        print("I'm Called !!!!!")
        let myCoordinate = locationManager.location?.coordinate
        let myRegion = MKCoordinateRegion.init(center: myCoordinate!, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(myRegion, animated: false)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(zoomRegion, animated: false)
    }
    
    private func create_semi_modal_view(){
        floatingPanelController = FloatingPanelController()
        floatingPanelController.view.frame = view.bounds
        floatingPanelController.set(contentViewController: semiModalViewController)
        floatingPanelController.addPanel(toParent: self, belowView: nil, animated: true)
        floatingPanelController.surfaceView.cornerRadius = 24.0
    }
    
    
    private func get_data_from_server(url:String){
        let url = URL(string: url)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in if error == nil, let data = data, let response = response as? HTTPURLResponse {
            let jsonString = String(data: data, encoding: String.Encoding.utf8) ?? ""
            let json_Data: Data =  jsonString.data(using: String.Encoding.utf8)!
//            print(json_Data)
            do {
                let parsed_data = try JSON(data: json_Data)
                print(parsed_data)
                for i in 0 ..< parsed_data.count
                {
                    let id = parsed_data[i]["id"].stringValue
                    print(id)
                    let lat = parsed_data[i]["latitude"].doubleValue
                    let lon = parsed_data[i]["longitude"].doubleValue
                    let updated = parsed_data[i]["updated"].stringValue
                    let memo = parsed_data[i]["memo"].stringValue
                    
                    let pin_lat:CLLocationDegrees = lat
                    let pin_lon:CLLocationDegrees = lon
                    let pin_point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pin_lat, pin_lon)
                    let pin = CustomPointAnnotation()
                    pin.coordinate = pin_point
                    pin.type = "db"
                    pin.id = id
                    pin.timestamp = updated
                    pin.memo = memo
                    pin.pinColor = UIColor.green
                    pin.subtitle = ""
                    
                    self.mapView.addAnnotation(pin)
                }
            } catch { print(error) }
            }
        }.resume()
    }
    
   
    @IBAction func mapViewDidTap(_ sender: UITapGestureRecognizer) {
        semiModalViewController.reset_semi_modal_view()
        floatingPanelController.hide(animated: true)
    }
    
    private func play_ad() {
        print("I'll play add")
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        currentCoordinate = latestLocation.coordinate
        if update_counter == 0 {
            zoomToLatestLocation(with: latestLocation.coordinate)
        }
        currentCoordinate = latestLocation.coordinate
        update_counter += 1
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("The status changed")
        if status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
    
}


extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)
        guard let markerAnnotationView = annotationView as? MKMarkerAnnotationView,
            let annotation = annotation as? CustomPointAnnotation else { return annotationView }
        let type = String((annotation as! CustomPointAnnotation).type)
        
        if(type == "db") {
            markerAnnotationView.markerTintColor = nil
            markerAnnotationView.clusteringIdentifier = "vending_machine"
        } else if (type == "Add") {
            markerAnnotationView.markerTintColor = UIColor.blue
        }
        
        return markerAnnotationView
    }
    
    internal func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Selected ")
        if(view.annotation?.title == "My Location"){
            print("this is my location")
            return
        }
        
        var annotation_subtitle:String = ""
        annotation_subtitle = String((view.annotation?.subtitle ?? "more")!)
        if(annotation_subtitle.suffix(4) == "more") {
            print("this is cluster")
        } else {
            floatingPanelController.show(animated: true)
            let type = String((view.annotation as! CustomPointAnnotation).type)
            let id = String((view.annotation as! CustomPointAnnotation).id)
            let memo = String((view.annotation as! CustomPointAnnotation).memo)
            let timestamp = String((view.annotation as! CustomPointAnnotation).timestamp)
            let latitude = String(Double(view.annotation?.coordinate.latitude ?? 0.000000000))
            let longitude = String(Double(view.annotation?.coordinate.longitude ?? 0.00000000))
            print(latitude)
            print(longitude)
            semiModalViewController.update_SemiModalView(type:type, id:id, latitude:latitude, longitude:longitude, timestamp:timestamp, memo:memo)
        }
        
        print(view.annotation?.title)
        print(view.annotation?.subtitle)
    }
    
}






class SemiModalViewController: UIViewController {
    let detail_text = UITextView()
    let timestamp_label = UILabel()
    let delete_button = UIButton()
    let add_button = UIButton()
    
    var selected_id: String! = nil
    var updated: String! = nil
    var add_latitude:String = ""
    var add_longitude:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        createTextView_and_Label()
        createButton()
    }
    
    
    private func createTextView_and_Label(){
        let viewWidth  = self.view.bounds.height
        let viewHeight = self.view.bounds.width
        
        self.detail_text.delegate = self
        detail_text.frame = CGRect(x:viewWidth/50 ,y: viewHeight/10,width: viewWidth/2.5,height: 200)
        detail_text.font = UIFont.systemFont(ofSize: CGFloat(20))
        detail_text.isEditable = false
        
        timestamp_label.frame = CGRect(x:viewWidth/50 ,y: viewHeight/1.8,width: viewWidth/2,height: 30)
        
        self.view.addSubview(detail_text)
        self.view.addSubview(timestamp_label)
    }
    
    private func createButton(){
        let viewWidth  = self.view.bounds.height
        let viewHeight = self.view.bounds.width
        
        delete_button.frame = CGRect(x:viewWidth/2.3, y: viewHeight/4, width: 70, height: 70)
        delete_button.backgroundColor = UIColor.red
        delete_button.layer.cornerRadius = 20.0
        delete_button.setTitle("削除", for: UIControl.State.normal)
        delete_button.titleLabel!.font = UIFont(name: "Helvetica-Bold", size: 20)
        delete_button.addTarget(self, action: #selector(self.onClick_delete_button(_:)), for: UIControl.Event.touchUpInside)
        delete_button.isHidden = true
        
        add_button.frame = CGRect(x:viewWidth/2.3, y: viewHeight/4, width: 70, height: 70)
        add_button.backgroundColor = UIColor.green
        add_button.layer.cornerRadius = 20.0
        add_button.setTitle("追加", for: UIControl.State.normal)
        add_button.titleLabel!.font = UIFont(name: "Helvetica-Bold", size: 20)
        add_button.addTarget(self, action: #selector(self.onClic_add_button(_:)), for: UIControl.Event.touchUpInside)
        add_button.isHidden = true
        
        self.view.addSubview(delete_button)
        self.view.addSubview(add_button)
    }
    
    @objc func onClick_delete_button(_ sender:UIButton){
        print("onClick_delete_button:")
        print("I will delete \(selected_id)")
        let alert: UIAlertController = UIAlertController(title: "削除確認", message: "このピンを削除しますか？", preferredStyle: UIAlertController.Style.actionSheet)
        let defaultAction: UIAlertAction = UIAlertAction(title: "削除する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) -> Void in
            self.delete_pin(delete_id:self.selected_id)
            print("deleted")
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) -> Void in
            print("Canceled")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func onClic_add_button(_ sender:UIButton){
        print("onClick_add_button:")
        let alert: UIAlertController = UIAlertController(title: "追加確認", message: "ここにピンを追加しますか？", preferredStyle: UIAlertController.Style.actionSheet)
        let defaultAction: UIAlertAction = UIAlertAction(title: "追加する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) -> Void in
            self.add_pin()
            print("added")
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) -> Void in
            print("Canceled")
            })
        
        print("I will add")
        print(add_latitude)
        print(add_longitude)
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func delete_pin(delete_id: String){
        let delete_url = "http://zihankimap.work/delete_data.php?id=" + delete_id
        let url = URL(string: delete_url)!
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            print("done session")
        }
        task.resume()
        let thankyou_alert: UIAlertController = UIAlertController(title: "協力ありがとう!", message: "ピンの削除処理をサーバに送りました。マップを更新するには右上のリロードボタンをおタップしてください。通信状況により、データの反映にラグが出ることがあります。その時は時間をおいてアプリを再起動してみてください\n\nまた、情報提供してくれるかな？", preferredStyle: UIAlertController.Style.actionSheet)
        
        let thankyou_defaultAction: UIAlertAction = UIAlertAction(title: "いいとも！", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) -> Void in
        })
        
        thankyou_alert.addAction(thankyou_defaultAction)
        present(thankyou_alert, animated: true, completion: nil)
        reset_semi_modal_view()
    }
    
    private func add_pin() {
        let latitude_str = "latitude=\(add_latitude)&"
        let longitude_str = "longitude=\(add_longitude)&"
        var memo_str = "memo="
        if(detail_text.text != "場所の簡単な説明をここに書こう！"){
            memo_str = "memo=" + String(detail_text.text)
        }
        
        var add_url: String = "http://zihankimap.work/add_data.php?" + latitude_str + longitude_str + memo_str
        let encodeUrlString: String = add_url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        print(add_url)
        let url = URL(string: encodeUrlString)!
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            print("done session")
        }
        task.resume()
        let thankyou_alert: UIAlertController = UIAlertController(title: "協力ありがとう!", message: "ピンの追加処理をサーバに送りました。マップを更新するには右上のリロードボタンをおタップしてください。通信状況により、データの反映にラグが出ることがあります。その時は時間をおいてアプリを再起動してみてください\n\nまた、情報提供してくれるかな？", preferredStyle: UIAlertController.Style.actionSheet)
        let thankyou_defaultAction: UIAlertAction = UIAlertAction(title: "いいとも！", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) -> Void in
        })
        thankyou_alert.addAction(thankyou_defaultAction)
        present(thankyou_alert, animated: true, completion: nil)
        reset_semi_modal_view()
    }
    
    
    func update_SemiModalView(type:String, id:String, latitude:String, longitude:String, timestamp:String, memo:String){
        
        if(type == "db"){
            delete_button.isHidden = false
            selected_id = id
            updated = timestamp
            detail_text.text = memo
            timestamp_label.text = "updated  " + timestamp
        } else if (type == "Add") {
            add_button.isHidden = false
            add_latitude = String(latitude)
            add_longitude = String(longitude)
            detail_text.isEditable = true
            detail_text.text = "場所の簡単な説明をここに100文字以内で書こう！"
            print("i'm here ")
            print(latitude)
            print(longitude)
        }
    }
    
    func reset_semi_modal_view() {
        delete_button.isHidden = true
        add_button.isHidden = true
        detail_text.isEditable = false
        detail_text.text = ""
        timestamp_label.text = ""
    }
    
    
    
    
    
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    
}

extension SemiModalViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            //あなたのテキストフィールド
            detail_text.resignFirstResponder()
            return false
        }
        return true
    }
}

