import Foundation
import Vision
import AppKit
import CoreImage

public struct DecodedBarcodePayload: Equatable, Codable, Hashable {
    public let payloadString: String
    public let symbology: String
    public let isURL: Bool
    public let isWiFi: Bool
    public let wifiSSID: String?
}

public enum BarcodeDetectorService {
    /// Detects QR codes, barcodes, Aztec, and DataMatrix on-device with Vision framework & CIDetector fallback
    public static func detectBarcodes(from imageData: Data, completion: @escaping (DecodedBarcodePayload?) -> Void) {
        guard let image = NSImage(data: imageData),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            // 1. Apple Vision Barcode Detector
            let request = VNDetectBarcodesRequest { request, error in
                if error == nil,
                   let results = request.results as? [VNBarcodeObservation],
                   let first = results.first,
                   let payload = first.payloadStringValue,
                   !payload.isEmpty {
                    
                    let symbologyName = first.symbology.rawValue
                    let isQR = symbologyName.localizedCaseInsensitiveContains("qr")
                    let isURL = payload.hasPrefix("http://") || payload.hasPrefix("https://")
                    let isWiFi = payload.hasPrefix("WIFI:")
                    var wifiSSID: String? = nil

                    if isWiFi {
                        let components = payload.replacingOccurrences(of: "WIFI:", with: "").components(separatedBy: ";")
                        for comp in components {
                            if comp.hasPrefix("S:") {
                                wifiSSID = String(comp.dropFirst(2))
                            }
                        }
                    }

                    let result = DecodedBarcodePayload(
                        payloadString: payload,
                        symbology: isQR ? "QR Code" : "Barcode",
                        isURL: isURL,
                        isWiFi: isWiFi,
                        wifiSSID: wifiSSID
                    )

                    DispatchQueue.main.async {
                        completion(result)
                    }
                    return
                }

                // 2. CoreImage Fallback Detector
                if let ciImage = CIImage(data: imageData) {
                    let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
                    if let features = detector?.features(in: ciImage) as? [CIQRCodeFeature],
                       let first = features.first,
                       let message = first.messageString,
                       !message.isEmpty {
                        
                        let isURL = message.hasPrefix("http://") || message.hasPrefix("https://")
                        let result = DecodedBarcodePayload(
                            payloadString: message,
                            symbology: "QR Code",
                            isURL: isURL,
                            isWiFi: message.hasPrefix("WIFI:"),
                            wifiSSID: nil
                        )
                        DispatchQueue.main.async {
                            completion(result)
                        }
                        return
                    }
                }

                DispatchQueue.main.async {
                    completion(nil)
                }
            }

            // Enable all barcode symbologies across 1D and 2D formats
            request.symbologies = [
                .qr, .code128, .code39, .code39Checksum, .code39FullASCII,
                .code93, .code93i, .ean13, .ean8, .upce, .aztec, .dataMatrix,
                .pdf417, .i2of5, .itf14, .codabar, .microQR, .microPDF417
            ]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}
