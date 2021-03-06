//
//  ChainTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvreactor. All rights reserved.
//

import XCTest


class ChainingTests: SetupFlaskTests {

    func testInlineMutation(){
        
        let expectation = self.expectation(description: "testInlineMutation")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner, mixing:substance)
        
        reactor.handler = { owner, reaction in
            reaction.on(AppState.prop.counter, { (change) in
                expectation.fulfill()
                
            })
        }
        
      
        
        reactor
            .mix(substance){ (substance) in
                substance.prop.counter=1
            }.mix(substance) { (substance) in
                substance.prop.counter=2
            }.react()
        
        waitForExpectations(timeout: 2, handler: nil)
        
        
    }
    
    func testChangesInLine(){
        
        let expectation = self.expectation(description: "testChangeInLine counter")
        let expectation2 = self.expectation(description: "testChangeInLine text")
        let expectation3 = self.expectation(description: "testChangeInLine object")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner,mixing:substance)
        
        let object = NSObject()
        let aObject = FlaskNSRef( object )
        
        
        reactor.handler = { owner, reaction in
            
            reaction.on(AppState.prop.counter, { (change) in
                
                let oldValue:Int? = change.oldValue()
                let newValue:Int? = change.newValue()
                XCTAssert(oldValue == 0)
                XCTAssert(newValue == 1)
                XCTAssert(change.key() == AppState.prop.counter.rawValue)
                XCTAssert(change.substance() === substance)
                
                expectation.fulfill()
            })
            
            reaction.on(AppState.prop.text, { (change) in
                
                XCTAssert(change.oldValue() == "")
                XCTAssert(change.newValue() == "reaction")
                XCTAssert(change.key() == AppState.prop.text.rawValue)
                XCTAssert(change.substance() === substance)
                
                expectation2.fulfill()
            })
            
            reaction.on(AppState.prop.object, { (change) in
                
          
                XCTAssert( isNilorNull(change.oldValue()) )
                XCTAssert(change.newValue() == aObject)
                XCTAssert(change.key() == AppState.prop.object.rawValue)
                XCTAssert(change.substance() === substance)
                
                expectation3.fulfill()
            })
            
        }
        
        reactor.mix(substance) { (substance) in
            substance.prop.counter = 1
            substance.prop.text = "reaction"
            substance.prop.object = aObject
        }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    func testChain(){
        
        let expectation = self.expectation(description: "testChain")
        let expectation2 = self.expectation(description: "testChain")
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner, mixing:substance)
        
        reactor.handler = { owner, reaction in
            reaction.on(AppState.prop.counter, { (change) in
                
                XCTAssert(substance.state.counter == 2)
                expectation.fulfill()
            })
            
            reaction.on(AppState.prop.text, { (change) in
                
                XCTAssert(substance.state.text == "mix no override")
                expectation2.fulfill()
            })
        }
        
        reactor
            .mix(substance){ (substance) in
                substance.prop.counter=2
            }.mix(substance) { (substance) in
                substance.prop.text="mix no override"
            }.react()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
    func testChainAbort(){
        
        let expectation = self.expectation(description: "testChain")
        expectation.isInverted = true
        
        let substance = self.substance!
        let owner:TestOwner = TestOwner()
        let reactor = Flask.reactor(attachedTo:owner, mixing:substance)
        
        reactor.handler = { owner, reaction in
            reaction.on(AppState.prop.counter, { (change) in
                expectation.fulfill()
//                XCTAssert(substance.state.counter == 2)
//                XCTAssert(substance.state.text == "mix no override")
                
            })
        }
        
        reactor
            .mix(substance){ (substance) in
                substance.prop.text="mix no override"
                substance.prop.counter=1
            }.mix(substance) { (substance) in
                substance.prop.counter=2
            }.abort()
        
        
        waitForExpectations(timeout: 2, handler: nil)
        
    }
    
    
}
