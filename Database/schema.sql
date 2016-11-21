DROP TABLE carts;
DROP TABLE orders;
DROP TABLE users;
DROP TABLE books_authors;
DROP TABLE books;
DROP TABLE authors;


CREATE TABLE books (
    book_id     SERIAL PRIMARY KEY,
    title       TEXT NOT NULL,
    ISBN        TEXT NOT NULL,
    year        INTEGER NOT NULL
);

CREATE INDEX idx_title_search ON books(title);

CREATE TABLE authors (
    author_id   SERIAL PRIMARY KEY,
    name        TEXT NOT NULL 
);

CREATE TABLE books_authors (
    book_id     INTEGER NOT NULL REFERENCES books,
    author_id   INTEGER NOT NULL REFERENCES authors 
);

CREATE TABLE users (
    user_id     SERIAL PRIMARY KEY, 
    first_name  TEXT NOT NULL,
    last_name   TEXT NOT NULL
);

CREATE TABLE carts (
    user_id     INTEGER NOT NULL REFERENCES users,
    book_id     INTEGER NOT NULL REFERENCES books,
    quantity    INTEGER NOT NULL
);

CREATE TABLE orders (
    order_id    SERIAL PRIMARY KEY,
    user_id     INTEGER REFERENCES users,
    book_id     INTEGER REFERENCES books,
    quantity    INTEGER NOT NULL
);

INSERT INTO books (book_id, title, ISBN, year) 
VALUES (1, 'A Game of Thrones', '978-0553593716', 2003),
       (2, 'A Clash of Kings', '978-0553593716', 2003),
       (3, 'A Storm of Swords', '034554398X', 2003),
       (4, 'Harry Potter and the Sorcerer''s Stone', '0439708184', 1999),
       (5, 'A Dance with Dragons', '0553582011', 2013);


INSERT INTO authors (author_id, name) 
VALUES (1, 'George R. R. Martin'),
       (2, 'J.K. Rowling');


INSERT INTO books_authors (book_id, author_id) 
VALUES (1, 1),
       (2, 1),
       (3, 1),
       (4, 2),
       (5, 1);

INSERT INTO users (user_id, first_name, last_name) 
VALUES (1, 'Robert', 'Dickerson');

INSERT INTO orders (order_id, user_id, book_id, quantity) 
VALUES (1, 1, 1, 1);

INSERT INTO carts (user_id, book_id, quantity) 
VALUES (1, 4, 2);