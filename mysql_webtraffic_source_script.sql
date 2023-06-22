USE mavenfuzzyfactory;

SELECT 
	website_sessions.utm_content, 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,  -- counts the distinct website sessions by utm content
    COUNT(DISTINCT orders.order_id) AS orders,  -- counts distinct orders made from each utm content
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_conv_rt -- calculates conversion rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
        
WHERE website_sessions.website_session_id Between 1000 AND 2000
GROUP BY 1         -- groups by column 1  website_sessions.utm_content
ORDER BY 2 DESC;    -- orders by column 2  sessions