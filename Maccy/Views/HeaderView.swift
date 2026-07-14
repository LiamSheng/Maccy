import Defaults
import SwiftUI

struct HeaderView: View {
  @State private var appState = AppState.shared

  let controller: SlideoutController
  @FocusState.Binding var searchFocused: Bool

  @Default(.compactMode) private var compactMode

  var previewPlacement: SlideoutPlacement {
    return controller.placement
  }

  // In compact mode items are hidden unless a search query is entered
  private var itemsHidden: Bool {
    compactMode && appState.history.searchQuery.isEmpty
  }

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      HStack(alignment: .center, spacing: 0) {
        ListHeaderView(
          searchFocused: $searchFocused,
          searchQuery: $appState.history.searchQuery
        )
        .padding(.horizontal, Popup.horizontalPadding)

        ToolbarButton {
          controller.togglePreview()
        } label: {
          Image(
            systemName: previewPlacement == .right
              ? "sidebar.left" : "sidebar.right"
          )
        }
        .shortcutKeyHelp(
          name: .togglePreview,
          key: "PreviewKey",
          tableName: "PreviewItemView",
          replacementKey: "previewKey"
        )
        .padding(.trailing, Popup.horizontalPadding)

        // Compact mode toggle: ">" means items are hidden, "v" means expanded
        ToolbarButton {
          compactMode.toggle()
          if appState.history.searchQuery.isEmpty {
            if compactMode {
              // Drop the selection so the preview doesn't auto-open
              appState.navigator.select(item: nil)
            } else {
              appState.navigator.select(
                item: appState.history.unpinnedItems.first ?? appState.history.pinnedItems.first
              )
            }
          }
          appState.popup.needsResize = true
        } label: {
          Image(systemName: itemsHidden ? "chevron.right" : "chevron.down")
        }
        .help(Text(verbatim: itemsHidden ? "Show history items" : "Hide items unless searching"))
        .padding(.trailing, Popup.horizontalPadding)
      }
      .opacity(appState.searchVisible ? 1 : 0)
      .layoutPriority(1)
    }
    .padding(.top, Popup.verticalPadding)
    .padding(.horizontal, 10)
    .animation(.default.speed(3), value: appState.navigator.leadSelection)
    .background(.clear)
    .frame(maxHeight: !appState.searchVisible ? 0 : nil, alignment: .top)
    .readHeight(appState, into: \.popup.headerHeight)
  }
}
