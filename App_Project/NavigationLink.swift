//
//  NavigationLink.swift
//  App_Project
//
//  Created by Burak Bozoğlu on 9.11.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {  // NavigationStack kullanarak gezinme işlevini ekliyoruz
            VStack {
                Text("Ana Sayfa")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // NavigationLink, tıklandığında LoginScreen'e geçiş yapar
                NavigationLink("Login Ekranına Git", destination: LoginScreen())
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
            }
            .navigationTitle("Ana Sayfa")  // Ana sayfa başlığı
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
