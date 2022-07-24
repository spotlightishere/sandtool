import CSandbox
import Foundation

struct SandboxError: Error {
    let message: String
}

public struct Sandstone {
    /// Compiles the passed profile in SBPL.
    /// - Parameter profile: A string of SBPL to request to be compiled
    /// - Returns: The compiled profile's bytecode.
    /// - Throws: Should an error be encountered during compilation.
    public static func compile(profile: String) throws -> Data {
        var errorPointer: UnsafeMutablePointer<CChar>?

        // Call!
        let profileString = profile.cString(using: .utf8)
        let compiledProfile = sandbox_compile_string(profileString, nil, &errorPointer)
        
        // Uh oh... time to handle.
        if let errorString = errorPointer {
            let errorMessage = String(cString: errorString, encoding: .utf8) ?? "Unable to decode string."
            
            // Wow, C is awful.
            free(errorString)
            throw SandboxError(message: errorMessage)
        }
        
        guard let profile = compiledProfile?.pointee else {
            // TODO: Is there a nicer way to handle this?
            // Hopefully it will never occur...
            throw SandboxError(message: "Sandbox is nil!")
        }

        // Finally, we can get on with our day.
        let contents = Data(bytes: profile.bytecode, count: profile.bytecode_length)
        sandbox_free_profile(compiledProfile)
        
        return contents
    }
}
