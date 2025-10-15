from flask import Flask, jsonify, render_template
from flask_cors import CORS
from db_config import get_connection
from dotenv import load_dotenv
load_dotenv()


app = Flask(__name__)
CORS(app)

# 🔹 Simple in-memory cache
cached_funnel_data = None

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/api/funnel')
def get_funnel_data():
    global cached_funnel_data

    if cached_funnel_data is None:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("""
        SELECT event_type, COUNT(DISTINCT user_id)
        FROM ecommerce_behavior
        GROUP BY event_type;
        """)
        rows = cur.fetchall()
        cur.close()
        conn.close()

        cached_funnel_data = [{'event_type': r[0], 'unique_users': r[1]} for r in rows]

    return jsonify(cached_funnel_data)

@app.route('/api/category')
def get_category_funnel():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        WITH category_funnel AS (
            SELECT
                category_code,
                COUNT(DISTINCT CASE WHEN event_type = 'view' THEN user_session END) AS view_sessions,
                COUNT(DISTINCT CASE WHEN event_type = 'cart' THEN user_session END) AS cart_sessions,
                COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_session END) AS purchase_sessions
            FROM ecommerce_behavior
            WHERE category_code IS NOT NULL
            GROUP BY category_code
        )
        SELECT
            category_code,
            view_sessions,
            cart_sessions,
            purchase_sessions,
            ROUND((cart_sessions::decimal / NULLIF(view_sessions, 0)) * 100, 2) AS view_to_cart_rate,
            ROUND((purchase_sessions::decimal / NULLIF(cart_sessions, 0)) * 100, 2) AS cart_to_purchase_rate,
            ROUND((purchase_sessions::decimal / NULLIF(view_sessions, 0)) * 100, 2) AS view_to_purchase_rate
        FROM category_funnel
        ORDER BY view_to_purchase_rate DESC
        LIMIT 15;
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()

    data = [
        {
            'category_code': r[0],
            'view_sessions': r[1],
            'cart_sessions': r[2],
            'purchase_sessions': r[3],
            'view_to_cart_rate': float(r[4]) if r[4] else 0,
            'cart_to_purchase_rate': float(r[5]) if r[5] else 0,
            'view_to_purchase_rate': float(r[6]) if r[6] else 0
        } for r in rows
    ]
    return jsonify(data)


@app.route('/api/brand')
def get_brand_funnel():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        WITH brand_funnel AS (
            SELECT
                brand,
                COUNT(DISTINCT CASE WHEN event_type = 'view' THEN user_session END) AS view_sessions,
                COUNT(DISTINCT CASE WHEN event_type = 'cart' THEN user_session END) AS cart_sessions,
                COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_session END) AS purchase_sessions
            FROM ecommerce_behavior
            WHERE category_code LIKE 'electronics.smartphone%'
              AND brand IS NOT NULL
            GROUP BY brand
        )
        SELECT
            brand,
            view_sessions,
            cart_sessions,
            purchase_sessions,
            ROUND((cart_sessions::decimal / NULLIF(view_sessions, 0)) * 100, 2) AS view_to_cart_rate,
            ROUND((purchase_sessions::decimal / NULLIF(cart_sessions, 0)) * 100, 2) AS cart_to_purchase_rate,
            ROUND((purchase_sessions::decimal / NULLIF(view_sessions, 0)) * 100, 2) AS view_to_purchase_rate
        FROM brand_funnel
        ORDER BY view_to_purchase_rate DESC
        LIMIT 15;
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()

    data = [
        {
            'brand': r[0],
            'view_sessions': r[1],
            'cart_sessions': r[2],
            'purchase_sessions': r[3],
            'view_to_cart_rate': float(r[4]) if r[4] else 0,
            'cart_to_purchase_rate': float(r[5]) if r[5] else 0,
            'view_to_purchase_rate': float(r[6]) if r[6] else 0
        } for r in rows
    ]
    return jsonify(data)


if __name__ == "__main__":
    app.run(debug=True)

