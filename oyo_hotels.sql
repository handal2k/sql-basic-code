-- HOW TO FIND THE SPECIFIC 'CITY' IN THE DATA --
SELECT 
    hotel_id, city
FROM
    (SELECT 
        os.hotel_id, ohd.city
    FROM
        oyo_sql os
    LEFT OUTER JOIN oyo_hotels_dataset ohd ON os.hotel_id = ohd.hotel_id) x
WHERE
    city = 'Delhi';




-- HOW TO COUNT HOTEL ON EACH CITY --
SELECT 
    COUNT(hotel_id) Hotel_Count,
    City
FROM
    oyo_hotels_dataset
GROUP BY City
ORDER BY Hotel_Count;



-- HOW TO COUNT THE 'STATUS' WERE 'STAYED' IN THE HOTEL --
SELECT 
    COUNT(status) Status_count
FROM
    (SELECT 
        os.status, ohd.city
    FROM
        oyo_sql os
    LEFT OUTER JOIN oyo_hotels_dataset ohd ON os.hotel_id = ohd.hotel_id
    WHERE
        status = ('Stayed')) x;



-- HOW TO FILTER THE DATA WHERE 'DISCOUNT' WERE GREATER THAN THE GIVEN 'DISCOUNT AVERAGE' --
SELECT 
    os.customer_id, os.amount, os.discount, ohd.city
FROM
    oyo_sql os
        LEFT OUTER JOIN
    oyo_hotels_dataset ohd ON os.hotel_id = ohd.hotel_id
WHERE
    discount > (SELECT 
            AVG(discount)
        FROM
            oyo_sql)
ORDER BY discount DESC;




-- HOW TO FIND THE HIGHEST AMOUNT WERE GREATER THANT THE AVERAGE AMOUNT AND THE STATUS WERE STAYED --
SELECT  
	*,
	row_number () over (partition by os.customer_id) AS row_nmbr
FROM oyo_sql os
	LEFT JOIN oyo_hotels_dataset ohd ON os.hotel_id = ohd.Hotel_id
WHERE
	os.amount > (SELECT AVG(amount) FROM oyo_sql)
	AND os.status = 'Stayed'
ORDER BY os.amount DESC
LIMIT 10;




-- AN EXAMPLE OF USING CTE (Common Table Expression) --
WITH cte_oyo_sql AS (
SELECT  *, 
		SUM(amount) AS total_amount,
        AVG(amount) AS average_amount
FROM oyo_sql
WHERE
	status = 'Stayed'
GROUP BY customer_id
ORDER BY total_amount DESC )

SELECT 
	customer_id, hotel_id,  average_amount, status
FROM cte_oyo_sql
GROUP BY customer_id
ORDER BY average_amount DESC;




-- HOW TO FIND GROSS REVENUE SORT BY CITY --
SELECT 
    os.customer_id,
    SUM(amount) total_amount,
    SUM(discount) total_discount,
    SUM(amount - discount) AS gross_revenue,
    ohd.city
FROM
    oyo_sql os
        LEFT OUTER JOIN
    oyo_hotels_dataset ohd ON os.hotel_id = ohd.hotel_id
GROUP BY city
ORDER BY gross_revenue DESC;




-- HOW TO USE DATEDIFF FUNCTIONS --
SELECT 
    date_of_booking,
    DATEDIFF(check_out, check_in) AS interval_time_stayed
FROM
    oyo_sql
WHERE
    status IN ('Stayed')
ORDER BY date_of_booking;



-- HOW TO USE DATE FUNCTIONS IN MORE CASE --
SELECT 
    check_in,
    check_out,
    DATE(date_of_booking) AS date_book,
    DAYNAME(date_of_booking) AS dayname_booking,
    DATEDIFF(check_out, check_in) AS interval_time_stayed
FROM
    oyo_sql
WHERE
    DATEDIFF(check_out, check_in) > 3
ORDER BY interval_time_stayed;




-- JUST TO MAKE SURE TO COUNT THE TOTAL CITY --
SELECT 
    COUNT(city)
FROM
    (SELECT DISTINCT
        city
    FROM
        oyo_hotels_dataset) x;




-- DATE FUNCTIONS + WHERE CLAUSE --
SELECT 
    customer_id,
    hotel_id,
    check_in,
    check_out,
    DATE(date_of_booking) AS date_book,
    DATEDIFF(check_out, check_in) AS interval_days
FROM
    oyo_sql
WHERE
    status = 'Stayed'
        AND DATEDIFF(check_out, check_in) > 3
GROUP BY customer_id
ORDER BY interval_days DESC;





-- HOW TO RANK THE CITY BASED ON TOTAL REVENUE --
SELECT customer_id,
		city,
		revenue,
        rank_id
FROM
(SELECT customer_id,
		city,
		amount,
        discount,
		sum(amount - discount) AS revenue,
        RANK () OVER (PARTITION BY city ORDER BY SUM(amount - discount) DESC) AS rank_id
FROM oyo_sql o
LEFT JOIN oyo_hotels_dataset ohd ON o.hotel_id = ohd.hotel_id
-- where amount - discount > 50000
GROUP BY customer_id
ORDER BY revenue DESC) x
WHERE rank_id < 2;



-- TOP 10 TOTAL REVENUE FROM CUSTOMER ID --
SELECT 
    customer_id,
    amount,
    discount,
    amount - discount AS revenue,
    SUM(amount - discount) AS total_revenue
FROM
    oyo_sql
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;




-- JUST COUNT THE TOTAL OF CUSTOMER_ID --
SELECT 
    COUNT(DISTINCT customer_id)
FROM
    oyo_sql;




-- HOW TO FILTER THE DATA USING LIKE CLAUSE --
SELECT 
    *
FROM
    oyo_sql OS
        LEFT OUTER JOIN
    oyo_hotels_dataset OHD ON OS.hotel_id = OHD.Hotel_id
WHERE
    CITY LIKE 'DELHI'
        AND STATUS LIKE 'STAYED'
GROUP BY OHD.Hotel_id
ORDER BY OS.check_in




