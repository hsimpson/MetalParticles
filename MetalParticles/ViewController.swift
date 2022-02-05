//
//  ViewController.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

import Cocoa
import Metal
import MetalKit

class ViewController: NSViewController {
    
    var mtkView: MTKView!
    var renderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mtkViewTemp = self.view as? MTKView else {
            print("View attached to ViewController is not an MTKView!")
            return
        }
        mtkView = mtkViewTemp
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        print("My GPU is: \(defaultDevice)")
        mtkView.device = defaultDevice
        
        guard let tempRenderer = Renderer(mtkView: mtkView) else {
            print("Render failed to initalize")
            return
        }
        renderer = tempRenderer
        mtkView.delegate = renderer
        
        mtkView.frame.size.width = 1280
        mtkView.frame.size.height = 720
        
        // Set a block that fires when a key is pressed
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            (keyEvent) -> NSEvent? in
            if self.keyDown(with: keyEvent) {
                return nil
            } else {
                return keyEvent
            }
        }
        
        // Set a block that fires when a key is released
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) {
            (keyEvent) -> NSEvent? in
            if self.keyUp(with: keyEvent) {
                return nil
            } else {
                return keyEvent
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        renderer.scrollWheel(with: event)
    }
    
    func keyDown(with event: NSEvent) -> Bool {
        renderer.keyDown(with: event)
        return true;
    }
    
    func keyUp(with event: NSEvent) -> Bool {
        renderer.keyUp(with: event)
        return true;
    }
    
    override func mouseDragged(with event: NSEvent) {
        renderer.mouseDragged(with: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        renderer.mouseDown(with: event)
    }
    
}

