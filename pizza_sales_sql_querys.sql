create database pizaa;
use pizaa;

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);
--  Retrieve the total number of orders placed.
select count(*) from orders;

-- Rename table pizzaas to pizza 
rename table pizaas to pizza;

-- Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity*pizza.price),2) from order_details join pizza on order_details.pizza_id=pizza.pizza_id; 

-- Identify the highest-priced pizza. 
select pizza_types.name,pizza.price
from pizza_types join pizza 
on pizza_types.pizza_type_id=pizza.pizza_type_id 
order by price desc limit 1;

-- Identify the most common pizza size ordered.
select  x.size,count(y.order_details_id) as Most_order_pizza_size 
from pizza as x join order_details as y on x.pizza_id=y.pizza_id group by x.size order by count(y.order_details_id) desc limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,
sum(order_details.quantity) from pizza_types join pizza
 on pizza_types.pizza_type_id=pizza.pizza_type_id 
 join order_details on order_details.pizza_id=pizza.pizza_id 
 group by pizza_types.name order by sum(order_details.quantity) desc limit 5;
 
 
 
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,
sum(order_details.quantity) from pizza_types join pizza
 on pizza_types.pizza_type_id=pizza.pizza_type_id 
 join order_details on order_details.pizza_id=pizza.pizza_id 
 group by pizza_types.category order by sum(order_details.quantity) desc;
 
 
 -- Determine the distribution of orders by hour of the day. 
 select hour(order_time),count(order_id) from orders group by hour(order_time) order by count(order_id) desc;
 
 -- Join relevant tables to find the category-wise distribution of pizzas.
 select category,count(name) from pizza_types group by category; 
 
 -- Group the orders by date and calculate the average number of pizzas ordered per day.
 
 select round(avg(quantity),2) from
 (select orders.order_date,sum(order_details.quantity) as quantity from orders 
 join order_details on orders.order_id=order_details.order_id group by orders.order_date) as avrage;
 
 -- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,
sum(order_details.quantity*pizza.price) as revenue 
from pizza_types join pizza on pizza.pizza_type_id=pizza_types.pizza_type_id
join order_details 
on order_details.pizza_id=pizza.pizza_id group by pizza_types.name order by revenue desc limit 3;

 -- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    round((SUM(order_details.quantity * pizza.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizza.price),
                        2)
        FROM
            order_details
                JOIN
            pizza ON order_details.pizza_id = pizza.pizza_id)) * 100,2) AS revenue
FROM
    pizza_types
        JOIN
    pizza ON pizza.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizza.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;
 
 -- Analyze the cumulative revenue generated over time.
 select order_date,
 sum(revenue) over (order by order_date) as cum_revenue from
(select orders.order_date,sum(order_details.quantity * pizza.price) as revenue 
from order_details join pizza on order_details.pizza_id=pizza.pizza_id 
join orders 
on orders.order_id = order_details.order_id 
group by  orders.order_date) as sales;
 
 
 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
 select category,name,revenue from
 (select category,name,revenue,rank() over(partition by category order by revenue desc) as rn from 
 (select pizza_types.category,pizza_types.name,
 sum(order_details.quantity * pizza.price) as revenue 
 from pizza_types join pizza 
 on  pizza_types.pizza_type_id=pizza.pizza_type_id 
 join order_details 
 on order_details.pizza_id=pizza.pizza_id
 group by pizza_types.category,pizza_types.name) as a) as b where rn >3;
 
 
 
 