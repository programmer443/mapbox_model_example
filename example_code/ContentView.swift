//
//  ExampleMapModel.swift
//  example_code
//
//  Created by M Ahmad on 09/05/2024.
//

import SwiftUI
@_spi(Experimental) import MapboxMaps


struct ExampleMapModel: View {
    @StateObject var mapVM = MapViewModel()
    
    var body: some View {
        ZStack {
            MapReader { proxy in
                Map()
                .onMapLoaded { _ in mapLoaded(proxy) }
                .mapStyle(.satelliteStreets)
            }
        }
        .ignoresSafeArea()
    }
    
    private func mapLoaded(_ proxy: MapProxy) {
        mapVM.setMapProxy(proxy)
        mapVM.addTerrainLayer(proxy.map!)
        mapVM.setup3DModel()
    }

}

#Preview {
    ExampleMapModel()
}
