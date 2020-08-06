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
    
    // MARK: Helper functions to assess the result of the operation that produced this result code.
    
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
    
    /// An integer code indicating what went wrong.
    let code: ResultCode
    
    /// Whether or not this error indicates end of file (EOF).
    var isEOF: Bool {code == EOF_CODE}
    
    /// A readable description of this error.
    var description: String {code.errorDescription}
    
    /// Instantiates a CodedError with a given result code.
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

///
/// Helper function to check if the given result code indicates end of file (EOF).
///
func isEOF(code: ResultCode) -> Bool {
    code == EOF_CODE
}
