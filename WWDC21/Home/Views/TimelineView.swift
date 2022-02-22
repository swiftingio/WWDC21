//
//  TimelineView.swift
//  WWDC21
//
//  Created by mazurkk3 on 22/02/2022.
//

import Foundation
import SpriteKit
import SwiftUI

struct BackgroundTimelineView: View {
    static var generateStars: [String] {
        var result: [String] = []
        for _ in 1 ..< Int.random(in: 30 ..< 70) {
            result.append("✦")
        }
        return result
    }

    let stars: [String]
    let grid: [Int: (CGFloat, CGFloat)]

    init(stars: [String]) {
        self.stars = stars
        var result: [Int: (CGFloat, CGFloat)] = [:]
        for (index, _) in stars.enumerated() {
            let xCoordinate = CGFloat.random(in: 0 ..< 1)
            let yCoordinate = CGFloat.random(in: 0 ..< 1)
            result[index] = (xCoordinate, yCoordinate)
        }
        grid = result
    }

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation) { timeline in
                ZStack {
                    Color.black
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    let angle = Angle.degrees(now.remainder(dividingBy: 360))
                    makeStarLayer(time: now, angle: angle, proxy: proxy, color: Color(uiColor: .lightGray))
                }
            }
        }
    }

    @ViewBuilder
    func makeStarLayer(time _: TimeInterval, angle: Angle, proxy: GeometryProxy, color: Color) -> some View {
        Canvas { context, _ in
            for (index, star) in stars.enumerated() {
                guard let coordinate = grid[index] else {
                    return
                }
                let xCoordinate = proxy.size.width * coordinate.0
                let yCoordinate = proxy.size.height * coordinate.1
                let image = context.resolve(
                    Text(star)
                        .font(.system(size: 10))
                        .foregroundColor(color)
                )
                context.rotate(by: angle)
                context.draw(image, at: .init(x: xCoordinate, y: yCoordinate))
            }
        }
    }
}
