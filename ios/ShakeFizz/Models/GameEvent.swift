import Foundation

enum GameEvent {
  /// シェイク開始（最初の1振りを検知した瞬間）
  case shakeStart
  
  /// シェイク中（連続して振っている状態・炭酸が溜まる音など）
  case shaking
  
  /// シェイク終了（手が止まった、または時間切れ時点）
  case shakeEnd
  
  /// 缶の開栓（プルタブを開ける「カチッ」というアクション）
  case canOpen
  
  /// 炭酸大爆発（結果画面に入り、空高く噴射するメイン演出の瞬間）
  case explosion
  
  /// スコア表示（メーターがポップアップして結果が出る時）
  case scoreAppear
  
  /// UIボタンタップ（「もう一度遊ぶ」や「設定」などのシステム操作時）
  case buttonTap
  
  /// ランクアップ・自己ベスト更新など、特別な成功演出時
  case rankUp
  
  /// リザルト画面で1度だけ鳴るシュワシュワという余韻の環境音
  case resultAmbient
  
  /// ゲーム開始（カウントダウン後のプレイ開始・BGM開始）
  case gameStart
  
  /// ゲーム終了（タイムアップ・プレイ中BGM停止）
  case gameEnd
  
  /// ホーム画面・メニュー用のメインBGM
  case menuBGM
  
  /// 任意のBGM強制停止
  case stopBGM
  
  /// ヘルプ画面でのシェイカーのループ再生用
  case helpShake
}
