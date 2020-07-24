import Cocoa
import ffmpeg

class Reader {
    
    static func readTrack(_ file: URL) -> TrackInfo? {
        
        if let fileCtx = AudioFileContext(file) {
            
            let chapters: [Chapter]
            var metadata: [String: String] = [:]
            var coverArt: NSImage? = nil
            
            let audioInfo: AudioInfo? = readAudioInfo(fileCtx.audioStream)

            for (key, value) in fileCtx.format.metadata {
                metadata[key] = value
            }
            
            for (key, value) in fileCtx.audioStream.metadata {
                metadata[key] = value
            }
            
            chapters = fileCtx.format.chapters
            
            if let imageStream = fileCtx.imageStream, let imageCodec = fileCtx.imageCodec {
                
                do {
                
                    if imageCodec.open(), let imageDataPacket = try fileCtx.format.readPacket(imageStream),
                        let imageData = imageCodec.decode(imageDataPacket) {
                        
                        coverArt = NSImage(data: imageData)
                    }
                    
                } catch {}
            }

            return TrackInfo(audioInfo: audioInfo, metadata: metadata, art: coverArt, chapters: chapters)
            
        } else {
            
            print("\nERROR reading metadata from file: \(file.path)")
            return nil
        }
    }
    
    private static func readAudioInfo(_ stream: AudioStream) -> AudioInfo? {
        
        guard let codec = stream.codec as? AudioCodec else {return nil}

        let codecName: String = codec.longName
        let duration: Double = stream.duration
        let sampleRate: Int = Int(codec.sampleRate)
        let sampleFormat: SampleFormat = codec.sampleFormat
        let bitRate: Int64 = codec.bitRate
        let channelCount: Int = codec.channelCount
        let frames: Int64 = stream.frameCount

        return AudioInfo(codec: codecName, duration: duration, sampleRate: sampleRate, sampleFormat: sampleFormat, bitRate: bitRate,
                          channelCount: channelCount, frameCount: frames)
    }
}

struct TrackInfo {
    
    var audioInfo: AudioInfo?
    var metadata: [String: String]
    var art: NSImage?
    var chapters: [Chapter]
    
    var displayedTitle: String? {
        
        let title = self.title
        let artist = self.artist
        
        if let theArtist = artist, let theTitle = title {
            return "\(theArtist) - \(theTitle)"
            
        } else {
            return title
        }
    }
    
    var title: String? {
        metadata.filter {$0.key.lowercased() == "title"}.first?.value
    }
    
    var artist: String? {
        metadata.filter {$0.key.lowercased() == "artist"}.first?.value
    }
    
    var album: String? {
        metadata.filter {$0.key.lowercased() == "album"}.first?.value
    }
    
    var displayedTrackNum: String? {
        
        let trackNum = self.trackNum
        let trackTotal = self.trackTotal
        
        if let theTrackNum = trackNum, let theTrackTotal = trackTotal {
            return "\(theTrackNum) / \(theTrackTotal)"
            
        } else {
            return trackNum
        }
    }
    
    var trackNum: String? {
        metadata.filter {$0.key.lowercased() == "track"}.first?.value
    }
    
    var trackTotal: String? {
        
        metadata.filter {$0.key.lowercased() == "tracktotal"}.first?.value ??
        metadata.filter {$0.key.lowercased() == "totaltracks"}.first?.value
    }
    
    var displayedDiscNum: String? {
        
        let discNum = self.discNum
        let discTotal = self.discTotal
        
        if let theDiscNum = discNum, let theDiscTotal = discTotal {
            return "\(theDiscNum) / \(theDiscTotal)"
            
        } else {
            return discNum
        }
    }
    
    var discNum: String? {
        metadata.filter {$0.key.lowercased() == "disc"}.first?.value
    }
    
    var discTotal: String? {
        
        metadata.filter {$0.key.lowercased() == "disctotal"}.first?.value ??
        metadata.filter {$0.key.lowercased() == "totaldiscs"}.first?.value
    }
    
    var genre: String? {
        metadata.filter {$0.key.lowercased() == "genre"}.first?.value
    }
    
    var year: String? {
        
        metadata.filter {$0.key.lowercased() == "year"}.first?.value ??
        metadata.filter {$0.key.lowercased() == "date"}.first?.value
    }
    
    var otherMetadata: [String: String] {
        
        let excludedKeys = ["title", "artist", "album", "genre", "year", "date", "track", "disc", "tracktotal", "totaltracks", "disctotal", "totaldiscs"]
        
        return metadata.filter {!excludedKeys.contains($0.key.lowercased())}
    }
}

struct Chapter {
    
    var startTime: Double
    var endTime: Double
    var title: String
}

struct AudioInfo {
    
    var codec: String
    var duration: Double
    var sampleRate: Int
    var sampleFormat: SampleFormat
    var bitRate: Int64
    var channelCount: Int
    var frameCount: Int64
}
