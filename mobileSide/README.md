# BarberShop Admin Mobile App

A Flutter mobile application for Admin and Barber users to manage appointments.

## Features

- **Login with Role Validation**: Only Admin and Barber roles are allowed
- **Admin Dashboard**: View all appointments, KPI cards, pending appointments queue
- **Barber Dashboard**: View personal appointments grouped by date
- **Confirm Appointments**: One-tap confirmation for pending appointments
- **Dark Theme**: Matches the Angular web application design

## Prerequisites

- Flutter SDK 3.41.6 or higher
- Android Studio / Xcode (for iOS)
- The backend Spring Boot server running

## Setup

1. **Install dependencies**:
   ```bash
   cd mobileSide
   flutter pub get
   ```

2. **Configure the backend URL**:
   
   Open `lib/services/api_service.dart` and update the `baseUrl`:
   - For Android Emulator: `http://10.0.2.2:8080/api`
   - For iOS Simulator: `http://localhost:8080/api`
   - For real device: `http://YOUR_MACHINE_IP:8080/api`

3. **Run the app**:
   ```bash
   flutter run
   ```

## Project Structure

```
mobileSide/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── main_app.dart             # Main navigation shell
│   ├── models/
│   │   ├── user.dart             # User and AuthResponse models
│   │   ├── appointment.dart      # Appointment model
│   │   └── barber.dart           # Barber model
│   ├── providers/
│   │   ├── auth_provider.dart    # Authentication state management
│   │   └── appointment_provider.dart # Appointments state management
│   ├── screens/
│   │   ├── splash_screen.dart    # Splash/loading screen
│   │   ├── login_screen.dart     # Login with role validation
│   │   ├── admin_dashboard_screen.dart  # Admin view
│   │   └── barber_dashboard_screen.dart # Barber view
│   ├── services/
│   │   └── api_service.dart      # HTTP API client
│   ├── theme/
│   │   └── app_theme.dart        # App theming (matches Angular)
│   └── widgets/
│       ├── kpi_card.dart         # KPI stat card
│       ├── appointment_card.dart # Appointment list item
│       └── confirm_dialog.dart   # Confirmation modal
├── pubspec.yaml
└── README.md
```

## API Endpoints Used

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/login` | POST | Login authentication |
| `/api/appointments` | GET | Get all appointments (Admin) |
| `/api/barbers/{id}/appointments` | GET | Get barber's appointments |
| `/api/appointments/{id}/confirm` | PATCH | Confirm appointment |
| `/api/appointments/{id}/cancel` | PATCH | Cancel appointment |
| `/api/barbers` | GET | Get all barbers |

## Test Users

Use these credentials to test (based on your backend seed data):

- **Admin**: username: `admin`, password: `admin123`
- **Barber**: username: `barber1`, password: `barber123`

## Notes

- The app automatically validates user roles on login - CLIENT role is rejected
- Token and user data are persisted using `shared_preferences`
- Pull-to-refresh is available on both dashboards
- The app uses the same color scheme as the Angular frontend
