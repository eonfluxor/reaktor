//
//  FlaskTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 8/31/18.
//  Copyright © 2018 hassanvreactor. All rights reserved.
//

import XCTest
import Flask


class FlaskTests: SetupFlaskTests {
    

    func testCallback(){
        
        let expectation = self.expectation(description: "testCallback Mutation counter")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner,mixing:substance)
        
        reactor.handler = { owner, reaction in
            
            reaction.on( AppState.prop.counter, { (change) in
                expectation.fulfill()
            })
            
        }
        
//        DispatchQueue.main.async {
        Flask.substances(reactTo:Mixers.Count, payload: ["test":"callback"])
        Flask.substances(reactTo:Mixers.Text, payload: ["test":"callback"])
//        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    func testOwner(){
        
        let expectation = self.expectation(description: "testOwner Delegate")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner,mixing:substance)
        
        reactor.handler = { owner, reaction in
            
            reaction.at(substance)?.on(AppState.prop.counter, { (change) in
                owner.reactionMethod(expectation)
            })
            
        }
        
        DispatchQueue.main.async {
            Flask.substances(reactTo:Mixers.Count, payload: ["test":"testOwner"])
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testEmpty(){
        
        let expectation = self.expectation(description: "testEmpty")
        expectation.isInverted=true
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner,mixing:substance)
        
        reactor.handler={owner, reaction in
            reaction.on(AppState.prop.counter, { (change) in
                expectation.fulfill()
            })
        }
        
        reactor.unbind()
        Flask.substances(reactTo:Mixers.Count, payload: ["test":"empty"])
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    
    func testStrongOwner(){
        
        let expectation = self.expectation(description: "testStrongOwner")
        
        let substance = self.substance!
        let owner:TestOwner? = TestOwner()
        
        weak var reactor = Flask.reactor(attachedTo:owner!, mixing:substance)
        
        reactor?.handler = { owner, reaction in}
   
        
        DispatchQueue.main.async {
            
            if reactor != nil {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testOwnerDispose(){
        
        let expectation = self.expectation(description: "testOwnerDispose")
        
        let substance = self.substance!
        var weakOwner:TestOwner? = TestOwner()
        
        weak var reactor = Flask.reactor(attachedTo:weakOwner!, mixing:substance)
        
        reactor?.handler = { owner, reaction in}
        
        
        // Calling mix after disposing the owner
        // should cause the factory to release this flask
        weakOwner = nil
        
        Flask.substances(reactTo:Mixers.Count, payload:  ["test":"ownerDispose"])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute:  {
            if reactor == nil {
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    
    func testChange(){
        
        let expectation = self.expectation(description: "testChange Mutation")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner,mixing:substance)
        
        reactor.handler = { owner, reaction in
            
            reaction.on(AppState.prop.counter, { (change) in
                
                XCTAssert(change.oldValue() == 0)
                XCTAssert(change.newValue() == 1)
                XCTAssert(change.key() == AppState.prop.counter.rawValue)
                XCTAssert(change.substance() === substance)
                
                expectation.fulfill()
            })
            
        }
        
        Flask.substances(reactTo:Mixers.Count, payload: ["test":"change"])
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    
    
    func testGlobalApp(){
        
        let expectation = self.expectation(description: "testGlobalSubstance testInlineMutation")
        
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner, mixing:Substances.app)
        
        reactor.handler = { owner, reaction in
            reaction.on(AppState.prop.counter, { (change) in
                expectation.fulfill()
                XCTAssert(Substances.app.state.counter == 2)
            })
        }
        
        reactor
            .mix(Substances.app){ (substance) in
                substance.prop.counter=1
            }.mix(Substances.app) { (substance) in
                substance.prop.counter=2
            }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
        
    }
    
    func testStateInternal(){
        
        let expectation = self.expectation(description: "testStateInternal")
        expectation.isInverted = true
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner, mixing:substance)
        
        reactor.handler = { owner, reaction in
            reaction.on("_internal", { (change) in
                expectation.fulfill()
            })
        }
        
        reactor.mix(substance){ (substance) in
            substance.prop._internal="shouldn't cause mix"
        }.react()
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    
    
    
}
