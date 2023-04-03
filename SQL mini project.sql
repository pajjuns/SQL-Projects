-- 1.	Import the csv file to a table in the database.
use project;
select * from icc_test_batting;

-- 2.	Remove the column 'Player Profile' from the table.
alter table icc_test_batting drop column `player profile`;
select * from icc_test_batting;

-- 3.	Extract the country name and player names from the given data and store it in separate columns for further usage.
alter table icc_test_batting drop column player_name;
alter table icc_test_batting add column player_name text, add column country_name text;
update icc_test_batting set player_name = substring_index(icc_test_batting.player,'(',1);
update icc_test_batting set country_name = substring_index(icc_test_batting.player,'(',-1);
update icc_test_batting set country_name = replace(country_name,')','');

-- 4.	From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage.
alter table icc_test_batting add column start_year text, add column end_year text;
update icc_test_batting set start_year = substring_index(icc_test_batting.span,'-',1);
update icc_test_batting set end_year = substring_index(icc_test_batting.span,'-',-1);


-- 5.	The column 'HS' has the highest score scored by the player so far in any given match. 
--      The column also has details if the player had completed the match in a NOT OUT status. 
--      Extract the data and store the highest runs and the NOT OUT status in different columns.
alter table icc_test_batting add column not_out text;
alter table icc_test_batting add column highest_score text;
update icc_test_batting set not_out=
case
when HS not like '%*%' then not_out
else HS
end;

update icc_test_batting set highest_score=
case
when HS like '%*%' then highest_score
else HS
end;
-- 6.	Using the data given, considering the players who were active in the year of 2019,
--      create a set of batting order of best 6 players using the selection criteria of those who have a good average score across all matches for India.
select player_name,country_name,avg from icc_test_batting
where end_year=2019 and country_name like '%india%'
order by avg desc
limit 6;
-- 7.	Using the data given, considering the players who were active in the year of 2019, 
--      create a set of batting order of best 6 players using the selection criteria of those who have the highest number of 100s across all matches for India.
select player_name, `100` from icc_test_batting
where end_year=2019 and country_name like '%india%'
order by `100` desc
limit 6;

-- 8.	Using the data given, considering the players who were active in the year of 2019, 
--      create a set of batting order of best 6 players using 2 selection criteria of your own for India.
select player_name from icc_test_batting
where (end_year=2019) and (country_name like '%india%') and (mat>=40)
order by runs desc
limit 6;

-- 9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given, considering the players who were active in the year of 2019, 
--      create a set of batting order of best 6 players using the selection criteria of those who have a good average score across all matches for South Africa.
create view batting_order_goodavgscorers_SA as
select player_name,avg from icc_test_batting
where end_year =2019 and country_name like '%SA%'
order by avg desc
limit 6;

select * from batting_order_goodavgscorers_SA;
-- 10.	Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, considering the players who were active in the year of 2019, 
--      create a set of batting order of best 6 players using the selection criteria of those who have highest number of 100s across all matches for South Africa.

create view batting_order_highestcenturyscorers_SA as
select player_name,`100` from icc_test_batting
where end_year = 2019 and country_name like '%SA%'
order by `100` desc
limit 6;

select * from batting_order_highestcenturyscorers_SA;

-- 11.	Using the data given, Give the number of player_played for each country.
select country_name,count(player_name) number_of_players from icc_test_batting
group by country_name
order by number_of_players desc;

-- 12.	Using the data given, Give the number of player_played for Asian and Non-Asian continent.

select 
case
when country_name like '%india%' then 'Asian continent'
when country_name like '%pak%' then 'Asian continent'
when country_name like '%sl%' then 'Asian continent'
when country_name like '%wi%' then 'Non Asian continent'
when country_name like '%bdesh%' then 'Asian continent'
when country_name like '%afg%' then 'Asian continent'
when country_name like '%sa%' then 'Non Asian continent'
when country_name like '%eng%' then 'Non Asian continent'
when country_name like '%nz%' then 'Non Asian continent'
when country_name like '%aus%' then 'Non Asian continent'
when country_name like '%zim%' then 'Non Asian continent'
when country_name like '%ire%' then 'Non Asian continent'
end Asian_NonAsian,
count(player_name) player_count
from icc_test_batting
group by asian_nonasian;

-- Part – B

-- “Richard’s Supply” is a company which deals with different food products. The company is associated with a pool of suppliers. 
-- Every Supplier supplies different types of food products to Richard’s supply. This company also receives orders for the food products from various customers.
-- Each order may have multiple products mentioned along with the quantity. The company has been maintaining the database for 2 years. 
-- Refer to the following Entity-Relationship diagram of the database. 

-- 1.	Company sells the product at different discounted rates. Refer actual product price in product table and selling price in the order item table. 
-- Write a query to find out total amount saved in each order then display the orders from highest to lowest amount saved. 
use supply_chain;
with cte as(
select orderid,productid,a.unitprice as selling_price,b.unitprice actual_price,quantity 
from orderitem a join product b on a.productid=b.id)
select orderid,sum((actual_price*quantity)-(selling_price*quantity))savings from cte
group by orderid order by savings desc;

-- 2.	Mr. Kavin want to become a supplier. He got the database of "Richard's Supply" for reference. Help him to pick: 
-- a. List few products that he should choose based on demand.
select a.id,productname,orderid,sum(quantity),b.productid from product a join orderitem b
on a.id=b.productid group by a.id order by sum(quantity) desc limit 20;

-- b. Who will be the competitors for him for the products suggested in above questions.
select companyname from supplier s join product a
on s.id = a.id
where productname in
(select productname from
(select a.id,productname,orderid,sum(quantity),b.productid from product a join orderitem b
on a.id=b.productid group by a.id order by sum(quantity) desc limit 20)t);


-- 3.	Create a combined list to display customers and suppliers details considering the following criteria 
create table cust_and_supp
select * from
(
select customerid, concat(firstname,' ',lastname) cust_name, c1.city cust_city, 
c1.country cust_country,  contactname, companyname,  s.city supp_city, s.country supp_country
from customer c1 join orders o on c1.id = o.customerid
join orderitem od on od.orderid = o.id join product p on od.productId = p.id
join supplier s on s.id = p.supplierid) t;

-- ●	Both customer and supplier belong to the same country
select cust_name customer,cust_country, contactname supplier, supp_country
from cust_and_supp where cust_city=supp_city;

-- ●	Customer who does not have supplier in their country
select * from customer
where country not in 
(select country from supplier);

-- ●	Supplier who does not have customer in their country
select * from supplier
where country not in 
(select country from customer);

-- 4.	Every supplier supplies specific products to the customers. Create a view of suppliers and total sales made by their products 
-- and write a query on this view to find out top 2 suppliers (using windows function) in each country by total sales done by the products.
create view supplier__sales as
(select a.id,a.companyname,a.country,sum(c.unitprice*c.quantity) totamt
from supplier a join product b on a.id=b.supplierid
join orderitem c on b.id=c.productid group by companyname);

select * from
(select id,companyname,country,totamt,rank()over(partition by country order by totamt desc) rnk from supplier__sales) t
where rnk in(1,2)
order by rnk;

-- 5.	Find out for which products, UK is dependent on other countries for the supply. List the countries which are supplying these products in the same list.
select productName,country from(
select productname,country from  supplier s join product p on s.Id = p.SupplierId) t1
where productname not in (
select productname from supplier s join product p ON s.id = p.supplierid where country like 'UK');

-- 6.	Create two tables as ‘customer’ and ‘customer_backup’ as follow - 
#‘customer’ table attributes -
#Id, FirstName,LastName,Phone
#‘customer_backup’ table attributes - 
#Id, FirstName,LastName,Phone

create table customer 
(id int,
Firstname varchar(20),
Lastname varchar(20),
phone varchar(20));

insert into customer values
(101,'Ram','Kumar',9362769282),
(102,'Ravi','Teja',9209339282),
(103,'Thara','sri',8366834722),
(104,'Danush','Karthi',8733790322),
(105,'Sasi','Kumar',7282386332);


create table customer_backup
(id int,
Firstname varchar(20),
Lastname varchar(20),
phone varchar(20));
-- Create a trigger in such a way that It should insert the details into the  ‘customer_backup’ table when you delete the record from the ‘customer’ table automatically.
create trigger backup_file
after delete 
on customer
for each row
insert into customer_backup values (old.id, old.firstname, old.lastname, old.phone);

delete from customer where id=102;

select * from customer;
select * from customer_backup;


