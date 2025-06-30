//
//  Texture.swift
//  Babii
//
//  Created by Matthew Reed on 4/22/25.
//

import MetalKit

class TextureLoader {
    static let shared = TextureLoader()
    var textures = [String: MTLTexture]()
    
    func loadTexture(name: String, device: MTLDevice) -> MTLTexture? {
        if let texture = textures[name] {
            return texture
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        let texture = try? textureLoader.newTexture(name: name, scaleFactor: 1.0, bundle: .main)
        if texture != nil {
            textures[name] = texture
        }
        return texture
    }
    
    func loadTexture(texture: MDLTexture, name: String, device: MTLDevice) -> MTLTexture? {
      if let texture = textures[name] {
        return texture
      }
      let textureLoader = MTKTextureLoader(device: device)
      let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
        [.origin: MTKTextureLoader.Origin.bottomLeft,
         .generateMipmaps: true]
      let texture = try? textureLoader.newTexture(
        texture: texture,
        options: textureLoaderOptions)
      print("loaded texture from USD file", name)
      textures[name] = texture
      return texture
    }
    
    func loadCubeTexture(imageName: String, device: MTLDevice) -> MTLTexture? {
      let textureLoader = MTKTextureLoader(device: device)
      // asset catalog loading
      if let texture = MDLTexture(cubeWithImagesNamed: [imageName]) {
        let options: [MTKTextureLoader.Option: Any] = [
          .origin: MTKTextureLoader.Origin.topLeft,
          .SRGB: false,
          .generateMipmaps: false
        ]
        return try? textureLoader.newTexture(
          texture: texture,
          options: options)
      }
      // bundle file loading
      let texture = try? textureLoader.newTexture(
        name: imageName,
        scaleFactor: 1.0,
        bundle: .main)
      return texture
    }
}
