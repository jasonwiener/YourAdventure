//
//  PolylineViewController.swift
//  YourAdventure
//
//  Created by Dominik Leszczyński on 05/06/2021.
//

import UIKit
import MapKit

class PolylineViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: - Settings for the MKPolyline
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
        {
//        Settings for PolyLine
            if(overlay is MKPolyline)
            {
                let polyLineRender = MKPolylineRenderer(overlay: overlay)
                polyLineRender.strokeColor = self.view.tintColor
                polyLineRender.lineWidth = 2

                return polyLineRender
            }

            return MKPolylineRenderer()
        }
}
