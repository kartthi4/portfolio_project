use portfolio ;
select * from Request_Data  ;

ALTER TABLE Request_Data 
CHANGE `Request timestamp - Day` Requested_day varchar(20) ;
ALTER TABLE Request_Data 
CHANGE  `Pickup point` Pickup_Place varchar(20) ;

-- 1. what is the total ride request, total completed trip , total cancellation , total unavailability of cars  ? -- 
select count(*) from Request_Data  ;

select count(*) as Total_req,
sum( case when status = 'Trip completed' then 1 else 0 end ) as completed_trip , 
sum(case when status = 'Cancelled'  then 1 else 0 end ) as  ride_cancelled , 
sum(case when status = 'No Cars Available' then 1 else 0 end ) as cars_unavailable , 
round(sum(case when status = 'Trip completed' then 1 else 0 end )  * 100 / count(*), 2) as ride_fullfilled_percenatge , 
round(sum(case when status in ('Cancelled', 'No Cars Available') then 1 else 0 end) * 100 /  count(*) ,2) as ride_unfullfilled_percenatge
from Request_Data 
 ; --  KPI summary-- 
 
-- 2. what is the weekday ride request and performance ? 

select Requested_day, count(*) as total_request , 
sum( case when status = 'Trip completed' then 1 else 0 end ) as completed_trip , 
sum(case when status = 'Cancelled'  then 1 else 0 end ) as  ride_cancelled , 
sum(case when status = 'No Cars Available' then 1 else 0 end ) as cars_unavailable , 
round(sum(case when status = 'Trip completed' then 1 else 0 end )  * 100 / count(*), 2) as ride_fullfilled_percenatge , 
round(sum(case when status in ('Cancelled', 'No Cars Available') then 1 else 0 end) * 100 /  count(*) ,2) as ride_unfullfilled_percenatge
from Request_Data 
group by  Requested_day
order by  Requested_day asc  ;

-- 3.what is city vs. Airport ride request performance ?  -- 

select Pickup_Place , count(*) as no_of_req,
sum( case when status = 'Trip completed' then 1 else 0 end ) as completed_trip , 
sum(case when status = 'Cancelled'  then 1 else 0 end ) as  ride_cancelled , 
sum(case when status = 'No Cars Available' then 1 else 0 end ) as cars_unavailable 
from Request_Data 
group by  Pickup_Place 
order by count(*) desc ;


-- 4.what is the request demand by hour -- 

select hour(`Request timestamp`) as time_of_request, count(*) as ride_request
from Request_Data 
group by hour(`Request timestamp`) 
order by  hour(`Request timestamp`) asc ; 

-- when does the unsuccessful ride usually happens -- 

select hour(`Request timestamp`) as time_of_request, count(*) as ride_request, Pickup_Place
from Request_Data 
where status in ('No Cars Available' , 'Cancelled')
group by hour(`Request timestamp`) , Pickup_Place
order by count(*) desc ; 

--  relationship between ride performance and place and time --

select  hour(`Request timestamp`) as time_of_request,  Pickup_Place, count(*) as total_request ,
    SUM(CASE WHEN Status = 'Trip Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN Status = 'No Cars Available' THEN 1 ELSE 0 END) AS no_cars_available
from Request_Data 
group by hour(`Request timestamp`)  , Pickup_Place
order by hour(`Request timestamp`) , Pickup_Place ;


--  relation bwetween weekday and pickuplocation --
select Requested_day, count(*) as no_of_req , 
sum(case when Pickup_Place = 'Airport' then 1 else 0 end ) as pickuppoint_airport , 
sum(case when Pickup_Place = 'City' then 1 else 0   end ) as pickuppoint_city
from Request_Data 
group by  Requested_day
order by count(*) desc ;      -- 3238 AP , 3507 CITY
 
-- Any patterns involved between days and location and demand -- 

select  Requested_day,  hour(`Request timestamp`) as time_of_request, count(*) as total_request ,
sum(case when Pickup_Place = 'Airport' then 1 else 0 end ) as req_from_airport , 
sum(case when Pickup_Place = 'City' then 1 else 0   end ) as req_from_city 
from Request_Data 
group by   Requested_day ,hour(`Request timestamp`)  
order by hour(`Request timestamp`) ;


-- This is the Additional analysis on driver count, however the dataset doesnt specify if these are total driver population or the one who were available on shift. 
-- Driver availability per hour -- 

select   count(distinct `Driver id`) as total_drivers 
from Request_Data ;

select hour(`Request timestamp`) as time_of_request, 
count(distinct `Driver id`) as total_drivers , count(*) as total_request 
from Request_Data 
group by hour(`Request timestamp`) 
order by hour(`Request timestamp`) asc ;

-- This is the indivual drivers cancellation, however the cancellation ddidnt record who intiated the cancel, and why or which specific location for further analysis -- 
-- which driver has more no of cancelllation ? -- 

select `Driver id` , count(`Driver id`)
from Request_Data 
where status = 'Cancelled'
group by `Driver id`
order by count(`Driver id`) desc ;



