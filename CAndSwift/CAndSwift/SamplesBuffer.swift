import AVFoundation
import Accelerate
import ffmpeg

class SamplesBuffer {
    
    var frames: [Frame] = []
    var floats: [Float] = []
    
    var sampleCount: Int32 = 0
    let maxSampleCount: Int32
    
    let sampleSize: Int
    let sampleFmt: AVSampleFormat
    
    var isFull: Bool {sampleCount >= maxSampleCount}
    
    init(maxSampleCount: Int32, sampleFmt: AVSampleFormat, sampleSize: Int) {
        
        self.maxSampleCount = maxSampleCount
        self.sampleFmt = sampleFmt
        self.sampleSize = sampleSize
    }
    
    func appendFrame(frame: Frame) {
        
        self.sampleCount += frame.sampleCount
        frames.append(frame)
    }
    
    func constructAudioBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {

        guard sampleCount > 0 else {return nil}
        
        if let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(sampleCount)) {
            
            let numChannels = Int(format.channelCount)
            
            buffer.frameLength = buffer.frameCapacity
            let channels = buffer.floatChannelData
            
            var sampleCountSoFar: Int = 0
            
            for frame in frames {
                
                let frameFloatData: [[Float]] = frame.dataAsFloatPlanar
            
                for channelIndex in 0..<numChannels {
                    
                    guard let channel = channels?[channelIndex] else {break}
                    let frameFloatsForChannel: [Float] = frameFloatData[channelIndex]
                    
                    cblas_scopy(frame.sampleCount, frameFloatsForChannel, 1, channel.advanced(by: sampleCountSoFar), 1)
                }
                
                sampleCountSoFar += Int(frame.sampleCount)
            }
            
            return buffer
        }
        
        return nil
    }
    
//    func constructAudioBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
//
//        guard sampleCount > 0 else {return nil}
//
//        if let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(sampleCount)) {
//
//            let numChannels = Int(format.channelCount)
//
//            buffer.frameLength = buffer.frameCapacity
//            let channels = buffer.floatChannelData
//
//            var sampleCountSoFar: Int32 = 0
//
//            for frame in frames {
//
//                let frameSampleCount = Int(frame.sampleCount)
//                let dataPointers = frame.byteArrayPointers
//
//                for channelIndex in 0..<numChannels {
//
//                    let bytesForChannel = dataPointers[channelIndex]
//                    guard let channel = channels?[channelIndex] else {break}
//
//                    switch sampleFmt {
//
//                    // Integer => scale to [-1, 1] and convert to Float.
//                    case AV_SAMPLE_FMT_U8, AV_SAMPLE_FMT_S16, AV_SAMPLE_FMT_S32, AV_SAMPLE_FMT_U8P, AV_SAMPLE_FMT_S16P, AV_SAMPLE_FMT_S32P:
//
//                        let frameFloatsForChannel: [Float]
//
//                        switch sampleSize {
//
//                        case 1:
//
//                            // Subtract 127 to make the unsigned byte signed (8-bit samples are always unsigned)
//                            let reboundData: UnsafePointer<Int8> = bytesForChannel.withMemoryRebound(to: Int8.self, capacity: frameSampleCount){$0}
//                            frameFloatsForChannel = (0..<frameSampleCount).map {Float(reboundData[$0] - 127) / max8BitFloatVal}
//
//                        case 2:
//
//                            let reboundData: UnsafePointer<Int16> = bytesForChannel.withMemoryRebound(to: Int16.self, capacity: frameSampleCount){$0}
//                            frameFloatsForChannel = (0..<frameSampleCount).map {Float(reboundData[$0]) / max16BitFloatVal}
//
//                        case 4:
//
//                            let reboundData: UnsafePointer<Int32> = bytesForChannel.withMemoryRebound(to: Int32.self, capacity: frameSampleCount){$0}
//                            frameFloatsForChannel = (0..<frameSampleCount).map {Float(reboundData[$0]) / max32BitFloatVal}
//
//                        case 8:
//
//                            let reboundData: UnsafePointer<Int64> = bytesForChannel.withMemoryRebound(to: Int64.self, capacity: frameSampleCount){$0}
//                            frameFloatsForChannel = (0..<frameSampleCount).map {Float(Double(reboundData[$0]) / max64BitDoubleVal)}
//
//                        default: continue
//
//                        }
//
//                        cblas_scopy(frame.sampleCount, frameFloatsForChannel, 1, channel.advanced(by: Int(sampleCountSoFar)), 1)
//
//                    case AV_SAMPLE_FMT_FLT, AV_SAMPLE_FMT_FLTP:
//
//                        let frameFloatsForChannel: UnsafePointer<Float> = bytesForChannel.withMemoryRebound(to: Float.self, capacity: frameSampleCount){$0}
//                        cblas_scopy(frame.sampleCount, frameFloatsForChannel, 1, channel.advanced(by: Int(sampleCountSoFar)), 1)
//
//                    case AV_SAMPLE_FMT_DBL, AV_SAMPLE_FMT_DBLP:
//
//                        let doublesForChannel: UnsafePointer<Double> = bytesForChannel.withMemoryRebound(to: Double.self, capacity: frameSampleCount){$0}
//                        let frameFloatsForChannel: [Float] = (0..<frameSampleCount).map {Float(doublesForChannel[$0])}
//
//                        cblas_scopy(frame.sampleCount, frameFloatsForChannel, 1, channel.advanced(by: Int(sampleCountSoFar)), 1)
//
//                    default:
//
//                        print("Invalid sample format", sampleFmt)
//                    }
//                }
//
//                sampleCountSoFar += frame.sampleCount
//            }
//
//            return buffer
//        }
//
//        return nil
//    }
}

extension AVFrame {

    var dataPointers: [UnsafeMutablePointer<UInt8>?] {
        Array(UnsafeBufferPointer(start: self.extended_data, count: 8))
    }
}
