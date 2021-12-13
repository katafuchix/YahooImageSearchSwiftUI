//
//  ContentView.swift
//  YahooImageSearchSwiftUI
//
//  Created by cano on 2021/05/09.
//

import SwiftUI
import QGrid
import ActivityIndicatorView

struct ContentView: View {
    
    @StateObject var imageLoader = ImageLoader()
    
    @State var text = ""
    @State private var buttonEnabled = false
    @State private var imageDatas = [ImageData]()
    @State var isLoading: Bool = false
    @State private var showLoadingIndicator: Bool = false
    
    var body: some View {
        return VStack {
            Spacer().frame(height: 20)
            HStack(spacing: 20) {
                Spacer()
                TextField("検索キーワード",
                            text: $text,
                            onEditingChanged: { editing in }
                ).onChange(of: text) {
                    // 3文字以上でボタン押下可能
                    self.buttonEnabled = $0.count >= 3
                }
                .textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                Spacer()
            }
            Button(action: {
                // キーボードを下げる
                UIApplication.shared.endEditing()
                
                // 検索
                if #available(iOS 15.0, *) {
                    Task {
                        do {
                            // 画像検索
                            try await imageLoader.search(text)
                        } catch {
                            print(error)
                        }
                    }
                } else {
                    // 画像検索
                    self.loadData()
                }
                
            }) {
                Text ("Search")
            }.disabled(buttonEnabled == false)
            Spacer()
            
            // ローディング
            ActivityIndicatorView(isVisible: $showLoadingIndicator, type: .growingArc(.black))
                .frame(width: 50.0, height: 50.0)
            
            // 検索結果をグリッド表示
            
            if #available(iOS 15.0, *) {
                QGrid(imageLoader.imageList, columns: 3,
                      columnsInLandscape: 5,
                      vSpacing: 16, hSpacing: 8,
                      vPadding: 16,hPadding: 16,
                      isScrollable: true, showScrollIndicators: false
                ) { data in
                    GridCell(imageData: data, container: ImageContainer(from: data.url))
                }
            } else {
                QGrid(self.imageDatas,
                      columns: 3,
                      columnsInLandscape: 5,
                      vSpacing: 16, hSpacing: 8,
                      vPadding: 16,hPadding: 16,
                      isScrollable: true, showScrollIndicators: false
                ) { data in
                    GridCell(imageData: data,  container: ImageContainer(from: data.url))
                }
            }
        }
    }
    
    // iOS15 以前の処理
    // データ取得 VMなどで別にしたい
    func loadData() {
        // 検索結果を初期化
        self.imageDatas = []
        self.isLoading  = true
        self.showLoadingIndicator = true
        // Yahoo画像検索
        let urlStr =  "https://search.yahoo.co.jp/image/search?ei=UTF-8&p=\(text)"
        let url = URL(string:urlStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!

        // User-Agentに自分のメールアドレスをセットしておく
        var request = URLRequest(url: url)
        request.addValue("katafuchix@gmail.com", forHTTPHeaderField: "User-Agent")
        
        /// リクエストの実行
        URLSession.shared.dataTask(with: request) { data, response, error in
 
            guard let data = data else { return }
            guard let str = String(data: data, encoding: .utf8) else { return }
            
            // HTML内の画像検索結果imgタグsrcを取得
            let pattern = "(https?)://msp.c.yimg.jp/([A-Z0-9a-z._%+-/]{2,1024}).jpg"
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let results = regex.matches(in: str, options: [], range: NSRange(0..<str.count))
            
            self.imageDatas = results.map({ result -> String in
                let start = str.index(str.startIndex, offsetBy: result.range(at: 0).location)
                let end = str.index(start, offsetBy: result.range(at: 0).length)
                let text = String(str[start..<end])
                return text
            })
            .reduce([], { $0.contains($1) ? $0 : $0 + [$1] })  // ユニーク
            .map( { ImageData(url: URL(string: $0)! )}) // 加工
            
            self.showLoadingIndicator = false
        }.resume()      // 開始処理
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
