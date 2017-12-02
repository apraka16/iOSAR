//
//  Brain.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 30/11/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

class Brain {
    
    private let maxNumberOfObjects = 5
    
    let colors = ["red", "blue", "green", "white", "black", "yellow"]
    
    private let shapesWithDifficultyOne = ["circle", "rectangle", "square"]
    private let shapesWithDifficultyTwo = ["cube", "cylinder", "sphere"]
    private let shapesWithDifficultyThree = ["cone", "pyramid", "torus", "cuboid"]
    
    var shapes: [String] {
        get {
            return shapesWithDifficultyOne + shapesWithDifficultyTwo + shapesWithDifficultyThree
        }
    }
    
    // Color, along with their scores
    var colorScores: [(name: String, score: Int)] {
        get {
            var result: [(name: String, score: Int)] = []
            for color in colors {
                result.append((name: color, score: 1))
            }
            return result
        }
    }
    
    // Shapes, along with scores
    // Generate array of shapes with score of 1
    private var shapesWithDifficultyOneScores: [(name: String, score: Int)] {
        get {
            var result: [(name: String, score: Int)] = []
            for shape in shapesWithDifficultyOne {
                result.append((name: shape, score: 1))
            }
            return result
        }
    }
    // Generate array of shapes with score of 2
    private var shapesWithDifficultyTwoScores: [(name: String, score: Int)] {
        get {
            var result: [(name: String, score: Int)] = []
            for shape in shapesWithDifficultyTwo {
                result.append((name: shape, score: 2))
            }
            return result
        }
    }
    // Generate array of shapes with score of 3
    private var shapesWithDifficultyThreeScores: [(name: String, score: Int)] {
        get {
            var result: [(name: String, score: Int)] = []
            for shape in shapesWithDifficultyThree {
                result.append((name: shape, score: 3))
            }
            return result
        }
    }
    
    // Complete Array of Shapes and their scores
    private var shapesScore: [(name: String, score: Int)] {
        get {
            return shapesWithDifficultyOneScores + shapesWithDifficultyTwoScores + shapesWithDifficultyThreeScores
        }
    }
    
    // Complete Array of Number of Objects, Color of Objects, Shapes of Objects and
    // their scores
    private var scenarios: [(number: Int, shape: String, color: String, score: Int)] {
        get {
            var result: [(number: Int, shape: String, color: String, score: Int)] = []
            for i in 1...maxNumberOfObjects {
                for shape in shapesScore {
                    for color in colorScores {
                        result.append((number: i, shape: shape.name, color: color.name, score: i*shape.score*color.score))
                    }
                }
            }
            return result
        }
    }
    
    // Output of array only for a particular score
    func getScenarios(expectedScore: Int) -> [(number: Int, shape: String, color: String, score: Int)] {
        var result: [(number: Int, shape: String, color: String, score: Int)] = []
        for scenario in scenarios {
            if scenario.score == expectedScore {
                result.append(scenario)
            }
        }
        
        return result
    }
    
}

