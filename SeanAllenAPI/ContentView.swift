//
//  ContentView.swift
//  SeanAllenAPI
//
//  Created by Tatsuya Moriguchi on 8/13/24.
//

import SwiftUI

// Create UI
struct ContentView: View {
    
    // Need an object to store GitHubUser data from getUser()
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
            
            //            Text("User Name") // change to display downloaded data.
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)
            
            //            Text("This is where the GitHub bio will go. Let's ake it long so it spans two lines.") // change to display downloaded data.
            Text(user?.bio ?? "Bio Placeholder")
                .padding()
            Spacer()
        }
        .padding()
        // Adds an asynchronous task to perform before this view appear.
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("invalid URL")
            } catch GHError.invalidResponse {
                print("invalid response")
            } catch GHError.invalidData {
                print("invalid data")
            } catch {
                print("unexpected error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/tatsuyamoriguchi"
        
        // Create url object
        guard let url = URL(string: endpoint) else { throw GHError.invalidURL }
        
        // URL Session for GET, download data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // response is HTTP reponse such as 404
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidURL
        }
        
        // Convert data into JSON object
        do {
            let decoder = JSONDecoder()
            // use .convertFromSnakeCase since changed avatar_url to avaterUrl (camel case convention)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            // Decode JSON into GitHubUser
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

// Create Model
struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String // avatar_url
    let bio: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

