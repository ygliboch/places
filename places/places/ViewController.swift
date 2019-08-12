//
//  ViewController.swift
//  places
//
//  Created by Yaroslava HLIBOCHKO on 8/12/19.
//  Copyright © 2019 Yaroslava HLIBOCHKO. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    var slides: [Slide] = []
    
    @IBOutlet weak var map: MKMapView!
    var locationManager = CLLocationManager()
    let requestManager = RequestManager()
    var venues: [JSON] = []
    var points: [MKPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        requestManager.getVenues { (response) in
            if response != nil {
                self.venues = response!["response"]["venues"].array!
                self.setPoints()
                self.createSlides()
                self.setupSlideScrollView()
            }
        }
    }

    func createSlides() {
        for venue in venues {
            let slide:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
            slide.label.text = venue["name"].string
//            let address = venue["location"]["formattedAddress"]
            slide.address.text = "\(venue["location"]["formattedAddress"][0]), \(venue["location"]["formattedAddress"][1]), \(venue["location"]["formattedAddress"][2])"
            slides.append(slide)
        }
    }
    
    func setupSlideScrollView() {
        scrollView.frame = CGRect(x: 0, y: 2 * view.frame.height / 3, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i) + 8, y: 0, width: view.frame.width - 16, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    func setPoints() {
        for venue in venues {
            let point = MKPointAnnotation()
            point.title = venue["name"].string
            point.subtitle = venue["categories"]["name"].string
            point.coordinate = CLLocationCoordinate2D(latitude: venue["location"]["lat"].double!, longitude: venue["location"]["lng"].double!)
            map.addAnnotation(point)
            points.append(point)
        }
        let location = CLLocation(latitude: venues[0]["location"]["lat"].double!, longitude: venues[0]["location"]["lng"].double!)
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func centerOnLocation(location : CLLocation) {
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("========================")
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        print(venues[Int(pageIndex)])
        centerOnLocation(location:  CLLocation(latitude: venues[Int(pageIndex)]["location"]["lat"].double!, longitude: venues[Int(pageIndex)]["location"]["lng"].double!)  )
    }
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if points.contains(view.annotation as! MKPointAnnotation) {
            let index = points.firstIndex(of: view.annotation as! MKPointAnnotation)
            scrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(index), y: 0), animated: true)
            print(index!)
        }
    }
}
