//
//  ARSceneViewBuilder.swift
//  Smaapper
//
//  Created by Alessandro Comparini on 05/07/23.
//

import UIKit
import ARKit


enum ARSceneState {
    case waitingWorldMapRecognition
    case excessiveMotion
    case done
    case sessionInterrupted
}

protocol ARSceneViewBuilderDelegate: AnyObject {
    func positionTouch(_ position: CGPoint)
    func stateARSceneView(_ state: ARSceneState)
    func requestCameraElevation(isElevation: Bool)
}


class ARSceneViewBuilder: ViewBuilder {
    weak var delegate: ARSceneViewBuilderDelegate?
    
    enum Alignment {
        case top
        case middle
        case bottom
    }
    
    struct Control {
        static var isCameraElevationControl = true
        static var sessionInterrupted: ARSession?
    }
    
    private(set) var isPaused: Bool = false
    private var shouldAttemptRelocalization: Bool = true
    private var arSceneView: ARSCNView?
    private var configuration: ARWorldTrackingConfiguration?
    private var snapshotARSceneView: UIImageView = UIImageView()
    private var positionTarget: ( aligment: Alignment, padding: CGFloat)?
    private var options: ARSession.RunOptions = []
    private var anchorsLoadWorldMap: [ARAnchor]?
    
    override init() {
        super.init()
        initialization()
    }
    
    private func freeMemory() {
        arSceneView = nil
        configuration = nil
        anchorsLoadWorldMap = nil
        arSceneView?.delegate = nil
        arSceneView?.session.delegate = nil
    }
    
    private func initialization() {
        addElements()
        configConstraints()
        setPreferredFramesPerSecond(15)
        start()
    }
    
    private func start() {
        snapshotARSceneView.removeFromSuperview()
        createSceneView()
        createConfiguration()
        addArSceneView()
        configArSceneViewConstraints()
        repositionTarget()
        configDelegate()
    }

    private func addArSceneView() {
        arSceneView?.add(insideTo: self.view)
    }
    
    private func createConfiguration() {
        configuration = ARWorldTrackingConfiguration()
        configuration?.isCollaborationEnabled = true
        if configuration?.planeDetection.isEmpty ?? true {
            configuration?.planeDetection = [.vertical, .horizontal]
        }
    }
    
    private func configDelegate() {
        arSceneView?.delegate = self
        arSceneView?.session.delegate = self
    }
    
    
//  MARK: - LAZY Area
    lazy var targetImage: ImageViewBuilder = {
        let img = ImageViewBuilder(UIImage(systemName: C.ARSceneView.Images.imageTarget))
            .setTintColor(Theme.shared.currentTheme.onSurface)
            .setSize(C.ARSceneView.sizeTarget)
            .setWeight(.thin)
            .setConstraints { build in
                build
                    .setVerticalAlignmentY.equalToSuperView(-100)
                    .setHorizontalAlignmentX.equalToSuperView
            }
            .setActions { build in
                build
                    .setDraggable()
            }
        return img
    }()
    
    lazy var targetBallImage: ImageViewBuilder = {
        let img = ImageViewBuilder(UIImage(systemName: C.ARSceneView.Images.imageBallTarget))
            .setTintColor(Theme.shared.currentTheme.onSurface.withAlphaComponent(0.8))
            .setSize(6)
            .setWeight(.thin)
            .setConstraints { build in
                build
                    .setAlignmentCenterXY.equalToSuperView
            }
        return img
    }()
    
    
//  MARK: - GET Area
    func getPositionOnPlaneByTouch(positionTouch: CGPoint, _ alignment: ARRaycastQuery.TargetAlignment) -> simd_float4x4? {
        if let raycastQuery = arSceneView?.raycastQuery(from: positionTouch, allowing: .existingPlaneGeometry, alignment: alignment) {
            if let castResult = arSceneView?.session.raycast(raycastQuery).first {
                return castResult.worldTransform
            }
        }
        return nil
    }
    
    func getPositionOnPlaneByTarget(_ alignment: ARRaycastQuery.TargetAlignment) -> simd_float4x4? {
        let positionTarget: CGPoint = targetImage.view.convert(targetBallImage.view.center, to: arSceneView)
        return getPositionOnPlaneByTouch(positionTouch: positionTarget, alignment)
    }
    
    func getPositionByCam(centimetersAhead: Float? = 1) -> simd_float4x4? {
        if let cameraTransform = arSceneView?.session.currentFrame?.camera.transform {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -((centimetersAhead ?? 0.0) / 100.0)
            return matrix_multiply(cameraTransform, translation)
        }
        return nil
    }
    
    func getWorldMapData() async throws -> Data {
        let worldMap = try await getCurrentWorldMap()
        return try convertWorldMapToData(worldMap)
    }
    
    func getPrint() -> UIImage? {
        return arSceneView?.snapshot()
    }
    
    
//  MARK: - SET Properties

    @discardableResult
    func setPlaneDetection(_ planeDetection: ARWorldTrackingConfiguration.PlaneDetection) -> Self {
        self.configuration?.planeDetection = planeDetection
        return self
    }

    @discardableResult
    func setDebug(_ debugOptions: ARSCNDebugOptions) -> Self {
        arSceneView?.debugOptions = debugOptions
        return self
    }
    
    @discardableResult
    func setEnabledTarget(_ enabled: Bool) -> Self {
        targetImage.setHidden(!enabled)
        return self
    }
    
    @discardableResult
    func setOptions(_ options: ARSession.RunOptions) -> Self {
        self.options.insert(options)
        return self
    }
    
    @discardableResult
    func setEnabledTargetDraggable(_ enabled: Bool) -> Self {
        targetImage.actions?.draggable?.setEnabledDraggable(enabled)
        return self
    }
    
    @discardableResult
    func setAlignmentTarget(_ alignment: Alignment, _ padding: CGFloat = 0) -> Self {
        DispatchQueue.main.async { [weak self] in
            self?.setAlignment(alignment, padding)
            self?.positionTarget = (alignment,padding)
        }
        return self
    }
    
    @discardableResult
    func setImageTarget(image: ImageViewBuilder, size: CGFloat = C.ARSceneView.sizeTarget) -> Self {
        self.targetImage.setImage(image.view.image)
        self.targetBallImage.setHidden(true)
        targetImage.setSize(size)
        return self
    }
    
    @discardableResult
    func setPreferredFramesPerSecond(_ framesPerSecond: Int) -> Self {
        self.arSceneView?.preferredFramesPerSecond = framesPerSecond
        return self
    }
    
    @discardableResult
    func setShouldAttemptRelocalization(_ flag: Bool ) -> Self {
        self.shouldAttemptRelocalization = flag
        return self
    }
    
    
//  MARK: - DELEGATE
    @discardableResult
    func setDelegateARSceneView(_ delegate: ARSCNViewDelegate) -> Self {
        arSceneView?.delegate = delegate
        return self
    }
    
    @discardableResult
    func setDelegateARSession(_ delegate: ARSessionDelegate) -> Self {
        arSceneView?.session.delegate = delegate
        return self
    }

    
//  MARK: - ACTIONS

    func runSceneView() {
        isPaused = false
        start()
        runSession()
    }
    
    func runSceneView(loadWorldMapData worldMapData: Data) throws {
        if worldMapData.isEmpty {
            runSceneView()
            return
        }
        start()
        return try runSceneWithWorldMap(worldMapData)
    }
    
    func pauseSceneView()  {
        arSceneView?.session.pause()
        addSnapShotToPauseAR()
        removeARSceneView()
        targetImage.setHidden(true)
        isPaused = true
    }
    
    func addNode(_ node: ARNodeBuilder) {
        let anchor = ARAnchor(name: node.name ?? C.String.empty, transform: node.simdTransform)
        node.setAnchor(anchor)
        arSceneView?.session.add(anchor: anchor)
        arSceneView?.scene.rootNode.addChildNode(node)
    }
    
 
//  MARK: - INVOKE SAVE WORLD MAP
    
    private func runSceneWithWorldMap(_ worldMapData: Data) throws {
        do {
            if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: worldMapData) {
                if !worldMap.anchors.isEmpty {
                    self.configuration?.initialWorldMap = worldMap
                }
                setOptions([.resetTracking, .removeExistingAnchors])
                runSession()
            }
        } catch {
            throw WorldMapError.invalidWorldMap(error: error.localizedDescription)
        }
    }
    
    private func runSession() {
        print(self.configuration?.initialWorldMap?.anchors.count ?? C.String.empty )
        if let configuration {
            self.arSceneView?.session.run(configuration, options: self.options)
        }
    }
    
    
//  MARK: - PRIVATE Area

    private func getCurrentWorldMap() async throws -> ARWorldMap {
        do {
            if let worldMap = try await arSceneView?.session.currentWorldMap() {
                return worldMap
            }
            throw WorldMapError.worldMapEmptyOrNil
        } catch let error {
            throw WorldMapError.getCurrentWordlMap(error: error.localizedDescription)
        }
    }
    
    private func getSesstion() -> ARSession {
        if let session = Control.sessionInterrupted {
            return session
        }
        return arSceneView?.session ?? ARSession()
    }
    
    private func convertWorldMapToData(_ worldMap: ARWorldMap) throws -> Data {
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        } catch {
            throw WorldMapError.convertToData(error: error.localizedDescription)
        }
    }
    

    private func removeARSceneView() {
        arSceneView?.removeFromSuperview()
        freeMemory()
    }
    
    private func addSnapShotToPauseAR() {
        guard let snapshot = arSceneView?.snapshot() else { return }
        snapshotARSceneView = UIImageView(image: snapshot)
        snapshotARSceneView.frame = arSceneView?.bounds ?? self.view.bounds
        view.addSubview(snapshotARSceneView)
    }
    
    private func repositionTarget() {
        targetImage.setHidden(true)
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            if let positionTarget {
                setAlignment(positionTarget.aligment, positionTarget.padding)
                targetImage.setHidden(false)
            }
        }
        sendARSceneViewToBack()
    }
    
    private func sendARSceneViewToBack() {
        view.bringSubviewToFront(targetImage.view)
    }
    
    private func setAlignment(_ alignment: Alignment, _ padding: CGFloat) {
        switch alignment {
            case .top:
                targetImage.view.frame.origin.y = self.view.bounds.minY + padding
            case .middle:
                targetImage.view.center.y = (self.view.bounds.midY) + padding
            case .bottom:
                targetImage.view.frame.origin.y = (self.view.bounds.maxY - targetImage.view.bounds.height) - padding
        }
    }
    
    private func createSceneView() {
        self.arSceneView = ARSCNView(frame: self.view.bounds)
    }
    
    private func configSceneView() {
        setEnabledTarget(true)
        setEnabledTargetDraggable(true)
    }
    
    private func addElements() {
        targetImage.add(insideTo: self.view)
        targetBallImage.add(insideTo: targetImage.view)
    }
    
    private func configConstraints() {
        targetImage.applyConstraint()
        targetBallImage.applyConstraint()
    }
    
    private func configArSceneViewConstraints() {
        arSceneView?.makeConstraints { make in
            make
                .setPin.equalToSuperView
                .apply()
        }
    }
    
    private func isCameraInVerticalPosition(_ camera: ARCamera) -> Bool {
        let pitch = camera.eulerAngles.x
        let degreesVerticalPosition = -25.0...10.0
        if degreesVerticalPosition.contains(Double(pitch).piToDegrees) {
            return true
        }
        return false
    }
    
    
    private func calculatePositionFromTarget(_ centimetersAhead: Float? = 0) {
        if let cameraTransform = arSceneView?.session.currentFrame?.camera.transform {
            print("TOP 1", arSceneView!.frame.height - targetImage.view.center.y)
            print("TOP 2", (arSceneView!.frame.height/2) - targetImage.view.center.y)
        
            print("height", arSceneView!.frame.height)
            print("Y", targetImage.view.center.y)
            
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -((8) / 100.0)
            translation.columns.3.x = -((0.73) / 100.0)
            let nodeTransform = matrix_multiply(cameraTransform, translation)

            let node = SCNNode()
            node.simdTransform = nodeTransform
            node.geometry = SCNSphere(radius: 0.005)
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            arSceneView?.scene.rootNode.addChildNode(node)
        }
    }
    
    private func invokeRequestCameraElevationIfNeeds(_ camera: ARCamera) {
        if Control.isCameraElevationControl {return}
        if !isCameraInVerticalPosition(camera) {
            Control.isCameraElevationControl = false
            delegate?.requestCameraElevation(isElevation: false)
            return
        } else {
            delegate?.requestCameraElevation(isElevation: true)
            Control.isCameraElevationControl = true
        }
    }
    
    private func callInsufficientFeatures(_ camera: ARCamera) {
        invokeRequestCameraElevationIfNeeds(camera)
    }
    
    private func callExcessiveMotion() {
        delegate?.stateARSceneView(.excessiveMotion)
    }
    
    private func callCameraNormal() {
        invokeARSceneViewDone()
    }
    
    private func invokeARSceneViewDone() {
        delegate?.stateARSceneView(.done)
    }
    
    private func callCameraLimited(_ reason: ARCamera.TrackingState.Reason, _ camera: ARCamera) {
        switch reason {
            case .excessiveMotion:
                callExcessiveMotion()
            
            case .insufficientFeatures:
                callInsufficientFeatures(camera)

            case .relocalizing:
                callRelocalizing(camera)
            
            default:
                break
        }
    }
        
    private func callRelocalizing(_ camera: ARCamera) {
        delegate?.stateARSceneView(.waitingWorldMapRecognition)
        invokeRequestCameraElevationIfNeeds(camera)
    }
}


//  MARK: - EXTENSION DELEGATE ARSessionDelegate

extension ARSceneViewBuilder: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if Control.isCameraElevationControl {return}
        if isCameraInVerticalPosition(frame.camera) {
            delegate?.requestCameraElevation(isElevation: true)
            Control.isCameraElevationControl = true
            return
        }
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        print("chamou isso aqui : SESSIONSHOULDATTEMPTRELOCALIZATION")
        return shouldAttemptRelocalization
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
            case .notAvailable:
                break
            
            case .limited( let reason ):
                callCameraLimited(reason, camera)
                
            case .normal:
                callCameraNormal()
        }
    }
        
    func sessionWasInterrupted(_ session: ARSession) {
        Control.sessionInterrupted = session
        delegate?.stateARSceneView(.sessionInterrupted)
    }
    
}


//  MARK: - EXTENSION DELEGATE ARSCNViewDelegate

extension ARSceneViewBuilder: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            return
        }
        print(anchor.identifier)
    }
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: self.arSceneView) {
            delegate?.positionTouch(touchLocation)
        }
    }
    
}
