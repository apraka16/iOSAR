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
    - possibly we can include half colors later whose score can be 2
 3. Shape of objects:
    - Circle, Rectangle, Square, Triangle: score of 1
    - Cube, Cylinder, Sphere, Cuboid: score of 2
    - Cone, Pyramid, Torus, Prism: score of 3
 4. Number of objects in scene:
    This is more difficult to calculate.
    Approach: Calculate number of optimum tiles which can be fit onto a detected plane.
    Choose a random number of tiles out of total tiles and throw in those many number of
    shapes onto those particular tiles. Let's say total number of tiles we have across all
    PlaneAnchorNodes is 25, we choose a number 16 (which is the complexity - since more
    number of objects increases confusion), we choose 16 random tiles to place these
    objects. As we go along we increase this complexity. 
 */
import Foundation

class Brain {
    
    let colors = ["red", "blue", "green", "white", "black", "yellow"]
//    let colorsWithDifficultyTwo = ["magenta", "orange", "purple", "gray", "brown", "cyan"]
    
    private let shapesWithDifficultyOne = ["circle", "rectangle", "square", "triangle"]
    private let shapesWithDifficultyTwo = ["cube", "cylinder", "sphere", "cuboid"]
    private let shapesWithDifficultyThree = ["cone", "pyramid", "torus", "prism"]
    
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
    private var scenarios: [(shape: String, color: String, score: Int)] {
        get {
            var result: [(shape: String, color: String, score: Int)] = []
            for shape in shapesScore {
                for color in colorScores {
                    result.append((shape: shape.name, color: color.name, score: shape.score * color.score))
                }
            }
            return result
        }
    }
    
    // Output of array only for a particular score
    func getScenarios(expectedScore: Int) -> [(shape: String, color: String, score: Int)] {
        var result: [(shape: String, color: String, score: Int)] = []
        for scenario in scenarios {
            if scenario.score == expectedScore {
                result.append(scenario)
            }
        }
        return result
    }
    
}

