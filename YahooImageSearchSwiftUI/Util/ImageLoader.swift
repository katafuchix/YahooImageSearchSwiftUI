//
//  ImageLoader.swift
//  YahooImageSearchSwiftUI
//
//  Created by cano on 2021/12/13.
//

import Foundation

class ImageLoader: ObservableObject  {
    
    @Published var imageList: [ImageData] = []
    
    @available(iOS 15.0.0, *)
    func search(_ keyword: String) async throws {
        let urlStr =  "https://search.yahoo.co.jp/image/search?ei=UTF-8&p=\(keyword)"
        let url = URL(string:urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
        
        var request = URLRequest(url: url)
        request.addValue("YOUR EMAIL", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request, delegate:nil)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw ImageError.serverError }
        guard let html = String(data: data, encoding: .utf8) else { throw ImageError.noData }
        
        DispatchQueue.main.async {  // メインスレッドで処理
            self.imageList = []
            // 画像検索結果のHTMLから検索結果の画像URLを正規表現で取得
            let pattern = "(https?)://msp.c.yimg.jp/([A-Z0-9a-z._%+-/]{2,1024}).jpg"
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let results = regex.matches(in: html, options: [], range: NSRange(0..<html.count))
            // 取得した画像URLをImageDataで返す
            self.imageList = results.compactMap { result in
                let start = html.index(html.startIndex, offsetBy: result.range(at: 0).location)
                let end = html.index(start, offsetBy: result.range(at: 0).length)
                let text = String(html[start..<end])
                return text
            }.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
            .map( { ImageData(url: URL(string: $0)! )})
        }
    }
}
