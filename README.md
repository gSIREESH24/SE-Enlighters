# 🌟 Enlightener

Enlightener is an Android application designed to provide inclusive spiritual guidance by connecting individuals with the wisdom of three major sacred texts:
the Bhagavad Gita, the Bible, and the Quran.

It allows users to ask religion-related questions in multiple languages and offers an interactive, accessible, and engaging experience aligned with the United Nations Sustainable Development Goals (SDGs).




## 🌍 SDG Alignment

Enlightener contributes to accessibility and education, aligning with:

🎓 SDG 4: Quality Education – Provides multilingual and accessible religious content for learners worldwide.

⚖ SDG 10: Reduced Inequalities – Ensures equal access to spiritual resources with language support and read-aloud features.

🕊 SDG 16: Peace, Justice, and Strong Institutions – Promotes respect, tolerance, and peaceful coexistence through wisdom from diverse religions.




## ✨ Key Features

🔐 Login & Signup – Secure email/password login, signup, and Forgot Password support.

![image alt](https://github.com/gSIREESH24/SE-Enlighters/blob/main/Images/LoginPage.jpg)
![image alt](https://github.com/gSIREESH24/SE-Enlighters/blob/main/Images/SignUpPage.jpg)


❓ FAQs & Search – Quick navigation and intelligent search for guidance.



![image alt](https://github.com/gSIREESH24/SE-Enlighters/blob/main/Images/HomePage(LightTheme).jpg)



📂 Navigation Menu – Access Profile, History, Settings, and Logout via hamburger menu.



![image alt](https://github.com/gSIREESH24/SE-Enlighters/blob/main/Images/Recents.jpg)



🌗 Dark Mode – Seamless light and dark theme toggle.



![image alt](https://github.com/gSIREESH24/SE-Enlighters/blob/main/Images/HomePage(DarkTheme).jpg)




🙏 Ask Me – Ask religion-related questions; answers sourced only from Bhagavad Gita, Bible, and Quran.




![image alt](https://github.com/gSIREESH24/SE-Enlighters/blob/main/Images/AfterSearch.jpg)
![image alt](https://github.com/gSIREESH24/SE-Enlighters/blob/main/Images/BackendFetching.jpg)
![image alt](https://github.com/gSIREESH24/SE-Enlighters/blob/main/Images/VoiceCommand.jpg)
![image alt](https://github.com/gSIREESH24/SE-Enlighters/blob/main/Images/MultiLanguage.jpg)
![image alt](https://github.com/gSIREESH24/SE-Enlighters/blob/main/Images/Comparision.jpg)

📊 Interactive Visualization – Animated loading screen → 3-colored pie chart → expandable religion-specific cards.

🔎 Comparative Insights – Side-by-side religious perspectives highlighting commonalities & differences.

📝 Detailed Answers – Double-tap a card for a detailed explanation.

🌐 Language Support – Multilingual responses with an easy selector.

🔊 Accessibility – Read-aloud functionality in multiple languages.

🤔 Flexible Question Handling – Handles both precise and open-ended queries intelligently.




##  🛠 Technologies Used

Frontend: Flutter

Backend: Node.js

Database: Firebase Firestore

Authentication: Firebase Auth

Data Processing: Python

OCR: Google Cloud Vision API




## 📱 How to Use

Login or Signup using your email and password.

Toggle between light/dark themes using the top-right switch.

Explore FAQs or type your question in the search bar.

Tap Ask Me → view the animated loading screen → see the 3-part pie chart.

Select a section → open a religion-specific card.

Double-tap card for a detailed answer.

Change language via the language selector.

Tap Read Aloud to listen to the answer (tap again to stop).

Access Profile, History, Settings, or Logout via the hamburger menu.

Tap View Comparative Insights to see shared & unique perspectives from all three religions.




## ⚙ Backend Processing & Technical Highlights

Sacred texts (Bhagavad Gita, Bible, Quran) are pre-processed into meaningful chunks for accurate retrieval.

Google Cloud Vision API (OCR) extracts and segments text while preserving structure.

Coordinate-based segmentation ensures logical grouping and context accuracy.

Chunks stored in Firestore for scalable querying.

Node.js APIs deliver relevant answers in real-time.

Firebase Authentication ensures secure user access.




## 👥 Team & Contributions

### Yashwin Sai (CS24B014)

* Developed backend architecture & APIs (with Rohith)

* Managed Firestore (with Rohith)

* Built multilingual read-aloud (with Sireesh)

* Prepared README, SDG analysis & screenshots (with Aditya)


### G Sireesh Reddy (CS24B013)

* Bridged frontend & backend

* Contributed to UI development

* Conducted testing and bug fixing (with Mohammed)

* Built multilingual read-aloud (with Yashwin)


### Ch Sai Rohith (CS24B009)

* Co-developed backend (with Yashwin)

* Integrated Firebase Authentication (with Mohammed)

* Co-managed Firestore (with Yashwin)

* DataProcessing of Holy Books


### Mohammed Owais Shaik (CS24B040)

* Built frontend components (with Aditya)

* Integrated Firebase Authentication (with Rohith)

* Implemented recent searches & dark mode (with Aditya)

* Conducted testing & QA (with Sireesh)


### Aditya P Rajesh (CS24B003)

* Built frontend components (with Mohammed)

* Implemented recent searches & dark mode (with Mohammed)

* Led project research efforts

* Prepared README, SDG analysis & screenshots (with Yashwin)
