CREATE database  pizzahut;
use pizzahut;
show tables;
select* from pizzahut.pizza_types;
-- que 1. Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;

-- que 2. Calculate the total revenue generated from pizza sales.
SELECT 
    round(sum(order_details.quantity * pizzas.price),2)as total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- que 3. Identify the highest-priced pizza.
select
	pizza_types.name,
    pizzas.price
from 
	pizzas
 join
	pizza_types on  pizzas.pizza_type_id=pizza_types.pizza_type_id
 order by
	pizzas.price desc
limit 1;

-- que 4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS total_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY total_count DESC;

-- que 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY quantity DESC;

select* from orders;

-- 7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, 
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);


-- 8. Join relevant tables to find the category-wise distribution of pizzas.

select 
	pizza_types.category,
    count(name) as name_count
from 
	pizza_types
group by 
	category
order by name_count desc
;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

select round( avg(quantity) ,1)from (select 
	orders.date,
    sum( order_details.quantity) as quantity
from orders
join
order_details
on 
orders.order_id=order_details.order_id
group by
orders.date) as order_qunatity;


-- 10. Determine the top 3 most ordered pizza types based on revenue.
select 
	pizza_types.category,
    sum(pizzas.price) as price
from 
	pizza_types
join
	pizzas
on 
	pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizza_types.category
order by price desc
limit 3;



-- 11. Calculate the percentage contribution of each pizza type to total revenue.
select 
	pizza_types.category,
    round(sum(pizzas.price * order_details.quantity)/
    
    
	(select	
		round(sum(order_details.quantity * pizzas.price),2) as total_sales
			from order_details 
				join pizzas
					on order_details.pizza_id = pizzas.pizza_id) *100,2) as revenue
from pizza_types
join pizzas
	on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
	on pizzas.pizza_id = order_details.pizza_id
group by category
order by revenue desc
;


-- 12. -- Analyze the cumulative revenue generated over time.
 
select date,
	sum(revenue) over(order by date) as cum_revenue
from 
(select orders.date,
	round(sum(pizzas.price * order_details.quantity),2)
    as revenue
from orders
join  order_details
	on 	order_details.order_id = orders.order_id
join pizzas
	on pizzas.pizza_id = order_details.pizza_id
group by date) as sales;

-- 13. -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;




