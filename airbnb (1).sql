LOAD DATA LOCAL INFILE "C:/Users/91972/Downloads/Airbnb_Open_Data_Clean.csv"
INTO TABLE airbnb_open_data_dirty
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- START 
 
SELECT * FROM airbnb_open_data_dirty ;
SELECT COUNT(*) FROM airbnb_open_data_dirty ;
SELECT DISTINCT COUNT(*) FROM airbnb_open_data_dirty ;


							-- REMOVING DUPLICATES using Window fnc

CREATE TABLE stag_airbnb AS ( 
			SELECT * , ROW_NUMBER() OVER ( PARTITION BY `id`, `NAME`, `host id`
														,`host_identity_verified`, `host name`, `neighbourhood group`, neighbourhood, lat, `long` 
														,`country`, `country code`, `instant_bookable`, `cancellation_policy`
														,`room type`, `Construction year`, `price`, `service fee`, `minimum nights`
														,`number of reviews`, `last review`, `reviews per month`, `review rate number` 
														,`calculated host listings count`, `availability 365`, house_rules, license ) AS rn 
			FROM airbnb_open_data_dirty);
            
DELETE FROM stag_airbnb
WHERE rn >1 ;                            

							 -- column 1 

SELECT COUNT(id) FROM stag_airbnb;                             

SELECT  DISTINCT COUNT(id) FROM stag_airbnb;

ALTER TABLE stag_airbnb
ADD CONSTRAINT PRIMARY KEY (id);

							 -- column 2
SELECT COUNT(`NAME`) FROM stag_airbnb;
SELECT DISTINCT COUNT(`NAME`) FROM stag_airbnb;

UPDATE stag_airbnb
SET `NAME` =TRIM(`NAME`);

SELECT *,(`NAME`) FROM stag_airbnb LIMIT 5000;

							-- Column 3 
SELECT COUNT(`host id`) FROM stag_airbnb;
SELECT DISTINCT COUNT(`host id`) FROM stag_airbnb;

SELECT DISTINCT length(`host id`) FROM stag_airbnb;                           
 
SELECT `host id` FROM stag_airbnb
WHERE length(`host id`) = 9; 

ALTER TABLE stag_airbnb
MODIFY COLUMN `host id` BIGINT;
                       
						-- Column 4
                        
SELECT COUNT(`host_identity_verified`) FROM stag_airbnb;
SELECT DISTINCT COUNT(`host_identity_verified`) FROM stag_airbnb;
                       
SELECT DISTINCT (`host_identity_verified`) FROM stag_airbnb;

UPDATE stag_airbnb
SET `host_identity_verified` = TRIM(`host_identity_verified`); 	                      


UPDATE stag_airbnb
SET `host_identity_verified` = 'Not Verified' 
WHERE `host_identity_verified` = 'unconfirmed';

UPDATE stag_airbnb
SET `host_identity_verified` = 'Verified' 
WHERE `host_identity_verified` = 'verified';

UPDATE stag_airbnb
SET `host_identity_verified` = NULL 
WHERE `host_identity_verified` = '';


ALTER TABLE stag_airbnb
MODIFY COLUMN `host_identity_verified` VARCHAR(20);
                       
SELECT *, `host_identity_verified` FROM stag_airbnb;

CREATE TABLE stag2 AS
			SELECT * ,
						LAG(`host_identity_verified`,1,'Not Verified') OVER () AS lag_hiv
			FROM stag_airbnb;            

UPDATE stag2
SET `host_identity_verified` = COALESCE(`host_identity_verified`, lag_hiv);

SELECT * FROM stag2;

									-- Column 5  
SELECT COUNT(`host name`) FROM stag2;                                   
SELECT DISTINCT `host name` FROM stag2
ORDER BY `host name`;                                   
-- this column is not needed for analysis

ALTER TABLE stag2
DROP COLUMN `host name` ;

								-- Column 6

SELECT COUNT(`neighbourhood group`) FROM stag2;

SELECT DISTINCT COUNT(`neighbourhood group`) FROM stag2;
SELECT (`neighbourhood group`) FROM stag2;
SELECT `neighbourhood group` , COUNT(`neighbourhood group`) FROM stag2
GROUP BY `neighbourhood group`;

UPDATE stag2
SET  `neighbourhood group` = NULL
WHERE `neighbourhood group` = '';

CREATE TABLE stag3 AS
			SELECT * ,
						LAG(`neighbourhood group`,1,'Brooklyn') OVER () AS lag_ng
			FROM stag2;           
            
UPDATE stag3
SET  `neighbourhood group` = COALESCE(`neighbourhood group`, lag_ng);

UPDATE stag3
SET  `neighbourhood group` = TRIM(`neighbourhood group`);

ALTER TABLE stag3
MODIFY COLUMN `neighbourhood group` VARCHAR(20);

									-- Column 7 
                                    
SELECT COUNT(`neighbourhood`) FROM stag3;
SELECT DISTINCT COUNT(`neighbourhood`) FROM stag3;
SELECT DISTINCT (`neighbourhood`) FROM stag3;

SELECT `neighbourhood` , COUNT(`neighbourhood`) FROM stag3
GROUP BY `neighbourhood`
ORDER BY 1;

SELECT DISTINCT `neighbourhood group` , (`neighbourhood`) FROM stag3
WHERE `neighbourhood` = '' ;

SELECT DISTINCT `neighbourhood group` , (`neighbourhood`) FROM stag3
WHERE `neighbourhood group` IN('Brooklyn','Manhattan');

UPDATE stag3
SET  `neighbourhood` = NULL
WHERE `neighbourhood` = '';

DELETE FROM  stag3
WHERE  `neighbourhood` IS NULL;

											--  Column  8

SELECT (lat) FROM stag3 ; 

SELECT COUNT(lat) FROM stag3 ; 

UPDATE stag3
SET lat = ROUND(lat,2);
                                          
                                   		--  Column  9

SELECT (`long`) FROM stag3 ; 

SELECT COUNT(`long`) FROM stag3 ; 

UPDATE stag3
SET `long` = ROUND(`long`,2);       

										--  Column  10	

SELECT DISTINCT (country) FROM stag3 ; 

SELECT country , COUNT(country) FROM stag3 
GROUP BY country; 


UPDATE stag3
SET  `country` = NULL
WHERE `country` = '';
   
UPDATE stag3
SET country = IFNULL(country, 'United States');

										-- Column 11


SELECT DISTINCT count(`country code`) FROM stag3 ; 
SELECT COUNT(`country code`) FROM stag3 ; 
SELECT DISTINCT (`country code`) FROM stag3 ; 

SELECT `country code` , COUNT(`country code`) FROM stag3 
GROUP BY `country code`; 
									
UPDATE stag3
SET  `country code` = NULL
WHERE `country code` = '';
   
UPDATE stag3
SET `country code` = IFNULL(`country code`, 'US');

ALTER TABLE stag3
MODIFY COLUMN country VARCHAR(20),
MODIFY COLUMN `country code` VARCHAR(20);                                    
                                    
									-- Column 12 
                                    
SELECT instant_bookable FROM stag3;                                    
                             
SELECT instant_bookable, COUNT(instant_bookable) FROM stag3
GROUP BY 1;

UPDATE stag3
SET instant_bookable = 'TRUE'
WHERE instant_bookable = '1';

UPDATE stag3 
SET instant_bookable = 'FALSE'
WHERE instant_bookable ='0';
 
UPDATE stag3 
SET instant_bookable = NULL
WHERE instant_bookable = '';
 
ALTER TABLE stag3
MODIFY COLUMN instant_bookable VARCHAR(10);					                              

SELECT * FROM stag3;          
                                        
DROP TABLE stag4;

CREATE TABLE stag4 AS
			SELECT * ,
						LAG(instant_bookable,1,FALSE) OVER () AS lag_ib
			FROM stag3;           

UPDATE stag4
SET instant_bookable = COALESCE(instant_bookable, lag_ib);

SELECT DISTINCT instant_bookable FROM stag4;

SELECT COUNT(instant_bookable) FROM stag4 WHERE instant_bookable  NULL ; 

DELETE FROM stag4 WHERE instant_bookable IS NULL ; 

											-- Column 13 
                                    
SELECT DISTINCT cancellation_policy FROM stag4;                                    
                             
SELECT cancellation_policy, COUNT(cancellation_policy) FROM stag4
GROUP BY 1;

SELECT instant_bookable, cancellation_policy, COUNT(cancellation_policy) FROM stag4
GROUP BY 1,2
ORDER BY 2;

UPDATE stag4
SET cancellation_policy = 'strict'
WHERE cancellation_policy = '' AND instant_bookable = 'FALSE' ;


SELECT instant_bookable, cancellation_policy, COUNT(cancellation_policy) FROM stag4
WHERE instant_bookable = 'TRUE'
GROUP BY 1,2
ORDER BY 2;

UPDATE stag4
SET cancellation_policy = 'flexible'
WHERE cancellation_policy = '' AND instant_bookable = 'TRUE' ;

UPDATE stag4
SET cancellation_policy = TRIM(cancellation_policy);

ALTER TABLE stag4
MODIFY COLUMN  cancellation_policy VARCHAR(20);

								-- Column 14 
                                    
SELECT DISTINCT `room type` FROM stag4;                                    
                             
SELECT `room type`, COUNT(`room type`) FROM stag4
GROUP BY 1;

UPDATE stag4
SET `room type` = TRIM(`room type`);

ALTER TABLE stag4
MODIFY COLUMN  `room type` VARCHAR(20);


									-- Column 15 
                                    
SELECT  *,`Construction year` FROM stag4;                                    
                             
SELECT `Construction year`, COUNT(`Construction year`) FROM stag4
GROUP BY 1;

CREATE TABLE stag5 AS
			SELECT * ,
						LAG( `Construction year`,1,2020) OVER () AS lag_cy
			FROM stag4;           

UPDATE stag5
SET `Construction year` = NULL
WHERE `Construction year` = '';


UPDATE stag5
SET `Construction year` = COALESCE(`Construction year`,lag_cy);


											-- Column 16

SELECT price_in_dollar FROM stag5;                                            

ALTER TABLE stag5
CHANGE COLUMN price price_in_dollar TEXT;

SELECT price_in_dollar , SUBSTR(price_in_dollar,2),REPLACE(price_in_dollar,',','') FROM stag5 LIMIT 113;

UPDATE stag5
SET price_in_dollar = SUBSTR(price_in_dollar,2);

UPDATE stag5
SET price_in_dollar = TRIM(REPLACE(price_in_dollar,',',''));

UPDATE stag5
SET price_in_dollar = null
WHERE price_in_dollar = '' ;

ALTER TABLE stag5
MODIFY COLUMN price_in_dollar INT;

SELECT * FROM stag5;

SELECT COUNT(*) FROM stag5 
WHERE price_in_dollar IS NULL;

									-- Column 17

SELECT `service fee` FROM stag5;                                            

ALTER TABLE stag5
CHANGE COLUMN  `service fee` `service fee in $` TEXT;

SELECT `service fee in $` , SUBSTR(`service fee in $`,2),REPLACE(`service fee in $`,',','') FROM stag5;

UPDATE stag5
SET `service fee in $` = SUBSTR(`service fee in $`,2);

UPDATE stag5
SET `service fee in $` = TRIM(REPLACE(`service fee in $`,',',''));

UPDATE stag5
SET `service fee in $` = null
WHERE `service fee in $` = '' ;

ALTER TABLE stag5
MODIFY COLUMN `service fee in $` INT;

SELECT * FROM stag5;

SELECT COUNT(*) FROM stag5 
WHERE `service fee in $` IS NULL;


									-- Column 18
SELECT COUNT(`minimum nights`) FROM stag5;                                    
                                    
SELECT * FROM stag5
WHERE `minimum nights` IS NULL;

									-- Column 19
SELECT COUNT(`number of reviews`) FROM stag5;

SELECT * FROM stag5
WHERE `number of reviews` IS NULL;

									-- Column 20
SELECT DISTINCT (`last review`) FROM stag5;      

ALTER TABLE stag5
MODIFY COLUMN  `last review` VARCHAR(13);
 
UPDATE stag5
SET  `last review` = TRIM(REPLACE(`last review`,'/','-'));

UPDATE stag5
SET `last review` = null
WHERE `last review` = '';

SELECT (`last review`) ,COALESCE(STR_TO_DATE(`last review`, '%m-%d-%Y')) FROM stag5;  

UPDATE stag5
SET `last review` = COALESCE(STR_TO_DATE(`last review`, '%m-%d-%Y'));


ALTER TABLE stag5
MODIFY COLUMN  `last review` DATE;

SELECT * FROM stag5 
WHERE `last review` > curdate();

DELETE FROM stag5 
WHERE `last review` > curdate();

SELECT YEAR(`last review`),COUNT(YEAR(`last review`)) FROM stag5
GROUP BY YEAR(`last review`)
ORDER BY 1;

SELECT COUNT(*) FROM stag5 
WHERE `last review` IS NULL ;

SELECT * FROM stag5; 

									-- Column 21

SELECT `reviews per month` FROM stag5;                                    

ALTER TABLE stag5
MODIFY COLUMN `reviews per month` VARCHAR(8);

UPDATE stag5
SET `reviews per month` = NULL
WHERE `reviews per month` ='';

UPDATE stag5
SET `reviews per month` = TRIM(`reviews per month`);

ALTER TABLE stag5
MODIFY COLUMN `reviews per month` DECIMAL(5,2);

									-- Column 22
SELECT DISTINCT `review rate number` FROM stag5;
   
UPDATE stag5
SET `review rate number` = NULL
WHERE `review rate number`  ='';
					
									-- Column 23
SELECT DISTINCT `calculated host listings count` FROM stag5;

UPDATE stag5
SET `calculated host listings count` = NULL
WHERE `calculated host listings count`  ='';

									-- Column 24
SELECT DISTINCT `availability 365` FROM stag5;

UPDATE stag5
SET `availability 365` = NULL
WHERE `availability 365`  ='';

									-- Column 25
SELECT DISTINCT `house_rules` FROM stag5;

ALTER TABLE stag5
DROP  house_rules ;

UPDATE stag5
SET `availability 365` = NULL
WHERE `availability 365`  ='';
   
									--  Column 26;
SELECT license FROM stag5;                                    

ALTER TABLE stag5
DROP license;


		-- deleting window fnc column 

ALTER TABLE stag5
DROP rn ,
DROP lag_hiv,
DROP lag_ng,
DROP lag_ib,
DROP lag_cy ;      

ALTER TABLE stag5
DROP `NAME` ;
