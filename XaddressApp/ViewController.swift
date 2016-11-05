//
//  ViewController.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/8/16.
//  Copyright © 2016 Paul Von Schrottky. All rights reserved.
//

import UIKit

import Alamofire
import GoogleMaps
import CoreLocation
import SwiftyJSON
import SnapKit
import GooglePlaces


class Bounds: CustomStringConvertible {
    
    // e.g. -9.9300701@153.5518096*-29.1785876@137.9945748
    init(bounds: String) {
        self.bottomLeftCoordinate = CLLocationCoordinate2D()
        self.topRightCoordinate = CLLocationCoordinate2D()
        
        let coordinates = bounds.characters.split("*")
        let start = String(coordinates[1])
        let end = String(coordinates[0])
        
        let startComponents = start.characters.split("@")
        self.bottomLeftCoordinate?.latitude = CLLocationDegrees(String(startComponents[0]))!
        self.bottomLeftCoordinate?.longitude = CLLocationDegrees(String(startComponents[1]))!
        
        let endComponents = end.characters.split("@")
        self.topRightCoordinate?.latitude = CLLocationDegrees(String(endComponents[0]))!
        self.topRightCoordinate?.longitude = CLLocationDegrees(String(endComponents[1]))!
    }
    
    let bottomLeftCoordinate: CLLocationCoordinate2D?
    let topRightCoordinate: CLLocationCoordinate2D?
    
    var description: String {
        return bottomLeftCoordinate.debugDescription + " " + topRightCoordinate.debugDescription
    }
}

class ViewController: UIViewController {
    
    var mapView: GMSMapView!
    var xaddressTextField: UITextField!
    var bottomLayoutConstraint: NSLayoutConstraint!
    
    var locationManager: CLLocationManager?
    var userLocation: CLLocation?
    var currentMarker: GMSMarker?
    
    var autocompleteResultsViewController: GMSAutocompleteResultsViewController!
    var searchController: UISearchController!
    
//    var address: XAAddress?
    
    let decodeViewController = DecodeChildViewController()
//    var addressView: AddressView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the autocomplete search bar.
        autocompleteResultsViewController = GMSAutocompleteResultsViewController()
        autocompleteResultsViewController.delegate = self
        searchController = UISearchController(searchResultsController: autocompleteResultsViewController)
        searchController.searchResultsUpdater = autocompleteResultsViewController
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
        
        // Start GPS.
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestWhenInUseAuthorization()
        locationManager!.startUpdatingLocation()
        
        // Draw the map at the default location.
        let camera = GMSCameraPosition.cameraWithLatitude(0, longitude: 0, zoom: 15)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: mapView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[mapView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["mapView": mapView]))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        decodeViewController.mapViewController = self
        addChildViewController(decodeViewController)
        let decodeView = decodeViewController.view
        decodeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decodeView)
        view.addConstraint(NSLayoutConstraint(item: decodeView, attribute: .Top, relatedBy: .Equal, toItem: mapView, attribute: .Bottom, multiplier: 1, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[decodeView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["decodeView": decodeView]))
        bottomLayoutConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: decodeView, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomLayoutConstraint)
        decodeViewController.didMoveToParentViewController(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        print("MEMORY WARNING!")
    }
    
    // #MARK: - Keyboard Handlers
    
    func keyboardWillShow(notification: NSNotification) {
        
        let beginFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        let endFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        
        print(beginFrame, endFrame)
        guard CGRectEqualToRect(beginFrame, endFrame) == false else {
            return
        }
        
        if let keyboardHeight = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height,
            duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            
            bottomLayoutConstraint.constant = keyboardHeight
//            decodeViewController.open()
            UIView.animateWithDuration(duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            closeXaddressTextField(duration)
        }
    }
    
    // #MARK: - Decode View
    
    func showCountryPicker() {
        
    }
    
    func closeXaddressTextField(duration: Double = 0) {
        bottomLayoutConstraint.constant = 0
//        decodeViewController.close()
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            if self.decodeViewController.decodingState == .Result {
                self.hideDecoder()
            }
        })
    }
    
    func showMarkerAtCoordinate(coordinate: CLLocationCoordinate2D) {
        currentMarker?.map = nil
        currentMarker = GMSMarker(position: coordinate)
        currentMarker?.title = "Location selected";
        currentMarker?.snippet = "Testing";
        currentMarker?.map = mapView
        mapView.selectedMarker = currentMarker
    }
    
    func encodePlaceAtCoordinate(coordinate: CLLocationCoordinate2D) {
        
        mapView.animateToLocation(coordinate)
        
        showMarkerAtCoordinate(coordinate)
        
        fetchStateAndCountry({ country, state in
            
//            self.boundsForPlace(country, state: state, onSuccess: { bounds in
//                
//                let table = self.combinationTable(bounds!)
//                print(table)
//                
//                self.xaddressForLocation(coordinate, combinationTable: table, onSuccess: { xaddress in
//                    print(xaddress)
//                    xaddress.country = country
//                    xaddress.state = state
//                    self.xaddress = xaddress
//                    
//                    self.xaddressView?.setupWithXaddress(xaddress)
//                })
//            })
        })
    }

    func fetchStateAndCountry(onSuccess: ((country: XACountry?, state: XAState?) -> Void)) {
        
        guard let lat = self.userLocation?.coordinate.latitude, lon = self.userLocation?.coordinate.longitude else {
            onSuccess(country: nil, state: nil)
            return
        }
        
        Alamofire.request(.GET, "https://maps.googleapis.com/maps/api/geocode/json", parameters: [
            "latlng"    : "\(lat),\(lon)",
            "key"       : "AIzaSyDSOWvIMZmgJDk9lh1CinNt1i6iQV8b4Jg",
        ]).responseJSON { response in
            
            if let data = response.data {
                let json = JSON(data: data)
                var country: XACountry?
                var state: XAState?
                if let addressComponents = json["results"][0]["address_components"].array {
                    let stateInfo = addressComponents.filter { component in
                        let isState = component["types"].array?.filter { type in
                            type == "administrative_area_level_1"
                        }.count > 0
                        
                        return isState
                    }.first
                    
                    let countryInfo = addressComponents.filter { component in
                        let isCountry = component["types"].array?.filter { type in
                            type == "country"
                        }.count > 0
                        
                        return isCountry
                    }.first
                    
//                    state = State(shortName: stateInfo?["short_name"].string, longName: stateInfo?["long_name"].string)
//                    country = Country(shortName: countryInfo?["short_name"].string, longName: countryInfo?["long_name"].string)
                }
                
                onSuccess(country: country, state: state)
            }
        }
    }
    
    func showPlace(locationCoordinate: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.setTarget(locationCoordinate, zoom: 10)
        mapView.animateWithCameraUpdate(cameraUpdate)
        showMarkerAtCoordinate(locationCoordinate)
    }
    
    func hideDecoder() {
        
        decodeViewController.view.setNeedsLayout()
        decodeViewController.view.layoutIfNeeded()
        
        self.bottomLayoutConstraint.constant = -decodeViewController.view.frame.height
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }

}

extension ViewController: GMSMapViewDelegate {
//    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//        
//        // ALlow animations in the info window.
//        marker.tracksInfoWindowChanges = true
//        
//        addressView = UINib(nibName: "AddressView", bundle: nil).instantiateWithOwner(nil, options: nil).first as? AddressView
//        self.addressView?.startLoading()
//        return addressView
//    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        encodePlaceAtCoordinate(coordinate)
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        encodePlaceAtCoordinate(marker.position)
        return false
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error.localizedDescription)")
//        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard locations.first?.horizontalAccuracy <= 10 else {
            print("Location accuracy (\(locations.first?.horizontalAccuracy) not good enough.)")
            return
        }
        
        print("Location: \(locations.first?.coordinate), accuracy: \(locations.first?.horizontalAccuracy) - GOOD ENOUGH.)")
        
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        
        userLocation = locations.first
        mapView.animateToLocation(userLocation!.coordinate)
    }
}


// Handle the user's selection.
extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        
        encodePlaceAtCoordinate(place.coordinate)
        
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}

