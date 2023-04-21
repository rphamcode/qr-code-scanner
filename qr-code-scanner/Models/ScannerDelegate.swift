//
//  ScannerDelegate.swift
//  qr-code-scanner
//
//  Created by Pham on 4/20/23.
//

import Foundation
import AVKit

class ScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
      @Published var scannedCode: String?
      
      func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metaObject = metadataObjects.first {
                  guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else { return }
                  guard let Code = readableObject.stringValue else { return }
                  
                  scannedCode = Code
                  
                  AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
      }
}
