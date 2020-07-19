import Foundation

protocol SchedulerProtocol {
    
    // Schedule and play the track (specified by the given playback session), starting at the given start position
    func playTrack(_ file: URL, _ startPosition: Double)
    
    // Schedule the track (specified by the given playback session), starting at the given start position. Begin playback if beginPlayback is true.
    func playLoop(_ file: URL, _ beginPlayback: Bool)
    
    // Schedule playback of a segment loop (specified by the given playback session), at the given playback start time. Begin playback if beginPlayback is true.
    func playLoop(_ file: URL, _ playbackStartTime: Double, _ beginPlayback: Bool)
    
    // End scheduling and playback for the segment loop (specified by the given playback session). Resume normal playback till the end of the track.
    // The loopEndTime parameter specifies the start time for the new segment: [loopEndTime, trackDuration].
    func endLoop(_ file: URL, _ loopEndTime: Double)
    
    // Seeks to a certain position (seconds) within the currently playing track (specified by the given playback session). Begin playback if beginPlayback is true.
    func seekToTime(_ file: URL, _ seconds: Double, _ beginPlayback: Bool)
    
    // Pause the player.
    func pause()
    
    // Resume the player.
    func resume()

    // Clears any previously scheduled audio segments, and stops playback.
    func stop()
    
    // Retrieves the current seek position, in seconds
    var seekPosition: Double {get}
}
