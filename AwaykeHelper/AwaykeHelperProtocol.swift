//
//  AwaykeHelperProtocol.swift
//

import Foundation

@objc public protocol AwaykeHelperProtocol {
    /// `disable` → true runs `pmset -a disablesleep 1`; false runs `… 0`.
    /// Reply is nil on success, NSError on failure.
    func setSleepDisabled(_ disable: Bool, reply: @escaping (NSError?) -> Void)
}

public enum AwaykeHelperConstants {
    public static let machServiceName = "daemonphantom.Awayke.Helper"
}
