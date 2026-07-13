# 🌟 Spotlight

### Connecting ALU Students With Startup Opportunities

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange)
![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-purple)
![Dart](https://img.shields.io/badge/Language-Dart-0175C2)

---

## 📌 Overview

Spotlight is a Flutter mobile application designed specifically for the African Leadership University (ALU) ecosystem.

The platform connects students looking for internship experience with student-led startups and early-stage ventures seeking talent in areas such as:

* Software Engineering
* Product Design
* Marketing
* Content Creation
* Research
* Business Analysis
* Operations

Many students struggle to find meaningful internship opportunities, while startups often struggle to find skilled contributors. Spotlight bridges this gap by creating a dedicated platform where students can showcase their abilities and organizations can discover potential collaborators.

---

# 🎯 Problem Statement

Within our university ecosystems, students often have valuable skills but lack visibility among organizations that need their expertise.

At the same time, student startups require contributors but lack efficient ways to identify suitable candidates.

Spotlight solves this problem by providing:

* Student professional profiles
* Startup profiles
* Internship opportunity posting
* Opportunity discovery
* Community engagement
* Direct communication

---

# 🚀 Features

## 🔐 Authentication

Implemented using Firebase Authentication.

Features:

* User registration
* Secure login
* Session persistence
* Role-based onboarding

Supported account types:

### Creator

Represents ALU students.

Students can:

* Create profiles
* Add skills
* Showcase work
* Discover opportunities
* Communicate with organizations

### Organization

Represents student startups.

Organizations can:

* Create startup profiles
* Publish opportunities
* Discover student talent

---

# 👤 Profile System

Spotlight provides customized profiles based on user type.

## Creator Profiles

Includes:

* Name
* University
* Major
* Academic year
* Skills
* Bio
* Portfolio information

## Organization Profiles

Includes:

* Startup name
* Industry
* Tagline
* Organization information

---

# 📱 Core Application Features

## Feed

A community space where users can:

* Share updates
* Showcase projects
* Upload content
* Engage with other users

## Opportunities

Organizations can create internship opportunities.

Students can:

* Browse opportunities
* Discover startups
* Apply for experiences

## Discover

Allows users to explore:

* Creators
* Organizations
* Opportunities

## Chat

Real-time communication between users.

Supports:

* Conversations
* Messages
* Collaboration discussions

---

# 🏗️ Architecture

Spotlight follows a layered Flutter architecture.

```
                 Flutter UI
                    |
                    |
             Riverpod Providers
                    |
                    |
          Repository / Services Layer
                    |
                    |
              Firebase Backend
                    |
        -------------------------
        |                       |
Firebase Authentication   Firestore Database
```

---

# 🛠️ Technology Stack

## Frontend

| Technology      | Purpose                      |
| --------------- | ---------------------------- |
| Flutter         | Mobile application framework |
| Dart            | Programming language         |
| Material Design | UI components                |

---

## Backend

| Technology              | Purpose             |
| ----------------------- | ------------------- |
| Firebase Authentication | User authentication |
| Cloud Firestore         | Database            |
| Firebase Storage        | Media storage       |

---

## State Management

### Riverpod

Riverpod is used to manage application state because it provides:

* Better scalability
* Separation of business logic and UI
* Improved testing
* Predictable state updates

---

# 🗄️ Firestore Database Structure

## users

Stores user profiles.

Example:

```json
{
"name": "John Doe",
"email": "john@example.com",
"accountType": "creator",
"skills": [
 "Flutter",
 "UI Design"
]
}
```

---

## feed_posts

Stores community posts.

```json
{
"authorId": "user123",
"caption": "My latest project",
"createdAt": "timestamp"
}
```

---

## opportunities

Stores internship opportunities.

```json
{
"title": "Flutter Developer Intern",
"description": "Build mobile applications",
"organizationId": "startup123"
}
```

---

## chats

Stores conversations.

```json
{
"participants": [
"user1",
"user2"
],
"lastMessage": "Hello"
}
```

---

# 📂 Project Structure

```
lib/

├── core/
│   ├── theme/
│   ├── widgets/
│   └── services/

├── features/

│   ├── auth/
│   ├── profile/
│   ├── feed/
│   ├── opportunities/
│   ├── discover/
│   ├── chat/
│   └── create/

└── main.dart
```

The project follows feature-based organization to improve maintainability.

---

# ⚙️ Installation

## Requirements

Before running the project, install:

* Flutter SDK
* Android Studio
* Firebase CLI

## Clone Repository

```bash
git clone https://github.com/codestantceasar/Spotlight--formative-assignment-2
```

Navigate into the project:

```bash
cd spotlight
```

Install dependencies:

```bash
flutter pub get
```

Run application:

```bash
flutter run
```

---

# 🔥 Firebase Setup

Create a Firebase project.

Enable:

* Firebase Authentication
* Cloud Firestore
* Firebase Storage

Configure FlutterFire:

```bash
flutterfire configure
```

---

# 🧪 Testing

The application was tested through:

* Authentication workflows
* Firestore CRUD operations
* Navigation testing
* UI responsiveness testing
* Real-time data synchronization

---

# 🔮 Future Improvements

Future versions could include:

* AI opportunity recommendations
* Startup verification
* Push notifications
* Application tracking dashboard
* Interview scheduling
* Portfolio builder
* Advanced analytics

---

# 👨‍💻 Developer

Developed as part of the African Leadership University Software Engineering Final Flutter Project.

---

# 📄 License

This project was developed for educational purposes.
# Demo Video link : https://drive.google.com/drive/folders/1-UwzHI2PqEhXakI6l2n9Y_3lUz84VjJv?usp=drive_link
