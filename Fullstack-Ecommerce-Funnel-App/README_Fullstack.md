Flask + PostgreSQL + Plotly.js Dashboard

This project is a full-stack data analytics app that connects a PostgreSQL database with a Flask backend and a Plotly-powered frontend.
It visualizes the e-commerce user conversion funnel — showing how users move from viewing products → adding to cart → purchasing, with dynamic category and brand filters.

🚀 Features
REST API built with Flask
Interactive Plotly.js funnel visualization
Real-time data fetched from PostgreSQL

API endpoints for:
/api/funnel → overall conversion funnel
/api/category → category-level funnel
/api/brand → smartphone brand-level funnel
Simple frontend dashboard with dynamic filters
Secure database configuration using .env variables

🧩 Project Structure
Fullstack_Funnel_App/
│
├── app.py                 # Main Flask app / API routes
├── db_config.py           # PostgreSQL connection handler
├── .env.example           # Template for environment variables (no real secrets)
├── requirements.txt       # Python dependencies
│
├── /templates/
│   └── index.html         # Frontend page (dashboard)
│
├── /static/
│   ├── style.css          # Custom CSS
│   └── script.js          # Plotly funnel + API requests
│
└── README_Fullstack.md    # You are here

⚙️ Setup Instructions
1️⃣ Clone the Repository
git clone https://github.com/<yourusername>/data-analytics-portfolio.git
cd data-analytics-portfolio/Fullstack_Funnel_App

2️⃣ Create and Activate a Virtual Environment
# Windows (PowerShell)
python -m venv .venv
.venv\Scripts\Activate

# macOS / Linux
python3 -m venv .venv
source .venv/bin/activate

3️⃣ Install Dependencies
pip install -r requirements.txt

4️⃣ Configure Your Database Connection
Create a .env file (copy .env.example) and update with your PostgreSQL credentials:

DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=dvdrental
DATABASE_USER=postgres
DATABASE_PASSWORD=yourpassword

5️⃣ Run the Application
python app.py


Then open your browser and go to:
👉 http://127.0.0.1:5000/

🧠 API Endpoints
Endpoint	Description
/api/funnel	Overall user funnel (view → cart → purchase)
/api/category	Top 15 categories by conversion rate
/api/brand	Top smartphone brands by conversion rate
📊 Tech Stack

Backend: Flask, psycopg2, python-dotenv
Database: PostgreSQL
Frontend: HTML5, CSS3, JavaScript (Plotly.js)
Other: REST API, Environment Variables, Data Visualization

💡 Key Learning Highlights
Built a RESTful API connected to live SQL queries
Integrated PostgreSQL analytics logic directly into Flask routes
Created dynamic Plotly funnel charts that update from backend data
Implemented environment variable management with .env for security

🧱 Future Improvements
Add interactive dropdown filters for category / brand on the frontend
Deploy app using Render, Railway, or Heroku
Integrate caching or async queries for faster API response
