# Salasel (سلاسل) - AI-Driven B2B Supply Chain Ecosystem

![Status](https://img.shields.io/badge/Status-In_Development-orange)
![Graduation Project](https://img.shields.io/badge/ITI-Graduation_Project-blue)

## Project Overview
Salasel is a dual-platform B2B ecosystem designed to digitize supply chain management for the Egyptian retail sector and SME merchants. It replaces complex ERP data entry with an AI-powered, voice-first natural language processing interface. 

Merchants use voice notes in colloquial Egyptian Arabic to manage inventory, while the system autonomously detects shortages, utilizes deterministic business rules to optimize supplier selection (evaluating price, stock, and delivery), and drafts purchase orders with built-in human verification UI.

## Architecture & Core Stack
Built with a highly scalable Microservices Architecture to separate operational transactional logic from the AI reasoning layers.

* **Mobile Interface (Merchants):** `Flutter` (Cross-platform voice-first UI)
* **Web Dashboard (Suppliers):** `Angular` (Real-time order tracking)
* **Core Backend & Rules Engine:** `.NET Core Web API` (Business logic, ACID transactions)
* **Database:** `SQL Server` (Entity Framework Core)
* **AI Microservice:** `Python / FastAPI`
    * **LLM Layer:** Llama 3 8B (via Groq) for intent recognition and entity extraction.
    * **RAG Layer:** Document retrieval for dynamic supplier catalogs to eliminate hallucination.

##  Key Features
1.  **Voice-First Procurement:** Extracts strict JSON entities (Items, Quantities, Urgency) from Egyptian Arabic audio.
2.  **Deterministic Optimization Engine:** Ranks dynamic suppliers based on live SQL querying for price and availability.
3.  **Agentic Fallback & Validation:** Implements confidence thresholds and a manual correction UI to prevent fully autonomous procurement fraud.

## The Team (Salasel Team)
Developed by Team 8 as part of the Information Technology Institute (ITI) 9-Month Professional Diploma.
* Abd Elrahman Saeed
* Ebrahim Reda Mohamed
* Ahmed Maher Algohary
* Islam Saeed Fouly
* Daniel Samy
* Mohamed Abdelgawad Mohamed
* Muhammed Reda Abdel Elmoamen

## How to Run Locally

### 1. Backend (.NET Core API)
```bash
cd backend
dotnet restore
dotnet run
```
*Note: Ensure SQL Server is running and the connection string in `appsettings.json` is configured.*

### 2. Frontend (Angular Web Dashboard)
```bash
cd frontend
npm install
npm start
```

### 3. AI Service (Python / FastAPI)
```bash
cd ai_service
pip install -r requirements.txt
uvicorn main:app --reload
```

### 4. Mobile Interface (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```
