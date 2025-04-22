//
//  Controls.swift
//  Babii
//
//  Created by Matthew Reed on 4/20/25.
//

import GameController

class Controls: @unchecked Sendable {
    struct Point {
        var x: Float = 0
        var y: Float = 0
    }
    
    var keysPressed: Set<GCKeyCode> = []
    var mouseDelta = Point()
    
    init() {
        NotificationCenter.default.addObserver(forName: .GCKeyboardDidConnect, object: nil, queue: nil) { notification in
            let keyboard = notification.object as? GCKeyboard
            keyboard?.keyboardInput?.keyChangedHandler = { _, _, keyCode, pressed in
                if pressed {
                    self.keysPressed.insert(keyCode)
                } else {
                    self.keysPressed.remove(keyCode)
                }
            }
        }

        #if os(macOS)
        NSEvent.addLocalMonitorForEvents(matching: [.keyUp, .keyDown]) { _ in nil }
        #endif
        
        NotificationCenter.default.addObserver(forName: .GCMouseDidConnect, object: nil, queue: nil) { notification in
            let mouse = notification.object as? GCMouse
            mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                self.mouseDelta = Point(x: deltaX, y: deltaY)
            }
        }
    }
}
