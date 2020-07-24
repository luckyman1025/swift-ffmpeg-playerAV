import Foundation

typealias ResultCode = Int32

extension ResultCode {

    var errorDescription: String {
        
        if self == 0 {
            return "No error"
            
        } else {
            
            let errString = UnsafeMutablePointer<Int8>.allocate(capacity: 100)
            return av_strerror(self, errString, 100) == 0 ? String(cString: errString) : "Unknown error"
        }
    }
}

class CodedError: Error {
    
    let code: ResultCode
    
    var isEOF: Bool {code == EOF_CODE}
    var description: String {code.errorDescription}
    
    init(_ code: ResultCode) {
        self.code = code
    }
}

class DecoderError: CodedError {}

class PacketReadError: CodedError {}

class SeekError: CodedError {}

class DecoderInitializationError: Error {}
