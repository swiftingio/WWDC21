//
//  VideoView.swift
//  WWDC21
//
//  Created by mazurkk3 on 18/02/2022.
//

import Foundation
import SwiftUI
import WebKit

struct VideoWebView: UIViewRepresentable {
    let request: URLRequest

    func makeUIView(context _: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        uiView.load(request)
    }
}

#if DEBUG
    struct WebView_Previews: PreviewProvider {
        static var previews: some View {
            VideoWebView(request: URLRequest(url: URL(string: "https://www.apple.com")!))
        }
    }
#endif
