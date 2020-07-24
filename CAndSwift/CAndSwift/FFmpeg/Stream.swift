import Foundation
import ffmpeg

class Stream {
    
    var pointer: UnsafeMutablePointer<AVStream>
    let avStream: AVStream
    
    let mediaType: AVMediaType
    let index: Int32
    
    var codecPointer: UnsafeMutablePointer<AVCodec>
    var avCodec: AVCodec
    
    var codecContextPointer: UnsafeMutablePointer<AVCodecContext>
    var codec: Codec
    
    init(_ pointer: UnsafeMutablePointer<AVStream>, _ mediaType: AVMediaType) {
        
        self.pointer = pointer
        self.avStream = pointer.pointee
        
        self.mediaType = mediaType
        self.index = avStream.index
        
        self.codecPointer = avcodec_find_decoder(avStream.codecpar.pointee.codec_id)
        self.avCodec = codecPointer.pointee
        
        self.codecContextPointer = avcodec_alloc_context3(codecPointer)
        avcodec_parameters_to_context(codecContextPointer, avStream.codecpar)
        
        switch mediaType {
            
        case AVMEDIA_TYPE_AUDIO:
            
            self.codec = AudioCodec(pointer: codecPointer, contextPointer: codecContextPointer)
            
        case AVMEDIA_TYPE_VIDEO:
            
            self.codec = ImageCodec(pointer: codecPointer, contextPointer: codecContextPointer)
            
        default:
            
            self.codec = Codec(pointer: codecPointer, contextPointer: codecContextPointer)
        }
    }
    
    func printInfo() {
        
        print("\n---------- Stream Info ----------\n")
        
        print(String(format: "Index:   %7d", index))
        
        print("---------------------------------\n")
    }
}

class AudioStream: Stream {
    
    var duration: Double {Double(avStream.duration) * avStream.time_base.ratio}
    
    init(_ pointer: UnsafeMutablePointer<AVStream>) {
        super.init(pointer, AVMEDIA_TYPE_AUDIO)
    }
    
    override func printInfo() {
        
        print("\n---------- Stream Info ----------\n")
        
        print(String(format: "Index:   %7d", index))
        print(String(format: "Duration: %7.2lf", duration))
        
        print("---------------------------------\n")
    }
}

class ImageStream: Stream {
    
    init(_ pointer: UnsafeMutablePointer<AVStream>) {
        super.init(pointer, AVMEDIA_TYPE_VIDEO)
    }
}
