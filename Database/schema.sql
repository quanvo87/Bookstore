CREATE TABLE book {
    id: INT,
    title: VARCHAR(1024),
    ISBN: VARCHAR(128),
    year: INT
};

CREATE TABLE author {
    id: INT,
    name: VARCHAR(512)
};

CREATE TABLE book_author {
    book_id: INT,
    author_id: INT
}


INSERT INTO book (id, title, ISBN, year) VALUES (1, "A Game of Thrones", "978-0553593716", 2003);
INSERT INTO book (id, title, ISBN, year) VALUES (1, "A Clash of Kings", "978-0553593716", 2003);
INSERT INTO book (id, title, ISBN, year) VALUES (1, "A Storm of Swords", "034554398X", 2003);

INSERT INTO author (id, first_name, last_name) VALUES (1, "George R. R. Martin")

INSERT INTO book_author (book_id, author_id) VALUES (1, 1);
INSERT INTO book_author (book_id, author_id) VALUES (2, 1);
INSERT INTO book_author (book_id, author_id) VALUES (3, 1);