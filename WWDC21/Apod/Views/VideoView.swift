//
//  VideoView.swift
//  WWDC21
//
//  Created by mazurkk3 on 18/02/2022.
//

import AVFoundation
import Foundation
import SwiftUI
import WebKit

struct VideoWebView: UIViewRepresentable {
    let request: URLRequest

    func makeUIView(context _: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(request)
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}
}

#if DEBUG
    struct WebView_Previews: PreviewProvider {
        static var previews: some View {
            VideoWebView(request: URLRequest(url: URL(string: "https://www.apple.com")!))
        }
    }
#endif
