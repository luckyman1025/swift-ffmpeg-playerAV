import Foundation

class AudioFileContext {
    
    let file: URL
    
    let format: FormatContext

    let audioStream: AudioStream
    let audioCodec: AudioCodec
    
    var imageStream: ImageStream?
    let imageCodec: ImageCodec?
    
    init?(_ file: URL) {
        
        self.file = file
        
        guard let theFormatContext = FormatContext(file), let audioStream = theFormatContext.audioStream, let theCodec = audioStream.codec as? AudioCodec else {
            return nil
        }

        self.format = theFormatContext
        self.audioStream = audioStream
        self.audioCodec = theCodec
        
        // Image stream, if present, will contain cover art.
        self.imageStream = theFormatContext.imageStream
        self.imageCodec = imageStream?.codec as? ImageCodec
    }
    
    func destroy() {
        
        audioCodec.destroy()
        format.destroy()
    }
    
    deinit {
        destroy()
    }
}
