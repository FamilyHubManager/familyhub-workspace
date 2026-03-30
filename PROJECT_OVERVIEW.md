# FamilyHub - Aplicație de Management Familial

## 📋 Scopul Aplicației

**FamilyHub** este o platformă self-hosted concepută pentru gestionarea eficientă a documentelor, proprietăților, bugetului și sarcinilor unei familii. Aplicația oferă o soluție completă pentru managementul vieții de zi cu zi, cu focus pe proprietăți închiriate și organizare financiară.

## 🎯 Problema Rezolvată

### Context

Familia Fusneica gestionează:

- **8 apartamente** distribuite în **3 clădiri** (Tineretului 31A, Tineretului 29A în Dudu Ilfov; Uverturii 163B în București S6)
- Zeci de **documente** (facturi, contracte, chitanțe, acte)
- **Tranzacții financiare** multiple (ING, BCR, Revolut)
- **Chiriași** cu contracte și plăți lunare
- **Sarcini** și reminder-e pentru întreținere

### Provocări

- ❌ Documente fizice dispersate, greu de găsit
- ❌ Lipsa vizibilității asupra plăților și restanțelor
- ❌ Dificultate în urmărirea cheltuielilor pe mai multe conturi
- ❌ Comunicare ineficientă cu chiriașii
- ❌ Lipsa automatizării pentru sarcini recurente

### Soluția FamilyHub

✅ **Centralizare** - Toate informațiile într-un singur loc  
✅ **Automatizare** - OCR, categorii AI, import CSV  
✅ **Vizibilitate** - Dashboard-uri și statistici în timp real  
✅ **Comunicare** - Mesaje WhatsApp și email integrate  
✅ **Acces mobil** - PWA instalabilă pe orice dispozitiv  
✅ **Self-hosted** - Date private, fără costuri recurente cloud

## 🏗️ Arhitectura Aplicației

### Stack Tehnic

#### Backend (Django 5)

```text
Python 3.13 + Django 5.x
├── REST API (Django REST Framework)
├── OCR (Tesseract) - Extragere text din documente
├── AI Local (Ollama + Llama 3.2) - Categorizare inteligentă
├── Celery - Task-uri asincrone (email, OCR, notificări)
├── PostgreSQL - Baza de date relațională
└── Redis - Cache și message broker
```

#### Frontend (React 18)

```text
React 18 + TypeScript + Vite 5
├── PWA - Instalabilă, funcționează offline
├── TailwindCSS - Design responsive, dark mode
├── Zustand - State management simplu
├── React Query - Cache și sincronizare server
└── React Hook Form + Zod - Validare formulare
```

#### Servicii Auxiliare

```text
Node.js (WhatsApp)
├── whatsapp-web.js - Integrare WhatsApp Web
└── Express - API server pentru comenzi

Nginx
├── Reverse proxy
├── SSL/TLS
└── Static files serving
```

### Diagrama Arhitecturală

```text
┌─────────────────────────────────────────────────────────────┐
│                         Frontend PWA                         │
│   React + Vite + TailwindCSS (Mobile-First Responsive)     │
└───────────────────────┬─────────────────────────────────────┘
                        │ HTTPS/WSS
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                      Nginx Reverse Proxy                     │
│         SSL Termination │ Load Balancing │ Caching         │
└──────────┬──────────────┴─────────────────┬─────────────────┘
           │                                 │
           ▼                                 ▼
┌──────────────────────┐         ┌──────────────────────┐
│   Django REST API    │         │  WhatsApp Service    │
│                      │         │    (Node.js)         │
│  • Users & Auth      │         │                      │
│  • Documents + OCR   │◄────────┤  • Send messages     │
│  • Properties        │         │  • Webhooks          │
│  • Payments          │         │  • QR pairing        │
│  • Budget            │         └──────────────────────┘
│  • Tasks             │
│  • Reminders         │
│  • Integrations      │
└─────┬────────────────┘
      │
      ├──────────────┬──────────────┬──────────────┐
      ▼              ▼              ▼              ▼
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│PostgreSQL│  │  Redis   │  │  Celery  │  │  Ollama  │
│          │  │          │  │  Workers │  │   AI     │
│ • Users  │  │ • Cache  │  │          │  │          │
│ • Docs   │  │ • Queue  │  │ • OCR    │  │ • Llama  │
│ • Props  │  │ • Session│  │ • Email  │  │   3.2 7B │
│ • Payments│ │         │  │ • Tasks  │  │          │
└──────────┘  └──────────┘  └──────────┘  └──────────┘
```

## 🎨 Module Principale

### 1. 📄 Documente

**Scop:** Digitalizare și organizare documente fizice

**Funcționalități:**

- Upload drag & drop (PDF, imagini, Word)
- OCR automat cu Tesseract (română + engleză)
- Categorizare AI (facturi, contracte, chitanțe, etc.)
- Extragere metadate (sumă, dată, furnizor)
- Filtrare și căutare full-text
- Atașare la apartamente/chiriași
- Sincronizare Google Drive (opțional)

**Use Case:**

```text
Mama scanează cu telefonul o factură ENEL
→ Aplicația extrage automat text cu OCR
→ AI detectează: "Factură - Utilități - ENEL - 250 RON"
→ Document atașat la apartamentul corespunzător
→ Notificare către administrator
```

### 2. 🏠 Proprietăți

**Scop:** Gestionare clădiri, apartamente, chiriași

**Structură:**

```text
Clădire (Building)
├── Adresă, oraș, țară
├── Număr apartamente
└── Apartamente
    ├── Nume (ex: "Ap. 3")
    ├── Suprafață, camere, etaj
    ├── Utilități (gaz, apă, curent)
    ├── Chirie lunară
    └── Chiriaș curent
        ├── Nume, contact
        ├── Contract (start, end, garanție)
        └── Istoric plăți
```

**Funcționalități:**

- Adăugare/editare clădiri și apartamente
- Gestionare chiriași și contracte
- Istoric ocupare și chirie
- Calculare automată utilități
- Export rapoarte PDF

**Use Case:**

```text
Chiriaș nou se mută în Ap. 5
→ Adaugă chiriaș cu date contact
→ Creează contract cu dată început/sfârșit
→ Setează chirie 1200 RON + utilități
→ Generează plăți automate lunare
```

### 3. 💳 Plăți

**Scop:** Tracking chirii, facturi, garanții

**Tipuri plăți:**

- **Chirie** - Lunară, scadență fixă
- **Utilități** - Gaz, apă, curent, internet
- **Garanție** - La început contract
- **Întreținere** - Reparații, îmbunătățiri
- **Altele** - Diverse taxe

**Status-uri:**

- 🟡 Pending - În așteptare
- 🟠 Partial - Plată parțială
- 🟢 Paid - Plătit complet
- 🔴 Overdue - Restant
- ⚪ Cancelled - Anulat

**Funcționalități:**

- Creare plăți manuale/automate
- Tracking status și istoric
- Alerte restanțe (email + WhatsApp)
- Rapoarte financiare
- Export pentru contabilitate

**Use Case:**

```text
Data 5 a lunii
→ Celery Beat generează automat plăți chirie
→ Status: Pending pentru toți chiriașii
→ Chiriaș plătește → Admin marchează Paid
→ Dacă restant după data 10 → Email + WhatsApp alert
```

### 4. 📊 Buget

**Scop:** Urmărire venituri și cheltuieli familiale

**Funcționalități:**

- **Conturi bancare** - ING, BCR, Revolut, cash
- **Categorii** - Chirie, utilități, mâncare, transport, etc.
- **Import CSV** - Parse automat CSV-uri bancă
- **Tranzacții** - Adăugare manuală/import
- **Statistici** - Grafice, trend-uri, buget lunar
- **Alerte** - Notificări când se depășește buget

**Import CSV:**

```text
ING: Data, Descriere, Debit, Credit, Sold
BCR: Data;Explicatii;Suma;Valuta;Sold
Revolut: Date, Description, Amount, Currency, Category
```

**Use Case:**

```text
Descarcă extras ING.csv
→ Upload în aplicație
→ Parser detectează format ING
→ Extrage 45 tranzacții
→ AI categorizează automat (80% confidence)
→ Utilizator confirmă/corectează restul 20%
```

### 5. ✅ Task-uri

**Scop:** Organizare sarcini și proiecte familiale

**Structură Jira-like:**

```text
Proiect
├── Task-uri
│   ├── Titlu, descriere
│   ├── Status (To Do, In Progress, Review, Done)
│   ├── Prioritate (Low, Medium, High, Urgent)
│   ├── Assignee (eu, mama, tata, radu)
│   ├── Due date
│   ├── Labels/Tags
│   └── Comentarii
└── Kanban Board (drag & drop)
```

**Funcționalități:**

- Board kanban interactiv
- Filtrare și sortare
- Assignare membri familie
- Reminder-e pentru deadline
- Istoric completare

**Use Case:**

```text
Task: "Verificare contoare apă - Ap. 3"
→ Assignee: tata
→ Due date: 15 febr
→ Status: To Do → In Progress → Done
→ Reminder cu 2 zile înainte
→ Notificare la completare
```

### 6. 🔔 Reminder-e

**Scop:** Notificări și alerte automate

**Tipuri:**

- **One-time** - O singură dată
- **Daily** - Zilnic
- **Weekly** - Săptămânal
- **Monthly** - Lunar (ex: plăți)
- **Custom CRON** - Personalizat

**Canale:**

- Email
- WhatsApp
- Push notifications (PWA)
- In-app

**Use Case:**

```text
Reminder: "Verifică contoare"
→ Trigger: Ziua 25 a lunii
→ Recipients: eu, tata
→ Channels: Email + WhatsApp
→ Celery Beat execută automat
```

### 7. 🔗 Integrări

**Scop:** Conectare servicii externe

**Google Drive:**

- Sincronizare automată documente
- Backup săptămânal
- OAuth2 authentication

**WhatsApp:**

- Trimitere mesaje chiriași
- Notificări alerte
- Confirmare plăți
- QR code pairing (whatsapp-web.js)

**Email (SMTP):**

- Gmail, Outlook, SMTP custom
- Template-uri pentru notificări
- Attachments (facturi, contracte)

**AI (Ollama):**

- Model: Llama 3.2 7B
- Categorizare documente
- Analiză cheltuieli
- Sugestii optimizare buget

## 👥 Utilizatori

### Roluri și Permisiuni

**Admin (eu, Florentin-Cristian):**

- ✅ Acces complet toate modulele
- ✅ Adăugare/ștergere utilizatori
- ✅ Configurare integrări
- ✅ Export date și rapoarte

**Manager (tata):**

- ✅ Gestionare proprietăți
- ✅ Adăugare plăți și documente
- ✅ Comunicare chiriași
- ❌ Configurare sistem

**Viewer (mama, radu):**

- ✅ Vizualizare documente
- ✅ Adăugare cheltuieli buget
- ✅ Task-uri proprii
- ❌ Modificare chiriași/plăți

**Tenant (chiriași):**

- ✅ Vizualizare propriul contract
- ✅ Istoric plăți
- ✅ Upload dovezi plată
- ❌ Date alți chiriași

## 📱 Interfață și UX

### Design Principles

- **Mobile-First** - Optimizat pentru telefon
- **Dark Mode** - Protecție ochi, economie baterie
- **Offline-First** - Funcționează fără internet (PWA)
- **Touch-Friendly** - Butoane mari, gesturi intuitive
- **Română** - Interfață completă în limba română

### Screenshots Concepte

**Dashboard:**

```text
┌─────────────────────────────────────┐
│  🏠 FamilyHub      🔔 [3]  👤 Admin│
├─────────────────────────────────────┤
│  Bună dimineața, Florentin! 👋      │
│                                     │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌─────┐│
│  │ 156  │ │  6   │ │  3   │ │ 1   ││
│  │Docs  │ │Active│ │Pend. │ │Over ││
│  └──────┘ └──────┘ └──────┘ └─────┘│
│                                     │
│  📊 Buget Luna Curentă              │
│  ┌─────────────────────────────────┐│
│  │ Venituri:  +8,500 RON          ││
│  │ Cheltuieli: -4,200 RON         ││
│  │ Balanță:    4,300 RON 📈       ││
│  └─────────────────────────────────┘│
│                                     │
│  📅 Plăți Viitoare                  │
│  • Ion Popescu - Ap.3 - 1,500 RON  │
│  • Maria Ionescu - Ap.5 - 1,200 RON│
└─────────────────────────────────────┘
```

## 🚀 Flux de Lucru Tipic

### Scenario 1: Nouă Factură Utilități

```text
1. Primești factură ENEL pe email
2. Salvezi PDF sau screenshot
3. Drag & drop în FamilyHub Documents
4. OCR extrage: "ENEL - 250 RON - Februarie 2025"
5. AI categorizează: Utilități
6. Selectezi apartamentul afectat
7. Document salvat și indexat
8. Poți căuta oricând: "ENEL februarie"
```

### Scenario 2: Chiriaș Nou

```text
1. Mergi la Properties → Add Tenant
2. Completezi: Nume, telefon, email, CNP
3. Selectezi apartament disponibil
4. Creezi contract: start date, chirie, garanție
5. Upload contract semnat (PDF)
6. Sistem generează automat plăți lunare
7. Trimite email welcome cu detalii
```

### Scenario 3: Plată Restantă

```text
1. Data 10 → sistem detectează plată pending
2. Celery task trimite email reminder
3. După 5 zile → escalare: email + WhatsApp
4. Chiriaș plătește → Upload dovadă
5. Admin marchează plată ca Paid
6. Status actualizat, email confirmare
```

## 💾 Date și Privacy

### Stocare

- **Documente:** Media folder, opțional Google Drive backup
- **Baza de date:** PostgreSQL cu backup automat zilnic
- **Logs:** Rotație 30 zile, arhivare pentru audit

### Securitate

- **Autentificare:** JWT tokens cu refresh
- **Permisiuni:** Granulare la nivel de obiect
- **HTTPS:** SSL/TLS obligatoriu în producție
- **Backup:** Zilnic PostgreSQL + media files
- **GDPR:** Export date personale la cerere

### Self-Hosted Avantaje

✅ Date private, nu sunt în cloud public  
✅ Fără costuri lunare de hosting  
✅ Control complet asupra codului  
✅ Customizare nelimitată  
✅ Offline-first pentru functionare fără internet

## 🎯 Beneficii și Impact

### Pentru Familie

- ⏱️ **Economie timp:** 10+ ore/lună (căutare documente, calcule)
- 💰 **Vizibilitate financiară:** Real-time tracking venituri/cheltuieli
- 📈 **Decizie informată:** Statistici și trend-uri pentru optimizare
- 🤝 **Colaborare:** Toți membrii familiei sincronizați

### Pentru Chiriași

- 📱 **Portal self-service:** Plăți, istoric, documente
- 🔔 **Notificări proactive:** Nu mai uită scadențe
- 💬 **Comunicare rapidă:** WhatsApp integration
- 📄 **Transparență:** Acces documente relevante

### Pentru Business

- 📊 **Rapoarte:** Export pentru contabilitate
- 🤖 **Automatizare:** Reducere munca manuală
- 📈 **Scalabilitate:** Adaugă apartamente fără efort
- 🔍 **Audit trail:** Istoric complet acțiuni

## 🔮 Viitor și Extensii

### Roadmap Potențial

- [ ] **Mobile Apps:** Flutter iOS/Android native
- [ ] **Blockchain:** Smart contracts pentru chirie
- [ ] **IoT:** Integrare contoare inteligente
- [ ] **Marketplace:** Găsire chiriași automat
- [ ] **AI Predictiv:** Prognoza cheltuieli
- [ ] **Multi-tenant:** Hosting pentru alți proprietari

### Plugin System

```python
# Custom plugin example
class CustomIntegration(BasePlugin):
    def on_payment_received(self, payment):
        # Custom logic
        self.send_to_accounting_software(payment)
```

## 📚 Resurse

### Documentație

- Backend API: `/api/docs/` (Swagger UI)
- Frontend Components: Storybook (opțional)
- User Guide: Wiki intern
- Video Tutorials: Pentru mama 😊

### Support

- Issues: GitHub Issues
- Updates: Changelog.md
- Community: Discord/Slack (opțional)

---

## Dezvoltat cu ❤️ pentru Familia Fusneica

> "Organizarea nu înseamnă perfecțiune, ci să știi unde e totul când ai nevoie"
