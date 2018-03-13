//
//  ViewController.swift
//  Pebbledrop
//
//  Created by Reid Case on 2/22/18.
//  Copyright © 2018 Reid Case. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import Photos

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let locationManager = CLLocationManager()
    let imagePickerController = UIImagePickerController()
    
    var testPebble:Pebble? = nil
    var location: CLLocation? = nil
    var imageURL: NSURL!
    var pebs: [Pebble] = []

    let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
    
    let tempImageName = "temp_image.jpg"
    
    //@IBOutlet weak var messageText: UITextField!
    let messageText: String = "Just a placeholder to save time fishing out all references. Got more importnt things to do."
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        //sceneView.scene.background.contents = imageView.image
        
        //let testPos = SCNVector3(0,-1,-1)
        //createLivePebble(at: testPos, texture: imageView.image!)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        imagePickerController.delegate = self
        checkPermission()
        saveImageLocally()
        imageView.isHidden = true
        sceneView.isHidden = false
        trashButton.isEnabled = false
        addButton.isEnabled = false

        setPebs("ViewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        checkPermission()
        saveImageLocally()
        setPebs("viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func showResults(_ sender: UIBarButtonItem) {
        print("PEBS!!!!!!!!!!!!")
        
        pebs = StorageFacade.sharedInstance.getPebbles()
        if pebs.count > 0 {
            var lastV:SCNVector3 = SCNVector3(0,Double(-1),0)
            
            print(pebs[0].image.size)
            //imageView.image = pebs[0].image
            //imageView.isHidden = false
            //imageView.contentMode = UIViewContentMode.scaleAspectFill
            
            for peb in pebs {
                let tempXCPeb = CLLocation(latitude: peb.location.coordinate.latitude, longitude: 0)
                let tempZCPeb = CLLocation(latitude: 0, longitude: peb.location.coordinate.longitude)
                let tempXCUser = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: 0)
                let tempZCUser = CLLocation(latitude: 0, longitude: (location?.coordinate.longitude)!)
                
                let x = tempXCPeb.distance(from: tempXCUser)
                let z = tempZCPeb.distance(from: tempZCUser)
                //let x = Double(peb.location.coordinate.latitude.distance(to: (location?.coordinate.latitude)!))
                let y = Double(lastV.y)
                //let z = Double(peb.location.coordinate.longitude.distance(to: (location?.coordinate.longitude)!))+1
                
                
                
                var tempV = SCNVector3(x,y,-z)
                if tempV.x <= lastV.x+1 && tempV.x >= lastV.x-1 && tempV.z <= lastV.z+1 && tempV.z >= lastV.z-1 {
                    tempV.y += 0.6
                }
                
                createLivePebble(at: tempV, texture: peb.image)
                
                lastV = tempV
            }
            //let newTempV = SCNVector3(10,0,5)
            //createLivePebble(at: newTempV, texture: imageView.image!)
        }
        
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        save(message: messageText)
        imageView.isHidden = true
        sceneView.isHidden = false
        addButton.isEnabled = false
        trashButton.isEnabled = false
        //msg.text = ""
    }
    
    @IBAction func editEnded(_ sender: UITextField) {
        resignFirstResponder()
    }
    
    @IBAction func pickPhoto(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)

        }
    }
    
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        if let url = imageURL {
            let fileManager = FileManager()
            if fileManager.fileExists(atPath: url.absoluteString!) {
                do {
                    try fileManager.removeItem(at: url as URL)
                    print("Success removing item")
                } catch {
                    print("error removing item")
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func trashImage(_ sender: UIBarButtonItem) {
        imageView.image = nil
        imageView.isHidden = true
        sceneView.isHidden = false
        trashButton.isEnabled = false
        addButton.isEnabled = false
    }
    
    func createLivePebble(at position : SCNVector3, texture: UIImage){
        let pebbleShape = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
        let pebbleMaterial = SCNMaterial()
        pebbleMaterial.diffuse.contents = texture
        //pebbleShape.materials.append(pebbleMaterial)
        for i in 0...5 {
            pebbleShape.materials.insert(pebbleMaterial, at: i)
        }
        
        //print("PEBBLE MATERIALS\(pebbleShape.materials.count) \(pebbleShape.materials[0]) \(pebbleShape.materials[1])")
        
        let pebbleNode = SCNNode(geometry: pebbleShape)
        pebbleNode.position = position
        sceneView.scene.rootNode.addChildNode(pebbleNode)
        print("created node \(pebbleNode.position)")
    }
    
    func setPebs(_ callingFunc: String) {
        if location == nil {
            locationManager.startUpdatingLocation()
            location = locationManager.location
        }
        print("INIT LOCATION AT \(callingFunc) \(location)")
        if let loc = location {
            StorageFacade.sharedInstance.getRecords(around: loc)
            pebs = StorageFacade.sharedInstance.getPebbles()
        }
        print("+++++++++++++++PEBBLES++++++++++++++++++")
        print(pebs.count)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.image = pickedImage
        }
        
        saveImageLocally()
        
        imageView.isHidden = false
        sceneView.isHidden = true
        trashButton.isEnabled = true
        addButton.isEnabled = true
        
        dismiss(animated: true, completion: nil)
        //print("+++++++++++++Is the image hidden?++++++++++++++++++\(imageView.isHidden)")
        //print(imageView.image)
    }
    
    func saveImageLocally() {
        if let img = imageView.image {
            print("SAVING IMAGE LOCALLY")
            let imageData: NSData = UIImageJPEGRepresentation(img, 0.8)! as NSData
            let path = documentsDirectoryPath.appendingPathComponent(tempImageName)
            imageURL = NSURL(fileURLWithPath: path)
            imageData.write(to: imageURL as URL, atomically: true)
            print("IMAGE URL: \(imageURL)")
        }
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    func save(message: String) -> Void {
        //let currentTime = NSDate()
        print("++++++++++Test++++++++++")
        if let imURL = imageURL {
            if let tempLoc = location {
                let newCoord = CLLocationCoordinate2DMake(tempLoc.coordinate.latitude, tempLoc.coordinate.longitude)
                let newLoc = CLLocation(coordinate: newCoord, altitude: tempLoc.altitude, horizontalAccuracy: tempLoc.horizontalAccuracy, verticalAccuracy: tempLoc.verticalAccuracy, timestamp: tempLoc.timestamp)
                testPebble = Pebble(message: message, locationOffset: 1, at: newLoc, imageURL: imURL, image: imageView.image!)
                StorageFacade.sharedInstance.drop(this: testPebble!)
                imageView.image = nil
                imageView.isHidden = true
                sceneView.isHidden = false
            }
        }else{
            //let fileURL = Bundle.main.url(forResource: "no_image", withExtension: "png")
            print("++++++++++++++++DEFAULT IMAGE++++++++++++++")
            print("IMAGE DOESNT EXIST")
            imageView.isHidden = true
            return
            //testPebble = Pebble(message: message, locationOffset: 1, at: location!, imageURL: imageURL)
            //StorageFacade.sharedInstance.drop(this: testPebble!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations[0]
        //setPebs()
        //print(location?.coordinate ?? "no location to print")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
