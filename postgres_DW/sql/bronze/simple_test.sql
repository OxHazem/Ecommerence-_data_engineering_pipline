SELECT customer_id, date_of_birth
FROM bronze.customer
WHERE date_of_birth = 'not-a-date'
LIMIT 10;