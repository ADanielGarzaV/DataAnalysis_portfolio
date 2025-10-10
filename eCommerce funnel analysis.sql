-- STEP 1 Import CSV and make sure everything is set properly

SELECT * FROM ecommerce_behavior LIMIT 10;

--STEP 2 — Basic sanity check of event types
--Let’s confirm how many unique events exist and get a feel for volume:
SELECT event_type, COUNT(*) AS total_events
FROM ecommerce_behavior
GROUP BY event_type
ORDER BY total_events DESC;

--STEP 3 — Count distinct users at each stage
--We’ll see how many unique users reached each step in the funnel:
SELECT event_type, COUNT(DISTINCT user_id) AS unique_users
FROM ecommerce_behavior
GROUP BY event_type
ORDER BY unique_users DESC;

--STEP 4 Funnel Breakdown
--| Funnel Stage   | Unique Users | Step Conversion                 | Overall Conversion                      |
--| -------------- | ------------ | ------------------------------- | --------------------------------------- |
--| Viewed product | 3,695,598    | —                               | —                                       |
--| Added to cart  | 826,323      | **22.4%** (826,323 / 3,695,598) | 22.4%                                   |
--| Purchased      | 441,638      | **53.4%** (441,638 / 826,323)   | **11.9% overall** (441,638 / 3,695,598) |

--So only about 1 in 9 users who view a product actually purchase, 
--and around half of those who add to cart finish the checkout.

--STEP 5 — Automate Funnel Table in SQL 
WITH user_funnel AS (
    SELECT event_type, COUNT(DISTINCT user_id) AS unique_users
    FROM ecommerce_behavior
    WHERE event_type IN ('view', 'cart', 'purchase')
    GROUP BY event_type
)
SELECT
    'view → cart → purchase' AS funnel_name,
    MAX(CASE WHEN event_type = 'view' THEN unique_users END) AS view_users,
    MAX(CASE WHEN event_type = 'cart' THEN unique_users END) AS cart_users,
    MAX(CASE WHEN event_type = 'purchase' THEN unique_users END) AS purchase_users,
    ROUND(MAX(CASE WHEN event_type = 'cart' THEN unique_users END)::NUMERIC /
          MAX(CASE WHEN event_type = 'view' THEN unique_users END) * 100, 2) AS cart_conversion_rate,
    ROUND(MAX(CASE WHEN event_type = 'purchase' THEN unique_users END)::NUMERIC /
          MAX(CASE WHEN event_type = 'cart' THEN unique_users END) * 100, 2) AS purchase_conversion_rate,
    ROUND(MAX(CASE WHEN event_type = 'purchase' THEN unique_users END)::NUMERIC /
          MAX(CASE WHEN event_type = 'view' THEN unique_users END) * 100, 2) AS total_conversion_rate
FROM user_funnel;

--— STEP B User Journey Over Time
--We already know:
--Each user_session has multiple events (view → cart → purchase)
--Each event has an event_time
--What we’ll do next:
--STEP 1: Understand the Journey Inside Each Session
--We’ll start by ranking events by time, for every user session 
--— so we can follow the user’s flow through the funnel.
--👉 Goal: See for each session:
--Which event came first, second, third

--How long between them (in seconds/minutes)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ecommerce_behavior';

--STEP 1: Rank Events per User Session by Time
--We’ll use the ROW_NUMBER() function to order each event within 
--a session (so we can trace user behavior in order).
-- STEP 1: Order each user's session activity by event_time
SELECT
    user_id,
    user_session,
    event_type,
    event_time,
    ROW_NUMBER() OVER (
        PARTITION BY user_session
        ORDER BY event_time
    ) AS event_order
FROM ecommerce_behavior
ORDER BY user_session, event_time
LIMIT 50;

--STEP 2: Let’s check one full user session
--This will help you see the story of one person’s actions.
-- STEP 2: Look at a single user's session journey
SELECT 
    user_id,
    user_session,
    event_type,
    event_time
FROM ecommerce_behavior
WHERE user_session IN (
    SELECT user_session
    FROM ecommerce_behavior
    WHERE event_type = 'purchase'
    LIMIT 1
)
ORDER BY event_time;

--(STEP 3): Measure time between steps
--Now we’ll calculate — for each session that made a purchase — 
--how long it took to go from:
--first view
--to first cart
--to first purchase
--That’ll show us if users are taking seconds, minutes, or 
--hours to make a buying decision
-- STEP 3: Time taken between view → cart → purchase in each session
WITH user_funnel AS (
    SELECT
        user_id,
        user_session,
        MIN(CASE WHEN event_type = 'view' THEN event_time END) AS first_view_time,
        MIN(CASE WHEN event_type = 'cart' THEN event_time END) AS first_cart_time,
        MIN(CASE WHEN event_type = 'purchase' THEN event_time END) AS purchase_time
    FROM ecommerce_behavior
    GROUP BY user_id, user_session
)
SELECT
    COUNT(*) AS sessions_with_purchase,
    AVG(EXTRACT(EPOCH FROM (first_cart_time - first_view_time)) / 60) AS avg_minutes_view_to_cart,
    AVG(EXTRACT(EPOCH FROM (purchase_time - first_cart_time)) / 60) AS avg_minutes_cart_to_purchase,
    AVG(EXTRACT(EPOCH FROM (purchase_time - first_view_time)) / 60) AS avg_minutes_view_to_purchase
FROM user_funnel
WHERE purchase_time IS NOT NULL
  AND first_view_time IS NOT NULL
  AND first_cart_time IS NOT NULL;

--STEP 4 Dig into “viewers who don’t buy”
--Now that we understand successful sessions, let’s compare 
--them to the unsuccessful ones (those with only “views” or 
--“cart” events but no purchase).
-- STEP 4: Compare session counts by funnel completion
WITH user_funnel AS (
    SELECT
        user_session,
        MAX(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS has_view,
        MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS has_cart,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS has_purchase
    FROM ecommerce_behavior
    GROUP BY user_session
)
SELECT
    SUM(CASE WHEN has_view = 1 AND has_cart = 0 AND has_purchase = 0 THEN 1 ELSE 0 END) AS only_views,
    SUM(CASE WHEN has_view = 1 AND has_cart = 1 AND has_purchase = 0 THEN 1 ELSE 0 END) AS cart_but_no_purchase,
    SUM(CASE WHEN has_view = 1 AND has_cart = 1 AND has_purchase = 1 THEN 1 ELSE 0 END) AS completed_purchases
FROM user_funnel;

--NEXT ANALYTICAL STEP
--We can use this information to break this funnel by product category
--or brand — for example: Which categories (e.g., electronics, 
--appliances, etc.) have the highest drop-off?
--Which brands convert best once users add to cart?

--STEP 1: Category-Level Funnel
--This query calculates:
--How many sessions viewed products in that category
--How many added something from that category to cart
--How many purchased something from that category
--Then gives conversion rates for:
--View → Cart
--Cart → Purchase
--View → Purchase
-- STEP 1: Category-level funnel analysis
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
LIMIT 20;

--Step 2 — 
--We’ll zoom into electronics.smartphone, since it’s the top performer,
--and break it down by brand to see what’s really driving that 7.7% 
--conversion rate.
-- STEP 2.5: Brand-level funnel within the smartphone category
WITH brand_funnel AS (
    SELECT
        brand,
        COUNT(DISTINCT CASE WHEN event_type = 'view' THEN user_session END) AS view_sessions,
        COUNT(DISTINCT CASE WHEN event_type = 'cart' THEN user_session END) AS cart_sessions,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_session END) AS purchase_sessions
    FROM ecommerce_behavior
    WHERE category_code = 'electronics.smartphone'
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

-- BONUS FINAL STEP: Average Price Per Brand (and Correlation to 
--Conversion)
--Let’s get the average price for each brand (based on actual 
--purchases), and then join that with your funnel stats.
--Analyze average price per brand and link with funnel performance

-- 1️⃣ Get brand-level funnel stats
WITH brand_funnel AS (
    SELECT 
        brand,
        COUNT(DISTINCT CASE WHEN event_type = 'view' THEN user_session END) AS view_sessions,
        COUNT(DISTINCT CASE WHEN event_type = 'cart' THEN user_session END) AS cart_sessions,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_session END) AS purchase_sessions
    FROM ecommerce_behavior
    WHERE category_code LIKE 'electronics.smartphone%'
    GROUP BY brand
),

-- 2️⃣ Get average price for purchases per brand
brand_prices AS (
    SELECT
        brand,
        AVG(price) AS avg_purchase_price
    FROM ecommerce_behavior
    WHERE category_code LIKE 'electronics.smartphone%'
      AND event_type = 'purchase'
      AND price IS NOT NULL
    GROUP BY brand
)

-- 3️⃣ Combine everything
SELECT
    f.brand,
    f.view_sessions,
    f.cart_sessions,
    f.purchase_sessions,
    ROUND((f.cart_sessions::decimal / NULLIF(f.view_sessions, 0)) * 100, 2) AS view_to_cart_rate,
    ROUND((f.purchase_sessions::decimal / NULLIF(f.cart_sessions, 0)) * 100, 2) AS cart_to_purchase_rate,
    ROUND((f.purchase_sessions::decimal / NULLIF(f.view_sessions, 0)) * 100, 2) AS view_to_purchase_rate,
    ROUND(p.avg_purchase_price, 2) AS avg_purchase_price
FROM brand_funnel f
LEFT JOIN brand_prices p
  ON f.brand = p.brand
ORDER BY view_to_purchase_rate DESC NULLS LAST;

