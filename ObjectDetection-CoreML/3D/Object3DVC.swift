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
    var tapMeasure = false
    var currentNode = SCNNode()
    var positionCurrentNode = SIMD3<Float>()
    var list3DPosition: [SIMD3<Float>] = []
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
        sceneView.session.delegate = self
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        // Pause the view's session
        sceneView.session.pause()
    }
  
    //MARK: add object 3d
    func addObject(position: SIMD3<Float>) {
        
        if itemSelected != "" {
            
            guard let scence = SCNScene(named: self.itemSelected) else {
                return
            }
            let modelNode = scence.rootNode
            modelNode.name = "\(list3DPosition.count)"
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
            list3DPosition.append(position)
            positionCurrentNode = position
            self.itemSelected = ""
            
            //            myObjectNodes.insert(modelNode)
        }else {
            currentNode.simdPosition = SIMD3(position.x, position.y, position.z)
        }
        
    }
    
    
    // gett parent node of nodes child was hitTest detected.
    func getParentNodeOf(_ nodeFound: SCNNode?, name: String) -> SCNNode? {
        if let node = nodeFound {
            if node.name == name {
                return node
            } else if let parent = node.parent {
//                print(node.name)
                return getParentNodeOf(parent, name: name)
            }
        }
        return nil
    }
    
    // Check object 3d existed tap location
    func checkVituralObjectExitsLocation(location: CGPoint, recognizerView: ARSCNView) -> SCNNode?{
        
        
        let hitTestResults = self.sceneView.hitTest(location, options: [.categoryBitMask: BodyType.ObjectModel.rawValue])
        
        for result in hitTestResults {
            for index in 0..<list3DPosition.count {
                if let node1 = getParentNodeOf(result.node, name: String(index)) {
                    positionCurrentNode = list3DPosition[index]
                    return node1
                }
            }
           
        }
        return nil
    }
    
    //MARK: Measure distance from object to plane
    func measureTheDistanceFromObjectToPlane(objLocation: SIMD3<Float>) {
        let sphereNode = SphereNode(position: objLocation)
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        let distance = currentNode.position.distance(to: sphereNode.position)
        print(distance)
        
//        let ray = SCNBox(width: 0.001, height: 0.001, length: distance, chamferRadius: 0)
//        ray.firstMaterial?.diffuse.contents = UIColor.black
//        let node = SCNNode(geometry: ray)
//        let rayLocation = centerPoint(from: positionCurrentNode, to: objLocation)
//        node.simdTransform.translation = rayLocation
//        sceneView.scene.rootNode.addChildNode(node)
        
        //line
        let line = SCNGeometry.line(from: positionCurrentNode, to: objLocation)
        let lineNode = SCNNode(geometry: line)
        lineNode.position = SCNVector3Zero
        sceneView.scene.rootNode.addChildNode(lineNode)
        
        
        let text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = .systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.alignmentMode  = CATextLayerAlignmentMode.center.rawValue
        text.truncationMode = CATextLayerTruncationMode.middle.rawValue
        text.firstMaterial?.isDoubleSided = true
        text.string = String(format: "%.2f cm", distance*100)
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)

        let textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        textNode.simdTransform.translation = centerPoint(from: positionCurrentNode, to: objLocation)
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    // caculate center 2 point
    
    func centerPoint(from A: SIMD3<Float>, to B: SIMD3<Float>) -> SIMD3<Float>{
        let centerX = (A.x + B.x)/2;
        let centerY = (A.y + B.y)/2;
        let centerZ = (A.z + B.z)/2;
        
        let center = SIMD3(x: centerX, y: centerY, z: centerZ)
        return center
    }
    
    //MARK: @objc func
    
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
            let touchLocation = hitFeature.worldTransform.translation
            
            if !tapMeasure {
                addObject(position: touchLocation)
            }else {
                measureTheDistanceFromObjectToPlane(objLocation: touchLocation)
            }
        }
      
    }
    
    // scale object
    @objc func scaleObject(_ gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == .changed {

            let pinchScaleX: CGFloat = gesture.scale * CGFloat((currentNode.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((currentNode.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((currentNode.scale.z))
            currentNode.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1

        }
        if gesture.state == .ended { }

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
                guard let query = recognizerView.raycastQuery(from: touch, allowing: .estimatedPlane, alignment: .horizontal)else {
                    return
                }
                guard let planeHit = recognizerView.session.raycast(query).first else {
                    return
                }
                currentNode = movedNode
                positionCurrentNode = planeHit.worldTransform.translation
                let id = Int(currentNode.name ?? "")
                list3DPosition[id!] = positionCurrentNode
                moveNode = nil
                print("10")
            }
            
        }
    }
    
    
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
  
}

extension Object3DVC: ARSessionDelegate {
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
}
