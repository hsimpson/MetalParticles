//
//  ViewController.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 24.01.22.
//

import Cocoa
import Metal
import MetalKit
import SwiftUI
import Combine

class ViewController: NSViewController {
    
    var mtkView: MTKView!
    var renderer: Renderer!
    let statsObservable = StatsObservable()
    var contentView: NSHostingController<ContentView>!
      
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
        
        var tempRenderer: Renderer
        do {
            try tempRenderer = Renderer(mtkView: mtkView, statsObservable: statsObservable)!
        } catch {
            print("Render failed to initalize")
            return
        }
        
        renderer = tempRenderer
        
        contentView = NSHostingController(rootView: ContentView(statsObservable: statsObservable, renderer: renderer))
        
        
        mtkView.delegate = renderer
        mtkView.preferredFramesPerSecond = 120
        
        view.frame.size.width = 1280
        view.frame.size.height = 720
        mtkView.frame.size.width = 1280
        mtkView.frame.size.height = 720
        
        addChild(contentView)
        view.addSubview(contentView.view)
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo:view.topAnchor).isActive = true
        //contentView.view.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true
        //contentView.view.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        //contentView.view.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
        
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

