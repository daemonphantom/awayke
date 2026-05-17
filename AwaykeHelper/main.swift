//
//  main.swift
//  AwaykeHelper
//
//  Privileged launchd daemon installed via SMAppService. Client
//  authorization is enforced by launchd via the SMAuthorizedClients
//  array embedded in the binary's __TEXT __info_plist section.
//

import Foundation

final class HelperTool: NSObject, NSXPCListenerDelegate, AwaykeHelperProtocol {

    private let listener: NSXPCListener

    override init() {
        self.listener = NSXPCListener(machServiceName: AwaykeHelperConstants.machServiceName)
        super.init()
        self.listener.delegate = self
    }

    func run() {
        listener.resume()
        RunLoop.current.run()
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        connection.exportedInterface = NSXPCInterface(with: AwaykeHelperProtocol.self)
        connection.exportedObject = self
        connection.resume()
        return true
    }

    func setSleepDisabled(_ disable: Bool, reply: @escaping (NSError?) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-a", "disablesleep", disable ? "1" : "0"]

        let errPipe = Pipe()
        process.standardError = errPipe

        do {
            try process.run()
        } catch {
            reply(error as NSError)
            return
        }

        process.waitUntilExit()

        if process.terminationStatus == 0 {
            reply(nil)
            return
        }

        let data = errPipe.fileHandleForReading.readDataToEndOfFile()
        let message = String(data: data, encoding: .utf8) ?? "pmset failed"
        reply(NSError(
            domain: "daemonphantom.Awayke.Helper",
            code: Int(process.terminationStatus),
            userInfo: [NSLocalizedDescriptionKey: message]
        ))
    }
}

HelperTool().run()
