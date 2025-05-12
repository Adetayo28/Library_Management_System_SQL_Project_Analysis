
CREATE DATABASE library_db;


-- Create table "Branch"  
DROP DATABASE IF EXISTS branch;
CREATE TABLE branch 
	(
		branch_id VARCHAR(10) PRIMARY KEY,
		manager_id VARCHAR(10),
		branch_address VARCHAR(30),
		contact_no VARCHAR(15)
	);

-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees 
	(
		emp_id VARCHAR(10) PRIMARY KEY,
		emp_name VARCHAR(30),
		position VARCHAR(30),
		salary DECIMAL(10,2),
		branch_id VARCHAR(10),
		FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
	);



-- create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
	(
		member_id VARCHAR(10) PRIMARY KEY,
		member_name VARCHAR(30),
		member_address VARCHAR(30),
		reg_date DATE
	);

-- Create table "Book"
DROP DATABASE IF EXISTS books;
CREATE TABLE books 
	(
		isbn VARCHAR(50) PRIMARY KEY,
		book_title VARCHAR(80),
		category VARCHAR(30),
		rental_price DECIMAL(10,2),
		status VARCHAR(10),
		author VARCHAR(30),
		publisher VARCHAR(30) 
	);


-- Create table "IssuedStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
	(
		issued_id VARCHAR(10) PRIMARY KEY,
		issued_member_id VARCHAR(30),
		issued_book_name VARCHAR(80),
		issued_date DATE,
		issued_book_isbn VARCHAR(50),
		issued_emp_id VARCHAR(10),
		FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
		FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn),
		FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id)
	);

  
-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
	(
		return_id VARCHAR(10) PRIMARY KEY,
		issued_id VARcHAR(30),
		return_book_name VARCHAR(80),
		return_date DATE,
		return_book_isbn VARCHAR(50),
		FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id),
		FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
	);


SELECT * FROM branch;
SELECT * FROM books;
SELECT * FROM members;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status; 


-- Project TASK
-- ### 2. CRUD Operations


-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;


-- Task 2: Update an Existing Member's Address
UPDATE members
SET	member_address ='125 Main St'
WHERE member_id = 'C101';


SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';

SELECT * FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_emp_id,
	COUNT(issued_id) AS total_book_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1;

SELECT * FROM issued_status;

-- ### 3. CTAS (Create Table As Select)
-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE book_count
AS
SELECT 
	b.isbn, 
	b.book_title,
	COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN
issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;

SELECT *
FROM book_count;

-- ### 4. Data Analysis & Findings
-- Task 7. **Retrieve All Books in a Specific Category:
 
SELECT * 
FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:



SELECT 
	b.category,
	SUM(b.rental_price),
	COUNT(*)
FROM books AS b
JOIN
issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Task 9. **List Members Who Registered in the Last 365 Days**:

SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '365 days';

SELECT CURRENT_DATE;


-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:

SELECT 
	e1.*,
	b.manager_id,
	e2.emp_name AS manager   
FROM employees AS e1
JOIN
branch AS b
ON e1.branch_id = b.branch_id
JOIN 
employees AS e2
ON e2.emp_id = b.manager_id;



-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold

CREATE TABLE books_greater_than_seven
AS
SELECT *
FROM books
WHERE rental_price > 7.00;

SELECT *
FROM books_greater_than_seven;


-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
	DISTINCT ist.issued_book_name
FROM issued_status AS ist
LEFT JOIN
return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;



	

--- Advanced SQL Operations
/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == returns_status
-- filter books which is returned 
-- overdue > 30 

SELECT 
	ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	-- rs.return_date,
	CURRENT_DATE - ist.issued_date AS over_dues_days
FROM issued_status AS ist
JOIN 
members AS m
ON m.member_id = ist.issued_member_id
JOIN
books AS bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN
return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE 
	rs.return_date IS NULL
	AND 
	(CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;


/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books
table to "available" when they are returned 
(based on entries in the return_status table).
*/

 -- Manual Method
SELECT *
FROM issued_status
WHERE issued_book_isbn ='978-0-451-52994-2'; 

SELECT *
FROM books
WHERE isbn='978-0-451-52994-2';

UPDATE books
SET status ='no'
WHERE isbn='978-0-451-52994-2';

SELECT *
FROM return_status
WHERE issued_id = 'IS130';

--
INSERT INTO return_status(return_id, issued_id, return_date,book_quality)
VALUES ('RS125', 'IS130', CURRENT_DATE, 'Good');

SELECT *
FROM return_status
WHERE issued_id = 'IS130';

UPDATE books
SET status ='yes'
WHERE isbn='978-0-451-52994-2';


-- store procedure

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql 
AS $$

DECLARE
	v_isbn VARCHAR(50);
	v_book_name VARCHAR(80);
BEGIN
	-- all logic and code
	-- insert into return_status table base on user input
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
	VALUES 
	(p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

	SELECT
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;
	
	UPDATE books
	SET status ='yes'
	WHERE isbn=v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
	
END;
$$
 
CALL add_return_records();

-- Testing function add_return_records

SELECT *
FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT *
FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT *
FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');


SELECT *
FROM books
WHERE isbn = '978-0-330-25864-8'; 

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-330-25864-8';

CALL add_return_records('RS148', 'IS140', 'Good');


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for 
each branch, showing the number of books issued, 
the number of books returned, 
and the total revenue generated from book rentals.
*/

SELECT * 
FROM branch;

SELECT *
FROM issued_status;

SELECT *
FROM employees;

SELECT * 
FROM books; 

SELECT *
FROM return_status;


CREATE TABLE branch_reports
AS
SELECT 
	b.branch_id,
	b.manager_id,
	COUNT(ist.issued_id) AS number_books_issued,
	COUNT(rs.return_id) AS number_books_return,
	SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN
employees AS e
ON e.emp_id = ist.issued_emp_id
JOIN
branch AS b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status AS rs
ON rs.issued_id = ist.issued_id
JOIN
books AS bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;


SELECT *
FROM branch_reports;


/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement 
to create a new table of active_members 
containing members who have issued 
at least one book in the last 6 months.
*/

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT
							DISTINCT issued_member_id
					FROM issued_status
					WHERE 
						issued_date >= CURRENT_DATE - INTERVAL '6 month'
					);


SELECT *
FROM active_members;


/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

SELECT 
	e.emp_name,
	b.branch_id,
	b.branch_address,
	COUNT(ist.issued_id) AS no_books_issued	
FROM issued_status AS ist
JOIN
employees AS e
ON e.emp_id = ist.issued_emp_id
JOIN
branch AS b
ON e.branch_id = b.branch_id
GROUP BY 1, 2
ORDER BY COUNT(ist.issued_id) DESC
LIMIT 3;
/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have 
issued books more than twice with the status 
"damaged" in the books table. 
Display the member name, book title, 
and the number of times they've issued damaged books.    
*/

SELECT 
	m.member_id,
	m.member_name,
	ist.issued_book_name,
	rs.book_quality,
	COUNT(rs.book_quality) AS book_quality_count
FROM members AS m
JOIN
issued_status AS ist
ON ist.issued_member_id = m.member_id
LEFT JOIN 
return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.book_quality = 'Damaged'
GROUP BY 1,3,4
ORDER BY COUNT(rs.book_quality);

/*
Task 19: Stored Procedure
Objective: Create a stored procedure 
to manage the status of books in a library system.

    Description: Write a stored procedure that updates 
	the status of a book based on its issuance or return. 
	Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.
*/


SELECT *
FROM books;

SELECT *
FROM issued_status;


CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30) , p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE 
-- all the variable goes here 
	v_status VARCHAR(10);
	
BEGIN
-- all the code goes here 
	-- check if book is available 'yes'
	SELECT 
		status
		INTO
		v_status
	FROM books
	WHERE isbn = p_issued_book_isbn;


	IF v_status = 'yes' THEN
		INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES
		(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;
		
		RAISE NOTICE'Book records added successfully for book isbn : %', p_issued_book_isbn;
		
	ELSE
		RAISE NOTICE'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
	END IF;

END;
$$


SELECT * FROM books;
-- "978-0-553-29698-2" yes
-- 978-0-375-41398-8   no
SELECT * FROM issued_status;


CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');


CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');


SELECT * 
FROM books
WHERE isbn = '978-0-375-41398-8';


/*
Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) 
query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table 
that lists each member and the books they have issued 
but not returned within 30 days. 
The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/





SELECT *
FROM books;


CREATE TABLE overdue_summary AS
SELECT  
    m.member_id,
	m.member_name,
    COUNT(ist.issued_id) AS total_books_issued,
    COUNT(
        CASE
            WHEN (
                rs.return_date IS NULL AND CURRENT_DATE - ist.issued_date > 30
            ) OR (
                rs.return_date IS NOT NULL AND rs.return_date - ist.issued_date > 30
            )
            THEN 1
            ELSE NULL
        END
    ) AS overdue_count,
    SUM(
        CASE
            WHEN rs.return_date IS NULL AND CURRENT_DATE - ist.issued_date > 30 THEN
                (CURRENT_DATE - ist.issued_date - 30) * 0.5
            WHEN rs.return_date IS NOT NULL AND rs.return_date - ist.issued_date > 30 THEN
                (rs.return_date - ist.issued_date - 30) * 0.5
            ELSE 0
        END
    ) AS total_fines
FROM members AS m
JOIN issued_status AS ist 
ON m.member_id = ist.issued_member_id
LEFT JOIN return_status AS rs 
ON rs.issued_id = ist.issued_id
GROUP BY m.member_id;


SELECT *
FROM overdue_summary;

