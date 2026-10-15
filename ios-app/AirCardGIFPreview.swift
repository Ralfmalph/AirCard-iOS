import SwiftUI
import ImageIO
import UIKit

/// UIImageView provides timed GIF frame playback; SwiftUI Image(uiImage:) does not.
struct AirCardGIFPreview: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ view: UIImageView, context: Context) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        let count = min(CGImageSourceGetCount(source), 180)
        var frames: [UIImage] = []
        var duration: TimeInterval = 0
        for i in 0..<count {
            guard let cg = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            let props = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
            let gif = props?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
            let delay = (gif?[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double)
                ?? (gif?[kCGImagePropertyGIFDelayTime as String] as? Double) ?? 0.1
            let clamped = max(0.02, delay)
            // UIImage animation uses uniform frame timing; duplicate for approximate delays.
            let repeats = min(50, max(1, Int((clamped / 0.05).rounded())))
            for _ in 0..<repeats { frames.append(UIImage(cgImage: cg)) }
            duration += Double(repeats) * 0.05
        }
        view.image = frames.first
        view.animationImages = frames
        view.animationDuration = duration
        view.animationRepeatCount = 0
        view.startAnimating()
    }
}
