/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view to display the plane, sine wave, terrain, and water examples.
*/

import SwiftUI
import RealityKit

struct HeightMapMeshView: View {
    /// The dimensions of the plane mesh.
    private let meshDimensions = SIMD2<UInt32>(512, 512)
    /// The size of the plane mesh.
    private let meshSize = SIMD2<Float>(1, 1)
    
    /// The entity that contains the scene.
    private var sceneContainer: Entity = Entity()
    /// The entity that contains the default plane mesh.
    private let defaultPlaneContainer: Entity = Entity()
    /// The height map mesh entity.
    private let heightMapMeshEntity: HeightMapMeshEntity
    
    private let sineWaveMaterial: SimpleMaterial = SimpleMaterial(color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), roughness: 0.85, isMetallic: false)
    private let terrainMaterial: SimpleMaterial = SimpleMaterial(color: #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1), roughness: 0.25, isMetallic: false)
    private let waterMaterial: SimpleMaterial = SimpleMaterial(color: #colorLiteral(red: 0, green: 0.8260448575, blue: 0.960488379, alpha: 1), roughness: 0.05, isMetallic: false)
    
    private let sineWaveHeightMapGenerator: HeightMapGenerator = SineWaveHeightMapGenerator()
    private let terrainHeightMapGenerator: HeightMapGenerator = TerrainHeightMapGenerator()
    private let waterHeightMapGenerator: HeightMapGenerator = WaterSurfaceHeightMapGenerator()

    init() {
        // Register the compute dispatch system.
        ComputeDispatchSystem.registerSystem()
        // Create the height map mesh entity.
        heightMapMeshEntity = HeightMapMeshEntity(size: meshSize, dimensions: meshDimensions, maxVertexDepth: 1)
    }
    
    /// Sets the height map generator and material that the `heightMapMeshEntity` uses.
    private func setHeightMapGenerator(heightMapGenerator: HeightMapGenerator, material: SimpleMaterial) {
        heightMapGenerator.reset()
        heightMapMeshEntity.heightMapMesh?.heightMap.heightMapGenerator = heightMapGenerator
        heightMapMeshEntity.model?.materials = [material]
    }

    #if os(visionOS)
    @Environment(\.physicalMetrics) var physicalMetrics
    #endif

    enum Generator: String, CaseIterable, Identifiable {
        var id: String { rawValue }

        /// Default plane.
        case plane = "Plane"

        /// Sine wave height map.
        case sine = "Sine"

        /// Terrain height map.
        case terrain = "Terrain"

        /// Water simulation height map.
        case water = "Water"

        var displayName: String { rawValue }
    }

    @State var generator: Generator = .plane

    var generatorPicker: some View {
        Picker("Generator", selection: $generator) {
            ForEach(Generator.allCases) { generator in
                Text(generator.displayName).tag(generator)
            }
        }.pickerStyle(.segmented)
        .onChange(of: generator) { oldValue, newValue in
            // Show the plane entity and hide the height map mesh entity when the person selects the plane generator.
            // Otherwise, hide the plane entity and show the height map mesh entity.
            let isDefaultPlaneSelected = newValue == .plane
            defaultPlaneContainer.isEnabled = isDefaultPlaneSelected
            heightMapMeshEntity.isEnabled = !isDefaultPlaneSelected
            
            // Set the current height map generator.
            switch newValue {
                case .sine:
                    setHeightMapGenerator(heightMapGenerator: sineWaveHeightMapGenerator, material: sineWaveMaterial)
                case .terrain:
                    setHeightMapGenerator(heightMapGenerator: terrainHeightMapGenerator, material: terrainMaterial)
                case .water:
                    setHeightMapGenerator(heightMapGenerator: waterHeightMapGenerator, material: waterMaterial)
                case .plane:
                    break
            }
        }
    }
    
    // Creates the scene the `RealityView` renders.
    func createScene() -> Entity {
        // Create a scene entity.
        let scene = Entity()
        
        // Create the default plane mesh.
        if let planeMesh = try? PlaneMesh(size: meshSize, dimensions: meshDimensions),
           let mesh = try? MeshResource(from: planeMesh.mesh) {
            
            // Create an entity with the plane mesh.
            let planeEntity = Entity()
            let planeModel = ModelComponent(mesh: mesh, materials: [SimpleMaterial()])
            planeEntity.components.set(planeModel)
            
            // Add the entity to the scene.
            defaultPlaneContainer.addChild(planeEntity)
            scene.addChild(defaultPlaneContainer)
        }
        
        // Start with the water surface height map generator.
        generator = .water

        // Add the height map mesh entity to the scene.
        scene.addChild(heightMapMeshEntity)
        
        // Rotate the scene to position the planes in xz-plane instead of the xy-plane.
        scene.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])

        return scene
    }

    var body: some View {
        #if os(visionOS)
        GeometryReader3D { geometry in
            RealityView { content in
                // Create the scene.
                let scene = createScene()
                // Position it just above the toolbar of the volume.
                scene.position.y = -0.425
                // Add it to the reality view.
                sceneContainer.addChild(scene)
                content.add(sceneContainer)
            }
            update: { content in
                // Resize the scene container to match the current size of the volume.
                sceneContainer.scale = .init(physicalMetrics.convert(geometry.size, to: .meters))
            }
            .gesture(
                DragGesture()
                    .targetedToEntity(heightMapMeshEntity)
                    .onChanged({ value in
                        let interactionPosition = value.convert(value.location3D,
                                                                from: .local,
                                                                to: heightMapMeshEntity)
                        heightMapMeshEntity.heightMapMesh?.interactionPosition = interactionPosition
                        heightMapMeshEntity.heightMapMesh?.isInteractionHappening = true
                    })
                    .onEnded({ value in
                        heightMapMeshEntity.heightMapMesh?.isInteractionHappening = false
                    })
            )
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    generatorPicker
                }
            }
        }
        #else
        VStack {
            RealityView { content in
                content.add(createScene())
                content.cameraTarget = heightMapMeshEntity
            }.realityViewCameraControls(.orbit)
            generatorPicker
                .padding()
        }
        #endif
    }
}
