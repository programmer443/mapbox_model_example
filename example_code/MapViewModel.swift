//
//  MapViewModel.swift
//  example_code
//
//  Created by M Ahmad on 09/05/2024.
//

import Foundation
import Combine
@_spi(Experimental) import MapboxMaps

class MapViewModel: ObservableObject {
    
    @Published var mapProxy: MapProxy?
    @Published var cameraZoom: CGFloat = 12
    @Published var cameraPitch: CGFloat = 0
    @Published var cameraBearing: CGFloat = 186.0
    @Published var latitude: CGFloat = 42.97330
    @Published var longitude: CGFloat = -75.085930
    @Published var altitude: Double = 9753.60
    @Published var heading: Double = 180.0
    
    
    // MARK: - Render Terrain
    
    func addTerrainLayer(_ mapboxMap: MapboxMap) {
        var demSource = RasterDemSource(id: "mapbox-dem")
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        demSource.tileSize = 514
        demSource.maxzoom = 18.0
        try! mapboxMap.addSource(demSource)
        
        var terrain = Terrain(sourceId: demSource.id)
        terrain.exaggeration = .constant(1.5)
        
        do {
            try mapboxMap.setTerrain(terrain)
        } catch {
            print("Failed to add a terrain layer to the map's style.")
        }
    }
    
    
    // MARK: - Render 3D Model
    
    func setup3DModel() {
        updateCameraPosition(alt: self.altitude, lat: self.latitude, lng: self.longitude, head: self.heading)

        
        let plane = Bundle.main.url(
            forResource: "A320",
            withExtension: "glb")!.absoluteString
        var source = GeoJSONSource(id: "source-id")
        source.maxzoom = 4
        try? mapProxy?.map!.addStyleModel(modelId: "model-id-plane", modelUri: plane)
        var planeFeature = Feature(geometry: Point(CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)))
        planeFeature.properties = ["model-id-key": .string("model-id-plane")]
        source.data = .featureCollection(FeatureCollection(features: [planeFeature]))
        try? mapProxy?.map!.addSource(source)
        var layer = ModelLayer(id: "model-layer-id", source: "source-id")
        layer.modelId = .expression(Exp(.get) { "model-id-key" })
        layer.modelType = .constant(.common3d)
        layer.modelScale = .constant([1, 1, 1])
        layer.modelTranslation = .constant([0, 0,  self.altitude])
        layer.modelRotation = .constant([0, 0, 90])
        layer.maxZoom = 23
        layer.minZoom = 5
        layer.modelCutoffFadeRange = .constant(0.0)
        try? mapProxy?.map!.addLayer(layer)

    }
    
    
    // for checing camera focus
    private func addMarkerAnnotation(lat: Double, lon: Double) {
        try? mapProxy?.map!.addImage(UIImage(named: "pin")!, id: "red")
        
        var source = GeoJSONSource(id: "source_id")
        source.data = .geometry(Geometry.point(Point(CLLocationCoordinate2D(latitude: lat, longitude: lon))))
        try? mapProxy?.map!.addSource(source)
        
        var layer = SymbolLayer(id: "layer_id", source: "source_id")
        layer.iconImage = .constant(.name("red"))
        layer.iconAnchor = .constant(.bottom)
        layer.iconOffset = .constant([0, 12])
        try? mapProxy?.map!.addLayer(layer)
        
    }
    
    func setMapProxy(_ proxy: MapProxy) {
        self.mapProxy = proxy
    }
    
    
    // MARK: - MoveCamera along with Model
    
    func updateCameraPosition(alt: Double, lat: Double, lng: Double, head: Double, pitch: Double = 0) {
        addMarkerAnnotation(lat: self.latitude, lon: self.longitude)
        let freeCam = self.mapProxy?.map?.freeCameraOptions
        // convert to from hundreds of feet to meters
        freeCam?.altitude = alt
        freeCam?.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        freeCam?.setPitchBearingForPitch(pitch, bearing: head)
        mapProxy?.map?.freeCameraOptions = freeCam!
    }
}

