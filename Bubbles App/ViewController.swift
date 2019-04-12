import Foundation
import ARKit
import UIKit
import AVFoundation
import CoreAudio

public class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, OptionViewDelegate, PhotoDelegate {
    
    // ARView stuff
    let session = ARSession()
//    var sceneView: ARSCNView!
    
    @IBOutlet weak var selectedColorView: CircledDotView!
    @IBOutlet weak var sceneView: ARSCNView!
    
    // Declares a view to display pics
    var photoView: PhotoView!
    
    var debugLabel: UILabel!
//    var detectingLabel: UILabel!
    
    // This is in order to play the pop sound
    //    let popSound = URL(fileURLWithPath: Bundle.main.path(forResource: "pop", ofType: "mp3")!)
    var audioPlayer: AVAudioPlayer!
    
    
    // This is in order to use the mic
    var recorder: AVAudioRecorder!
    let LEVEL_THRESHOLD: Float = -20.0
    
    // Color picking stuff
    var colorPicker: UIImage!
    var colorPickerView: UIImageView!
    var currentColor: UIColor!
    
    
    // Bubble blower stuff
    var bubbleBlowerImage: UIImage!
    var bubbleBlowerView: UIImageView!
    
    // Armazena o estado tendo em vista as opcoes
    var currentState: String!
    var bubbleCounter: Int!

    @IBOutlet var newView: UIView!
    @IBOutlet weak var autoButton: UIButton!
    
    var isAuto: Bool!
    
    
    var blowLabel: UILabel!
    var hasBlown: Bool!
    
    public override func loadView() {
        self.currentColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.isAuto = false
        self.blowLabel = UILabel()
        self.hasBlown = false
        super.loadView()
//        sceneView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 768, height: 1024))
        photoView = PhotoView(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
        
        initMicrophone() // Inicializa o microfone para detectar o sopro
        sceneView.delegate = self
        sceneView.session = session
        
        bubbleCounter = 0
        
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        photoView.delegate = self
        self.setupUI()
        self.setUpSceneView()
        self.currentState = "blow"
        
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        //        self.spawnBubblePopParticle(spawnAt: SCNVector3(0, 0, 0), withColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
        
    }
    
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        colorPickerView.layer.cornerRadius = colorPickerView.frame.width * 0.5
        
    }
    
    
    func updateAuto(_ sender: UIButton){
        self.isAuto = !self.isAuto
        self.updateAutoColor(sender)
        self.currentState = self.isAuto ? "auto" : "blow"
    }
    
    func updateAutoColor(_ sender: UIButton){
        let image = UIImage(named: "catavento")?.maskWithColor(color: self.isAuto ? #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        sender.setImage(image, for: .normal)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let frame = self.sceneView.session.currentFrame else {
            return
        }
        let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
        let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
        
        
        for node in sceneView.scene.rootNode.childNodes {
            node.look(at: pos)
        }
        if self.currentState == "auto"{
            if self.bubbleCounter % 6 == 0{
                spawnBubble()
            }
            bubbleCounter += 1
        }else if self.currentState == "blow"{
            self.updateMic()
        }
    }
    
    func onBackButtonPressed() {
        print("Back button pressed!")
//        self.view = sceneView
    }
    
    @objc func onCameraPressed() {
        print("Tirando foto na GameScene")
        let pic = self.sceneView.snapshot()
        self.goToPhotoView(image: pic)
    }
    
    func onOptionChanged(newOption: String) {
        self.currentState = newOption
        print("Mudando o estado para", newOption)
    }
    //    TODO: Aprender a usar isso aqui
//    let colorPicker : UIImageView = {
//        let image = UIImageView()
//        image.image = UIImage(named: "colorPicker")
//        image.translatesAutoresizingMaskIntoConstraints = false
//        return image
//    }()
//
    //Hierarquia (addSubview)
    //Constraints
    //Configurações adicionais
    
    private func setupUI() {

        // Creating and setting the detecting plane label
        let font = UIFont(name: "HelveticaNeue-BoldItalic", size: 22)
//        detectingLabel = UILabel(frame: CGRect(x: 20, y: -20, width: 300, height: 100))
//        detectingLabel.font = font
//        detectingLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        detectingLabel.layer.shadowColor = UIColor.black.cgColor
//        detectingLabel.layer.shadowOpacity = 1.0
//        detectingLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
//        detectingLabel.text = "detecting horizontal plane..."
//
        
        // Instantiating and setting the debug label
        debugLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 300, height: 100))
        debugLabel.font = font
        debugLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        debugLabel.layer.shadowColor = UIColor.black.cgColor
        debugLabel.layer.shadowOpacity = 1.0
        debugLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        //        debugLabel.text = "\(recorder.averagePower(forChannel: 0))"
        
        // Loading image for the color picker
        colorPicker = UIImage(named: "raw_color_picker")!
        
        // Instancia a view da escolha de cores
        let colorPickerView = UIImageView(image: colorPicker)
        colorPickerView.frame = CGRect(x: 0, y:0, width: 60, height: 60)
        colorPickerView.layer.cornerRadius = 8
        colorPickerView.clipsToBounds = true
        colorPickerView.isUserInteractionEnabled = true
        self.colorPickerView = colorPickerView
        
        // Instancia a view do bubble blower
        let bubbleBlowerImage = self.getBubbleBlowerImage()
        let bubbleBlowerView = UIImageView(image: bubbleBlowerImage)
        bubbleBlowerView.contentMode = .scaleAspectFill
        bubbleBlowerView.frame = CGRect(x: 0, y:0, width: 60, height: 60)
        self.bubbleBlowerView = bubbleBlowerView
        
        
        let optionsView = OptionsView()
        optionsView.delegate = self
        // coloca as imagens nas views
//        self.view.addSubview(bubbleBlowerView)
        self.view.addSubview(colorPickerView)
        //        self.view.addSubview(detectingLabel)
        //        self.view.addSubview(debugLabel)
//        self.view.addSubview(optionsView)
        //        self.view.addSubview(optionsView)
        
        //        self.view.addSubview(self.segmentControl)
        // Configura as constrains do colorPicker
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 23).isActive = true
        colorPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -240).isActive = true
//        colorPickerView.topAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -CGFloat((colorPickerView.image?.cgImage?.height)!) ).isActive = true
        colorPickerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15).isActive = true
        colorPickerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        
        // Configura as constrains do bubblePicker
//        bubbleBlowerView.translatesAutoresizingMaskIntoConstraints = false
//        bubbleBlowerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        bubbleBlowerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        bubbleBlowerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true
//        bubbleBlowerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
//
////        self.initAutoButton()
//        self.initCameraButton()
        self.initBlowLabel()
        
        // Configura as contrains do menu de opcoes
//        optionsView.translatesAutoresizingMaskIntoConstraints = false
//        optionsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
//        optionsView.bottomAnchor.constraint(equalTo:colorPickerView.bottomAnchor, constant: 0).isActive = true
//        optionsView.widthAnchor.constraint(equalTo:  view.widthAnchor, multiplier: 0.1).isActive = true
//        optionsView.heightAnchor.constraint(equalTo: colorPickerView.heightAnchor).isActive = true
    }
    
    
    func goToPhotoView(image toDisplay: UIImage){
        self.photoView.image = toDisplay
        self.view = self.photoView
    }
    
    func initMicrophone(){
        
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let url = documents.appendingPathComponent("record.caf")
        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            44100.0,
            AVNumberOfChannelsKey:      2,
            AVEncoderBitRateKey:        12800,
            AVLinearPCMBitDepthKey:     16,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            try recorder = AVAudioRecorder(url:url, settings: recordSettings)
            
        } catch {
            return
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()
    }
    
    func spawnBubble(){
        self.blowLabel.isHidden = true
        guard let frame = self.sceneView.session.currentFrame else {
            return
        }
        let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
        
        let position = getNewPosition()
        
        let newBubble = Bubble(color: self.currentColor)
        newBubble.position = position
        newBubble.scale = SCNVector3(1,1,1) * floatBetween(0.6, and: 1)
        //        self.debugLabel.text = "\(self.currentColor.redValue), \(self.currentColor.greenValue), \(self.currentColor.blueValue), "
        newBubble.setColor(newColor: self.currentColor)
        
        let firstVector = dir.normalized() * 0.5 + SCNVector3(0,0.15,0)
        let secondVector =  dir + SCNVector3(floatBetween(-1.5, and:1.5 ),floatBetween(0, and: 1.5),0)
        
        let firstAction = SCNAction.move(by: firstVector, duration: 0.5)
        firstAction.timingMode = .easeOut
        
        let secondAction = SCNAction.move(by: secondVector, duration: TimeInterval(floatBetween(8, and: 11))) // Tempo de vida da bolha
        
        secondAction.timingMode = .easeOut
        newBubble.runAction(firstAction)
        newBubble.runAction(secondAction, completionHandler: {
            newBubble.runAction(SCNAction.fadeOut(duration: 0), completionHandler: {
                let moved = newBubble.position + firstVector + secondVector
                //                self.playPop()
                self.spawnBubblePopParticle(spawnAt: moved, withColor: self.currentColor)
                newBubble.removeFromParentNode()
            })
        })
        
        sceneView.scene.rootNode.addChildNode(newBubble)
    }
    
    func spawnBubblePopParticle(spawnAt point: SCNVector3, withColor color: UIColor){
        return
        let emitter = SCNParticleSystem(named: "reactor", inDirectory: "Assets.xcassets")!
        emitter.particleColor = color
        emitter.particleLifeSpan = 1.0
        sceneView.scene.rootNode.addParticleSystem(emitter)
//        emitter.removeAllAnimations()
    }
    
    public func setUpSceneView() {
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        sceneView.delegate = self
    }
    
    
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        DispatchQueue.main.async {
//            self.detectingLabel.isHidden = true
//        }
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = UIColor.clear
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isAuto{
            spawnBubble()
        }
        
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleColorChange(touches)
    }
    
    func handleColorChange(_ touches: Set<UITouch>){
        for touch in touches{
            let point = touch.location(in: self.colorPickerView)
            let color = self.colorPickerView.getPixelColorAt(point: point)
            if color.alphaValue != 0{
                self.bubbleBlowerView.image = self.getBubbleBlowerImage()
                self.currentColor = color.withAlphaComponent(1.0)
                self.selectedColorView.updateColor(color: self.currentColor)
            }
        }
    }
    
    @objc func takePic(){
        print("Taking picture")
        
        let pic = self.sceneView.snapshot()

        mimicScreenShotFlash()
        print("Loaded pic")
        UIImageWriteToSavedPhotosAlbum(pic, nil, nil, nil)
        print("Saved pic")
    }
    func mimicScreenShotFlash() {
        
        let aView = UIView(frame: self.view.frame)
        aView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.view.addSubview(aView)
        
        UIView.animate(withDuration: 1.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            aView.alpha = 0.0
        }, completion: { (done) -> Void in
            aView.removeFromSuperview()
        })
    }
    func playPop(){
        //        print("Played pop!")
        ////        canRecord = false;
        //        do{
        //            try AVAudioSession.sharedInstance().setCategory(.playback , mode: .default)
        //
        //            audioPlayer = try AVAudioPlayer(contentsOf: popSound)
        //            audioPlayer.play()
        //        }catch let error  {
        //            print("AI IRMAO DEU RUIM \(error)")
        //        }
        //        canRecord = true;
    }
    
    func getNewPosition() -> (SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            return pos + SCNVector3(0,-0.07,0) + dir.normalized() * 0.5
        }
        return SCNVector3(0, 0, -1)
    }
    
    func updateMic(){
//        initMicrophone()
        recorder.updateMeters()
        let level = recorder.averagePower(forChannel: 0)
        let isLoud = level > LEVEL_THRESHOLD
        if isLoud{
            spawnBubble()
        }
    }
    
    
    func getBubbleBlowerImage() -> UIImage{
        let img = UIImage(named: "bubbleblower")!
        return img
        return img.maskWithColor(color: self.currentColor)!
        //        return imgz
    }
    //

    
    func initBlowLabel(){
        self.blowLabel.text = "Blow."
        self.blowLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.blowLabel.adjustsFontSizeToFitWidth = true
        self.blowLabel.textAlignment = .center
        self.blowLabel.font = UIFont(name: self.blowLabel.font.fontName, size: 20   )
        self.view.addSubview(self.blowLabel)
        
        self.blowLabel.translatesAutoresizingMaskIntoConstraints = false
        self.blowLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.blowLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.blowLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
        self.blowLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
        
    }
    
    
    @IBAction func onHelpButtonPressed(_ sender: Any) {
        self.takePic()
    }
    
    @IBAction func onCameraButtonClicked(_ sender: Any) {
//        self.onCameraPressed()
        self.takePic()
    }
    @IBAction func onAutoButtonClicked(_ sender: Any) {
        let button = sender as! UIButton
        self.updateAuto(button)
    }
}


