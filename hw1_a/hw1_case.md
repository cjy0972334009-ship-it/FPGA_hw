# HW1（有 `case` 版本）：三段式 FSM 輪流計數與 PWM 產生器

## 1. 程式簡介

本版本為 HW1 的進階標準化架構，採用硬體描述語言（VHDL）中業界推崇的「Controller（有限狀態機）與 Datapath（資料路徑）解耦」設計模式，並透過 **`case` 敘述**明確定義各個狀態的行為與轉移條件。

相較於單一 `process` 的 `if-else` 寫法，使用 `case` 搭配列舉狀態型態（`state_type`）能讓波形模擬直接顯示具語意化的狀態名稱（如 `COUNT_UP`、`COUNT_DOWN` 或 `RUN_CNT1`、`RUN_CNT2`），大幅提升程式碼的可讀性、除錯效率，以及未來擴充多組狀態（如加入暫停 `IDLE` 或第三組計數器）的彈性。

### 核心功能

* **語意化狀態管理**：利用 `case current_state is` 清晰區分不同計數階段，避免深層巢狀 `if-else` 造成的邏輯混亂。

* **模組化職責分離**：將「狀態轉移判斷」與「計數器加減運算」拆分為獨立的 `process`，杜絕跨區塊多重驅動（Multi-driven）風險。

* **動態上限支援（PWM 演進版）**：可將計數上限參數化（接收外部 `up1`、`up2`），無縫銜接成為 HW2 呼吸燈專題的底層 PWM 波形產生器。

## 2. 狀態機介紹 (FSM)

本架構採用兩狀態的有限狀態機（`COUNT_UP` 與 `COUNT_DOWN`），並可依據設計習慣分為「三段式 FSM（狀態暫存器 + 次態組合邏輯 + 輸出暫存器）」或「握手旗標式 FSM（Controller 監控 `done1` / `done2` 脈衝）」。

### 狀態圖 (State Diagram)

```
stateDiagram-v2
    [*] --> COUNT_UP : rest = '0' (非同步重置)
    
    COUNT_UP : 狀態一：COUNT_UP (上數 / 亮燈計時)
    COUNT_UP : cnt1_reg 持續遞增 (+1)
    COUNT_UP : cnt2_reg 凍結維持原值
    
    COUNT_DOWN : 狀態二：COUNT_DOWN (下數 / 滅燈計時)
    COUNT_DOWN : cnt2_reg 持續遞減 (-1)
    COUNT_DOWN : cnt1_reg 凍結維持原值

    COUNT_UP --> COUNT_UP : cnt1_reg < 9 (未達上限)
    COUNT_UP --> COUNT_DOWN : cnt1_reg >= 9 (達上限，觸發狀態切換)
    
    COUNT_DOWN --> COUNT_DOWN : cnt2_reg > 17 (未達下限)
    COUNT_DOWN --> COUNT_UP : cnt2_reg <= 17 (達下限，觸發狀態切換)

```

### 狀態定義表

| 列舉狀態名稱 | 系統職責 | 計數器 1 (`cnt1`) 動作 | 計數器 2 (`cnt2`) 動作 | `case` 轉移條件 | 
| ----- | ----- | ----- | ----- | ----- | 
| `COUNT_UP` | 第一組計數階段 | 每個時脈遞增 1，滿 9 時歸零。 | 保持凍結不動作。 | 當 `cnt1_reg >= "1001"` 時，次態切換至 `COUNT_DOWN`。 | 
| `COUNT_DOWN` | 第二組計數階段 | 保持 `"0000"` 凍結不動作。 | 每個時脈遞減 1，達 17 時重載 253。 | 當 `cnt2_reg <= "00010001"` 時，次態切換回 `COUNT_UP`。 | 
| `when others` | 容錯安全保護 | 重置為 `"0000"`。 | 重置為 `"11111101"`。 | 發生未預期狀態時，強制導回 `COUNT_UP` 防止當機。 | 

## 3. 程式介紹 (詳細)

以下以最標準的三段式狀態機（`acd.vhd`）為基準，詳細拆解三個獨立 `process` 的運作分工。

### 腳位介面定義 (Entity Port)

* `clk` (in)：系統時脈輸入。

* `rest` (in)：非同步重置訊號（低電位 `'0'` 有效）。

* `cnt1 [3:0]` (out)：第一組計數器輸出（0 \~ 9）。

* `cnt2 [7:0]` (out)：第二組計數器輸出（253 \~ 17）。

### 內部邏輯三區塊拆解

#### (1) Process 1：狀態轉移暫存器 (`proc_state_reg` - Sequential)

* **職責**：純粹作為狀態正反器（State Register），負責在時脈上升緣將組合邏輯算出的「次態（`flag_next_state`）」更新至「現態（`flag_current_state`）」。

* **運作細節**：當 `rest = '0'` 時，非同步強制回到初始狀態 `COUNT_UP`；正常運作時每個時脈週期穩定更新一次狀態。

#### (2) Process 2：次態判斷邏輯 (`proc_next_state` - Combinational)

* **職責**：純組合邏輯區塊，透過 `case flag_current_state is` 根據目前狀態與計數器數值，提前預判下一拍該前往哪個狀態。

* **關鍵設計規範**：

  * **防 Latch 預設值**：在進入 `case` 之前，第一行必先寫上 `flag_next_state <= flag_current_state;`，確保所有未明確賦值的條件分支都有預設路徑，避免合成出意外的組合邏輯鎖存器（Latch）。

  * **嚴禁修改計數器**：此區塊只負責決定 `flag_next_state`，絕不在此對 `cnt1_reg` 或 `cnt2_reg` 進行歸零或賦值，以遵守「單一暫存器僅由單一 Process 驅動」的硬體設計鐵律。

#### (3) Process 3：計數資料路徑暫存器 (`proc_counter_reg` - Sequential)

* **職責**：專責管理所有資料暫存器（`cnt1_reg`、`cnt2_reg`）的實際算術運算與數值重載。

* **運作細節**：

  * 在 `rising_edge(clk)` 觸發後，同樣使用 `case flag_current_state is` 分流處理：

  * **`when COUNT_UP =>`**：檢查 `cnt1_reg < "1001"`，成立則 `+ 1`，否則歸零 `"0000"`（與 Process 2 的狀態切換剛好在同一個時脈邊緣完美對齊）。

  * **`when COUNT_DOWN =>`**：檢查 `cnt2_reg > "00010001"`，成立則 `- 1`，否則重載初值 `"11111101"`。

  * **`when others =>`**：提供完整的異常狀態復原機制，確保電路在雜訊干擾下仍具備自我恢復能力。