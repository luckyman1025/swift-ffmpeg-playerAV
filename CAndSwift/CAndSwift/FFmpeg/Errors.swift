import Foundation

typealias ResultCode = Int32

///
/// Helper functions and properties for convenience in error handling and logging.
///
extension ResultCode {

    var errorDescription: String {
        
        if self == 0 {
            return "No error"
            
        } else {
            
            let errString = UnsafeMutablePointer<Int8>.allocate(capacity: 100)
            return av_strerror(self, errString, 100) == 0 ? String(cString: errString) : "Unknown error"
        }
    }
    
    var isNonNegative: Bool {self >= 0}
    var isNonPositive: Bool {self <= 0}
    
    var isPositive: Bool {self > 0}
    var isNegative: Bool {self < 0}
    
    var isZero: Bool {self == 0}
    var isNonZero: Bool {self != 0}
}

///
/// Represents an error with an associated integer error code.
///
class CodedError: Error {
    
    let code: ResultCode
    
    var isEOF: Bool {code == EOF_CODE}
    var description: String {code.errorDescription}
    
    init(_ code: ResultCode) {
        self.code = code
    }
}

///
/// Represents an error encountered by a codec while decoding audio packets.
///
class DecoderError: CodedError {
    static let eof: DecoderError = DecoderError(EOF_CODE)
}

///
/// Represents an error encountered while reading audio packets from a stream.
///
class PacketReadError: CodedError {
    static let eof: PacketReadError = PacketReadError(EOF_CODE)
}

///
/// Represents an error encountered while seeking within an audio stream.
///
class SeekError: CodedError {}

///
/// Represents an error encountered while initializing a decoder.
///
class DecoderInitializationError: CodedError {}

///
/// Represents an error encountered while initializing a player.
///
class PlayerInitializationError: Error {}

