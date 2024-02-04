-- выгружаем число клиентов
SELECT
  count(1) customers_count
FROM
  customers c 


-- top_10_total_income
SELECT
	concat(first_name , ' ', last_name) as name,
	count(s.sales_id) as operations,
	COALESCE(FLOOR(sum(s.quantity * p.price)),0) income 
FROM
	employees e 
	left join sales s on e.employee_id  = s.sales_person_id 
	left join products p on p.product_id = s.product_id 
group by 
	concat(first_name , ' ', last_name)
order by
	income desc
limit 10


-- lowest_average_income
SELECT
	concat(first_name , ' ', last_name) as name,
	COALESCE(round(avg(s.quantity * p.price),0),0) average_income
FROM
	employees e 
	left join sales s on e.employee_id  = s.sales_person_id 
	left join products p on p.product_id = s.product_id 
group by 
	concat(first_name , ' ', last_name)
having 
	avg(s.quantity * p.price) < (
		select 
			avg(s.quantity * p.price)
		from 
			sales s
			left join products p on p.product_id = s.product_id 
	)	
order by
	average_income


-- day_of_the_week_income
select 
	concat(first_name , ' ', last_name) as name,
	to_char(sale_date, 'day') as weekday,
	COALESCE(round(sum(s.quantity * p.price)),0) income
FROM
	sales s 
	left join employees e on e.employee_id  = s.sales_person_id 
	left join products p on p.product_id = s.product_id 
group by 
	concat(first_name , ' ', last_name),
	to_char(sale_date, 'day'),
	extract(isodow from sale_date)
order by
	extract(isodow from sale_date),
	concat(first_name , ' ', last_name)


-- age_groups
select 
	case 
		when age >= 16 and age <= 25 then '16-25'
		when age >= 26 and age <= 40 then '26-40'
		when age > 40 then '40+'
		else 'other'
	end age_category,
	count(1) as count
from 
	customers c 
group by 
	age_category
order by
	age_category


-- customers_by_month
select 
	to_char(sale_date, 'yyyy-mm') as date,
	count(distinct customer_id) as total_customers,
	FLOOR(sum(s.quantity * p.price)) income
from 
	sales s 
	left join products p on p.product_id = s.product_id
group by
	date
order by
	date


-- special_offer
with 
sales_with_dr as (
	select 
		*,
		dense_rank () over (partition by customer_id order by sale_date) dr
	from
		sales s 
	order by 
		sale_date 
)

select 
	concat(c.first_name , ' ', c.last_name) as customer,
	s.sale_date ,
	concat(e.first_name , ' ', e.last_name) as seller
from 
	sales_with_dr s 
	left join products p on s.product_id = p.product_id 
	left join customers c on s.customer_id = c.customer_id 
	left join employees e on s.sales_person_id = e.employee_id 
where
	s.dr = 1
group by
	customer,
	c.customer_id,
	s.sale_date ,
	seller
having
	min(p.price) = 0
order by 
	c.customer_id
