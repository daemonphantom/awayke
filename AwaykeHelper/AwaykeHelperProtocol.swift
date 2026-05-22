//
//  AwaykeHelperProtocol.swift
//

import Foundation

@objc public protocol AwaykeHelperProtocol {
    func setSleepDisabled(_ disable: Bool, reply: @escaping (NSError?) -> Void)
}

public enum AwaykeHelperConstants {
    public static let machServiceName = "daemonphantom.Awayke.Helper"
}
