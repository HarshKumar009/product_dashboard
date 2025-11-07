# Product Dashboard Web App

A responsive Flutter Web application for product management, built with BLoC for state management.

**Live Demo:** `[YAHAN APNI VERCEL YA FIREBASE KI LIVE LINK PASTE KAREIN]`

---

## 🚀 How to Run

- **Clone Repo:**
  ```bash
  git clone [YAHAN APNI GITHUB REPO KI LINK PASTE KAREIN]
  cd your-repo-name
  
- **Get Dependencies:**
  - flutter pub get
  - flutter run -d chrome

- **Login Credentials**
    -Username: harsh
    -Password: harsh

- Folder Structure
  - The project uses a  Clean Architecture to keep the code scalable and organized.
  - lib/core: Shared code (router, theme).
  - lib/features: Contains individual features like product and auth.
    - product/data: API calls and data handling.
    - product/presentation: UI (pages/widgets) and State Management (BLoC).
    - product/models: Dart data models.
    
-  **Libraries Used**
  -  flutter_bloc: For predictable State Management.
  -  go_router: For declarative Web Navigation & Routing.
  -  http: For API Communication with the server.
  -  equatable: To simplify BLoC/Cubit state and event comparisons.
  -  shimmer: For a  loading UI effect.
  -  flutter_staggered_animations: For  list animations.
  
- **Implemented Features**
  -  Mock Authentication:  login/logout flow with redirects.
  -  Pagination: Infinite scrolling for the product list.
  -  Sorting: Sort products by ID, name, or price.
  -  Theme Switcher: Toggle between Light and Dark mode.
  -  Fully Responsive UI: Adapts from desktop to mobile screens.
  -  CRUD Operations: Users can Create, View, Update, and Delete products.
  -  UI: Includes a summary dashboard, animations, and a polished design.

