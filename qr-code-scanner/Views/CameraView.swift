//
//  CameraView.swift
//  qr-code-scanner
//
//  Created by Pham on 4/20/23.
//

import SwiftUI
import AVKit

struct CameraView: UIViewRepresentable {
      var frameSize: CGSize
      
      @Binding var orientation: UIDeviceOrientation
      @Binding var session: AVCaptureSession
      
      func makeUIView(context: Context) -> UIView {
            let view = UIViewType(frame: CGRect(origin: .zero, size: frameSize))
            view.backgroundColor = .clear
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
            cameraLayer.frame = .init(origin: .zero, size: frameSize)
            cameraLayer.videoGravity = .resizeAspectFill
            cameraLayer.masksToBounds = true
            
            view.layer.addSublayer(cameraLayer)
            
            return view
      }
      
      func updateUIView(_ uiView: UIView, context: Context) {
            if let layer = uiView.layer.sublayers?.first(where: { layer in
                  layer is AVCaptureVideoPreviewLayer
            }) as? AVCaptureVideoPreviewLayer {
                  switch orientation {
                        case .portrait: layer.setAffineTransform(.init(rotationAngle: 0))
                        case .landscapeLeft: layer.setAffineTransform(.init(rotationAngle: -.pi / 2))
                        case .landscapeRight: layer.setAffineTransform(.init(rotationAngle: .pi / 2))
                        case .portraitUpsideDown: layer.setAffineTransform(.init(rotationAngle: .pi))
                        default: break
                  }
            }
      }
}
