import Foundation

class Codec {
    
    var pointer: UnsafeMutablePointer<AVCodec>
    let avCodec: AVCodec
    
    var contextPointer: UnsafeMutablePointer<AVCodecContext>?
    let context: AVCodecContext
    
    var id: UInt32 {avCodec.id.rawValue}
    var name: String {String(cString: avCodec.name)}
    var longName: String {String(cString: avCodec.long_name)}
    
    init(pointer: UnsafeMutablePointer<AVCodec>, contextPointer: UnsafeMutablePointer<AVCodecContext>) {
        
        self.pointer = pointer
        self.avCodec = pointer.pointee
        
        self.contextPointer = contextPointer
        self.context = contextPointer.pointee
    }
    
    func open() -> Bool {
        
        let codecOpenResult: ResultCode = avcodec_open2(contextPointer, pointer, nil)
        if codecOpenResult != 0 {
            print("\nCodec.open(): Failed to open codec '\(name)'. Error: \(codecOpenResult.errorDescription))")
        }
        
        return codecOpenResult == 0
    }
    
    private var destroyed: Bool = false
    
    func destroy() {
        
        if destroyed {return}
        
        // TODO: This crashes when the context has already been automatically destroyed (after playback completion)
        // Can we check something before proceeding ???
        
        if 0 < avcodec_is_open(self.contextPointer) {
            avcodec_close(self.contextPointer)
        }
        
        avcodec_free_context(&self.contextPointer)
        
        destroyed = true
    }
    
    deinit {
        destroy()
    }
}

class AudioCodec: Codec {
    
    var bitRate: Int64 = 0
    var sampleRate: Int32 = 0
    var sampleFormat: SampleFormat = SampleFormat(avFormat: AVSampleFormat(0))
    var channelCount: Int = 0
    
    override init(pointer: UnsafeMutablePointer<AVCodec>, contextPointer: UnsafeMutablePointer<AVCodecContext>) {
        
        super.init(pointer: pointer, contextPointer: contextPointer)
        
        self.bitRate = context.bit_rate
        self.sampleRate = context.sample_rate
        self.sampleFormat = SampleFormat(avFormat: context.sample_fmt)
        self.channelCount = Int(context.channels)
    }
    
    func printInfo() {
        
        print("\n---------- Codec Info ----------\n")
        
        print(String(format: "Sample Rate:   %7d", sampleRate))
        print(String(format: "Sample Format: %7@", sampleFormat.name))
        print(String(format: "Sample Size:   %7d", sampleFormat.size))
        print(String(format: "Channels:      %7d", channelCount))
        print(String(format: "Planar ?:      %7@", String(sampleFormat.isPlanar)))
        
        print("---------------------------------\n")
    }
    
    func decode(_ packet: Packet) throws -> [Frame] {
        
        // Send the packet to the decoder
        var resultCode: ResultCode = avcodec_send_packet(contextPointer, packet.pointer)
        packet.destroy()

        if resultCode < 0 {
            
            print("\nCodec.decode(): Failed to decode packet. Error: \(resultCode.description))")
            throw DecoderError(resultCode)
        }
        
        // Receive (potentially) multiple frames

        var frames: [Frame] = []
        var avFrame = AVFrame()
        
        resultCode = avcodec_receive_frame(contextPointer, &avFrame)

        // Keep receiving frames while no errors are encountered
        while resultCode == 0, avFrame.nb_samples > 0 {
            
            frames.append(Frame(&avFrame, sampleFormat: sampleFormat))
            resultCode = avcodec_receive_frame(contextPointer, &avFrame)
        }
        
        av_frame_unref(&avFrame)
        
        return frames
    }
}

class ImageCodec: Codec {

    func decode(_ packet: Packet) -> Data? {
        
        let avPacket = packet.avPacket
        
        if let theData = avPacket.data, avPacket.size > 0 {
            return Data(bytes: theData, count: Int(avPacket.size))
        }
        
        return nil
    }
}
