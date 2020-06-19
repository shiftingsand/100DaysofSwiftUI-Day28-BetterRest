//
//  ContentView.swift
//  BetterRest
//
//  Created by Chris Wu on 4/29/20.
//  Copyright © 2020 Chris Wu. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUP = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current recommended bedtime").font(.headline)) {
                    Text("\(getFinalUserMsg())")
                        .font(.headline)
                }
                
                Section(header: Text("When do you want to wake up?").font(.headline)) {
                    
                    DatePicker("Please enter a time", selection: $wakeUP, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                    
                }
                
                Section(header: Text("Desired amount of sleep")
                    .font(.headline)) {
                        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                            Text("\(sleepAmount, specifier: "%g"  ) hours")
                        }
                        .accessibility(value: Text("\(sleepAmount, specifier: "%g") hours of sleep."))
                }
                
                Section(header: Text("Daily coffee intake").font(.headline)) {
                    Picker("Please enter how many cups of coffee", selection: $coffeeAmount) {
                        ForEach(1..<21) { indexer in
                            Text("\(indexer)")
                        }
                    }
                    .labelsHidden()
                }
            }
            .navigationBarTitle("BetterRest")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    //  Day 28 - Challenge 3.
    // "Change the user interface so that it always shows their
    //  recommended bedtime using a nice and large font. You
    //  should be able to remove the “Calculate” button entirely.
    func getFinalUserMsg() -> String {
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUP)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        let userMsg : String
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUP - prediction.actualSleep

            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            userMsg = formatter.string(from: sleepTime)
        } catch {
            userMsg = "Error with calculation"
        }
        
        return userMsg
    }
    
    func calculateButton() {
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUP)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUP - prediction.actualSleep

            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is..."
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
