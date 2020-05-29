-- /home/brent/srcsql/bpgsql/kors/MySQL/Import.csv
-- https://www.mysqltutorial.org/import-csv-file-mysql-table/
CREATE TABLE discounts (
    id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    expired_date DATE NOT NULL,
    amount DECIMAL(10 , 2 ) NULL,
    PRIMARY KEY (id)
);
/*
id.title,expired_date,amount
1,"Spring Break 2014",01/04/2014,20
2,"Back to School 2014",01/09/2014,25
3,"Summer 2014",06/25/2014,10
*/

/*
 * PATH IS LOCAL TO THE DATABASE SERVER IN THIS CASE
 * would have to move import file to docker container.
 */
LOAD DATA INFILE '/Import.csv'  
INTO TABLE discounts
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(title,@expired_date,amount)
SET expired_date = STR_TO_DATE(@expired_date, '%m/%d/%Y');
select * from discounts;
/*
 * PATH IS LOCAL TO THE DATABASE CLIENT IN THIS CASE
 * THIS IS SLOWER
 */
LOAD DATA LOCAL INFILE  '/home/brent/srcsql/bpgsql/kors/MySQL/Import.csv'
INTO TABLE discounts
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(title,@expired_date,amount)
SET expired_date = STR_TO_DATE(@expired_date, '%m/%d/%Y');

select * from discounts d 



