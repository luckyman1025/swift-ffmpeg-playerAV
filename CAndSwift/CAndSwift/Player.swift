import AVFoundation
import ffmpeg

class Player {
    
    let audioEngine: AudioEngine = AudioEngine()
    var audioFormat: AVAudioFormat!
    var eof: Bool = false
    
    var scheduledBufferCount: Int = 0
    
    var playingFile: AudioFileContext?
    
    var state: PlayerState = .stopped
    
    var volume: Float {
        
        get {audioEngine.volume}
        set {audioEngine.volume = min(1, max(0, newValue))}
    }
    
    var seekPosition: Double {audioEngine.seekPosition}
    
    func togglePlayPause() {
        
        audioEngine.pauseOrResume()
        state = audioEngine.isPlaying ? .playing : .paused
    }
    
    func play(_ file: URL) {
        
        stop()
        
        do {
            
            let fileCtx = try setupForFile(file)
            playingFile = fileCtx
            
            print("\nSuccessfully opened file: \(file.path). File is ready for decoding.")
            fileCtx.audioStream.printInfo()
            fileCtx.audioCodec.printInfo()
            
            if !fileCtx.audioCodec.open() {return}
            
            var time = measureTime {
                scheduleOneBuffer(fileCtx, 5)
            }
            
            print("\nTook \(Int(round(time * 1000))) msec to decode 5 seconds")

            audioEngine.seekTo(0)
            audioEngine.play()
            state = .playing

            NSLog("Playback Started !\n")

            time = measureTime {
                scheduleOneBuffer(fileCtx, 5)
            }

            print("\nTook \(Int(round(time * 1000))) msec to decode another 5 seconds")

        } catch {

            print("\nFFmpeg / audio engine setup failure !")
            return
        }
    }
    
    func stop(_ playbackFinished: Bool = true) {
        
        state = .stopped
        audioEngine.stop()
        
        if playbackFinished {
            playingFile = nil
        }
    }
    
    func setupForFile(_ file: URL) throws -> AudioFileContext {
        
        guard let fileCtx = AudioFileContext(file) else {throw DecoderInitializationError()}
        
        eof = false
        
        audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(fileCtx.audioCodec.sampleRate), channels: AVAudioChannelCount(2), interleaved: false)!
        audioEngine.prepare(audioFormat)
        
        return fileCtx
    }
    
    private func scheduleOneBuffer(_ fileCtx: AudioFileContext, _ seconds: Double = 10) {
        
        print()
        NSLog("Began decoding ... \(seconds) seconds of audio")
        
        let formatCtx: FormatContext = fileCtx.format
        let stream = fileCtx.audioStream
        let codec: AudioCodec = fileCtx.audioCodec
        
        let buffer: SamplesBuffer = SamplesBuffer(sampleFormat: codec.sampleFormat, maxSampleCount: Int32(seconds * Double(codec.sampleRate)))
        
        while !(buffer.isFull || eof) {
            
            do {
                
                if let packet = try formatCtx.readPacket(stream) {
                    for frame in try codec.decode(packet) {
                        buffer.appendFrame(frame: frame)
                    }
                }
                
            } catch {
                
                // TODO: Possibility of infinite loop with continuous errors suppressed here.
                // Maybe set a maximum consecutive error limit ??? eg. If 3 consecutive errors are encountered, then break from the loop.
                if (error as? PacketReadError)?.isEOF ?? false {
                    self.eof = true
                }
            }
        }
        
        if buffer.isFull || eof, let audioBuffer: AVAudioPCMBuffer = buffer.constructAudioBuffer(format: audioFormat) {
            
            audioEngine.scheduleBuffer(audioBuffer, {

                self.scheduledBufferCount -= 1

                if self.state != .stopped {

                    if !self.eof {

                        let time = measureTime {
                            self.scheduleOneBuffer(fileCtx)
                        }

                        NSLog("Decoded 10 seconds of audio in \(Int(round(time * 1000))) msec\n")

                    } else if self.scheduledBufferCount == 0 {
                        
                        DispatchQueue.main.async {
                            self.playbackCompleted()
                        }
                    }
                }
            })
            
            // Write out the raw samples to a .raw file for testing in Audacity
//            BufferFileWriter.writeBuffer(audioBuffer)
//            BufferFileWriter.closeFile()
            
            scheduledBufferCount += 1
        }
        
        if eof {
            NSLog("Reached EOF !!!")
        }
    }
    
    private func playbackCompleted() {
        
        NSLog("Playback completed !!!\n")
        
        stop()
        audioEngine.playbackCompleted()
        playingFile?.destroy()
        
        NotificationCenter.default.post(name: .playbackCompleted, object: self)
    }
    
    func seekToTime(_ seconds: Double, _ beginPlayback: Bool = true) {
        
        if let thePlayingFile = playingFile {

            stop(false)
            
            do {
                
                try thePlayingFile.format.seekWithinStream(thePlayingFile.audioStream, seconds)
                
                scheduleOneBuffer(thePlayingFile, 5)
                
                audioEngine.seekTo(seconds)
                audioEngine.play()
                state = .playing
                
                scheduleOneBuffer(thePlayingFile, 5)
                
            } catch {
                
                if let seekError = error as? SeekError, seekError.isEOF {
                    playbackCompleted()
                }
            }
        }
    }
}

enum PlayerState {
    
    // Not playing any track
    case stopped
    
    // Playing a track
    case playing
    
    // Paued while playing a track
    case paused
}

extension AVRational {

    var ratio: Double {Double(num) / Double(den)}
    var reciprocal: Double {Double(den) / Double(num)}
}
