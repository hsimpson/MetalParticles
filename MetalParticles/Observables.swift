//
//  Observables.swift
//  MetalParticles
//
//  Created by Daniel Toplak on 18.02.22.
//

import Foundation
import SwiftUI

class StatsObservable: ObservableObject {
    @Published var frameTime: Double = 0.0
    @Published var computeTime: Double = 0.0
}
