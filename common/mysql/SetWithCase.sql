UPDATE my_table
    SET field = CASE
        WHEN id IN (/* true ids */) THEN TRUE
        WHEN id IN (/* false ids */) THEN FALSE
        ELSE field=field 
    END