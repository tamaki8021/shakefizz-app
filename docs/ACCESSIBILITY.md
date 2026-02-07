# アクセシビリティ仕様

全画面で適用する、アクセシビリティ・ユーザビリティのための数値基準と実装ルールをまとめます。

> **関連ドキュメント**: 
> - [UI画面仕様](UI-DESIGN.md) - 各画面の詳細UI仕様
> - [ナビゲーション仕様](NAVIGATION.md) - 画面遷移・戻るボタンの挙動

---

## タップ領域の最小サイズ

- **主要ボタン**（START SHAKING, GOT IT!, TRY AGAIN など）: **最小 44pt × 44pt**（iOS Human Interface Guidelines 準拠）
- **ナビゲーションボタン**（戻る、×、フッターアイコン）: **最小 44pt × 44pt**
- **小さなボタン**（シェアアイコン、設定など）: **最小 44pt × 44pt** を確保（アイコンは小さくても、タップ領域は広げる）
- **カード・リスト項目**: 全体がタップ可能、高さ **最小 60pt**

**実装時の注意**: SwiftUI の場合 `.frame(minWidth: 44, minHeight: 44)` または `.contentShape(Rectangle())` でタップ領域を確保。UIKit の場合 `hitTest` でタップ範囲を調整。

---

## フォントサイズ・可読性

| 要素 | 最小フォントサイズ | 推奨 |
|------|-------------------|------|
| **本文** | 14pt | 16pt（読みやすさ優先） |
| **ラベル・補足** | 12pt | 14pt |
| **ボタンテキスト** | 16pt | 18pt（太字） |
| **見出し** | 24pt | 32pt〜 |
| **メイン数値**（スコア等） | 48pt | 72pt〜（インパクト） |

**フォントウェイト**: 本文は Regular、強調・ボタンは Bold、見出しは Extra Bold を基本とします。

**行間**: 本文は 1.4〜1.6 倍、タイトルは 1.2 倍。

---

## コントラスト比（WCAG 2.1 準拠）

| 組み合わせ | 比率目標 | 検証方法 |
|-----------|----------|----------|
| **白文字 on ダークグレー/黒** | 4.5:1 以上（AA レベル） | 実機・シミュレータで確認 |
| **ネオンシアン・ティール on 黒** | 4.5:1 以上 | 明るさを調整（必要に応じてシアンを明るく） |
| **黄色（警告） on 黒** | 4.5:1 以上 | 黄色の明度を上げる |
| **グレー（補足文） on 黒** | 3:1 以上 | 読めればよい（非主要情報） |

**チェックツール**: WebAIM Contrast Checker、または Xcode の Accessibility Inspector。

---

## VoiceOver（スクリーンリーダー）対応

### 読み上げ順の定義（主要画面のみ）

- **飲み物選択**: 「SHAKE FIZZ」→「SELECT YOUR ULTIMATE FIZZ」→ 各缶カード（「ULTRA COLA, FIZZ 85%, タップして選択」）→「START SHAKING ボタン」→ フッターナビ
- **安全警告**: 「SAFETY FIRST」→「HOLD TIGHT WITH BOTH HANDS」→ 補足文 → 「GOT IT ボタン、タップして続ける」
- **プレイ**: カウントダウン中は「3, 2, 1, GO」を読み上げ、プレイ中は「タイマー: 残り 12秒」など定期的に読み上げ
- **結果**: 「MISSION COMPLETE, SHAKEN」→「RANK S」→「18.7メートル」→「NEW PERSONAL RECORD」→「TRY AGAIN ボタン」→「CHANGE DRINK ボタン」

### アクセシビリティラベル

- **ボタン**: `accessibilityLabel` で「戻る」「プレイ開始」など明確なラベルを設定
- **画像アイコン**: 代替テキスト（「コーラ缶」「稲妻アイコン」など）を設定
- **装飾的な要素**: `accessibilityHidden = true` で読み上げをスキップ

**実装例（SwiftUI）**:
```swift
Button("START SHAKING") {
    // アクション
}
.accessibilityLabel("プレイ開始ボタン")
.accessibilityHint("タップしてゲームを開始します")
```

**実装例（UIKit）**:
```swift
button.accessibilityLabel = "プレイ開始ボタン"
button.accessibilityHint = "タップしてゲームを開始します"
```

---

## その他のユーザビリティ配慮

- **ダークモード専用**: 現状はダークテーマのみですが、ライトモードは非対応（ネオンの映える暗い背景が核心）
- **ハプティクス**: 設定でオフにできる（UserSettings.hapticsEnabled）
- **音声**: 設定でオフにできる（UserSettings.soundEnabled）
- **画面向き**: 縦向き（Portrait）固定。横向きは非対応（片手で持って振る想定）

---

*詳細なUI仕様については [UI-DESIGN.md](UI-DESIGN.md) を参照してください。*
