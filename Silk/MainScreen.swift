//
//  MainScreen.swift
//  Silk
//
//  Created by RoyalGraphX on 5/23/23.
//  Assisted by ChatGPT
//

import SwiftUI
import MapKit

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct MainScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isMapFullScreen = false
    @State private var isShowingSettings = false
    @State private var addresses: [String] = [""]
    @State private var isScrollingUp = false
    @State private var scrollOffset: CGFloat = 0
    @State private var currentHour: Int = Calendar.current.component(.hour, from: Date())
    
    @StateObject private var addressSearchManager = AddressSearchManager()
    @State private var textFieldText: String = "" // Add this line
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    ScrollViewReader { scrollViewProxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text("Silk Maps")
                                        .font(.system(size: 28 + (isScrollingUp ? min(-scrollOffset, 0) : 0)))
                                        .fontWeight(.bold)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 80)
                                        .padding(.leading, 16)
                                        .padding(.bottom, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                                            scrollViewProxy.scrollTo("top", anchor: .top)
                                        }
                                        .id("top")

                                    Button(action: {
                                        isShowingSettings = true
                                        print("Gear icon tapped") // Add this line to print a message when the button is tapped
                                    }) {
                                        Image(systemName: "gear")
                                            .font(.title)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 80)
                                            .padding(.trailing, 25)
                                    }
                                    .sheet(isPresented: $isShowingSettings) {
                                        Settings()
                                    }
                                }
                                
                                // Dynamic greeting text
                                HStack {
                                    Text(determineGreeting())
                                        .font(.title3)
                                        .fontWeight(.regular)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .padding(.top, -15)
                                    Spacer()
                                }
                                .padding(.leading, 16)
                                
                                MapView()
                                    .frame(height: 200)
                                    .cornerRadius(16)
                                    .padding(.horizontal, 16)
                                    .onTapGesture {
                                        withAnimation {
                                            isMapFullScreen = true
                                        }
                                    }
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .fullScreenCover(isPresented: $isMapFullScreen) {
                                        ContentView()
                                    }
                                
                                ForEach(addresses.indices, id: \.self) { index in
                                            HStack {
                                                TextField("Enter Address...", text: $addresses[index])
                                                    .padding()
                                                    .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.5))
                                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                                    .cornerRadius(8)
                                                    .frame(height: 60)
                                                    .padding(.horizontal, 16)
                                                    .onChange(of: addresses[index]) { query in
                                                        addressSearchManager.searchCompleter.queryFragment = query
                                                    }
                                                
                                                if index == addresses.indices.last {
                                                    Button(action: {
                                                        addresses.append("")
                                                        scrollViewProxy.scrollTo("address\(addresses.count - 1)", anchor: .bottom)
                                                    }) {
                                                        Image(systemName: "plus")
                                                            .foregroundColor(.gray)
                                                    }
                                                    .padding(.trailing, 16)
                                                } else {
                                                    Button(action: {
                                                        addresses.remove(at: index)
                                                    }) {
                                                        Image(systemName: "minus")
                                                            .foregroundColor(.gray)
                                                    }
                                                    .padding(.trailing, 16)
                                                }
                                            }
                                            .id("address\(index)")
                                            
                                            AddressSuggestionsView(addressSearchManager: addressSearchManager, textFieldText: $addresses[index]) // Pass the binding to AddressSuggestionsView
                                                .padding(.horizontal, 16)
                                        }
                                
                                Button(action: {
                                    // Handle route action
                                }) {
                                    Text("Route!")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.gray)
                                        .cornerRadius(8)
                                        .padding(.horizontal, 16)
                                }
                                
                                Spacer()
                            }
                            .padding(.bottom, 16)
                            .frame(width: geometry.size.width)
                            .onChange(of: scrollOffset) { _ in
                                withAnimation {
                                    isScrollingUp = scrollOffset < 0
                                }
                            }
                            .padding(.top, isScrollingUp ? -scrollOffset : 0)
                            .padding(.bottom, isScrollingUp ? 0 : -scrollOffset)
                        }
                        .coordinateSpace(name: "scroll")
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            scrollOffset = value
                        }
                    }
                    .onAppear {
                        currentHour = Calendar.current.component(.hour, from: Date())
                    }
                    .background(GeometryReader { innerGeometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: innerGeometry.frame(in: .named("scroll")).minY)
                    })
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    // This function will determine the greeting based on the current time
    func determineGreeting() -> String {
        if currentHour >= 5 && currentHour < 12 {
            return "🌞 Good morning, drive safe!"
        } else if currentHour >= 12 && currentHour < 21 {
            return "⛅ Good afternoon, drive safe!"
        } else {
            return "🦉 Drive safe, Night Owl!"
        }
    }
}
