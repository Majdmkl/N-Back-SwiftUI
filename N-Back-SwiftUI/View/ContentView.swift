//
//  ContentView.swift
//  N-Back-SwiftUI
//
//  Created by Majid Makhoul on 2025-11-07.
//

import SwiftUI


// Our custom view modifier to track rotation and
// call our action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

struct ContentView: View {
    @EnvironmentObject var vm: N_Back_SwiftUIVM

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                
                Text("High-Score: \(vm.highScore)")
                    .font(.title2)
                
                // Show base-settings in homescreen
                Text("Settings: chosen mode • n=\(vm.n) • intervall=\(String(format: "%.1f", vm.interval))s • events=\(vm.totalEvents)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Text("Choose game mode").font(.headline).padding(.top,8)
                
                HStack(spacing: 24) {
                    NavigationLink {
                        GameView(mode: .visual)
                    } label: {
                        ImageIconView() // Existing button component
                    }
                    NavigationLink {
                        GameView(mode: .audio)
                    } label: {
                        SoundIconView() // Existing button component
                    }
                }
                
                NavigationLink {
                    DualGameView()
                } label: {
                    Label("Dual", systemImage: "rectangle.3.group.bubble.left.fill").padding().foregroundColor(.white).background(Color.blue).cornerRadius(45).shadow(radius: 4)
                }
            Spacer()
        }
        .padding()
        .navigationTitle("N-Back Game")
        .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}



struct ContentView_Previews:  PreviewProvider {
    static var previews: some View {
        Group{
            ForEach(["iPhone SE (3rd generation)", "iPhone 14 Pro Max"], id: \.self) { deviceName in
                           ContentView()
                                .previewDevice(PreviewDevice(rawValue: deviceName))
                                .previewDisplayName(deviceName)
                                .environmentObject(N_Back_SwiftUIVM())
                      }
            
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 Pro Max Landscape")
                .environmentObject(N_Back_SwiftUIVM())
                .previewInterfaceOrientation(.landscapeRight)
        }
        
    }
}





