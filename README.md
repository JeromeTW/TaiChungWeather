# 台中天氣(TaiChungWeather)APP說明:
#### 環境:
Swift3.2,僅支援iPhone直式，iOS 10.0+。以支援多國語的架構進行開發。

#### 新的挑戰:
- MVC-n架構。
- 用CoreData作為資料庫。
- 用iOS APP來爬RSS的XML以及HTML。

#### 開發日誌:
##### 2018/02/02:
- 研究并嘗試實作MVC-n架構，最後還是沒有成功。最後將n改為丑丑的Singleton。
##### 2018/02/03:
- 研究RSS的使用。
- 成功使用Ji套件來爬RSS的XML以及HTML。
- 模仿參考資料，成功將資料寫入進CoreData中。
- 將氣象局的自定義字串“Fri, 02 Feb 2018 03:18:25 GMT”轉為iso8061格式。
- 研究NSPredicate的用法。
##### 2018/02/04:
- 嘗試抓蘋果日報的每日一句頁面的HTML，但是只抓到“<script>window.location.href="/recommend/realtime/"</script>”。因為個人對HTML和JavaScript不太熟悉，所以沒有找到Redirect後的URL，只好笨笨地在NetworkController中加一個WKWebview，讓其完成Redirect。但是WKWebview會開啟手機版的蘋果日報首頁。最後讓WKWebview假裝是桌機版的瀏覽器才取得到每日一句的HTML。
- 將每日一句寫入CoreData中。
- 上網找合適的免費icon和背景圖片。最後用免費的icon,自製Launch screen和主頁面的背景圖片。
2018/02/05:
- 實作主頁面UI。
- 檢查網路狀態。

#### 備註:
- 一開啟APP進入主頁面後，會先呈現資料庫中的資料（如果有的話），然後等取回每日一句和氣象預報後，會寫入資料庫，并更新主頁面。
- 主頁面的TableView下拉可以重新下載每日一句和氣象預報（如果沒有正在取得上述任一資料的話）。
- 可以在AppDelegate.swift將clearAllRecord設為true, 如果是在Debug Mode下的話，會清空Core Data的所有資料，模擬第一次開啟APP的狀態。

#### 參考資料:
##### Apple Sample Code:
- https://developer.apple.com/library/content/samplecode/TopSongs/Introduction/Intro.html
- https://developer.apple.com/library/content/samplecode/Earthquakes/Introduction/Intro.html
- https://developer.apple.com/library/content/samplecode/ThreadedCoreData/Introduction/Intro.html
##### 其他:
- https://github.com/itisjoe/swiftgo_files/tree/master/database/coredata
##### 圖片來源:
- https://www.flaticon.com/free-icon/cloud_146518
