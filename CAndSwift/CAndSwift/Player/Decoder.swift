import Foundation

class Decoder {
    
    private var file: AudioFileContext!
    
    var eof: Bool = false
    
    private var format: FormatContext! {file.format}
    private var stream: AudioStream! {file.audioStream}
    private var codec: AudioCodec! {file.audioCodec}
    
    func initialize(with file: AudioFileContext) throws {
        
        self.file = file
        self.frameQueue.clear()
        self.eof = false
        
        try codec.open()
        print("\nSuccessfully opened file: \(file.file.path). File is ready for decoding.")
        
        file.audioStream.printInfo()
        file.audioCodec.printInfo()
    }
    
    func decode(_ maxSampleCount: Int32) throws -> SamplesBuffer {
        
        let buffer: SamplesBuffer = SamplesBuffer(sampleFormat: codec.sampleFormat, maxSampleCount: maxSampleCount)
        
        while !eof {
            
            do {
                
                let frame = try nextFrame()
                
                if buffer.appendFrame(frame: frame) {
                    
                    _ = frameQueue.dequeue()
                    
                } else {    // Buffer is full, stop filling it.
                    break
                }
                
            } catch let packetReadError as PacketReadError {
                
                self.eof = packetReadError.isEOF
//                if !eof {throw DecoderError(packetReadError.code)}
                
            } catch let decError as DecoderError {
                
                print("\nDecError:", decError)
            }
        }
        
        return buffer
    }
    
    func seekToTime(_ seconds: Double) throws {
        
        print("\nDecoder-seeking ... seconds: \(seconds)")
        
        do {
            
            try format.seekWithinStream(stream, seconds)
            self.eof = false
            
        } catch let seekError as SeekError {
            
            self.eof = seekError.isEOF
            if !eof {throw DecoderError(seekError.code)}
        }
    }
    
    private var frameQueue: Queue<BufferedFrame> = Queue<BufferedFrame>()
    
    private func nextFrame() throws -> BufferedFrame {
        
        while frameQueue.isEmpty {
        
            if let packet = try format.readPacket(stream) {
                
                for frame in try codec.decode(packet) {
                    frameQueue.enqueue(frame)
                }
            }
        }
        
        return frameQueue.peek()!
    }
    
    func stop() {
        frameQueue.clear()
    }
}
