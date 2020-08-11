import AVFoundation
import Accelerate

///
/// Encapsulates an ffmpeg AVFrame struct that represents a single (decoded) frame,
/// i.e. audio data in its raw decoded / uncompressed form, post-decoding,
/// and provides convenient Swift-style access to its functions and member variables.
///
class Frame {
 
    ///
    /// The encapsulated AVFrame object.
    ///
    var avFrame: AVFrame {pointer.pointee}
    
    var pointer: UnsafeMutablePointer<AVFrame>
    
    ///
    /// Describes the number and physical / spatial arrangement of the channels. (e.g. "5.1 surround" or "stereo")
    ///
    var channelLayout: UInt64 {avFrame.channel_layout}
    
    ///
    /// Number of channels of audio data.
    ///
    var channelCount: Int32 {avFrame.channels}

    ///
    /// PCM format of the samples.
    ///
    var sampleFormat: SampleFormat
    
    ///
    /// Total number of samples in this frame.
    ///
    var sampleCount: Int32 {truncatedSampleCount ?? avFrame.nb_samples}
    
    var truncatedSampleCount: Int32?
    
    var firstSampleIndex: Int32
    
    ///
    /// Whether or not this frame has any samples.
    ///
    var hasSamples: Bool {avFrame.nb_samples.isPositive}
    
    ///
    /// Sample rate of the decoded data (i.e. number of samples per second or Hz).
    ///
    var sampleRate: Int32 {avFrame.sample_rate}
    
    ///
    /// For interleaved (packed) samples, this value will equal the size in bytes of data for all channels.
    /// For non-interleaved (planar) samples, this value will equal the size in bytes of data for a single channel.
    ///
    var lineSize: Int {Int(avFrame.linesize.0)}
    
    ///
    /// A timestamp indicating this frame's position (order) within the parent audio stream,
    /// specified in stream time base units.
    ///
    /// ```
    /// This can be useful when using concurrency to decode multiple
    /// packets simultaneously. The received frames, in that case,
    /// would be in arbitrary order, and this timestamp can be used
    /// to sort them in the proper presentation order.
    /// ```
    ///
    var timestamp: Int64 {avFrame.best_effort_timestamp}
    
    var pts: Int64 {avFrame.pts}
    
    var dataPointers: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>! {avFrame.extended_data}
    
    ///
    /// Instantiates a Frame and sets the sample format.
    ///
    /// - Parameter sampleFormat: The format of the samples in this frame.
    ///
    init(sampleFormat: SampleFormat) {
        
        self.pointer = av_frame_alloc()
        self.sampleFormat = sampleFormat
        self.firstSampleIndex = 0
    }
    
    func keepFirstNSamples(sampleCount: Int32) {
        
        if sampleCount < self.sampleCount {

            firstSampleIndex = 0
            truncatedSampleCount = sampleCount
        }
    }
    
    func keepLastNSamples(sampleCount: Int32) {
        
        if sampleCount < self.sampleCount {

            firstSampleIndex = self.sampleCount - sampleCount
            truncatedSampleCount = sampleCount
        }
    }
    
    func copySamples(to audioBuffer: AVAudioPCMBuffer, startingAt offset: Int) {

        // Get pointers to the audio buffer's internal Float data buffers.
        guard let audioBufferChannels = audioBuffer.floatChannelData else {return}
        
        let intSampleCount: Int = Int(sampleCount)
        let intFirstSampleIndex: Int = Int(firstSampleIndex)
        
        for channelIndex in 0..<Int(channelCount) {
            
            // Get the pointers to the source and destination buffers for the copy operation.
            guard let bytesForChannel = dataPointers[channelIndex] else {break}
            let audioBufferChannel = audioBufferChannels[channelIndex]
            
            // Re-bind this frame's bytes to Float for the copy operation.
            bytesForChannel.withMemoryRebound(to: Float.self, capacity: intSampleCount) {
                
                (floatsForChannel: UnsafeMutablePointer<Float>) in
                
                // Use Accelerate to perform the copy optimally, starting at the given offset.
                cblas_scopy(sampleCount, floatsForChannel.advanced(by: intFirstSampleIndex), 1, audioBufferChannel.advanced(by: offset), 1)
                
                if channelIndex == 0, firstSampleIndex != 0 {
                    print("\n\(sampleCount) samples copied from frame with PTS \(pts), firstIndex = \(firstSampleIndex)")
                }
            }
        }
    }
    
    /// Indicates whether or not this object has already been destroyed.
    private var destroyed: Bool = false
    
    ///
    /// Performs cleanup (deallocation of allocated memory space) when
    /// this object is about to be deinitialized or is no longer needed.
    ///
    func destroy() {

        // This check ensures that the deallocation happens
        // only once. Otherwise, a fatal error will be
        // thrown.
        if destroyed {return}
        
        // Free up the space allocated to this frame.
        av_frame_unref(pointer)
        av_freep(pointer)
        
        destroyed = true
    }
    
    /// When this object is deinitialized, make sure that its allocated memory space is deallocated.
    deinit {
        destroy()
    }
}
