//
//  DisplayWakeKeeper.swift
//  Awayke
//
//  Holds an IOPMAssertion that prevents display sleep, screen saver,
//  and auto-lock while Awayke is active. Same mechanism as
//  `caffeinate -d`. Released automatically if the app exits.
//

import IOKit.pwr_mgt

final class DisplayWakeKeeper {

    private var assertionID: IOPMAssertionID = 0

    var isHolding: Bool { assertionID != 0 }

    func prevent() {
        guard assertionID == 0 else { return }
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Awayke is active" as CFString,
            &assertionID
        )
        if result != kIOReturnSuccess {
            assertionID = 0
        }
    }

    func allow() {
        guard assertionID != 0 else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
    }
}
