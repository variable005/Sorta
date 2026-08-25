import Foundation
import Vision
import AppKit

public struct DecodedBarcodePayload: Equatable, Codable, Hashable {
    public let payloadString: String
    public let symbology: String
    public let isURL: Bool
    public let isWiFi: Bool
    public let wifiSSID: String?
}

public enum BarcodeDetectorService {
    /// Detects QR codes, barcodes, Aztec, and DataMatrix on-device with Vision framework
    public static func detectBarcodes(from imageData: Data, completion: @escaping (DecodedBarcodePayload?) -> Void) {
        guard let image = NSImage(data: imageData),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNDetectBarcodesRequest { request, error in
                guard error == nil,
                      let results = request.results as? [VNBarcodeObservation],
                      let first = results.first,
                      let payload = first.payloadStringValue,
                      !payload.isEmpty else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }

                let symbologyName = first.symbology.rawValue
                let isQR = symbologyName.localizedCaseInsensitiveContains("qr")
                let isURL = payload.hasPrefix("http://") || payload.hasPrefix("https://")
                let isWiFi = payload.hasPrefix("WIFI:")
                var wifiSSID: String? = nil

                if isWiFi {
                    // Format: WIFI:S:MySSID;T:WPA;P:MyPassword;;
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
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}
