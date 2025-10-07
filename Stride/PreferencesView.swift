import SwiftUI

struct PreferencesView: View {
    var onComplete: () -> Void
    @State private var selectedPreference: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Text("Set Your Preferences")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                // Example preference selection
                Picker("Favorite Run Type", selection: $selectedPreference) {
                    Text("Scenic").tag("Scenic")
                    Text("Fastest").tag("Fastest")
                    Text("Coffee Shop Route").tag("Coffee")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button(action: {
                    onComplete()
                }) {
                    Text("Save Preferences")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.orange)
                        .cornerRadius(28)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(onComplete: {})
    }
} 