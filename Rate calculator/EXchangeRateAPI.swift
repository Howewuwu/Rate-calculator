//
//  EXchangeRateAPI.swift
//  Rate calculator
//
//  Created by Howe on 2023/10/30.
//

// 引入必要的模組
import Foundation
import Alamofire

// 定義一個符合 Decodable 協議的結構，用於解碼 JSON
struct ExchangeRateResponse: Decodable {
    let result: String
    let documentation: String
    let terms_of_use: String
    let time_last_update_unix: Int
    let base_code: String
    let conversion_rates: [String: Double]
}


// 定義 fetchExchangeRates 函數
// 這個函數接受一個尾隨閉包作為參數，這個閉包會在 HTTP 請求完成後被調用。
func fetchExchangeRates(completion: @escaping (ExchangeRateResponse?, Error?) -> Void) {
    
    // 定義 API 的 URL 字串
    // 我們將從這個 URL 獲取匯率資料
    let url = "https://v6.exchangerate-api.com/v6/2aacc8dc47c13303532f484b/latest/USD"
    
    // 使用 Alamofire 的 AF.request 方法來發送 HTTP GET 請求到上面的 URL
    // responseDecodable(of: ExchangeRateResponse.self) 表示我們期望的回應可以被解碼為 ExchangeRateResponse 結構
    AF.request(url).responseDecodable(of: ExchangeRateResponse.self) { response in
        
        // 處理 HTTP 回應
        // 使用 switch 來根據 response.result 的值來執行不同的操作
        switch response.result {
        case .success(let exchangeRateResponse):
            // 如果請求成功，response.result 會是 .success
            // 我們取出它的 associated value，也就是 exchangeRateResponse，並傳遞給尾隨閉包
            // 錯誤為 nil，因為請求成功了
            completion(exchangeRateResponse, nil)
        case .failure(let error):
            // 如果請求失敗，response.result 會是 .failure
            // 我們取出它的 associated value，也就是 error，並傳遞給尾隨閉包
            // exchangeRateResponse 為 nil，因為請求失敗了
            completion(nil, error)
        }
    }
}



// 使用方法示例
/*
 fetchExchangeRates { (exchangeRateResponse, error) in
 if let error = error {
 // 處理錯誤
 print("Error: \(error)")
 } else if let exchangeRateResponse = exchangeRateResponse {
 // 處理成功情況，印出結果和特定的匯率（例如：美元對台幣）
 print("Result: \(exchangeRateResponse.result)")
 print("USD to TWD: \(exchangeRateResponse.conversion_rates["TWD"] ?? 0.0)")
 // 其他處理邏輯
 }
 }
 */


