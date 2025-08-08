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

 

