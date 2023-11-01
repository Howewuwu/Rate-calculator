//
//  CalculatorViewController.swift
//  Rate calculator
//
//  Created by Howe on 2023/10/25.
//

// 引入 UIKit 框架以使用 iOS 的 UI 元素
import UIKit

// 引入 Alamofire 框架以便執行網絡請求
import Alamofire



// 定義 CalculatorViewController 類，繼承自 UIViewController
class CalculatorViewController: UIViewController {
    
    // 使用 @IBOutlet 宣告 UI 元素的變數，這些變數用於與 Storyboard 中的 UI 元素進行綁定
    
    // 貨幣 A 和貨幣 B 的標籤
    @IBOutlet weak var CurrencyALabel: UILabel!
    @IBOutlet weak var CurrencyBLabel: UILabel!
    
    // 用於顯示計算結果的標籤
    @IBOutlet weak var resultALabel: UILabel!
    @IBOutlet weak var resultBLabel: UILabel!
    
    // 宣告計算器的按鈕：清除、後退和切換貨幣
    @IBOutlet weak var cleanAllButtonOutlet: UIButton!
    @IBOutlet weak var backwardButtonOutlet: UIButton!
    @IBOutlet weak var changeCurrencyABButtonOutlet: UIButton!
    
    // 操作符按鈕（例如加、減、乘、除等）
    @IBOutlet var operatorButtonOutlets: [UIButton]!
    
    // 百分比和小數點按鈕
    @IBOutlet weak var percentageButtonOutlet: UIButton!
    @IBOutlet weak var dotButtonOutlet: UIButton!
    
    // 等於按鈕
    @IBOutlet weak var equalButtonOutlet: UIButton!
    
    // 數字按鈕（0-9）
    @IBOutlet var numberButtonOutlets: [UIButton]!
    
    // 顯示今天日期和匯率資訊的標籤
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var exchangeInfoLabel: UILabel!
    
    // 儲存計算元素（數字和操作符）的陣列
    var calculationElements: [String] = []
    
    // 儲存上一次計算的結果
    var lastResult: Double?
    
    // 用於標記是否為第一次進行計算
    var isFirstOperation: Bool = true
    
    // 用於標記是否可以添加小數點
    var canAddDot: Bool = true
    
    // 儲存匯率的字典，鍵是貨幣代碼，值是匯率
    var exchangeRates: [String: Double]?
    
    
    
    // MARK: - viewDidLoad Section
    
    
    // 這個方法在視圖控制器的視圖加載後自動調用
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 調用 initUI 方法來初始化用戶界面
        initUI()
    }
    
    
    
    
    // MARK: - IBAction Section
    
    
    // 定義數字按鈕被按下時的動作
    @IBAction func numberPressed(_ sender: UIButton) {
        
        // 從按鈕的標題中獲取數字的文字
        if let numberText = sender.titleLabel?.text {
            
            // 檢查是否需要使用上一次計算的結果
            if let lastResult = lastResult, calculationElements.isEmpty {
                
                // 更新結果標籤並將上一次的結果添加到計算元素陣列中
                resultALabel.text = "\(lastResult)"
                calculationElements.append("\(lastResult)")
            }
            
            // 更新用戶界面以及計算元素陣列
            if resultALabel.text == "0" || resultALabel.text == "" {
                resultALabel.text = numberText
            } else {
                // 確保顯示的數字不超過九位
                if resultALabel.text!.count < 9 {
                    resultALabel.text! += numberText
                }
            }
            calculationElements.append(numberText)
        }
        
        // 一旦按下數字，設置 isFirstOperation 為 false
        isFirstOperation = false
        print("calculationElements: \(calculationElements)")
    }
    
    
    
    
    // 定義操作符按鈕（例如 "+"、"-"、"×"、"÷"等）被按下時的動作
    @IBAction func operatorPressed(_ sender: UIButton) {
        
        // 如果這是第一次操作，且沒有上一次的計算結果，則直接返回
        if isFirstOperation && lastResult == nil {
            return
        }
        
        // 從按鈕的標題中獲取操作符的文字
        if let operation = sender.titleLabel?.text {
            // 檢查是否需要使用上一次的結果
            if let lastResult = lastResult, calculationElements.isEmpty {
                if floor(lastResult) == lastResult {
                    // 如果上一次的結果是整數，則轉為 Int 顯示
                    resultALabel.text = "\(Int(lastResult))"
                    calculationElements.append("\(Int(lastResult))")
                } else {
                    // 如果上一次的結果是小數，則直接顯示
                    resultALabel.text = "\(lastResult)"
                    calculationElements.append("\(lastResult)")
                }
            }
            
            // 更新結果標籤和計算元素陣列
            if resultALabel.text != "" {
                resultALabel.text! += operation
                calculationElements.append(operation)
            }
        }
        
        // 重置 canAddDot 變數，允許下一個數字包含小數點
        canAddDot = true
        print("calculationElements: \(calculationElements)")
    }
    
    
    
    
    // 定義等於按鈕被按下時的行為
    @IBAction func equalPressed(_ sender: UIButton) {
        
        // 如果這是第一次操作，則不執行任何計算
        if isFirstOperation == true {
            return
        }
        
        // 計算結果
        if let result = calculateResult() {
            var resultText: String
            if floor(result) == result {
                // 如果結果是整數
                resultText = "\(Int(result))"
            } else {
                // 如果結果不是整數
                resultText = "\(result)"
            }
            
            // 檢查以確保結果不超過九位
            if resultText.count > 9 {
                let index = resultText.index(resultText.startIndex, offsetBy: 9)
                resultText = String(resultText[..<index])
            }
            
            // 更新 resultALabel 的文本
            resultALabel.text = resultText
            // 儲存最後的計算結果
            lastResult = result
            // 重置計算元素陣列為新的結果
            calculationElements = [resultText]
            print("calculationElements: \(calculationElements)")
            
            
            // 如果存在匯率資訊，則進行貨幣轉換
            if let currencyA = CurrencyALabel.text,
               let currencyB = CurrencyBLabel.text,
               let rateA = exchangeRates?[currencyA],
               let rateB = exchangeRates?[currencyB] {
                
                let convertedResult = (result / rateA) * rateB
                
                // 更新 resultBLabel，並保留小數點後三位
                resultBLabel.text = String(format: "%.3f", convertedResult)
            }
        } else {
            
            // 如果計算結果出錯，顯示"錯誤"
            resultALabel.text = "錯誤"
            lastResult = nil
        }
        
        // 重置 isFirstOperation
        isFirstOperation = true
    }
    
    
    
    
    // 定義清除按鈕被按下時的行為
    @IBAction func clearPressed(_ sender: UIButton) {
        initUI()  // 初始化用戶界面
    }
    
    
    
    
    // 定義小數點按鈕被按下時的行為
    @IBAction func dotPressed(_ sender: UIButton) {
        
        // 檢查是否可以添加小數點
        if canAddDot {
            
            // 在結果標籤和計算元素陣列中添加小數點
            resultALabel.text! += "."
            calculationElements.append(".")
            
            // 一旦添加了小數點，禁止再次添加
            canAddDot = false
        }
    }
    
    
    
    
    // 定義百分比按鈕被按下時的行為
    @IBAction func percentPressed(_ sender: UIButton) {
        // 檢查當前文本是否存在，並且長度是否小於或等於9，然後嘗試將其轉換為Double類型
        if let currentText = resultALabel.text, currentText.count <= 9, let currentValue = Double(currentText) {
            // 計算百分比值
            let percentValue = currentValue / 100.0
            var resultText: String
            if floor(percentValue) == percentValue {
                // 如果結果是整數
                resultText = "\(Int(percentValue))"
            } else {
                // 如果結果不是整數
                resultText = "\(percentValue)"
            }
            
            // 更新 resultALabel 和 calculationElements
            resultALabel.text = resultText
            calculationElements = [resultText]
        }
    }
    
    
    
    
    // 定義後退按鈕被按下時的行為
    @IBAction func backward(_ sender: UIButton) {
        // 如果 calculationElements 是空的，則表示剛完成一個運算
        // 這時候使用 lastResult 來初始化它
        if calculationElements.isEmpty, let lastResult = lastResult {
            let resultText = floor(lastResult) == lastResult ? "\(Int(lastResult))" : "\(lastResult)"
            calculationElements = [resultText]
            resultALabel.text = resultText
        }
        
        // 獲取當前在 resultALabel 上顯示的數字
        if var currentText = resultALabel.text, !currentText.isEmpty {
            
            // 如果數字中包含小數點，則允許再次添加小數點
            if currentText.contains(".") {
                canAddDot = true
            }
            
            // 刪除最後一個字符
            currentText.removeLast()
            
            // 更新 resultALabel 的文字
            resultALabel.text = currentText.isEmpty ? "0" : currentText
            
            // 更新 calculationElements
            if let lastElement = calculationElements.last, lastElement.count > 1 {
                // 如果最後一個元素的字符數大於1（例如，是一個多位數字或包含小數點的數字）
                var newLastElement = lastElement
                
                // 刪除最後一個字符
                newLastElement.removeLast()
                
                // 刪除原來的最後一個元素
                calculationElements.removeLast()
                
                // 將新的、經過修訂的最後一個元素添加到陣列中
                calculationElements.append(newLastElement)
            } else {
                
                // 如果最後一個元素只有一個字符（例如，是一個單位數字或運算符）
                // 直接從陣列中刪除
                calculationElements.removeLast()
            }
            
        }
    }
    
    
    
    
    @IBAction func exchange(_ sender: UIButton) {
        
        // Step 1: 互換貨幣
        // 將 CurrencyALabel 和 CurrencyBLabel 的內容互換
        let tempCurrency = CurrencyALabel.text
        CurrencyALabel.text = CurrencyBLabel.text
        CurrencyBLabel.text = tempCurrency
        
        // Step 2: 使用新的匯率重新計算
        // 讀取目前 A 貨幣和 B 貨幣的值，並進行匯率轉換
        if let resultA = Double(resultALabel.text ?? "0"),
           let currencyA = CurrencyALabel.text,
           let currencyB = CurrencyBLabel.text,
           let rateA = exchangeRates?[currencyA],
           let rateB = exchangeRates?[currencyB] {
            
            // 進行匯率計算
            let convertedResult = (resultA / rateA) * rateB
            
            // 只顯示到小數點後三位
            // 將計算結果四捨五入到小數點後三位
            let roundedConvertedResult = Double(String(format: "%.3f", convertedResult)) ?? convertedResult
            resultBLabel.text = String(roundedConvertedResult)
        }
    }
    
    
    
    
    @IBAction func changeBCurrency(_ sender: UITapGestureRecognizer) {
        
        // 輸出觸摸事件到控制台
        print("touch")
        
        // 創建一個動作表單(alert)
        let alert = UIAlertController(title: "選擇幣別", message: nil, preferredStyle: .actionSheet)
        
        // 預定義的貨幣選項
        let currencies = ["JPY", "USD", "EUR", "TWD"]  // 可以添加更多貨幣
        for currency in currencies {
            // 為每一種貨幣添加一個選項
            let action = UIAlertAction(title: currency, style: .default) { _ in
                // 當用戶選擇這個選項後，更新 CurrencyBLabel 的文字
                self.CurrencyBLabel.text = currency
                
                // 調用更新匯率的函數
                self.updateExchangeRate()
            }
            alert.addAction(action)
        }
        
        // 添加一個取消選項
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // 顯示動作表單
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Function Section
    
    
    
    
    func initUI() {
        // 初始化 UI 元素
        resultALabel.text = "0"
        resultBLabel.text = "0"
        
        // 清空計算元素和上次的結果
        calculationElements = []
        lastResult = nil
        
        // 重置第一個運算標記和小數點添加標記
        isFirstOperation = true
        canAddDot = true
        
        // 設置當前的日期和時間
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        formatter.dateFormat = "yyyy/MM/dd/ HH:mm"
        let todayDate = formatter.string(from: date)
        todayDateLabel.text = todayDate
        
        // 發起網絡請求來獲取匯率數據
        fetchExchangeRates { (exchangeRateResponse, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let exchangeRateResponse = exchangeRateResponse {
                print("Result: \(exchangeRateResponse.result)")
                self.exchangeRates = exchangeRateResponse.conversion_rates
            }
        }
        
        // 更新匯率信息標籤
        if let currencyA = CurrencyALabel.text, let currencyB = CurrencyBLabel.text {
            if let rateA = exchangeRates?[currencyA], let rateB = exchangeRates?[currencyB] {
                let convertedRate = (1.0 / rateA) * rateB
                DispatchQueue.main.async {
                    self.exchangeInfoLabel.text = "1 \(currencyA) = \(convertedRate) \(currencyB)"
                }
            }
        }
    }
    
    
    
    
    // 這個函數會在選擇了新的貨幣之後重新計算匯率
    func updateExchangeRate() {
        if let resultA = Double(resultALabel.text ?? "0"),
           let currencyA = CurrencyALabel.text,
           let currencyB = CurrencyBLabel.text,
           let rateA = exchangeRates?[currencyA],
           let rateB = exchangeRates?[currencyB] {
            // 使用新的匯率重新計算 B 貨幣的值
            let convertedResult = (resultA / rateA) * rateB
            
            // 只顯示到小數點後三位
            let roundedConvertedResult = Double(String(format: "%.3f", convertedResult)) ?? convertedResult
            resultBLabel.text = String(roundedConvertedResult)
            
            // 也更新匯率信息標籤
            let convertedRate = (1.0 / rateA) * rateB
            DispatchQueue.main.async {
                self.exchangeInfoLabel.text = "1 \(currencyA) = \(convertedRate) \(currencyB)"
            }
        }
    }
    
    
    
    
    
    // MARK: - Calculation Logic Section
    
    func calculateResult() -> Double? {
        // 初始化數字堆疊和運算符堆疊
        var numStack: [Double] = []
        var opStack: [String] = []
        
        // 用於暫存當前讀取的數字（可能是多位數）
        var currentNumber: String = ""
        
        // 迭代每個計算元素
        for element in calculationElements {
            // 判斷當前元素是否是數字或者是小數點
            if Double(element) != nil || element == "." {
                currentNumber += element
            } else {
                print("currentNumber : \(currentNumber)")
                
                // 如果 currentNumber 是一個有效的數字，則加入 numStack
                if let num = Double(currentNumber) {
                    numStack.append(num)
                    print("0 numStack : \(numStack)")
                }
                // 清空 currentNumber 以便於下次使用
                currentNumber = ""
                
                // 判斷是否需要立即執行運算
                while let lastOp = opStack.last, shouldPerformOperation(lastOp, before: element) {
                    if numStack.count < 2 { return nil }
                    let operand2 = numStack.removeLast()
                    let operand1 = numStack.removeLast()
                    if let result = performOperation(operand1, operand2, with: lastOp) {
                        numStack.append(result)
                    } else {
                        return nil
                    }
                    opStack.removeLast()
                }
                // 將當前運算符加入 opStack
                opStack.append(element)
            }
        }
        
        // 處理最後一個數字
        if let num = Double(currentNumber) {
            numStack.append(num)
            print("1 numStack : \(numStack)")
        }
        
        // 執行剩下的所有運算
        while let lastOp = opStack.last {
            if numStack.count < 2 { return nil }
            let operand2 = numStack.removeLast()
            let operand1 = numStack.removeLast()
            if let result = performOperation(operand1, operand2, with: lastOp) {
                numStack.append(result)
            } else {
                return nil
            }
            opStack.removeLast()
        }
        
        print("2 numStack : \(numStack)")
        return round(numStack.first! * 1000000) / 1000000
    }
    
    
    
    
    // 判斷是否應該先執行 op1 而不是 op2
    func shouldPerformOperation(_ op1: String, before op2: String) -> Bool {
        // 定義運算符的優先級
        let precedence: [String: Int] = ["+": 1, "−": 1, "×": 2, "÷": 2]
        if let precedenceOp1 = precedence[op1], let precedenceOp2 = precedence[op2] {
            // 如果 op1 的優先級大於或等於 op2，則返回 true
            return precedenceOp1 >= precedenceOp2
        } else {
            return false
        }
    }
    
    
    
    
    // 執行具體的運算
    func performOperation(_ operand1: Double, _ operand2: Double, with op: String) -> Double? {
        switch op {
        case "+":
            return operand1 + operand2
        case "−":
            return operand1 - operand2
        case "×":
            return operand1 * operand2
        case "÷":
            // 避免除以零的情況
            if operand2 == 0.0 {
                return nil
            }
            return operand1 / operand2
        default:
            // 未知運算符
            return nil
        }
    }
    
    
    
    
}
