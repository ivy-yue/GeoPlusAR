//
//  ViewController.swift
//  GeoPlusAR
//
//  Created by wangyue on 2019-11-04.
//  Copyright © 2019 ___ivy___. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var faceLabel: UILabel!
    
    var analysis = ""
    let noseOptions = [ "🐽", "👃", "💧", " "]

    
    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Set the view's delegate
//        sceneView.delegate = self
//
//        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
        
        super.viewDidLoad()
        
        // 1 add radius to label
        labelView.layer.cornerRadius = 10
        faceLabel.text = "Hello"
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
    
        // 2 check if support face tracking
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
        let configuration = ARFaceTrackingConfiguration()
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let _ = sceneView.device else {
          return nil
        }
        
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        
        // TODO: add a btn to enable stickers
        node.geometry?.firstMaterial?.transparency = 0.3
        
        let noseNode = EmojiNode(with: noseOptions)
        noseNode.name = "nose"

        node.addChildNode(noseNode)
        updateFeatures(for: node, using: faceAnchor)
        return node
    }
    
    // change the face mesh during update
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)
            
            DispatchQueue.main.async {
                self.faceLabel.text = self.analysis
            }
            
            updateFeatures(for: node, using: faceAnchor)
        }
    }
    
    // Add-on feature1: expression detection
    func expression(anchor: ARFaceAnchor) {

        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let tongue = anchor.blendShapes[.tongueOut]
        let blinkLeft = anchor.blendShapes[.eyeBlinkLeft]
        let blinkRight = anchor.blendShapes[.eyeBlinkRight]
        
        self.analysis = ""

        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
            self.analysis += "Smiling."
        }
     
        if cheekPuff?.decimalValue ?? 0.0 > 0.1 {
            self.analysis += "Cheeks puffed. "
        }
     
        if tongue?.decimalValue ?? 0.0 > 0.1 {
            self.analysis += "Tongue out."
        }
        
        if ((blinkLeft?.decimalValue ?? 0.0 ) + (blinkRight?.decimalValue ?? 0.0)) > 0.9 {
            self.analysis += "Blink."
        }
    }
    
    // Add-on feature2:
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        let child = node.childNode(withName: "nose", recursively: false) as? EmojiNode
        
        let vertices = [anchor.geometry.vertices[9]]
        
        child?.updatePosition(for: vertices)
    }
    
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
