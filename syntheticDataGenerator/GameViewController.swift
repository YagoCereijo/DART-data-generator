//
//  GameViewController.swift
//  syntheticDataGenerator
//
//  Created by Yago  Cereijo Botana on 11/7/22.
//

import SceneKit
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

class GameViewController: NSViewController, SCNSceneRendererDelegate {
    
    let scene = SCNScene(named: "dart.scn")!
    let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
    var dart:SCNNode = SCNNode()
    var countTextNode:SCNNode!
    var dartBoard:SCNNode!
    var r:CGFloat = 0.0
    var count:Int = 1
    let dataQuantity:Int = 5000
    var data:String = "[\n"
    var filters:[CIFilter]!
    var captured = true
    
    
    var url:URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        url = documentsURL.appendingPathComponent("dartData")
        
        dartBoard = scene.rootNode.childNode(withName: "dartBoard", recursively: false)!
        countTextNode = scene.rootNode.childNode(withName: "text", recursively: false)!
        sceneView.setFrameSize(NSSize(width: 150, height: 150))
        sceneView.scene = scene
        self.view.addSubview(sceneView)
        sceneView.delegate = self
        //sceneView.showsStatistics = true
        //sceneView.rendersContinuously = true
        sceneView.preferredFramesPerSecond = 30
        sceneView.play(self)
        setupFilters()
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        
        if count <= dataQuantity && captured {
            captured = false
            let scale = CGFloat.random(in: 0.1...1)
           
            let dartBoardPadding = (dartBoard.boundingBox.max.x - dartBoard.boundingBox.min.x) * scale / 2
            let xPosition = CGFloat.random(in: (-22.5+dartBoardPadding)...(22.5-dartBoardPadding))
            let yPosition = CGFloat.random(in: (-22.5+dartBoardPadding)...(22.5-dartBoardPadding))
            
            dartBoard.scale.x = scale
            dartBoard.scale.y = scale
            dartBoard.position = SCNVector3(xPosition, yPosition, 0)
            
            let min = sceneView.projectPoint(dartBoard.convertPosition(dartBoard.boundingBox.min, to: nil) )
            let max = sceneView.projectPoint(dartBoard.convertPosition(dartBoard.boundingBox.max, to: nil) )
           
            let imageName = String(count) + ".png"
            
//            let text = NSString(string: String(count))
//            let countText = SCNText()
//            countText.font = NSFont(name: "Avenir Heavy", size: 10)
//            countText.string = text
//            countText.firstMaterial?.diffuse.contents = NSColor.systemGreen
//            countTextNode.geometry = countText
            
            scene.background.contents = randomBackground()
            
            let width = Float(max.x-min.x) * 2
            let height = Float(max.y-min.y) * 2
            
            let x = (Float(min.x) * 2 + width/2)
            let y = ((300 - Float(min.y) * 2) - height/2)
            
            let coordinates = Coordinates(x: x, y: y, width: width, height: height)
            let annotations = Annotations(label: "dartboard", coordinates: coordinates)
            let detectionData = DetectionData(image: imageName, annotations: [annotations])
        
            let jsonEncoder = JSONEncoder()
            let jsonData = try? jsonEncoder.encode(detectionData)
            let jsonString = String(data: jsonData!, encoding: .utf8)!
            
            data.append(jsonString + ",\n")
            
            DispatchQueue.main.async { [self] in
                var image = sceneView.snapshot()
                count += 1
                captured = true
                let imageURL = url.appendingPathComponent(imageName)
                try? image.pngWrite(to: imageURL)
            }
        
        }else if(count > dataQuantity){
            data.append("]")
            let fileURL = url.appendingPathComponent("annotations.json")
            if (FileManager.default.createFile(atPath: fileURL.path, contents: data.data(using: .utf8), attributes: nil)) {
                print("File created successfully.")
            } else {
                print("File not created.")
            }
            
            exit(0)
        }
    }
    
    func randomBackground()->NSImage{
  
        var background:CIImage!
        let backgroundRect = CGRect(x: 0, y: 0, width: 300, height: 300)
        let backgroundType = Int.random(in: 1...2)
        var filtersCopy = filters!
        
        switch backgroundType {
        case 1:
            background = CIImage(color: randomCIColor()).cropped(to: backgroundRect)
            break
        case 2:
            let filter = CIFilter.checkerboardGenerator()
            filter.sharpness = Float.random(in: 0...1)
            filter.width = Float.random(in: 0...30)
            filter.color0 = randomCIColor()
            filter.color1 = randomCIColor()
            let output = filter.outputImage!.cropped(to: backgroundRect)
            background = output
            break
        default: break
        }
        
        for _ in 0...Int.random(in: 0..<6){
            let top = filtersCopy.count == 0 ? 0 : Int.random(in: 0..<filtersCopy.count)
            let filter = filtersCopy.remove(at: top)
            filter.setValue(background as CIImage, forKey: "inputImage")
            let output = filter.outputImage
            background = output
        }
        
        
        let rep = NSCIImageRep(ciImage: background.cropped(to: CGRect(x: 0, y: 0, width: 300, height: 300)))
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        
        return nsImage
    }
    
    func setupFilters(){
        
        let pointillizeFilter = CIFilter.pointillize()
        pointillizeFilter.radius = Float.random(in: 0...100)

        let triangleKaleidoscopeFilter = CIFilter.triangleKaleidoscope()
        triangleKaleidoscopeFilter.size = Float.random(in: 50...100)
        triangleKaleidoscopeFilter.decay = Float.random(in: 1...1.5)
        triangleKaleidoscopeFilter.rotation = Float.random(in: -Float.pi...Float.pi)
 
        let triangleTileFilter = CIFilter.triangleTile()
        triangleTileFilter.width = Float.random(in: 0...100)
        triangleTileFilter.angle = Float.random(in: -Float.pi...Float.pi)

        let circularScreenFilter = CIFilter.circularScreen()
        circularScreenFilter.width = Float.random(in: 0...100)
        circularScreenFilter.sharpness = Float.random(in: 0...1)
    
        let crystallizeFilter = CIFilter.crystallize()
        crystallizeFilter.radius = Float.random(in: 0...30)
    
        let hexagonalPixellateFilter = CIFilter.hexagonalPixellate()
        hexagonalPixellateFilter.scale = Float.random(in: 0...100)
        
        filters = [pointillizeFilter, triangleKaleidoscopeFilter, triangleTileFilter, circularScreenFilter, crystallizeFilter, hexagonalPixellateFilter]
    }
    
    func randomCIColor()->CIColor{
        let randomColor = CIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1)
        
        return randomColor
    }
}

extension CIImage {
    func resizeToSquareFilter(size: Float)->CIImage?{
        
        let resize = CIFilter.lanczosScaleTransform()
        resize.scale = size/Float(self.extent.height)
        resize.aspectRatio = size/(Float(self.extent.width)*resize.scale)
        resize.inputImage = self
        return resize.outputImage
        
    }
    
    func resizeToSquareAffineTransform(size: Double)->CIImage?{
        let scaleX = size/self.extent.width
        let scaleY = size/self.extent.height
        let image = self.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        return image
    }
}


