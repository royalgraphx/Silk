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
    @State private var addresses: [String] = Array(repeating: "", count: 1)
    @State private var isScrollingUp = false
    @State private var scrollOffset: CGFloat = 0
    @State private var currentHour: Int = Calendar.current.component(.hour, from: Date())
    
    @StateObject private var addressSearchManager1 = AddressSearchManager()
    @StateObject private var addressSearchManager2 = AddressSearchManager()
    @StateObject private var addressSearchManager3 = AddressSearchManager()
    @StateObject private var addressSearchManager4 = AddressSearchManager()
    @StateObject private var addressSearchManager5 = AddressSearchManager()
    @StateObject private var addressSearchManager6 = AddressSearchManager()
    @StateObject private var routeManager = RouteManager()
    
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

                                MapView(routeManager: routeManager)
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
                                        MapController(routeManager: routeManager)
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
                                                getAddressSearchManager(forIndex: index).searchCompleter.queryFragment = query
                                            }

                                        if index == addresses.indices.last && index < 5 { // Display "+" icon for all text boxes except the last one
                                            Button(action: {
                                                addresses.append("")
                                                scrollViewProxy.scrollTo("address\(addresses.count - 1)", anchor: .bottom)
                                            }) {
                                                Image(systemName: "plus")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.trailing, 30)
                                        } else if index == addresses.indices.last && index >= 5 { // Display no icon for the last text box
                                        } else {
                                            Button(action: {
                                                addresses.remove(at: index)
                                            }) {
                                                Image(systemName: "minus")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.trailing, 30)
                                        }
                                    }
                                    .id("address\(index)")

                                    AddressSuggestionsView(addressSearchManager: getAddressSearchManager(forIndex: index), textFieldText: $addresses[index])
                                        .padding(.horizontal, 16)
                                        .id("suggestions\(index)") // Add an ID to the suggestions view
                                }

                                Button(action: {
                                    // Validate addresses first
                                    let validAddresses = addresses.filter { !$0.isEmpty }
                                    if validAddresses.isEmpty {
                                        print("No valid addresses provided.")
                                    } else {
                                        guard let currentLocation = routeManager.location else {
                                            print("Could not get current location.")
                                            return
                                        }
                                        let currentAddress = "\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)"
                                        var allAddresses = validAddresses
                                        allAddresses.insert(currentAddress, at: 0)
                                        routeManager.routeBetweenAddresses(addresses: allAddresses)
                                    }
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
                            .preference(key: ScrollOffsetPreferenceKey.self, value: innerGeometry.frame(in: .named("scroll")).origin.y)
                    })
                }
            }
            .ignoresSafeArea()
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
    }

    func determineGreeting() -> String {
        if currentHour >= 5 && currentHour < 12 {
            return "🌞 Good morning, drive safe!"
        } else if currentHour >= 12 && currentHour < 21 {
            return "⛅ Good afternoon, drive safe!"
        } else {
            return "🦉 Drive safe, Night Owl!"
        }
    }

    func getAddressSearchManager(forIndex index: Int) -> AddressSearchManager {
        switch index {
        case 0:
            return addressSearchManager1
        case 1:
            return addressSearchManager2
        case 2:
            return addressSearchManager3
        case 3:
            return addressSearchManager4
        case 4:
            return addressSearchManager5
        case 5:
            return addressSearchManager6
        default:
            fatalError("Unexpected index.")
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
