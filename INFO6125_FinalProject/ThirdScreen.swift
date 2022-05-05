//
//  ThirdScreen.swift
//  INFO6125_FinalProject
//
//  Created by Anh Dinh Le on 2022-04-10.
//

import UIKit
import CoreLocation

class ThirdScreen: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherInfor: UILabel!
    @IBOutlet weak var iconTemp: UIImageView!
    @IBOutlet weak var iconCond: UIImageView!
    @IBOutlet weak var StartActivityButton: UIButton!
    
    
    
    let locationManager = CLLocationManager()
    var temp: Float?
    var Latitude: Double?
    var Longtitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StartActivityButton.isEnabled = false
        locationManager.delegate = self
        
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemYellow, .systemTeal])
        self.iconTemp.preferredSymbolConfiguration = config
        self.iconTemp.image = UIImage(systemName: "thermometer")
        self.iconCond.preferredSymbolConfiguration = config
        self.iconCond.image = UIImage(systemName: "globe.americas")
    
    }
    
    // screen is locked in portrait
    override open var shouldAutorotate: Bool {
       return false
    }

    // Specify the orientation.
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        getWeather(search: textField.text)
        return true
    }
    
//    @IBAction func onSearchTapped(_ sender: UIButton) {
//        searchTextfield.endEditing(true)
//        getWeather(search: searchTextfield.text)
//
//    }
    @IBAction func startActivityButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToNextPage", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNextPage"
        {
         let destination = segue.destination as! FourScreen
        destination.userLatitude = Latitude!
        destination.userLongitude = Longtitude!
        }
    }
    
    private func getWeather(search: String?)
    {
        guard let search = search else {
            return
            
        }
       
        //step1 : get URL
        let url = getUrl(search: search)
        
        guard let url = url else{
            print("could not get URL")
            return
        }
        
        // step 2: create URLSession
        let session = URLSession.shared
        
        // step 3: create task for session
        let dataTask = session.dataTask(with: url) {data,respond,error in
            print("network call complete")
            
            guard error == nil else{
                print("error")
                return
            }
            guard let data = data else{
                print("no data found")
                return
            }
            
            if let weather = self.pareJson(data: data){
                print(weather.location.name)
                print(weather.current.temp_c)
                
                self.getIcon(iconCode: weather.current.condition.code)
                self.temp = weather.current.temp_c
                DispatchQueue.main.async {
                    self.locationLabel.text = weather.location.name
                    self.tempLabel.text = "\(weather.current.temp_c) C"
                    self.weatherInfor.text = weather.current.condition.text
                }
            }
        }
        // step 4: start the task
        dataTask.resume()
    }
    
    private func pareJson(data:Data) -> WeatherResponse?
    {
        let decoder = JSONDecoder()
        var weatherResponse: WeatherResponse?
        do {
            weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
        }
        catch
        {
            print("error parsing weather")
            print(error)
        }
        
        return weatherResponse
    }
    
    private func getUrl(search: String) -> URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEnpoint = "current.json"
        let apiKey = "dd51a85797db4427ac7210251221603"
        
        let url = "\(baseUrl)\(currentEnpoint)?key=\(apiKey)&q=\(search)"
        return URL(string: url)
    }
    
    private func getIcon(iconCode: Int)
    {
      let url = URL(string: "https://www.weatherapi.com/docs/weather_conditions.json")
        guard let url = url else{
            print("could not get URL")
            return
            
        }
      let session = URLSession.shared
      let dataTask = session.dataTask(with: url) {data,respond,error in
            print("network call complete")
            
            guard error == nil else{
                print("error")
                return
            }
            guard let data = data else{
                print("no data found")
                return
            }
            
          if let weather = self.pareIconJson(data: data){
              
                 //print(weather)
              for  code in weather {
                  if code.code == iconCode {
                      //print(code.icon)
                    
                      DispatchQueue.main.async {
                          //self.weatherImage.image = UIImage(named: "\(code.icon)")
                         let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemYellow, .systemTeal])
                         self.weatherImage.preferredSymbolConfiguration = config
                          switch code.icon
                          {
                          case 113: self.weatherImage.image = UIImage(systemName: "sun.max.fill")
                          case 116: self.weatherImage.image = UIImage(systemName: "cloud.fill")
                          case 119: self.weatherImage.image = UIImage(systemName: "cloud.fill")
                          case 122: self.weatherImage.image = UIImage(systemName: "cloud.fog.fill")
                          case 143: self.weatherImage.image = UIImage(systemName: "cloud.fog.fill")
                          case 176: self.weatherImage.image = UIImage(systemName: "cloud.heavyrain.fill")
                          case 179: self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                          case 182: self.weatherImage.image = UIImage(systemName: "cloud.sleet.fill")
                          case 185: self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                          case 200: self.weatherImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
                          case 227: self.weatherImage.image = UIImage(systemName: "wind.snow")
                          case 230: self.weatherImage.image = UIImage(systemName: "snowflake.circle.fill")
                          case 248: self.weatherImage.image = UIImage(systemName: "cloud.fog.fill")
                          case 260: self.weatherImage.image = UIImage(systemName: "cloud.fog.fill")
                          case 263: self.weatherImage.image = UIImage(systemName: "cloud.rain.fill")
                          case 266: self.weatherImage.image = UIImage(systemName: "cloud.rain.fill")
                          case 281: self.weatherImage.image = UIImage(systemName: "cloud.heavyrain.fill")
                          case 284: self.weatherImage.image = UIImage(systemName: "cloud.heavyrain.fill")
                          case 293: self.weatherImage.image = UIImage(systemName: "cloud.drizzle.fill")
                          case 296: self.weatherImage.image = UIImage(systemName: "cloud.drizzle.fill")
                          case 299: self.weatherImage.image = UIImage(systemName: "cloud.drizzle.fill")
                          case 302: self.weatherImage.image = UIImage(systemName: "cloud.drizzle.fill")
                          case 305: self.weatherImage.image = UIImage(systemName: "cloud.heavyrain.fill")
                          case 308: self.weatherImage.image = UIImage(systemName: "cloud.heavyrain.fill")
                          case 311: self.weatherImage.image = UIImage(systemName: "cloud.rain.fill")
                          case 314: self.weatherImage.image = UIImage(systemName: "cloud.heavyrain.fill")
                          case 317: self.weatherImage.image = UIImage(systemName: "cloud.sleet.fill")
                          case 320: self.weatherImage.image = UIImage(systemName: "cloud.sleet.fill")
                          case 323: self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                          case 326: self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                          case 329: self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                          case 332: self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                          case 335: self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                          case 338: self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                          case 350: self.weatherImage.image = UIImage(systemName: "snowflake.circle.fill")
                          case 353: self.weatherImage.image = UIImage(systemName: "cloud.sun.rain.fill")
                          case 356: self.weatherImage.image = UIImage(systemName: "cloud.heavyrain.fill")
                          case 359: self.weatherImage.image = UIImage(systemName: "cloud.heavyrain.fill")
                          case 362: self.weatherImage.image = UIImage(systemName: "cloud.sleet.fill")
                          case 365: self.weatherImage.image = UIImage(systemName: "cloud.sleet.fill")
                          case 368: self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                          case 371: self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                          case 374: self.weatherImage.image = UIImage(systemName: "snowflake.circle.fill")
                          case 377: self.weatherImage.image = UIImage(systemName: "snowflake.circle.fill")
                          case 386: self.weatherImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
                          case 389: self.weatherImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
                          case 392: self.weatherImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
                          case 395: self.weatherImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
                          default:
                              self.weatherImage.image = UIImage(systemName: "sun.max.fill")
                          }
                      }
                  }
               }
            }
        }
     dataTask.resume()
    }
    
    private func pareIconJson(data:Data) -> [WeatherIconResponse]?
    {
        let decoder = JSONDecoder()
        var weatherIconResponse: [WeatherIconResponse]?
        do {
            weatherIconResponse = try decoder.decode([WeatherIconResponse].self, from: data)
        }
        catch
        {
            print("error parsing weather")
            print(error)
        }
        
        return weatherIconResponse
    }
    
    func displayLocation (location:String) {
        locationLabel.text = location
    }
    
    
    @IBAction func onChangeTemp(_ sender: UISwitch) {
        guard let temp = temp else
        {print("Temp doesn't have data")
         return
        }
        
        if sender.isOn == false
        {
            let F: Float = (temp * 9/5) + 32
            tempLabel.text = "\(F) F"
        }else{
            tempLabel.text = "\(temp) C"
        }
        
        
    }
    
    @IBAction func onGetLocationTapped(_ sender: UIButton) {
        //StartActivityButton.isEnabled = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func getlocation(lat: Double, lon: Double)
    {
        if lat == nil , lon == nil {
            print("could not have data")
            return
        }
       
        let url = getUrl(search: "\(lat),\(lon)")
        guard let url = url else{
            print("could not get URL")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) {data,respond,error in
            print("network call complete")
            
            guard error == nil else{
                print("error")
                return
            }
            guard let data = data else{
                print("no data found")
                return
            }
            
            if let location = self.pareJson(data: data){
                print(location.location.name)
                DispatchQueue.main.async {
                    self.locationLabel.text = location.location.name
                }
                self.getWeather(search: location.location.name)
                }
            }
        dataTask.resume()
        }
    
}
  
    


struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location : Decodable{
    let name: String
    let lat: Float
    let lon: Float
}

struct Weather: Decodable{
    let temp_c: Float
    let condition: WeatherCondition
}

struct WeatherCondition : Decodable{
    let text:String
    let code:Int
}

struct WeatherIconResponse: Decodable {
    let code: Int
    let icon: Int
    let day: String
}

struct locationResponse: Decodable {
    let name: String
}

extension ThirdScreen: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            print("Got Location")

           if let location = locations.last{
               var latitude = location.coordinate.latitude
               var longitude = location.coordinate.longitude
               self.Latitude = latitude
               self.Longtitude = longitude
               if latitude.isNaN == false && longitude.isNaN == false
               {
                   StartActivityButton.isEnabled = true
               }
                print("LattLng: (\(latitude),\(longitude))")
                getlocation(lat: latitude, lon: longitude)
            }
        }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error)
        }
}
