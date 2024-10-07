//
//  ContentView.swift
//  WordScramble
//
//  Created by Zheen Suseyi on 10/7/24.
//
/*
 One of the best ways to learn is to write your own code as often as possible, so here are three ways you should try extending this app to make sure you fully understand what’s going on:

 1. Disallow answers that are shorter than three letters or are just our start word.
 2. Add a toolbar button that calls startGame(), so users can restart with a new word whenever they want to.
 3. Put a text view somewhere so you can track and show the player’s score for a given root word. How you calculate score is down to you, but something involving number of words and their letter count would be reasonable.
 */
import SwiftUI

struct ContentView: View {
    // Array that will store our already guessed valid words
    @State private var usedWords = [String]()
    // rootWord which will be randomly given, will always be 8 letters
    @State private var rootWord = ""
    // newWord which the user will input
    @State private var newWord = ""
    // error title
    @State private var errorTitle = ""
    // error message
    @State private var errorMessage = ""
    // will be toggled depending on if error happens
    @State private var showingError = false
    // a way to keep track of userScore
    @State private var userScore = 0
    
    var body: some View {
        // VStack for keeping track of score at the top
        VStack {
            Text("Your score for \(rootWord) Is \(userScore)")
                .font(.title2)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            // Navigation Stack
            NavigationStack {
                // List which we will put our sections in
                List {
                    
                    // Seciton and Textfield for entering word
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                    }
                    // Section which will show up once we correctly guess a word
                    Section {
                        // looping through the usedWords array
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                // Outputs the word in an HStack with a circle + number of letters
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
                // Our rootWord
                .navigationTitle(rootWord)
                // When we enter a new word into the text box this method activates
                .onSubmit(addNewWord)
                // When app is started this method activates
                .onAppear(perform: startGame)
                // Alert that shows an error
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK") { }
                } message: {
                    Text(errorMessage)
                }
                // Top right button that users can restart the game with
                .toolbar {
                    Button("New Word?", action: startGame)
                }
            }
        }
    }
    
    // Function for guessing a new word from root word
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count > 0 else { return }
        
        // exit if word isnt original
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        // exit if word is the same as root
        guard isNotRoot(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        // exit if the word is possible to make from rootword
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        // exit if the word does not exist
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        // exit if the word is less then 4 letters
        guard letterRequirements(word: answer) else {
            wordError(title: "Word too short!", message: "Needs to be bigger then 3 letters")
            return
        }
        
        // animation for smooth transition for valid words
        withAnimation {
            // inserts the new word into the usedWords array
            usedWords.insert(answer, at: 0)
            // if the wordcount is over 5 then user gets 2 points
            if answer.count > 5 {
                userScore += 2
            }
            // otherwise, user will only get 1 point
            else {
               userScore += 1
            }
        }
        // new word is empty by default
        newWord = ""
    }
    
    // function to start the game
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        usedWords.removeAll()
        userScore = 0
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"

                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    // function to check if the word is original
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    // function to check if the word is not the same as the rootword
    func isNotRoot(word: String) -> Bool {
        !word.contains(rootWord)
    }
    
    // function to check if the word entered was possible to be made from rootword
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    // function to check if the word is even real
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    // function to check if the word is over 3 letters
    func letterRequirements(word: String) -> Bool {
        if word.count < 4 {
            return false
        }
        else {
            return true
        }
    }
    
    // function that will be used once an error is thrown
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}


#Preview {
    ContentView()
}
