-- выгружаем число клиентов
SELECT
  count(1) customers_count
FROM
  customers c 


-- top_10_total_income
SELECT
	concat(first_name , ' ', last_name) as name,
	count(s.sales_id) as operations,
	COALESCE(sum(s.quantity * p.price),0) income 
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
	COALESCE(sum(s.quantity * p.price),0) income
FROM
	employees e 
	left join sales s on e.employee_id  = s.sales_person_id 
	left join products p on p.product_id = s.product_id 
group by 
	concat(first_name , ' ', last_name),
	to_char(sale_date, 'day'),
	extract(isodow from sale_date)
order by
	extract(isodow from sale_date),
	concat(first_name , ' ', last_name)
