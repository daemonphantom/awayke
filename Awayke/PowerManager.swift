//
//  PowerManager.swift
//  Awayke
//
//  Toggles `pmset -a disablesleep` via the helper when approved, or via
//  osascript with admin privileges as a fallback.
//

import Foundation

enum PowerManagerError: LocalizedError {
    case scriptFailed(status: Int32, message: String)
    case launchFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .scriptFailed(let status, let message):
            if message.isEmpty { return "pmset failed (exit \(status))." }
            return "pmset failed (exit \(status)): \(message)"
        case .launchFailed(let error):
            return "Couldn't launch osascript: \(error.localizedDescription)"
        }
    }
}

final class PowerManager {

    private let helper: HelperManager

    init(helper: HelperManager = .shared) {
        self.helper = helper
    }

    func disableSleep(_ disable: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        if helper.isUsable {
            Task {
                do {
                    try await helper.setSleepDisabled(disable)
                    completion(.success(()))
                } catch {
                    self.disableSleepViaOsascript(disable, completion: completion)
                }
            }
        } else {
            disableSleepViaOsascript(disable, completion: completion)
        }
    }

    private func disableSleepViaOsascript(_ disable: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let flag = disable ? "1" : "0"
        let shellCommand = "/usr/bin/pmset -a disablesleep \(flag)"
        let appleScript = "do shell script \"\(shellCommand)\" with administrator privileges"

        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            process.arguments = ["-e", appleScript]

            let stderrPipe = Pipe()
            process.standardError = stderrPipe
            process.standardOutput = Pipe()

            do {
                try process.run()
            } catch {
                completion(.failure(PowerManagerError.launchFailed(underlying: error)))
                return
            }

            process.waitUntilExit()

            if process.terminationStatus == 0 {
                completion(.success(()))
                return
            }

            let data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            completion(.failure(PowerManagerError.scriptFailed(
                status: process.terminationStatus,
                message: message
            )))
        }
    }
}
