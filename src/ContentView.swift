import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \Board.createdAt) private var boards: [Board]
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: UUID?

    private let sidebarWidth: CGFloat = 300

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                SidebarView(selection: $selection)
                    .frame(maxWidth: sidebarWidth, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .top)

                detail
                    .ignoresSafeArea(.container, edges: .top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea(.all, edges: .top)

            // Draw the divider above the HStack so its shadow can bleed into the
            // canvas without becoming another pane or changing either width.
            GLWNSidebarBoundaryDivider()
                // The divider's line is on the overlay's trailing edge, so the
                // overlay starts just inside the sidebar and ends at the pane
                // boundary. This keeps the shadow on the sidebar side.
                .offset(x: sidebarWidth - GLWNSidebarBoundaryDivider.overlayWidth)
                .ignoresSafeArea(.container, edges: .top)
                .frame(width: GLWNSidebarBoundaryDivider.overlayWidth)
                .frame(maxHeight: .infinity)
                .accessibilityHidden(true)
        }
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        // Keep both panes visually active while the app is active. Losing window
        // focus may still dim the whole scene.
        .environment(\.appearsActive, scenePhase == .active)
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
