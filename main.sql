 -- Creating a book managment system that stores:
 -- Books (title, author, genre, publication info, ratings, stock)
 -- Authors (name, nationality, birth date)
 -- Customers (borrowing / buying books)
 -- Transactions (sales or loans)

 -- Creating the authors table 
 create table authors (
    author_id int primary key identity(1,1),
    name varchar(100) not null,
    nationality varchar(50),
    birth_date date
 );

 -- Creating the genres table
 create table genres (
    genre_id int primary key identity(1,1),
    genre_name varchar(50) not null unique
 );

 -- Creating the books table
 create table books(
    book_id int primary key identity(1,1),
    title varchar(200) not null,
    genre_id int,
    publication_year int check (publication_year > 0),
    price decimal(6,2)
    stock int default 0,
    CONSTRAINT fk_genre FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
 );

 -- creating the book_authors table 
 -- Many to many relationship for co-authored books
 create table book_authors (
    book_id int,
    author_id int,
    primary key (book_id, author_id),
    FOREIGN key (book_id) references books(book_id),
    FOREIGN key (author_id) references authors(author_id)
 );

-- creating the customer table
create table customers(
    customer_id int primary key identity(1,1),
    name varchar(100) not null, 
    email varchar(100) unique,
    join_date date default getdate()
);

-- Creating the transactions table
create table transactions(
    transaction_id int primary key identity(1,1),
    customer_id int,
    book_id int,
    transaction_date date default getdate(),
    quantity int check (quantity > 0),
    FOREIGN key (customer_id) references customers(customer_id),
    FOREIGN key (book_id) references books(book_id)
);

-- Creating a view for best_selling_books
create view best_selling_books as 
select b.title, sum(t.quantity) as total_sold
from transactions t 
join books b on t.book_id = b.book_id
group by b.title
order by total_sold desc;

-- Creating a stored procedure to get books by genre
create procedure getBooksByGenre @genreName varchar(50)
as
begin
select b.title, a.name, as author
from books b
join genres g on b.genre_id = g.genre_id
join book_authors ba on b.book_id = ba.book_id
join authors a on ba.author_id = a.author_id
where g.genre_name = @genreName;
end;

-- Creating a trigger where a books' stock can go down when it is purchased
create trigger reduce_stock 
on transactions
after insert
as 
begin
update books
set stock = stock - inserted.quantity
from books
join inserted on books.book_id - inserted.book_id;
end;

-- Creating a window function 
select
b.title, 
sum(t.quantity) as total_sold,
rank() over (order by sum(t,quantity)desc) as sales_rank
from transactions t
join books b on t.book_id = b.book_id
group by b.title;


-- inserting sample data into the database
INSERT INTO genres (genre_name) VALUES ('Fantasy'), ('Science Fiction'), ('Mystery');
INSERT INTO authors (name, nationality, birth_date) VALUES 
('J.K. Rowling', 'British', '1965-07-31'),
('Isaac Asimov', 'American', '1920-01-02');

INSERT INTO books (title, genre_id, publication_year, price, stock) VALUES
('Harry Potter', 1, 1997, 19.99, 10),
('Foundation', 2, 1951, 14.99, 8);

INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),
(2, 2);

-- running queries on our data

-- Finding all books with their authors and genres
select b.title, a.name as author, g.genre_name
from books b
join book_authors ba on b.book_id = ba.book_id
join authors a on ba.author_id = a.author_id
join genres g on b.genre_id = g.genre_id;

-- finding the top 5 selling books
select top 5 b.title, sum(t.quantity) as total_sold
from transactions t
join books b on t.book_id = b.book_id
group by b.title
order by total_sold desc;

-- finding the customers who bought more than 3 books in a month
SELECT c.name, COUNT(t.transaction_id) AS total_purchases
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
WHERE MONTH(t.transaction_date) = 8
GROUP BY c.name
HAVING COUNT(t.transaction_id) > 3;






