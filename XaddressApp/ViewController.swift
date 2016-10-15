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
import SwiftCSV
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
    
    var countries: CSV!
    var states: CSV!
    var words: CSV!
    var adjectives: CSV!
    
    var xaddress: Xaddress?
    var xaddressView: XaddressView?

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

        // Read the CSV files.
        do {
            countries = try CSV(name: NSBundle.mainBundle().pathForResource("countries", ofType: "csv")!)
            states = try CSV(name: NSBundle.mainBundle().pathForResource("states", ofType: "csv")!)
            words = try CSV(name: NSBundle.mainBundle().pathForResource("en", ofType: "csv")!)
            adjectives = try CSV(name: NSBundle.mainBundle().pathForResource("adj_en", ofType: "csv")!)
        } catch {
            // Catch
        }
        
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
        
        xaddressTextField = UITextField()
        xaddressTextField.borderStyle = .RoundedRect
        xaddressTextField.delegate = self
        view.addSubview(xaddressTextField)
        xaddressTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: xaddressTextField, attribute: .Top, relatedBy: .Equal, toItem: mapView, attribute: .Bottom, multiplier: 1, constant: 8))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(8)-[xaddressTextField]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["xaddressTextField": xaddressTextField]))
        bottomLayoutConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: xaddressTextField, attribute: .Bottom, multiplier: 1, constant: 8)
        view.addConstraint(bottomLayoutConstraint)
        xaddressTextField.placeholder = "Enter an Xaddress to find its location"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidChangeFrame), name: UIKeyboardDidChangeFrameNotification, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        print("MEMORY WARNING!")
    }
    
    // #MARK: - Keyboard Handlers
    
    func keyboardDidChangeFrame(notification: NSNotification) {
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        let beginFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        let endFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        
        print(beginFrame, endFrame)
        guard CGRectEqualToRect(beginFrame, endFrame) == false else {
            return
        }
        
        if let keyboardHeight = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height,
            duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            
            bottomLayoutConstraint.constant = keyboardHeight + 8
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
    
    func closeXaddressTextField(duration: Double = 0) {
        bottomLayoutConstraint.constant = 8
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func parseXaddressComponents(string: String) {
        
        guard let xaddress = string.xa_address() else { return }

        let combinationTable = xaddress.p1Encoded
        
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
            
            self.boundsForPlace(country, state: state, onSuccess: { bounds in
                
                let table = self.combinationTable(bounds!)
                print(table)
                
                self.xaddressForLocation(coordinate, combinationTable: table, onSuccess: { xaddress in
                    print(xaddress)
                    xaddress.country = country
                    xaddress.state = state
                    self.xaddress = xaddress
                    
                    self.xaddressView?.setupWithXaddress(xaddress)
                })
            })
        })
    }
    
    func fetchStateAndCountry(onSuccess: ((country: Country?, state: State?) -> Void)) {
        
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
                var country: Country?
                var state: State?
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
                    
                    state = State(shortName: stateInfo?["short_name"].string, longName: stateInfo?["long_name"].string)
                    country = Country(shortName: countryInfo?["short_name"].string, longName: countryInfo?["long_name"].string)
                }
                
                onSuccess(country: country, state: state)
            }
        }
    }

}

extension ViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        // ALlow animations in the info window.
        marker.tracksInfoWindowChanges = true
        
        self.xaddressView = UINib(nibName: "XaddressView", bundle: nil).instantiateWithOwner(nil, options: nil).first as? XaddressView
        self.xaddressView?.startLoading()
        return xaddressView
    }
    
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
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
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

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == xaddressTextField {
            closeXaddressTextField()
            if let text = textField.text {
                parseXaddressComponents(text)
            }
        }
    }
}

