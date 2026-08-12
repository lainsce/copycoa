import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \Board.createdAt) private var boards: [Board]
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: UUID?

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
                .navigationSplitViewColumnWidth(
                    min: 300,
                    ideal: 300,
                    max: 300
                )
                .toolbar(removing: .sidebarToggle)
                // Keep the canvas rows at full strength while the app is active. The
                // split view may otherwise apply its inactive appearance to this column
                // as focus moves between the sidebar and the detail canvas.
                .environment(\.appearsActive, scenePhase == .active)
        } detail: {
            detail
                .ignoresSafeArea(.container, edges: .top)
                // A NavigationSplitView can report its detail column as inactive while
                // the sidebar has keyboard focus. Keep the canvas visually active while
                // the app's scene itself is active; losing window focus may still dim it.
                .environment(\.appearsActive, scenePhase == .active)
        }
        .navigationSplitViewStyle(.balanced)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: ensureSelection)
        .onChange(of: boards.count) { _, _ in
            ensureSelection()
        }
        .focusedSceneValue(\.newCanvasAction) {
            addBoard()
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let id = selection, let board = boards.first(where: { $0.id == id }) {
            CanvasView(board: board)
                .id(board.id)
        } else {
            ContentUnavailableView(
                "Select or create a canvas",
                systemImage: "rectangle.dashed"
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func ensureSelection() {
        if boards.isEmpty {
            let board = Board(name: defaultBoardName(number: 1))
            context.insert(board)
            selection = board.id
        } else if selection == nil || !boards.contains(where: { $0.id == selection }) {
            selection = boards.first?.id
        }
    }

    private func addBoard() {
        let board = Board(name: defaultBoardName(number: boards.count + 1))
        context.insert(board)
        selection = board.id
    }

    private func defaultBoardName(number: Int) -> String {
        String(
            localized: "Canvas #\(number)",
            comment: "Default canvas name. The variable is the canvas number."
        )
    }
}
