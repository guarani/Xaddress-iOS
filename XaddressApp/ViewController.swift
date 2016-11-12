//
//  ViewController.swift
//  XaddressApp
//
//  Created by Paul Von Schrottky on 10/8/16.
//  Copyright © 2016 Paul Von Schrottky. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import GoogleMaps
import CoreLocation
import SwiftyJSON
import GooglePlaces


class ViewController: UIViewController {
    
    var mapView: GMSMapView!
    var decodedView: DecodedView!
    
    var mapBottomLayoutConstraint: NSLayoutConstraint!
    var decodedBottomLayoutConstraint: NSLayoutConstraint!
    var decodeVCBottomLayoutConstraint: NSLayoutConstraint!
    
    var locationManager: CLLocationManager?
    var userLocation: CLLocation?
    var currentMarker: GMSMarker?
    
    var autocompleteResultsViewController: GMSAutocompleteResultsViewController!
    var searchController: UISearchController!
    
    let decodeViewController = DecodeChildViewController()
    
    var moc: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }

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
        
        decodedView = UINib(nibName: "DecodedView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! DecodedView
        view.addSubview(decodedView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[decodedView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["decodedView": decodedView]))
        view.addConstraint(NSLayoutConstraint(item: decodedView, attribute: .Top, relatedBy: .Equal, toItem: mapView, attribute: .Bottom, multiplier: 1, constant: 0))
        
        decodeViewController.mapViewController = self
        addChildViewController(decodeViewController)
        let decodeVCView = decodeViewController.view
        decodeVCView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decodeVCView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[decodeVCView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["decodeVCView": decodeVCView]))
        decodeViewController.didMoveToParentViewController(self)
        
        // Setup variable constraints.
        mapBottomLayoutConstraint = NSLayoutConstraint(item: decodeVCView, attribute: .Top, relatedBy: .Equal, toItem: mapView, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraint(mapBottomLayoutConstraint)
        decodedBottomLayoutConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: decodedView, attribute: .Bottom, multiplier: 1, constant: decodeViewController.view.frame.height)
        decodeVCBottomLayoutConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: decodeVCView, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraint(decodeVCBottomLayoutConstraint)

        // Get keyboard notification events so we can move the decodeVC view up and down.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // #MARK: - Keyboard Handlers
    
    func keyboardWillShow(notification: NSNotification) {
        
        let beginFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        let endFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        
        guard CGRectEqualToRect(beginFrame, endFrame) == false else {
            return
        }
        
        if let keyboardHeight = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height,
            duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            
            decodeVCBottomLayoutConstraint.constant = keyboardHeight
            UIView.animateWithDuration(duration, animations: { self.view.layoutIfNeeded() })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            decodeVCBottomLayoutConstraint.constant = 0
            UIView.animateWithDuration(duration, animations: { self.decodeViewController.view.layoutIfNeeded() })
        }
    }
    
    // #MARK: - Decode View
    
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
        
        fetchStateAndCountry(coordinate, onSuccess: { country, state in
            print(country, state)
            
            guard let country = country, state = state else { return }
            
            guard let components = XAUtils.encodeCoordinate(coordinate, inCountry: country, inState: state, moc: self.moc) else {
                return
            }
            
            self.showDecodedAddress(components, atCoordinate: coordinate)
            
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

    func fetchStateAndCountry(coordinate: CLLocationCoordinate2D, onSuccess: ((country: XACountry?, state: XAState?) -> Void)) {
        
        Alamofire.request(.GET, "https://maps.googleapis.com/maps/api/geocode/json", parameters: [
            "latlng"    : "\(coordinate.latitude),\(coordinate.longitude)",
            "key"       : "AIzaSyDSOWvIMZmgJDk9lh1CinNt1i6iQV8b4Jg",
        ]).responseJSON { response in
            
            if let data = response.data {
                let json = JSON(data: data)
                guard let country = XACountry.matchingGooglePlace(json, inManagedContext: self.moc) else { return }
                guard let state = XAState.matchingGooglePlace(json, inManagedContext: self.moc) else { return }
                
                print("Country:", country.name, country.lat, country.lon)
                print("State:", state.name1, state.lat, state.lon)
        
                onSuccess(country: country, state: state)
            }
        }
    }
    
    func resetView() {
        view.removeConstraint(decodedBottomLayoutConstraint)
        mapBottomLayoutConstraint.active = true
        self.decodedView.alpha = 0
    }
    
    func showDecodedAddress(address: XAAddressComponents, atCoordinate coordinate: CLLocationCoordinate2D) {
        mapBottomLayoutConstraint.active = false
        decodedBottomLayoutConstraint.constant = decodeViewController.view.frame.height
        view.addConstraint(decodedBottomLayoutConstraint)
        self.decodedView.alpha = 1
        
        decodedView.topLabel.text = address.description
        var location = ""
        if let country = address.country?.name {
            location += country
        }
        if let state = address.state?.name1 {
            location += " \(state)"
        }
        decodedView.middleLabel.text = location
        showPlace(coordinate)
    }
    
    func showPlace(locationCoordinate: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.setTarget(locationCoordinate, zoom: 10)
        mapView.animateWithCameraUpdate(cameraUpdate)
        showMarkerAtCoordinate(locationCoordinate)
    }
}

extension ViewController: GMSMapViewDelegate {
    
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


extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        encodePlaceAtCoordinate(place.coordinate)
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: NSError) {
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

