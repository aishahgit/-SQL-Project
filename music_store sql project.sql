Music_store database
Easy level
-- Q1: Who is the senior most employee based on the job title?

select * from employee
ORDER BY levels desc
limit 1

-- Q2: Which countries have most invoices?

select * from invoice

select COUNT(*) AS c , billing_country
from invoice
group by billing_country
order by c desc

-- Q3.What are the top 3 values of total invoice?

select total from invoice
order by total desc
limit 3

-- Q4.Which city has the best customer. We would like to through a promotional music  festival in the
-- city we made the most money. Write a query that returns one city that has the highest sum of 
-- invoice totals. Return both the city name and sum of all invoice total.

select * from invoice

select sum(total) AS total_invoice,billing_city 
from invoice
group by billing_city
order by total_invoice desc

-- Q5.Who is the best customer? The customer who has spend the most money will be declared the best customer
-- write a query that returns a person who has spent the most money.

select * from customer


SELECT c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESc
LIMIT 1;

Moderate level

-- Q1: Write a query to return emai, first name, last name, & genre of all rock musiclisteners. 
-- 	Return your list order alphabatically by email starting with A?

SELECT DISTINCT email,first_name,last_name
from customer 
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
	select track_id from track
	JOIN genre ON track.genre_id = genre.genre_id
	where genre.name LIKE 'Rock'
)
order by email;
second way:
SELECT DISTINCT email,first_name,last_name
from customer 
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
where genre.name LIKE 'Rock'
order by email;


-- Q2: lets invite the artist who have written the most rock music in our dataset
-- write a query that returns the artist name and total track count of the top 10 rock bands.

-- select * from track
-- select * from album
-- select * from genre
-- select * from artist

select artist.artist_id,artist.name,count(track.track_id) AS number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

-- Q3:Return the track name that have a song length longer than the average song 
-- length.

static:
select AVG(milliseconds) from track
select name,milliseconds from track where milliseconds > 393599.212103910933 order by milliseconds desc

dynamic:
select name,milliseconds
from track
where milliseconds> (
	select avg(milliseconds) AS average_track_length
	from track)
order by milliseconds desc;

Hard level

-- Q1: Find how much money spent by each customer on artist? write a query to return customer name, artist name,
-- and total spent.

WITH best_selling_artist AS(
	select artist.artist_id AS artist_id, artist.name AS artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id =track.album_id
	join artist on artist.artist_id = album.artist_id 
	group by 1 
	order by 3 desc
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;


-- Q2:We want to find out the most popular music genre to each country 
-- we determine the most popular genre as the genre with the highest amount of purchases.
-- write a query that returns each country along with the top genre. for countries where the 
-- maximum number of purchases is shared return all genres.
	
WITH popular_genre AS
(
	select count(invoice_line.quantity) AS purchases, customer.country,
	genre.name, genre.genre_id, ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track  on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <=1
