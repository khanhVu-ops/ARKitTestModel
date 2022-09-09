//
//  3DObjectVC.swift
//  ObjectDetection-CoreML
//
//  Created by KhanhVu on 9/6/22.
//  Copyright © 2022 tucan9389. All rights reserved.
//

import UIKit
import ARKit
class Object3DVC: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var cltvListObject: UICollectionView!
    var itemSelected = "aa"
    var currentNode = SCNNode()
    let listObject: [ObjectModel] = [ObjectModel(pathObject3D: "art.scnassets/Plane", title: "Plane", image2DName: "Plane"),
                                     ObjectModel(pathObject3D: "art.scnassets/Car", title: "Car", image2DName: "Car"),
                                     ObjectModel(pathObject3D: "art.scnassets/Cup", title: "Cup", image2DName: "Cup"),
                                     ObjectModel(pathObject3D: "art.scnassets/Shoes", title: "Shoes", image2DName: "Shoes"),
                                     ObjectModel(pathObject3D: "art.scnassets/Guitar", title: "Guitar", image2DName: "Guitar"),
                                     ObjectModel(pathObject3D: "art.scnassets/Chair", title: "Chair", image2DName: "Chair")]
    
    enum BodyType : Int {
        case ObjectModel = 2;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
       
    }
    
    func setUpView() {
//        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_ :)) )
        sceneView.addGestureRecognizer(tapGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotation))
        sceneView.addGestureRecognizer(rotationGesture)
        
//        let moveGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(moved))
//        self.sceneView.addGestureRecognizer(moveGestureRecognizer)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(moved(recognizer:)))
        self.sceneView.addGestureRecognizer(panGesture)
        cltvListObject.register(UINib(nibName: "ListObjectCLTVC", bundle: nil), forCellWithReuseIdentifier: "ListObjectCLTVC")
        cltvListObject.delegate = self
        cltvListObject.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        sceneView.autoenablesDefaultLighting = true
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        //1. Get The Current Touch Point
//        guard let currentTouchPoint = touches.first?.location(in: self.sceneView),
//            //2. Get The Next Feature Point Etc
//            let hitTest = sceneView.hitTest(currentTouchPoint, types: .existingPlane).first else { return }
//
//        //3. Convert To World Coordinates
//        let worldTransform = hitTest.worldTransform
//
//        //4. Set The New Position
//        let newPosition = SCNVector3(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)
//
//        //5. Apply To The Node
//        currentNode.simdPosition = float3(newPosition.x, newPosition.y, newPosition.z)
//
//    }
    
    func addObject(position: SCNVector3) {

        if itemSelected != "" {
//
            guard let scence = SCNScene(named: "Car" + ".scn") else {
                            return
            }
            let modelNode = scence.rootNode
//            guard let modelNode =  scence.rootNode.childNode(
//                withName: "theNameOfTheParentNodeOfTheObject", recursively: true) else {
//                return
//            }

            modelNode.name = "Car"
//            modelNode.categoryBitMask = BodyType.ObjectModel.rawValue
//            modelNode.enumerateChildNodes { (node, _) in
//                   node.categoryBitMask = BodyType.ObjectModel.rawValue
//            }

            print(position)
            modelNode.simdPosition = SIMD3(position.x, position.y, position.z)
            modelNode.simdScale = SIMD3(0.01, 0.01, 0.01)
            currentNode = modelNode
            modelNode.enumerateChildNodes { (node, _) in
                node.categoryBitMask = BodyType.ObjectModel.rawValue
            }
            modelNode.categoryBitMask = BodyType.ObjectModel.rawValue
            sceneView.scene.rootNode.addChildNode(modelNode)
//
//            let objectModelScene = SCNScene(named:
//                    "Car.scn")!
////            let objectNode =  objectModelScene.rootNode
//            guard let objectNode =  objectModelScene.rootNode.childNode(
//                    withName: "car", recursively: true) else {
//                return
//            }
//            objectNode.categoryBitMask = BodyType.ObjectModel.rawValue
//            objectNode.enumerateChildNodes { (node, _) in
//                    node.categoryBitMask = BodyType.ObjectModel.rawValue
//                }
//            objectNode.simdPosition = SIMD3(position.x, position.y, position.z)
//            objectNode.simdScale = SIMD3(0.01, 0.01, 0.01)
//                       currentNode = objectNode
//            sceneView.scene.rootNode.addChildNode(objectNode)
            itemSelected = ""
//            myObjectNodes.insert(modelNode)
        }else {
            currentNode.simdPosition = SIMD3(position.x, position.y, position.z)
        }
        
    }
    
    func getParentNodeOf(_ nodeFound: SCNNode?) -> SCNNode? {
        if let node = nodeFound {
            if node.name == "Car" {
                return node
            } else if let parent = node.parent {
                return getParentNodeOf(parent)
            }
        }
        return nil
    }
    
    
    //MARK: @objc func
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        guard let scene = gesture.view as? ARSCNView else {return}
        let position = gesture.location(in: scene)
//        checkNodeExistAtLocation(position: position)
        guard let query = sceneView.raycastQuery(from: position, allowing: .estimatedPlane, alignment: .horizontal) else {
            return
        }
        guard let hitFeature = sceneView.session.raycast(query).first else {
            return
        }
        
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)
        let hitPosition = SCNVector3(hitTransform.m41,
                                           hitTransform.m42,
                                           hitTransform.m43)
          
        addObject(position: hitPosition)
    }
    
   
    @objc func rotation(_ gesture: UIRotationGestureRecognizer) {
//        let location = gesture.location(in: self.sceneView)
//        if let result = sceneView.hitTest(location, options: nil ).first  {
//            let chairNode = result.node
//
//            if gesture.state == .changed {
//                chairNode.eulerAngles.y -= Float(gesture.rotation)
//            }
//            gesture.rotation = 0
//
//        }
        
        
        if gesture.state == .changed {
            currentNode.eulerAngles.y -= Float(gesture.rotation)
        }
        gesture.rotation = 0
        
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let recognizerView = recognizer.view as? ARSCNView else { return }
        let position = recognizer.location(in: recognizerView)
//        checkNodeExistAtLocation(position: position)
        guard let query = sceneView.raycastQuery(from: position, allowing: .estimatedPlane, alignment: .any) else {
            return
        }
        guard let result = sceneView.session.raycast(query).first else {
            return
        }
        currentNode.simdWorldPosition = result.worldTransform.translation
        
        let previousOrientation = currentNode.simdWorldTransform.orientation
        let currentOrientation = result.worldTransform.orientation
        currentNode.simdWorldOrientation = simd_slerp(previousOrientation, currentOrientation, 0.1)
    }
    
    @objc func moved(recognizer :UIPanGestureRecognizer) {
        
        guard let recognizerView = recognizer.view as? ARSCNView else { return }
        let touch = recognizer.location(in: recognizerView)
        
        let hitTestResults = self.sceneView.hitTest(touch, options: [.categoryBitMask: BodyType.ObjectModel.rawValue])
//        guard let modelNodeHit = hitTestResults.lazy.compactMap({ result in
//            result.node
//        }).first else {
//            return
//        }
        var modelNodeHit = SCNNode()
        print(hitTestResults.count)
//        guard let modelNodeHit = getParentNodeOf(hitTestResult.first?.node) else { return }
//        guard let modelNodeHit = getParentNodeOf(hitTestResults.first?.node) else {
//            return
//        }
        for result in hitTestResults {
            if let node1 = getParentNodeOf(result.node) {
                    modelNodeHit = node1
                print("Oke")
                break
            }
            

        }
        
//        guard let modelNodeHit = getParentNodeOf(hitTestResult.first?.node) else { return }
        
//        guard let query = sceneView.raycastQuery(from: touch, allowing: .existingPlaneGeometry, alignment: .any) else {
//            return
//        }
//
//        guard let result = sceneView.session.raycast(query).first?.anchor else {
//            return
//        }
        
        
        
        
        var planeHit : ARHitTestResult!
        
        if recognizer.state == .changed {
            
            let hitTestPlane = self.sceneView.hitTest(touch, types: .existingPlane)
            guard hitTestPlane.first != nil else { return }
            planeHit = hitTestPlane.first!
            print(planeHit)
            print(modelNodeHit.name)
            modelNodeHit.position = SCNVector3(planeHit.worldTransform.columns.3.x,modelNodeHit.position.y,planeHit.worldTransform.columns.3.z)
            print(sceneView.anchor(for: modelNodeHit)?.name ?? "hi")
            print(sceneView.anchor(for: modelNodeHit)?.transform.columns.3 ?? "lo")
        
        }else if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed{
            
            guard let oldAnchor = sceneView.anchor(for: modelNodeHit) else { return }
            let newAnchor = ARAnchor(name: oldAnchor.name!, transform: modelNodeHit.simdTransform )
            print(oldAnchor.transform.columns.3)        // old position
            sceneView.session.remove(anchor: oldAnchor)
            sceneView.session.add(anchor: newAnchor)
            print(newAnchor.transform.columns.3)        // updated position

        }
    }

}
extension Object3DVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listObject.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cltvListObject.dequeueReusableCell(withReuseIdentifier: "ListObjectCLTVC", for: indexPath) as! ListObjectCLTVC
        cell.configure(object: listObject[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/4, height: self.cltvListObject.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemSelected = listObject[indexPath.row].pathObject3D
        
    }
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        cltvListObject.deselectItem(at: indexPath, animated: true)
//    }
    
}