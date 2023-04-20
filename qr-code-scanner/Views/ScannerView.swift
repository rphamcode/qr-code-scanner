//
//  ScannerView.swift
//  qr-code-scanner
//
//  Created by Pham on 4/20/23.
//

import SwiftUI
import AVKit

struct ScannerView: View {
      @State private var isScanning: Bool = false
      @State private var session: AVCaptureSession = .init()
      @State private var cameraPermission: CameraPermission = .idle
      
      @State private var qrOutput: AVCaptureMetadataOutput = .init()
      
      @State private var errorMessage: String = ""
      @State private var showError: Bool = false
      @Environment(\.openURL) private var openURL
      
      @StateObject private var qrDelegate = ScannerDelegate()
      
      @State private var scannedCode: String = ""
      
      @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
      
    var body: some View {
          VStack(spacing: 8) {
                Button {
                      // button functions
                } label: {
                      Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(Color("DarkBlue"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Please place the QR code inside the area")
                      .font(.title3)
                      .foregroundColor(.black.opacity(0.8))
                      .padding(.top, 20)
                
                Text("Scanning will start automatically")
                      .font(.callout)
                      .foregroundColor(.gray)
                
                Spacer(minLength: 0)
                
                GeometryReader {
                      let size = $0.size
                      let squareWidth = min(size.width, 300)
                      
                      ZStack {
                            CameraView(frameSize: CGSize(width: squareWidth, height: squareWidth), orientation: $orientation, session: $session)
                                  .cornerRadius(5)
                                  .scaleEffect(0.97)
                                  .onRotate {
                                        if session.isRunning {
                                              orientation = $0
                                        }
                                  }
                            
                            ForEach(0...4, id: \.self) { index in
                                  let rotation = Double(index) * 90
                                  
                                  RoundedRectangle(cornerRadius: 2, style: .circular)
                                        .trim(from: 0.61, to: 0.64)
                                        .stroke(Color("DarkBlue"), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                        .rotationEffect(.init(degrees: rotation))
                            }
                      }
                      .frame(width: squareWidth, height: squareWidth)
                      .overlay(alignment: .top) {
                            Rectangle()
                                  .fill(Color("DarkBlue"))
                                  .frame(height: 2.5)
                                  .shadow(color: .black.opacity(0.8), radius: 8, x: 0, y: isScanning ? 15 : -15)
                                  .offset(y: isScanning ? squareWidth : 0)
                      }
                      .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 45)
                
                Spacer(minLength: 15)
                
                Button {
                      if !session.isRunning && cameraPermission == .approved {
                            reactivateCamera()
                            activateScannerAnimation()
                      }
                } label: {
                      Image(systemName: "qrcode.viewfinder")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                }
                
                Spacer(minLength: 45)
          }
          .padding(15)
          .onAppear(perform: checkCameraPermission)
          .onDisappear {
                session.stopRunning()
          }
          .alert(errorMessage, isPresented: $showError) {
                if cameraPermission == .denied {
                      Button("Settings") {
                            let settingsString = UIApplication.openSettingsURLString
                            if let settingsURL = URL(string: settingsString) {
                                  openURL(settingsURL)
                            }
                      }
                      
                      Button("Cancel", role: .cancel) {
                      }
                }
          }
          .onChange(of: qrDelegate.scannedCode) { newValue in
                if let code = newValue {
                      scannedCode = code
                      session.stopRunning()
                      deActivateScannerAnimation()
                      qrDelegate.scannedCode = nil
                      presentError(scannedCode)
                }
          }
          .onChange(of: session.isRunning) { newValue in
                if newValue {
                      orientation = UIDevice.current.orientation
                }
          }
    }
      
      func reactivateCamera() {
            DispatchQueue.global(qos: .background).async {
                  session.startRunning()
            }
      }
      
      func activateScannerAnimation() {
            withAnimation(.easeInOut(duration: 0.8)) {
                  isScanning = false
            }
      }
      
      func deActivateScannerAnimation() {
            withAnimation(.easeInOut(duration: 0.85)) {
                  isScanning = false
            }
      }
      
      func checkCameraPermission() {
            Task {
                  switch AVCaptureDevice.authorizationStatus(for: .video) {
                        case .authorized:
                              cameraPermission = .approved
                              
                              if session.inputs.isEmpty {
                                    setupCamera()
                              } else {
                                    reactivateCamera()
                              }
                              
                        case .notDetermined:
                              if await AVCaptureDevice.requestAccess(for: .video) {
                                    cameraPermission = .approved
                                    setupCamera()
                              } else {
                                    cameraPermission = .denied
                                    presentError("Please Provide Access to Camera for scanning codes")
                              }
                              
                        case .denied, .restricted:
                              cameraPermission = .denied
                              presentError("Please Provide Access to Camera for scanning codes")
                              
                        default: break
                  }
            }
      }
      
      func setupCamera() {
            do {
                  guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
                        presentError("UNKNOWN DEVICE ERROR")
                        return
                  }
                  
                  let input = try AVCaptureDeviceInput(device: device)
                  guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
                        presentError("UNKNOWN INPUT/OUTPUT ERROR")
                        return
                  }
                  
                  session.beginConfiguration()
                  session.addInput(input)
                  session.addOutput(qrOutput)
                  
                  qrOutput.metadataObjectTypes = [.qr]
                  qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
                  session.commitConfiguration()
                   
                  DispatchQueue.global(qos: .background).async {
                        session.startRunning()
                  }
                  activateScannerAnimation()
            } catch {
                  presentError(error.localizedDescription)
            }
      }
      
      func presentError(_ message: String) {
            errorMessage = message
            showError.toggle()
      }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
