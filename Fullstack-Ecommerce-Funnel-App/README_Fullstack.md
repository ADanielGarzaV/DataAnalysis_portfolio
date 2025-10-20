🛍️ E-Commerce Funnel Fullstack App
Flask + PostgreSQL + Plotly.js Dashboard

This project is a full-stack data analytics web app that connects a PostgreSQL database to a Flask backend and an interactive Plotly.js frontend.
It visualizes the e-commerce user conversion funnel, showing how users move from viewing products → adding to cart → purchasing, with category and brand-level breakdowns.

🚀 Features
Flask REST API serving live data from PostgreSQL
Plotly.js funnel visualization for real-time analytics
Dynamic endpoints for overall funnel, category, and brand insights
.env-based configuration for secure credentials
Modular, production-ready structure with caching support

API endpoints for:
/api/funnel → overall conversion funnel
/api/category → category-level funnel
/api/brand → smartphone brand-level funnel
Simple frontend dashboard with dynamic filters
Secure database configuration using .env variables

🧩 Project Structure
Fullstack_Funnel_App/
│  

├──   app.py        # Main Flask app / API routes

├── db_config.py  # PostgreSQL connection handler

├── .env.example  # Environment variable template

├── requirements.txt # Python dependencies

│

├── /templates/

│   └── index.html  # Frontend HTML dashboard

│

├── /static/

│   ├── style.css   # Dashboard styling

│   └── script.js   # Plotly chart and API calls

│
└── README_Fullstack.md   # Project documentation


⚙️ Setup Instructions

1️⃣ Clone the repository
git clone https://github.com/<yourusername>/data-analytics-portfolio.git
cd data-analytics-portfolio/Fullstack_Funnel_App


2️⃣ Create and activate virtual environment
python -m venv .venv
.\.venv\Scripts\activate    # (Windows)
# or
source .venv/bin/activate   # (macOS/Linux)

3️⃣ Install dependencies
pip install -r requirements.txt


4️⃣ Configure your PostgreSQL credentials
Create a .env file:

DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=dvdrental
DATABASE_USER=postgres
DATABASE_PASSWORD=yourpassword

5️⃣ Run the app
python app.py


Then open your browser and go to:
👉 http://127.0.0.1:5000/

🧠 API Endpoints
| Endpoint        | Description                                  |
| --------------- | -------------------------------------------- |
| `/api/funnel`   | Overall user funnel (view → cart → purchase) |
| `/api/category` | Top 15 categories by conversion rate         |
| `/api/brand`    | Smartphone brand-level funnel                |


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
Total Conversion Rate: 11.9% (view → purchase)
Average time from view to purchase: ~8 minutes
Smartphones had the highest category conversion (7.7%)
Samsung outperformed Apple in cart-to-purchase rate despite lower price

🧱 Future Improvements
Add interactive dropdown filters for category / brand on the frontend
Deploy app using Render, Railway, or Heroku
Integrate caching or async queries for faster API response
