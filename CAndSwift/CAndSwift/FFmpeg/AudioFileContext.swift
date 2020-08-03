import Foundation

///
/// Encapsulates a context for reading audio data / metadata from a single audio track using ffmpeg.
///
/// Instantiates, provides, and manages the life cycles of several member objects through which several ffmpeg functions can be executed.
///
class AudioFileContext {

    let file: URL
    
    let format: FormatContext

    let audioStream: AudioStream
    let audioCodec: AudioCodec
    
    var imageStream: ImageStream?
    let imageCodec: ImageCodec?
    
    init?(_ file: URL) {
        
        self.file = file
        
        guard let theFormatContext = FormatContext(file, [AVMEDIA_TYPE_AUDIO, AVMEDIA_TYPE_VIDEO]),
            let audioStream = theFormatContext.audioStream else {
                
            return nil
        }

        self.format = theFormatContext
        self.audioStream = audioStream
        self.audioCodec = audioStream.codec
        
        // Image stream, if present, will contain cover art.
        self.imageStream = theFormatContext.imageStream
        self.imageCodec = imageStream?.codec
    }
    
    private var destroyed: Bool = false
    
    func destroy() {
        
        if destroyed {return}

        audioCodec.destroy()
        imageCodec?.destroy()
        format.destroy()
        
        destroyed = true
    }

    deinit {
        destroy()
    }
}
