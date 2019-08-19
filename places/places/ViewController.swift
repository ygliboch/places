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
    var newView: Slide?
    var slide: Slide?
    
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
            slide.address.text = "\(venue["location"]["formattedAddress"][0]), \(venue["location"]["formattedAddress"][1]), \(venue["location"]["formattedAddress"][2])"
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handle))
            slide.isUserInteractionEnabled = true
            slide.gestureRecognizers = [panGesture]
            
            slides.append(slide)
        }
    }
    
    func setupSlideScrollView() {
        scrollView.frame = CGRect(x: 0, y: 2 * view.frame.height / 3, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i) + 12, y: 0, width: view.frame.width - 24, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    @objc func handle(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.velocity(in: gestureRecognizer.view).x < -1500.0 && gestureRecognizer.velocity(in: gestureRecognizer.view).x < -1500.0 && scrollView.contentOffset.x + self.view.frame.width <= scrollView.contentSize.width{
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x + self.view.frame.width, y: 0), animated: true)
            if newView != nil {
                self.newView?.removeFromSuperview()
                self.newView = nil
                self.slide!.isHidden = false
            }
            return
        } else if gestureRecognizer.velocity(in: gestureRecognizer.view).x > 1500.0 && gestureRecognizer.velocity(in: gestureRecognizer.view).x > 1500.0  && scrollView.contentOffset.x - self.view.frame.width >= 0{
            if newView != nil {
                self.newView?.removeFromSuperview()
                self.newView = nil
                self.slide!.isHidden = false
            }
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x - self.view.frame.width, y: 0), animated: true)
            return
        }
        if gestureRecognizer.state == .began {
            newView = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as? Slide
            slide = gestureRecognizer.view as? Slide
            newView?.label.text = slide!.label.text
            newView?.address.text = slide!.address.text
            newView?.frame = CGRect(x: 12, y: (view.frame.height / 3) * 2, width: view.frame.width - 24, height: view.frame.height)
            view.addSubview(newView!)
            slide!.isHidden = true
        } else if gestureRecognizer.state == .changed && newView != nil{
            let translation = gestureRecognizer.translation(in: self.view)
            if newView!.center.y + translation.y >= view.center.y {
                newView!.center = CGPoint(x: newView!.center.x, y: newView!.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint(x: 0,y: 0), in: self.view)
            }
        } else if gestureRecognizer.state == .ended && newView != nil{
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.newView!.frame.origin.y = self.scrollView.frame.origin.y
            }) { (_) in
                self.newView?.removeFromSuperview()
                self.newView = nil
                self.slide!.isHidden = false
            }
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
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        centerOnLocation(location:  CLLocation(latitude: venues[Int(pageIndex)]["location"]["lat"].double!, longitude: venues[Int(pageIndex)]["location"]["lng"].double!)  )
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if points.contains(view.annotation as! MKPointAnnotation) {
            let index = points.firstIndex(of: view.annotation as! MKPointAnnotation)
            scrollView.setContentOffset(CGPoint(x: self.view.frame.width * CGFloat(index!), y: 0), animated: true)
        }
    }
}
