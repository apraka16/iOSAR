//
//  Brain.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 30/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//


/*
 Algo for calculating complexity should be based on 3 parameters:
 1. Color of objects (red, blue, green, white, black, yellow): score of 1
 Note: Color of objects is not used as a parameter for the MVP
 3. Shape of objects
 - Circle, Rectangle, Square, Triangle - pool 1
 - Cube, Cylinder, Sphere, Cuboid - pool 2
 - Cone, Pyramid, Torus, Prism - pool 3
 4. Number of objects in scene (init in Main VC: sceneComplexity)
 Approach to calculate sceneComplexity: Calculate number of optimum tiles which can be fit onto
 a detected plane. Choose a random number of tiles out of total tiles and throw in those many
 number of shapes onto those particular tiles. Let's say total number of tiles we have across all
 PlaneAnchorNodes is 25, we choose a number 16 (which is the complexity - since more
 number of objects increases confusion), we choose 16 random tiles to place these
 objects. As we go along we increase this complexity.
 
 Complexity is deemed to be higher for objects from pools higher in hierarachy (pool3 >> pool1).
 Hence, probability array, such as [0.8, 0.2, 0.0] will be used to determine the object which is
 generated when the associated function is called from main VC. Here, when associated function is
 called from main VC, object generated has 80% chance it came from pool1, and 20% chance it came
 from pool3
 */

import Foundation

class Brain {
    
    let colors = ["red", "blue", "green", "white", "black", "yellow"]
    
    private let shapesWithDifficultyOne = ["circle", "rectangle", "square", "triangle"]
    private let shapesWithDifficultyTwo = ["cube", "cylinder", "sphere", "cuboid"]
    private let shapesWithDifficultyThree = ["cone", "pyramid", "torus", "prism"]
    
    // Collection of array of all shapes
    var collectionOfShapes: [[String]] {
        get {
            var result: [[String]] = []
            result.append(shapesWithDifficultyOne)
            result.append(shapesWithDifficultyTwo)
            result.append(shapesWithDifficultyThree)
            return result
        }
    }
    
    // Generate objects from the three pools using probabilities of objects stemming from a particular
    // pool
    private func generateRandomObjectWith(_ shapes: [[String]], _ probabilities: [Double]) -> String {
        let result = randRange(lower: 1, upper: 10)
        let cumProb = calculateCumulativeProbabilities(with: probabilities)
        if result <= Int(10 * cumProb.first!) {
            return shapes.first![randRange(lower: 0, upper: (shapes.first?.count)! - 1)]
        } else if result <= Int(10 * cumProb[1]) {
            return shapes[1][randRange(lower: 0, upper: (shapes[1].count) - 1)]
        } else {
            return shapes.last![randRange(lower: 0, upper: (shapes.last?.count)! - 1)]
        }
    }
    
    // Combine object generated from 'generateRandomObjectWith(...)' with random color from color
    // array
    func generateRandomObjectWithColor(using individualProbabilities: [Double]) ->
        (shape: String, color: String) {
        let shape = generateRandomObjectWith(collectionOfShapes, individualProbabilities)
        let color = colors[randRange(lower: 0, upper: colors.count - 1)]
        return (shape: shape, color: color)
    }
    
    // For the lack of a better solution, below is array of individual probabilities.
    // Index of this array will be stored in userdefaults and will be used to progress
    // further. Last one of this array is the generic case when all levels for a user has
    // been exhausted, this will be the fallback untill user RESETS it. @TODO: How to allow
    // user to reset?
    let arrayOfProbabilities: [[Double]] = [
        [1.0, 0.0, 0.0],
        [0.9, 0.1, 0.0],
        [0.8, 0.2, 0.0],
        [0.7, 0.3, 0.0],
        [0.6, 0.4, 0.0],
        [0.5, 0.4, 0.1],
        [0.4, 0.5, 0.1],
        [0.3, 0.6, 0.1],
        [0.2, 0.6, 0.2],
        [0.1, 0.7, 0.2],
        [0.0, 0.8, 0.2],
        [0.0, 0.7, 0.3],
        [0.0, 0.6, 0.4],
        [0.0, 0.5, 0.5],
        [0.0, 0.4, 0.6],
        [0.0, 0.3, 0.7],
        [0.0, 0.2, 0.8],
        [0.2, 0.4, 0.4]
    ]

    
    // MARK: - Helper Functions - randRange, cumulativeProbabilities
    
    // Private method to generate random Int between two given numbers.
    private func randRange (lower: Int, upper: Int) -> Int {
        return Int(UInt32(lower) + arc4random_uniform(UInt32(upper) - UInt32(lower) + 1))
    }
    
    /*
     Private method to generate cumulative probabilities from individual probabilities
     Used for generating shapes randomly given probabilities of generation
     If individual probabilities are 0.1, 0.3, 0.5, & 0.1, corresponding cumulative
     probabilities would be 0.1, 0.4, 0.9, 1.0
     */
    private func calculateCumulativeProbabilities(with probabilities: [Double]) -> [Double] {
        var result: [Double] = []
        var cumsum = 0.0
        for probability in probabilities {
            cumsum += probability
            //        cumsum = round(cumsum, to: 2)
            result.append(cumsum)
        }
        return result
    }
    
}

