USE library;

/*
 * Exercise 1
 */

-- 1
SELECT title, title_no FROM title;

-- 2
SELECT title FROM title WHERE title_no=10;

-- 3
SELECT member_no, ISNULL(fine_assessed, 0) - ISNULL(fine_paid, 0) - ISNULL(fine_waived, 0) AS fine
FROM loanhist
WHERE ISNULL(fine_assessed, 0) - ISNULL(fine_paid, 0) - ISNULL(fine_waived, 0) BETWEEN 8 AND 9;

-- 4
SELECT title_no, author FROM title WHERE author IN ('Charles Dickens', 'Jane Austen');
-- or
SELECT title_no, author FROM title WHERE author='Charles Dickens' OR author='Jane Austen';

-- 5
SELECT title_no, title FROM title WHERE title LIKE '%adventures%';

-- 6
SELECT member_no,
       ISNULL(fine_assessed, 0) - ISNULL(fine_paid, 0) - ISNULL(fine_waived, 0) AS fine,
       ISNULL(fine_paid, 0) AS fine_paid
FROM loanhist
WHERE ISNULL(fine_assessed, 0) - ISNULL(fine_paid, 0) - ISNULL(fine_waived, 0) > 0;

-- 7
SELECT DISTINCT city, state FROM adult;


/*
 * Exercise 2
 */

-- 1
SELECT title FROM title ORDER BY 1;  -- 1 refers to the first displayed column (in this example it's a 'title')
-- or:
SELECT title FROM title ORDER BY title;

-- 2 (we don't have to use ISNULL function after SELECT, because we will have only positive fine_assessed values)
SELECT member_no, isbn, fine_assessed, 2 * fine_assessed AS "double fine"
FROM loanhist
WHERE ISNULL(fine_assessed, 0) > 0;

-- 3.1
SELECT firstname + ' ' + middleinitial + ' ' + lastname AS email_name FROM member WHERE lastname='Anderson';
-- or:
SELECT CONCAT(firstname, ' ', middleinitial, ' ', lastname) AS email_name FROM member WHERE lastname='Anderson';

-- 3.2 (after modification)
SELECT LOWER(firstname + middleinitial + SUBSTRING(lastname, 1, 2)) AS email_name FROM member WHERE lastname='Anderson';
-- or:
SELECT LOWER(CONCAT(firstname, middleinitial, SUBSTRING(lastname, 1, 2))) AS email_name
FROM member
WHERE lastname='Anderson';

-- 4
SELECT 'The title is: ' + title + ', title number ' + TRIM(STR(title_no)) FROM title;
-- or
SELECT CONCAT('The title is: ', title, ', title number ', title_no) FROM title;
