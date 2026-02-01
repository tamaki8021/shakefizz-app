import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = GameViewModel()

  var body: some View {
    Group {
      switch viewModel.gameState {
      case .selection:
        DrinkSelectionView(viewModel: viewModel)
      case .safetyWarning:
        SafetyWarningView(viewModel: viewModel)
      case .playing:
        PlayScreenView(viewModel: viewModel)
      case .result:
        ResultView(viewModel: viewModel)
      }
    }
    .statusBar(hidden: true)
  }
}
