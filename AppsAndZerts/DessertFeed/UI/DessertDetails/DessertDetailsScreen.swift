//
//  DessertDetailsScreen.swift
//  AppsAndZertsTests
//
//  Created by Dustyn August on 1/26/24.
//

import SwiftUI

// FIXME: Alert UI kinda sucks...

struct DessertDetailsScreen: View {
    @ObservedObject var viewModel: DessertDetailsViewModel
    
    var body: some View {
        ZStack {
            if case let .loaded(item) = viewModel.state {
                
                ScrollView { 
                    VStack {
                        Section {
                            DessertContent(
                                ingredients: item.ingredients,
                                instructions: item.instructions
                            )
                            
                        } header: {
                            Header(
                                text: item.name,
                                thumbnail: item.thumbnailURL ?? URL(string: "")!
                            )
                        }
                        .padding(.top)
                    }
                }
            }
            
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .onFirstAppear {
            Task { await viewModel.getDetails() }
        }
        .alert("Failed to retrieve details", isPresented: $viewModel.showingAlert) {
            Button("Reload", role: .cancel) {
                Task { await viewModel.getDetails() }
            }
        }
    }
    
    private struct Header: View {
        let text: String
        let thumbnail: URL
        
        var body: some View {
            AsyncImage(url: thumbnail) { image in
                image
                    .resizable()
                
            } placeholder: {
                ProgressView()
            }
            .frame(height: 300)
            
            Text(text)
                .font(.title)
                .padding(.horizontal)
            
            Divider()
        }
    }
    
    private struct DessertContent: View {
        let ingredients: [Ingredient]
        let instructions: String
        
        var body: some View {
            VStack {
                
                LeadingTitleText(text: "Ingredients:")
                    .padding(.bottom)
                    
                ForEach(ingredients, id: \.self) {
                    IngredientRow(
                        name: $0.name,
                        measurement: $0.measurement
                    )
                }
                
                Divider()
                    .padding(.vertical)
                
                LeadingTitleText(text: "Instructions:")
                    .padding(.bottom)
                
                Text(instructions)
                    .padding(.horizontal)
            }
        }
    }
    
    private struct LeadingTitleText: View {
        let text: String
        
        var body: some View {
            Text(text)
                .font(.title2)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(.horizontal)
        }
    }
    
    private struct IngredientRow: View {
        let name: String
        let measurement: String
        
        var body: some View {
            HStack {
                Text(name.capitalized)
                
                Spacer()
                
                Text(measurement.capitalized)
            }
            .padding(.horizontal)
        }
    }
}

// FIXME: Would be nice to not hit the endpoint here
#Preview {
    DessertDetailsScreen(
        viewModel: .init(mealID: "52855")
    )
}
