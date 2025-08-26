# MoviesDC (iOS App)

## 📱 What the app does
An iOS application built with SwiftUI that displays a list of movies.  
The app fetches movie data from a public API made by me (developed with FastAPI and deployed in Render).  
It includes error handling and shows loading states for a smooth user experience.

## 🌐 API used
The app connects to this API endpoint:  
- **Movies**: [https://movies-api-wgms.onrender.com/movies](https://movies-api-wgms.onrender.com/movies)  

## ⚙️ How to run the app
- **Xcode version**: 15+  
- **iOS target**: iOS 17+  
- Steps:
  1. Clone this repository:
     ```bash
     git clone <your-repo-url>
     ```
  2. Open `MoviesDC.xcodeproj` in Xcode.
  3. Run the app in the iOS Simulator (`Cmd + R`) or on a physical iPhone.
  4. Ensure the API is online (Render automatically restarts the container when inactive).

