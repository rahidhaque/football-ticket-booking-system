-- =========================================================================
-- SYSTEM: Football Ticket Booking System Database Setup Template
-- DESCRIPTION: Pseudo-DDL Template for Table Creation & Data Insertion
-- INSTRUCTIONS: Replace 'TYPE' and the constraint placeholders with your own
--               actual data types, relational keys, and check criteria.
-- =========================================================================
-- DROP TABLES IF THEY ALREADY EXIST TO PREVENT CONFLICTS
DROP TABLE IF EXISTS Bookings;

DROP TABLE IF EXISTS Matches;

DROP TABLE IF EXISTS Users;

-- =========================================================================
-- 1. CREATE USERS TABLE
-- =========================================================================
CREATE TABLE Users (
  user_id serial PRIMARY KEY,
  full_name varchar(100),
  email varchar(100) NOT NULL UNIQUE,
  role varchar(20) NOT NULL check (role in ('Ticket Manager', 'Football Fan')),
  phone_number varchar(20)
  -- Write your constraint to make 'user_id' the Primary Key
  -- Write your constraint to ensure 'email' values are never duplicated
  -- Write your check constraint to restrict 'role' to specific allowed strings
);

-- =========================================================================
-- 2. CREATE MATCHES TABLE
-- =========================================================================
CREATE TABLE Matches (
  match_id serial primary key,
  fixture varchar(200),
  tournament_category varchar(100),
  base_ticket_price int check (base_ticket_price > 0),
  match_status varchar(30) check (
    match_status in (
      'Available',
      'Selling Fast',
      'Sold Out',
      'Postponed'
    )
  )
  -- Write your constraint to make 'match_id' the Primary Key
  -- Write your check constraint to prevent negative ticket prices
  -- Write your check constraint to restrict 'match_status' values
);

-- =========================================================================
-- 3. CREATE BOOKINGS TABLE
-- =========================================================================
CREATE TABLE Bookings (
  booking_id serial primary key,
  user_id integer references users (user_id),
  match_id integer references matches (match_id),
  seat_number varchar(20),
  payment_status varchar(30) default 'Pending' check (
    payment_status in ('Pending', 'Confirmed', 'Cancelled', 'Refunded')
  ),
  total_cost int check (total_cost >= 0)
  -- Write your constraint to make 'booking_id' the Primary Key
  -- Write your Foreign Key constraint linking 'user_id' to the Users table
  -- Write your Foreign Key constraint linking 'match_id' to the Matches table
  -- Write your check constraint to ensure 'total_cost' is non-negative
  -- Write your check constraint to restrict 'payment_status' values
);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================
INSERT INTO
  Users (user_id, full_name, email, role, phone_number)
VALUES
  (
    1,
    'Tanvir Rahman',
    'tanvir@mail.com',
    'Football Fan',
    '+8801711111111'
  ),
  (
    2,
    'Asif Haque',
    'asif@mail.com',
    'Football Fan',
    '+8801722222222'
  ),
  (
    3,
    'Sajjad Rahman',
    'sajjad@mail.com',
    'Ticket Manager',
    '+8801733333333'
  ),
  (
    4,
    'Jannat Ara',
    'jannat@mail.com',
    'Football Fan',
    NULL
  );

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================
INSERT INTO
  Matches (
    match_id,
    fixture,
    tournament_category,
    base_ticket_price,
    match_status
  )
VALUES
  (
    101,
    'Real Madrid vs Barcelona',
    'Champions League',
    150.00,
    'Available'
  ),
  (
    102,
    'Man City vs Liverpool',
    'Premier League',
    120.00,
    'Selling Fast'
  ),
  (
    103,
    'Bayern Munich vs PSG',
    'Champions League',
    130.00,
    'Available'
  ),
  (
    104,
    'AC Milan vs Inter Milan',
    'Serie A',
    90.00,
    'Sold Out'
  ),
  (
    105,
    'Juventus vs Roma',
    'Serie A',
    80.00,
    'Available'
  );

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================
INSERT INTO
  Bookings (
    booking_id,
    user_id,
    match_id,
    seat_number,
    payment_status,
    total_cost
  )
VALUES
  (501, 1, 101, 'A-12', 'Confirmed', 150.00),
  (502, 1, 102, 'B-04', 'Confirmed', 120.00),
  (503, 2, 101, 'A-13', 'Confirmed', 150.00),
  (504, 2, 101, NULL, NULL, 150.00),
  (505, 3, 102, 'C-20', 'Pending', 120.00);

-- ==========================================================================================================================
-- Query 1: Retrieve all upcoming football matches belonging to the 'Champions League' where the match status is 'Available'.
-- ==========================================================================================================================
select
  match_id,
  fixture,
  base_ticket_price
from
  matches
where
  tournament_category = 'Champions League'
  and match_status = 'Available';

-- ====================================================================================================================
-- Query 2: Search for all users whose full names start with 'Tanvir' or contain the phrase 'Haque' (case-insensitive).
-- ====================================================================================================================
select
  user_id,
  full_name,
  email
from
  users
where
  full_name ilike 'Tanvir%'
  OR full_name ilike '%Haque%'
  -- ====================================================================================================================================
  -- Query 3: Retrieve all booking records where the payment status is missing (NULL), replacing the empty result with 'Action Required'.
  -- ====================================================================================================================================
select
  booking_id,
  user_id,
  match_id,
  coalesce(payment_status, 'Action Required') as systematic_status
from
  bookings
where
  payment_status is NULL;

-- ===============================================================================================================
-- Query 4: Retrieve match booking details along with the User's full name and the scheduled Match fixture teams.
-- ===============================================================================================================
select
  b.booking_id,
  u.full_name,
  m.fixture,
  b.total_cost
from
  bookings b
  inner join users u on b.user_id = u.user_id
  inner join matches m on b.match_id = m.match_id;

-- ==============================================================================================================================================
-- Query 5: Display a comprehensive list of all users and their booking IDs, ensuring that fans who have never bought a ticket are still listed.
-- ==============================================================================================================================================
select
  u.user_id,
  u.full_name,
  b.booking_id
from
  users u
  left join bookings b on u.user_id = b.user_id
order by
  u.user_id;

-- =======================================================================================================================
-- Query 6: Find all ticket bookings where the total cost is strictly higher than the average cost of all ticket bookings.
-- =======================================================================================================================
select
  booking_id,
  match_id,
  total_cost
from
  bookings
where
  total_cost > (
    select
      avg(total_cost)
    from
      bookings
  );

-- ============================================================================================================================
-- Query 7: Retrieve the top 2 most expensive matches sorted by base ticket price, skipping the absolute highest premium match.
-- ============================================================================================================================
select
  match_id,
  fixture,
  base_ticket_price
from
  matches
order by
  base_ticket_price desc
limit
  2
offset
  1;