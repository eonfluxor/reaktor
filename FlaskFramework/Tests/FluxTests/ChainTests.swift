//
//  ChainTests.swift
//  SwiftyFLUXTests
//
//  Created by hassan uriostegui on 9/5/18.
//  Copyright © 2018 hassanvflask. All rights reserved.
//

import XCTest


class ChainingTests: SetupFlaskTests {

    func testInlineMutation(){
        
        let expectation = self.expectation(description: "testInlineMutation")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, mixin:molecule)
        
        flask.reactor = { owner, reaction in
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
                
            })
        }
        
        flask.mutate(molecule,{ (molecule, commit, abort) in
            molecule.state.counter=1
            commit()
        }).mutate(molecule) { (molecule, commit, abort) in
            molecule.state.counter=2
            commit()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        
    }
    
    func testChangesInLine(){
        
        let expectation = self.expectation(description: "testChangeInLine counter")
        let expectation2 = self.expectation(description: "testChangeInLine text")
        let expectation3 = self.expectation(description: "testChangeInLine object")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner,mixin:molecule)
        
        let object = NSObject()
        let aObject = FlaskRef( object )
        
        
        flask.reactor = { owner, reaction in
            
            reaction.on(State.prop.counter, { (change) in
                
                let oldValue:Int? = change.oldValue()
                let newValue:Int? = change.newValue()
                XCTAssert(oldValue == 0)
                XCTAssert(newValue == 1)
                XCTAssert(change.key() == State.prop.counter.rawValue)
                XCTAssert(change.molecule() === molecule)
                
                expectation.fulfill()
            })
            
            reaction.on(State.prop.text, { (change) in
                
                XCTAssert(change.oldValue() == "")
                XCTAssert(change.newValue() == "reaction")
                XCTAssert(change.key() == State.prop.text.rawValue)
                XCTAssert(change.molecule() === molecule)
                
                expectation2.fulfill()
            })
            
            reaction.on(State.prop.object, { (change) in
                
                XCTAssert( isFlaskNil(change.oldValue()) )
                XCTAssert(change.newValue() == aObject)
                XCTAssert(change.key() == State.prop.object.rawValue)
                XCTAssert(change.molecule() === molecule)
                
                expectation3.fulfill()
            })
            
        }
        
        flask.mutate(molecule,{ (molecule, commit, abort) in
            molecule.state.counter = 1
            molecule.state.text = "reaction"
            molecule.state.object = aObject
            commit()
        })
        
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testChain(){
        
        let expectation = self.expectation(description: "testChain")
        
        let molecule = self.molecule!
        let owner:TestOwner = TestOwner()
        let flask = Lab.flask(ownedBy:owner, mixin:molecule)
        
        flask.reactor = { owner, reaction in
            reaction.on(State.prop.counter, { (change) in
                expectation.fulfill()
                XCTAssert(change.newValue() == 2)
            })
        }
        
        flask.mutate(molecule){ (molecule) in
            molecule.state.counter=1
        }.mutate(molecule) { (molecule) in
            molecule.state.counter=2
        }.commit()
        
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    
}
