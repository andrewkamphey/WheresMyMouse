import SwiftUI

// The App Store build's additions to the shared MenuView.

/// The quick toggle in the menu's header.
struct HighlightSwitch: View {
    @EnvironmentObject private var store: PointerStore

    var body: some View {
        Toggle("Show the big pointer", isOn: Binding(get: { store.isHighlightOn }, set: { store.setHighlight($0) }))
            .labelsHidden()
            .toggleStyle(.switch)
            .help("On or off. Also: right-click the menu bar icon, or press \(GlobalShortcut.label)")
    }
}

/// Arrow or halo, next to the Size title.
struct StylePicker: View {
    @EnvironmentObject private var store: PointerStore

    var body: some View {
        Picker("Style", selection: Binding(get: { store.highlightStyle }, set: { store.setHighlightStyle($0) })) {
            ForEach(HighlightStyle.allCases) { Text($0.label).tag($0) }
        }
        .labelsHidden()
        .pickerStyle(.segmented)
        .fixedSize()
        .help("Arrow: a bigger pointer behind yours. Halo: a ring around it.")
    }
}

/// One line under the size slider about what's drawn.
struct HighlightHint: View {
    @EnvironmentObject private var store: PointerStore

    var body: some View {
        Group {
            if !store.isHighlightOn {
                Label("Off: 1× is your own pointer. Turn it on with the switch, a right-click on the icon, or \(GlobalShortcut.label).",
                      systemImage: "info.circle")
            } else if store.highlightStyle == .arrow {
                Label {
                    HStack(spacing: 4) {
                        Text("Your own pointer shows on top.")
                        Button("Match its colors…") { CursorController.openPointerSettings() }
                            .buttonStyle(.link)
                            .foregroundColor(.accentColor)
                            .help("Open Accessibility → Display → Pointer to give the real pointer the same colors")
                    }
                } icon: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }
}
