# ShakeFizz

スマホを炭酸飲料の缶に見立てて振る、超楽しいエンタメゲームアプリ！  
思いっきり振って、どれだけ高く噴き出すかを競おう！ 🚀

## コンセプト
スマホ画面全体を「缶の中身の窓」にして、液体が激しく揺れ（sloshing）、泡が弾け、振りが強くなると炭酸が上へ噴き上がる！  
噴射の高さ（メートル単位）で友達とスコアを競う、中毒性抜群の遊びアプリです。

## 遊び方
1. 好きな飲み物を選ぶ（コーラ、レモンソーダ、エナドリなど）
2. **スマホを両手でガッチリ持って！** ⚠️ 落とさないでね
3. スタート！（3…2…1…GO!）
4. 思いっきり振る！（強さ・長さで噴射量が変わる）
5. **最高噴射高さを競え！**（何メートルまで届いた？ ランク発表）

## スクリーンショット
<!-- ここに実際の画像をアップロードして挿入 -->

![Drink Selection Screen](screenshots/drink-selection.png)  
*飲み物選択画面*

![Play Screen - Sloshing Liquid](screenshots/play-screen.png)  
*プレイ画面（缶内部ビュー + 液体揺れ）*

![Result Screen - High Spray](screenshots/result-screen.png)  
*結果画面（最高高さ18.7m！）*

## 主な機能
- **没入型アニメーション**: 画面=缶の中身。Accelerometerでリアルタイムに液体が揺れる
- **高さ競争**: 噴射高さをメーターで視覚化（0m〜30m+）、物理風計算で最大到達点決定
- **粒子エフェクト**: 泡・液体滴が上へ噴き上がる派手な演出
- **ランクシステム**: C/B/A/S で評価（20m超えでSランク！）
- **安全重視**: 振る前の警告表示
- **シェア機能**: 結果をSNSで友達に自慢

## 技術スタック
- React Native + Expo (SDK 51+)
- expo-sensors (Accelerometer)
- react-native-reanimated (液体波・粒子アニメーション)
- expo-av (シュワーッ音エフェクト)
- @react-navigation/native-stack
- NativeWind (Tailwind CSS風スタイリング)

## 開発状況
- bolt.new でプロトタイプ検証済み
- 本番開発中（Antigravity / Cursor 使用）
- #BuildInPublic で進捗公開中 → [@tamo38570240](https://x.com/tamo38570240)

## 今後の予定
- オンラインランキング（Firebase）
- モード追加（タイムアタック / エンドレス）
- カスタム缶デザイン（有料）
- App Store / Google Play 公開

## フィードバック大歓迎！
このアプリ面白そう？ 改善点やアイデアあったらぜひ教えてください！  
Xで気軽にメンション or Issue立ててね 😄

#ShakeFizz #indiedev #ReactNative #Expo
