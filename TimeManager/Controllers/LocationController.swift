//
//  LocationController.swift
//  TimeManager
//
//  Created by Huanrong on 3/8/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import UIKit
import CoreLocation

class LocationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "地理位置"
        // Do any additional setup after loading the view.
        
        if let location = DatabaseMamager.shared.latestLocationInDataBase() {
            print("okay:\(location.coordinate.latitude)---\(location.coordinate.longitude)")
            let geoCoder = CLGeocoder()
            print("\(location.coordinate.latitude)---\(location.coordinate.longitude)")
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) in
                guard let placeMark = placeMarks?[0] else {
                    return
                }
                let countryNumber = placeMark.isoCountryCode
                let usLocale = Locale(identifier: "zh_Hans")

//                CLPlacemark *placemark;
//                NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: placemark.ISOcountryCode forKey: NSLocaleCountryCode]];
//                NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//                NSString *country = [usLocale displayNameForKey: NSLocaleIdentifier value: identifier];
                
                print(placeMark.country)
                print(placeMark.administrativeArea)
                print(placeMark.locality)
                print(placeMark.subLocality)
                print(placeMark.thoroughfare)
            })
        }
        return
//        DatabaseMamager.shared.allLocationInDataBase { (locations) in
//            print(locations.count)
////            print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬okay")
//
//
//            let Addressvalues = locations.map({ (location) -> String in
//                let geoCoder = CLGeocoder()
//                print("\(location.coordinate.latitude)---\(location.coordinate.longitude)")
//                geoCoder.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) in
//                    guard let placeMark = placeMarks?[0] else {
//                        return
//                    }
//                    print(placeMark.country)
//                    print(placeMark.administrativeArea)
//                    print(placeMark.postalCode)
//                })
//                return "okay"
//            })
//        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
