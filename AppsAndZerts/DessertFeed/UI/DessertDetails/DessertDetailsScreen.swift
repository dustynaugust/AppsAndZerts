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
            if case let .loaded(detailsItem) = viewModel.state {
                
                VStack(alignment: .leading) {
                    Section {
                        IngredientList(ingredients: detailsItem.ingredients)
                        
                    } header: {
                        Header(text: detailsItem.name)
                        
                    } footer: {
                        Footer(text: detailsItem.instructions)
                    }
                    .padding(.top)
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
        
        var body: some View {
            Text(text)
                .font(.title)
                .padding(.horizontal)
            
            Divider()
        }
    }
    
    private struct IngredientList: View {
        let ingredients: [Ingredient]
        
        var body: some View {
            List(ingredients, id: \.self) {
                IngredientRow(name: $0.name, measurement: $0.measurement )
            }
            .listStyle(.plain)
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
        }
    }
    
    private struct Footer: View {
        let text: String
        
        var body: some View {
            Divider()
            
            ScrollView {
                Text(text)
                    .padding(.horizontal)
            }
        }
    }
}

// FIXME: Would be nice to not hit the endpoint here
//#Preview {
//    DessertDetailsScreen(
//        viewModel: .init(mealID: "52855")
//    )
//}
