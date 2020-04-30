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
    @State private var wakeUP = Date()
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {

        NavigationView {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please enter a time", selection: $wakeUP, displayedComponents: .hourAndMinute)
                .labelsHidden()
                
                Text("Desired amount of sleep")
                    .font(.headline)
                
                Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                    Text("\(sleepAmount, specifier: "%g"  ) hours")
                }
                
                Text("Daily coffee intake")
                    .font(.headline)
                
                Stepper(value: $coffeeAmount, in: 1...20) {
                    if 1 == coffeeAmount {
                        Text("1 cup")
                    } else {
                        Text("\(coffeeAmount) cups")
                    }
                }
             } // VStack
            .navigationBarTitle("BetterRest")
            .navigationBarItems(trailing:
                Button(action: calculateButton) {
                    Text("Calculate")
                }
            )
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
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
