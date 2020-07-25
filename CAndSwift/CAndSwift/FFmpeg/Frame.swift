import Foundation

fileprivate let max8BitFloatVal: Float = Float(Int8.max)
fileprivate let max16BitFloatVal: Float = Float(Int16.max)
fileprivate let max32BitFloatVal: Float = Float(Int32.max)
fileprivate let max64BitDoubleVal: Double = Double(Int64.max)

class Frame {
    
    private var _dataArray: [Data]
    var dataArray: [Data] {_dataArray}
    
    var dataPointers: [UnsafePointer<UInt8>] {dataArray.compactMap {$0.withUnsafeBytes{$0}}}
    
    let channelCount: Int
    let sampleCount: Int32
    let lineSize: Int
    
    let sampleFormat: SampleFormat
    
    let timestamp: Int64
    
    init(_ frame: UnsafeMutablePointer<AVFrame>, sampleFormat: SampleFormat) {
        
        self.timestamp = frame.pointee.best_effort_timestamp
        
        self.channelCount = Int(frame.pointee.channels)
        self.sampleCount = frame.pointee.nb_samples
        self.lineSize = Int(frame.pointee.linesize.0)
        
        self.sampleFormat = sampleFormat
        self._dataArray = []
        
        let bufferPointers = frame.pointee.dataPointers
        
        for channelIndex in (0..<8) {
            
            guard let buffer = bufferPointers[channelIndex] else {break}
            _dataArray.append(Data(bytes: buffer, count: lineSize))
        }
    }
    
    var planarFloatData: [[Float]] {
        
        var allFloatData: [[Float]] = []
        let intSampleCount: Int = Int(sampleCount)
        
        for bytesForChannel in dataPointers {
            
            let floatsForChannel: [Float]
            
            switch sampleFormat.avFormat {
                
            // Integer => scale to [-1, 1] and convert to Float.

            // Unsigned 8-bit integer
            case AV_SAMPLE_FMT_U8P:
                
                // Subtract 127 to make the unsigned byte signed (8-bit samples are always unsigned)
                let reboundData: UnsafePointer<Int8> = bytesForChannel.withMemoryRebound(to: Int8.self, capacity: intSampleCount){$0}
                floatsForChannel = (0..<intSampleCount).map {Float(reboundData[$0] - 127) / max8BitFloatVal}
                
            // Signed 16-bit integer
            case AV_SAMPLE_FMT_S16P:
                
                let reboundData: UnsafePointer<Int16> = bytesForChannel.withMemoryRebound(to: Int16.self, capacity: intSampleCount){$0}
                floatsForChannel = (0..<intSampleCount).map {Float(reboundData[$0]) / max16BitFloatVal}

            // Signed 32-bit integer
            case AV_SAMPLE_FMT_S32P:
                
                let reboundData: UnsafePointer<Int32> = bytesForChannel.withMemoryRebound(to: Int32.self, capacity: intSampleCount){$0}
                floatsForChannel = (0..<intSampleCount).map {Float(reboundData[$0]) / max32BitFloatVal}

            // Signed 64-bit integer
            case AV_SAMPLE_FMT_S64P:
                
                let reboundData: UnsafePointer<Int64> = bytesForChannel.withMemoryRebound(to: Int64.self, capacity: intSampleCount){$0}
                floatsForChannel = (0..<intSampleCount).map {Float(Double(reboundData[$0]) / max64BitDoubleVal)}

            // Floating point
            case AV_SAMPLE_FMT_FLTP:
                
                floatsForChannel = Array(UnsafeBufferPointer(start: bytesForChannel.withMemoryRebound(to: Float.self, capacity: intSampleCount){$0}, count: intSampleCount))

            // Double-precision floating point
            case AV_SAMPLE_FMT_DBLP:
                
                let doublesForChannel: UnsafePointer<Double> = bytesForChannel.withMemoryRebound(to: Double.self, capacity: intSampleCount){$0}
                floatsForChannel = (0..<intSampleCount).map {Float(doublesForChannel[$0])}
                
            default:
                
                print("Invalid sample format", sampleFormat.name)
                return []
            }
            
            allFloatData.append(floatsForChannel)
        }
        
        return allFloatData
    }
    
    static var convTime: Double = 0
    
    var packedFloatData: [Float] {
        
        let sampleCountForAllChannels: Int = Int(sampleCount) * channelCount
        
        let allBytes = dataPointers[0]
            
        switch sampleFormat.avFormat {
            
        // Integer => scale to [-1, 1] and convert to Float.

        // Unsigned 8-bit integer
        case AV_SAMPLE_FMT_U8:
            
            // Subtract 127 to make the unsigned byte signed (8-bit samples are always unsigned)
            let reboundData: UnsafePointer<Int8> = allBytes.withMemoryRebound(to: Int8.self, capacity: sampleCountForAllChannels){$0}
            return (0..<sampleCountForAllChannels).map {Float(reboundData[$0] - 127) / max8BitFloatVal}
            
        // Signed 16-bit integer
        case AV_SAMPLE_FMT_S16:
            
            let reboundData: UnsafePointer<Int16> = allBytes.withMemoryRebound(to: Int16.self, capacity: sampleCountForAllChannels){$0}
            return (0..<sampleCountForAllChannels).map {Float(reboundData[$0]) / max16BitFloatVal}

        // Signed 32-bit integer
        case AV_SAMPLE_FMT_S32:
            
            var floats: [Float] = []
            
            let ctime = measureTime {
                
                let reboundData: UnsafePointer<Int32> = allBytes.withMemoryRebound(to: Int32.self, capacity: sampleCountForAllChannels){$0}
                floats = (0..<sampleCountForAllChannels).map {Float(reboundData[$0]) / max32BitFloatVal}
            }
            
            Self.convTime += ctime
            return floats
            
        // Signed 64-bit integer
        case AV_SAMPLE_FMT_S64:
            
            let reboundData: UnsafePointer<Int64> = allBytes.withMemoryRebound(to: Int64.self, capacity: sampleCountForAllChannels){$0}
            return (0..<sampleCountForAllChannels).map {Float(Double(reboundData[$0]) / max64BitDoubleVal)}

        // Floating point
        case AV_SAMPLE_FMT_FLT:
        
            return Array(UnsafeBufferPointer(start: allBytes.withMemoryRebound(to: Float.self, capacity: sampleCountForAllChannels){$0}, count: sampleCountForAllChannels))

        // Double-precision floating point
        case AV_SAMPLE_FMT_DBL:
            
            let doublesForChannel: UnsafePointer<Double> = allBytes.withMemoryRebound(to: Double.self, capacity: sampleCountForAllChannels){$0}
            return (0..<sampleCountForAllChannels).map {Float(doublesForChannel[$0])}
        
        default:
        
            print("Invalid sample format", sampleFormat.name)
            return []
        }
    }
}

extension AVFrame {
    
    var dataPointers: [UnsafeMutablePointer<UInt8>?] {
        Array(UnsafeBufferPointer(start: self.extended_data, count: 8))
    }
}
