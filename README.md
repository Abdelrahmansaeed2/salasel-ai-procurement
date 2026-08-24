# Salasel (سلاسل) - AI-Driven B2B Supply Chain Ecosystem

![Status](https://img.shields.io/badge/Status-In_Development-orange)
![Graduation Project](https://img.shields.io/badge/ITI-Graduation_Project-blue)

## 1. Abstract & Enterprise Vision
Salasel is a comprehensive, dual-platform Business-to-Business (B2B) ecosystem meticulously engineered to digitize supply chain management for the Egyptian retail sector and SME merchants. By supplanting complex ERP data entry with an AI-powered, voice-first natural language processing interface, the system democratizes access to sophisticated procurement workflows. Merchants leverage colloquial Egyptian Arabic audio to manage inventory, while the underlying AI agent pipeline autonomously detects shortages, utilizes deterministic business rules to optimize supplier selection (evaluating price, stock, proximity, and quality), and orchestrates purchase order drafting with a built-in human-in-the-loop validation paradigm.

## 2. Core Technology Stack
The platform is built upon a highly scalable, distributed Microservices Architecture, strictly separating operational transactional logic from the non-deterministic AI reasoning layers to ensure system resilience and ACID compliance.

- **Mobile Interface (Merchants):** `Flutter` (Cross-platform voice-first UI optimized for usability)
- **Web Dashboard (Suppliers & Admins):** `Angular` (Real-time order tracking and dynamic catalog management)
- **Core Backend & Deterministic Rules Engine:** `.NET Core Web API` (Enterprise-grade business logic, transactional integrity)
- **Database:** `SQL Server` for transactional core & `pgvector` for semantic indexing
- **AI Microservice:** `Python / FastAPI` (Agentic workflow execution)
  - **Large Language Model (LLM) Layer:** Claude Haiku/Sonnet via ITI API Gateway & Llama 3 8B via Groq fallback for robust intent recognition.
  - **Voice Conversion:** Amazon Transcribe
  - **Retrieval-Augmented Generation (RAG) Layer:** Cohere Rerank 3.5 & semantic chunking over `pgvector` to mitigate LLM hallucination.
  - **Offline Fallback:** Self-hosted local Ollama Llama 3 model for edge gateway offline processing.

## 3. Enterprise Design System & Typography
To guarantee visual consistency, all interfaces strictly adhere to a tokenized color matrix:
- **Primary Blue/Orange (#0052CC / #FF5630):** High-intent action buttons and key routing.
- **Success Green (#36B37E):** Confirmed transactional workflows.
- **Warning Yellow (#FFAB00):** Low stock alert badges, processing states.
- **Critical Error Red (#DE350B):** Fraud flags, network outages, blocked permissions.
- **Typography:** Enforces native Right-to-Left (RTL) Arabic rendering using **Cairo**, **Tajawal**, or **Almarai**. English LTR rendering uses **Inter**.

## 4. Platform Architecture & Ecosystem Sitemap
### 4.1 Public Web Ecosystem & Supplier Web Control Tower (Angular)
- **1.0 Marketing & Trust Portals:** Hero banners, AI Trinity Explainer, and High Availability Engineering details.
- **2.0 Live Central Feed:** Real-Time Incoming Order Card Stack running on persistent WebSocket server loops.
- **3.0 Kanban Order Operations Board:** Pending Review, Accepted Processing Pipeline, In-Transit Logistics, and Exceptions Archive.
- **4.0 RAG Document Knowledge Base Center:** Drag-and-Drop Bulk File Ingestion for PDF/Excel catalogs, mapping to vector embeddings.
- **5.0 Fraud & Hard-Limits Configuration:** Enterprise risk metric configurations (e.g., MaxOrderValue) and rule selector arrays.
- **6.0 Internal System Audit Room:** Comprehensive Administrative Operation Record Matrix (Tracking all executed actions and identity hashes).

### 4.2 Merchant Mobile Application (Flutter)
- **1.0 Enterprise Onboarding:** Store registration, GPS coordinates sniper, and Hardware Token OTP Verification.
- **2.0 Core Workspace Hub:** Persistent bottom navigation, omnipresent floating voice capture trigger, live asset roster grid.
- **3.0 Voice Procurement Loop:** Floating waveform overlay, manual correction UI (reading transcription panes, editable JSON entity matrix), and split-routing summaries.
- **4.0 System Resilience Guard:** Deep-linked microphone access guidance, local offline edge gateway synch banners.

## 5. Agentic Workflows & System User Flows

### Flow 1: End-to-End Autonomous AI Voice Ordering & Splitting Route
1. **Audio Ingestion Initiated:** Merchant taps the floating action button; Flutter records colloquial Egyptian Arabic via waveform UI.
2. **NLP Intent Processing:** Audio pushes to backend via Amazon Transcribe, routed through Claude LLMs to extract structural JSON entities with >92% colloquial accuracy.
3. **Deterministic Optimization Agent (LangGraph):** The state-driven computational graph evaluates the request against price books, proximity, and pgvector stock balances.
4. **Agent Order Splitting Resolution:** If Supplier A cannot fulfill the volume, the transaction is autonomously split, diverting the shortfall to Supplier B.
5. **Correction UI & Transactional Finalization:** The merchant reviews the explicit split routing path, edits any mismatched strings, and taps "Confirm Order" to execute the SQL Server transaction.

### Flow 2: Wholesaler Catalog RAG Vectorization
1. **Document Binary Dispatch:** Admin drops a multi-page unstructured PDF catalog into the Angular portal.
2. **Semantic Token Segmentation:** Python microservice parses text into uniform 100-token chunks.
3. **Vector Store Insertion:** Segments transform into dense embeddings directly into the `pgvector` database.
4. **Retrieval Evaluation:** Tested against Cohere Rerank 3.5 to verify accuracy and signal completion to the Angular client.

### Flow 3: Real-Time B2B Procurement Order Fulfillment
1. **Real-Time Data Pipeline:** Supplier dashboard connects via persistent WebSocket loops.
2. **UI Card Injection Event:** When a merchant confirms an order, a crisp audio ping alerts the warehouse dispatcher, injecting a new transaction card into the Kanban inbox.
3. **Cross-Platform Signal Broadcast:** Dispatcher clicks "Accept", instantly updating the merchant's Flutter app shipment tracking chip to "In-Transit".

## 6. Edge-Case, Exception & Error State Roster
- **Network Outage & Offline Edge Gateway Fallback:** In the event of a drop in connectivity, the Flutter app redirects the audio payload over the local network to an on-site edge gateway (Ollama Llama 3) for offline transaction caching.
- **Low-Confidence AI Speech Ingestion:** Ambient noise causing <92% confidence triggers a diagnostic modal, enabling merchants to review transcription, retry recording, or switch to manual typing.
- **Enterprise Procurement Fraud Detection Trip:** Outlier quantity values trip hard limits, locking the submission button, tinting the layout critical red, and routing the transaction to a supervisor review queue.

## 7. Deployment & Local Development Guide
### 1. Backend Core (.NET API)
```bash
cd backend-dotnet
dotnet restore
dotnet run
```
*Requirement: Ensure SQL Server is operational and the configuration string in `.env` or `appsettings.json` is properly initialized.*

### 2. Supplier Dashboard (Angular)
```bash
cd frontend
npm install
npm start
```

### 3. AI Service (Python/FastAPI)
```bash
cd ai_service
pip install -r requirements.txt
uvicorn main:app --reload
```
*Note: Valid API keys for Groq/Claude/Cohere are required in the `.env` variables for LLM operations.*

### 4. Merchant Mobile Interface (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```

### Docker Compose Integration
```bash
docker-compose up --build
```

## 8. Authors & Contributors
Developed collaboratively by Team 8 as the capstone graduation project for the Information Technology Institute (ITI) 9-Month Professional Diploma.

- **Abd Elrahman Saeed**
- **Ebrahim Reda Mohamed**
- **Ahmed Maher Algohary**
- **Islam Saeed Fouly**
- **Daniel Samy**
- **Mohamed Abdelgawad Mohamed**
- **Muhammed Reda Abdel Elmoamen**
