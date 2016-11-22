DROP TABLE carts;
DROP TABLE orders;
DROP TABLE users;
DROP TABLE books;


CREATE TABLE books (
    book_id     SERIAL PRIMARY KEY,
    title       TEXT NOT NULL,
    author      TEXT NOT NULL,
    ISBN        TEXT NOT NULL,
    year        INTEGER NOT NULL
);

CREATE INDEX idx_title_search ON books(title);
CREATE INDEX idx_author_search ON books(author);

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
    user_id     INTEGER NOT NULL REFERENCES users,
    book_id     INTEGER NOT NULL REFERENCES books,
    quantity    INTEGER NOT NULL
);

INSERT INTO books (book_id, title, author, ISBN, year) 
VALUES (1, 'A Game of Thrones', 'George R. R. Martin', '978-0553593716', 2003),
       (2, 'A Clash of Kings', 'George R. R. Martin', '978-0553593716', 2003),
       (3, 'A Storm of Swords', 'George R. R. Martin', '034554398X', 2003),
       (4, 'Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', '0439708184', 1999),
       (5, 'A Dance with Dragons', 'George R. R. Martin', '0553582011', 2013);

INSERT INTO users (user_id, first_name, last_name) 
VALUES (1, 'Robert', 'Dickerson');

INSERT INTO orders (order_id, user_id, book_id, quantity) 
VALUES (1, 1, 1, 1);

INSERT INTO carts (user_id, book_id, quantity) 
VALUES (1, 4, 2);