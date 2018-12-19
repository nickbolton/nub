//
//  DispatchTaskPerformer.swift
//  Nub
//
//  Created by Nick Bolton on 7/11/18.
//
import Foundation

protocol DispatchTaskPerformer {
    func performTaskInBackground(_ task: @escaping ()->())
    func performTaskOnMainThread(_ task: @escaping ()->())
    func performTaskAfterDelay(_ delay: Double, task: @escaping ()->())
}

extension DispatchTaskPerformer {
    
    func performTaskInBackground(_ task: @escaping ()->()) {
        DispatchQueue.global(qos: .default).async(execute : task)
    }
    
    func performTaskOnMainThread(_ task: @escaping ()->()) {
        DispatchQueue.main.async(execute: task)
    }
    
    func performTaskAfterDelay(_ delay: Double, task: @escaping ()->()) {
        let delay = delay * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: task)
    }
}
