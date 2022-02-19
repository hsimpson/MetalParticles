//
//  ContentView.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 17.02.22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var statsObservable: StatsObservable
    @State var particleColor = Color(.sRGB, red: 1.0, green: 0.0, blue: 0.0)
    
    var renderer: Renderer
    
    @State var sliderValue = 0.5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Average frame time: \(statsObservable.frameTime*1000, specifier: "%.3f") ms")
            Text("FPS: \(1 / statsObservable.frameTime, specifier: "%.2f")")
            Text("Average compute time: \(statsObservable.computeTime*1000, specifier: "%.3f") ms")
            Spacer(minLength: 25)
            VStack {
                Text("Particle count:")
                Slider(value: $sliderValue).frame(width: 200)
            }
            ColorPicker("Particle color", selection: $particleColor).onChange(of: particleColor, perform: { newColor in
                renderer.updateColor(color: newColor.cgColor!)
            })
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .foregroundColor(.white)
        .font(.system(size: 18))
        .padding()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
