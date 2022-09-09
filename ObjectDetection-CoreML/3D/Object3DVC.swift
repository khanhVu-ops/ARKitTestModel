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
    @IBOutlet weak var btnMeasure: UIButton!
    var itemSelected = ""
    var currentNode = SCNNode()
    let listObject: [ObjectModel] = [ObjectModel(pathObject3D: "vase.scn", title: "vase", image2DName: "vase"),
                                     ObjectModel(pathObject3D: "sticky note.scn", title: "sticky note", image2DName: "sticky note"),
                                     ObjectModel(pathObject3D: "painting.scn", title: "painting", image2DName: "painting"),
                                     ObjectModel(pathObject3D: "lamp.scn", title: "lamp", image2DName: "lamp"),
                                     ObjectModel(pathObject3D: "cup.scn", title: "cup", image2DName: "cup"),
                                     ObjectModel(pathObject3D: "chair.scn", title: "chair", image2DName: "chair"),
                                     ObjectModel(pathObject3D: "candle.scn", title: "candle", image2DName: "candle"),
                                     ObjectModel(pathObject3D: "Center Table.obj", title: "Center Table", image2DName: "Center Table"),
                                     ObjectModel(pathObject3D: "eb_house_plant_01.obj", title: "eb_house_plant_01", image2DName: "eb_house_plant_01"),
                                     ObjectModel(pathObject3D: "IronMan.obj", title: "IronMan", image2DName: "IronMan")]
    
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
        sceneView.debugOptions = [.showFeaturePoints]
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_ :)) )
        sceneView.addGestureRecognizer(tapGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotation))
        sceneView.addGestureRecognizer(rotationGesture)
        
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleObject(_:)))
        
        self.sceneView.addGestureRecognizer(scaleGesture)
        
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
  
    
    func addObject(position: SIMD3<Float>) {
        
        if itemSelected != "" {
            
            guard let scence = SCNScene(named: self.itemSelected) else {
                return
            }
            let modelNode = scence.rootNode
            modelNode.name = "Car"
            print(position)
            modelNode.simdPosition = SIMD3(position.x, position.y, position.z)
            modelNode.simdPosition = position
            modelNode.simdScale = SIMD3(0.1, 0.1, 0.1)
            self.currentNode = modelNode
            modelNode.enumerateChildNodes { (node, _) in
                node.categoryBitMask = BodyType.ObjectModel.rawValue
            }
            modelNode.categoryBitMask = BodyType.ObjectModel.rawValue
            self.sceneView.scene.rootNode.addChildNode(modelNode)
            self.itemSelected = ""
            
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
    
    func checkVituralObjectExitsLocation(location: CGPoint, recognizerView: ARSCNView) -> SCNNode?{
        
        
        let hitTestResults = self.sceneView.hitTest(location, options: [.categoryBitMask: BodyType.ObjectModel.rawValue])
        for result in hitTestResults {
            if let node1 = getParentNodeOf(result.node) {
                return node1
            }
        }
        return nil
    }
    
    //MARK: @objc func
    
    @objc func scaleObject(_ gesture: UIPinchGestureRecognizer) {

//        let location = gesture.location(in: sceneView)
       
        if gesture.state == .changed {

            let pinchScaleX: CGFloat = gesture.scale * CGFloat((currentNode.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((currentNode.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((currentNode.scale.z))
            currentNode.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1

        }
        if gesture.state == .ended { }

    }
    
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        guard let scene = gesture.view as? ARSCNView else {return}
        let position = gesture.location(in: scene)
        
        // check virtual content exits location
        
        if let nodeExit = checkVituralObjectExitsLocation(location: position, recognizerView: scene) {
            currentNode = nodeExit
        }
        else {
            let results = scene.hitTest(position, types: .estimatedHorizontalPlane)
            guard let hitFeature = results.first else {
                return
            }
            
//            let hitTransform = SCNMatrix4(hitFeature.worldTransform)
//            let hitPosition = SCNVector3(hitTransform.m41,
//                                         hitTransform.m42,
//                                         hitTransform.m43)
            let touchLocation = hitFeature.worldTransform.translation
            addObject(position: touchLocation)
        }
      
    }
    
    
    @objc func rotation(_ gesture: UIRotationGestureRecognizer) {
    
        if gesture.state == .changed {
            currentNode.eulerAngles.y -= Float(gesture.rotation)
        }
        gesture.rotation = 0
        
    }
    
   
    var moveNode : SCNNode?
    @objc func moved(recognizer :UIPanGestureRecognizer) {
        
        guard let recognizerView = recognizer.view as? ARSCNView else { return }
        let touch = recognizer.location(in: recognizerView)
        print("Touch")
     
        if recognizer.state == .began {
            if let nodePan = checkVituralObjectExitsLocation(location: touch, recognizerView: recognizerView) {
                moveNode = nodePan
                print("END Began")
            }
        }else if recognizer.state == .changed {
            print("Changed")
            guard let query = recognizerView.raycastQuery(from: touch, allowing: .estimatedPlane, alignment: .horizontal)else {
                return
            }
            guard let planeHit = recognizerView.session.raycast(query).first else {
                return
            }
            
            if let movingNode = moveNode {
                movingNode.simdWorldPosition = planeHit.worldTransform.translation
            }
     
        }else if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed{
            print("END")
            
            if let movedNode = moveNode {
                print("OK")
                currentNode = movedNode
                moveNode = nil
                print("10")
            }
            
        }
    }
    var tapMeasure = false
    
    @IBAction func didTapMeasure(_ sender: Any) {
        btnMeasure.tintColor = tapMeasure ? .blue : .gray
        tapMeasure = !tapMeasure
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
