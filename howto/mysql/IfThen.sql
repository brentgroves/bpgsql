DELIMITER $$
DROP FUNCTION IF EXISTS `check2_login`$$
CREATE  FUNCTION `check2_login`(p_username VARCHAR(30),p_password VARCHAR(30),role VARCHAR(20)) RETURNS BOOL
    BEGIN
    DECLARE retval INT;
            IF role = "customer" THEN
                SELECT COUNT(custid) INTO retval FROM customer WHERE custid = p_username and pwd = p_password;
                IF retval != 0 THEN
                    RETURN TRUE;    
                ELSE
                    RETURN FALSE;                           
                END IF;
            ELSEIF role = "executive" THEN
                SELECT COUNT(execid) INTO retval FROM executive WHERE execid = p_username and pwd = p_password;
                IF retval != 0 THEN
                    RETURN TRUE;    
                ELSE
                    RETURN FALSE;                           
                END IF;
            ELSEIF role = "admin" THEN
                SELECT COUNT(empid) INTO retval FROM employee WHERE empid = p_username and pwd = p_password;
                IF retval != 0 THEN
                    RETURN TRUE;    
                ELSE
                    RETURN FALSE;                           
                END IF;
            ELSE
                RETURN FALSE;       
            END IF;
    END$$
DELIMITER ;