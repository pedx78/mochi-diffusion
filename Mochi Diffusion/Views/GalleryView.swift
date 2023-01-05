//
//  GalleryView.swift
//  Mochi Diffusion
//
//  Created by Joshua Park on 1/4/23.
//

import SwiftUI
import QuickLook

struct GalleryView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var store: Store
    @State private var quicklookImage: URL? = nil
    private var gridColumns = Array(repeating: GridItem(.adaptive(minimum: 170), spacing: 10), count: 3)
    
    var body: some View {
        VStack(spacing: 0) {
            if case let .error(msg) = store.mainViewStatus {
                ErrorBanner(errorMessage: msg)
            }
            
            if store.images.count > 0 {
                ScrollView {
                    LazyVGrid(columns: gridColumns) {
                        ForEach(Array(store.images.enumerated()), id: \.offset) { i, sdi in
                            GeometryReader { geo in
                                GalleryItemView(size: geo.size.width, sdi: sdi, i: i)
                            }
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(i == store.selectedImageIndex ? Color.accentColor : Color.clear, lineWidth: 4)
                            )
                            .gesture(TapGesture(count: 2).onEnded {
                                quicklookImage = try? sdi.image?.asNSImage().temporaryFileURL()
                            })
                            .simultaneousGesture(TapGesture().onEnded {
                                store.selectImage(index: i)
                            })
                            .contextMenu {
                                Section {
                                    Button("Copy to Prompt") {
                                        store.copyToPrompt()
                                    }
                                    Button("Convert to High Resolution") {
                                        store.upscaleImage(sdImage: sdi)
                                    }
                                    Button("Save Image...") {
                                        sdi.save()
                                    }
                                }
                                Section {
                                    Button("Remove") {
                                        store.removeImage(index: i)
                                    }
                                }
                            }
                        }
                    }
                    .quickLookPreview($quicklookImage)
                    .padding()
                }
            }
            else {
                Color.clear
            }
        }
        .background(
            Image(systemName: "circle.fill")
                .resizable(resizingMode: .tile)
                .foregroundColor(Color.black.opacity(colorScheme == .dark ? 0.05 : 0.02))
        )
        .navigationSubtitle("\(store.images.count) \(store.images.count == 1 ? "image" : "images")")
        .toolbar {
            GalleryToolbarView()
        }
    }
}
