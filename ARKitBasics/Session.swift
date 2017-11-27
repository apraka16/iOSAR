//
//  Session.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 27/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import CoreData
import SceneKit

class Session: NSManagedObject {
    
    static func createSession(with sessionId: String, in context: NSManagedObjectContext) -> Session {
        
        let aSession = Session(context: context)
        aSession.sessionId = "123456"
        return aSession
    }
    
    static func fetchSessionCount(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        if let sessionCount = (try? context.fetch(request))?.count {
            print("\(sessionCount) - Count of sessions")
        }
    }
    
    static func fetchAllSessions(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        if let sessions = (try? context.fetch(request)) {
            for session in sessions {
                print("\(session.sessionId) - session")
            }
        }
    }
    
    static func deleteAllSessions(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        if let sessions = (try? context.fetch(request)) {
            for session in sessions {
                context.delete(session)
            }
        }
    }
}
