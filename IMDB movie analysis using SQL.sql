create database imdb;
use imdb;

-- 1. List all movies released in the year 1998.
SELECT * FROM movies
WHERE year = 1998;

-- 2. Count the total number of movies in the dataset.
SELECT count(*) AS total_movies
FROM movies;

-- 3. Find the top 10 highest-rated movies.
SELECT * FROM movies
ORDER BY rankscore DESC
LIMIT 10;

-- 4. How many movies were released each year?
SELECT year, count(*) AS total_movies
FROM movies
GROUP BY year
ORDER BY year;

-- 5. What is the average rank (rating) of movies for each genre?
SELECT mg.genre, avg(rankscore) AS avg_rating
FROM movies m
INNER JOIN movies_genres mg
ON m.id = mg.movie_id
GROUP BY mg.genre
ORDER BY avg_rating DESC;

-- 6. Find directors who have directed more than 5 movies.
SELECT d.id, d.first_name, d.last_name, COUNT(md.movie_id) AS total_movies
FROM directors d
JOIN movies_directors md
ON d.id = md.director_id
GROUP BY d.id,d.first_name,d.last_name
HAVING COUNT(md.movie_id) > 5
ORDER BY total_movies DESC;

-- 7. List all actors who acted in the movie 'Dosti'.
SELECT a.id, a.first_name, a.last_name, a.gender
FROM movies m
INNER JOIN roles r
ON m.id = r.movie_id
INNER JOIN actors a
ON r.actor_id = a.id
WHERE m.name = 'Dosti';

-- 8. Find the names of directors and the movies they directed in the 'Sci-Fi' 
SELECT d.id, d.first_name, d.last_name, m.name AS movie_name
FROM directors d
INNER JOIN movies_directors md
ON d.id = md.director_id
INNER JOIN movies m
ON md.movie_id = m.id
INNER JOIN movies_genres mg
ON m.id = mg.movie_id
WHERE mg.genre = 'Sci-Fi';

-- 9. List the top 5 actors who have appeared in the maximum number of movies.
SELECT a.id, a.first_name, a.last_name, a.gender, count(DISTINCT r.movie_id) AS movie_count
FROM actors a
JOIN roles r
ON a.id = r.actor_id
GROUP BY a.id, a.first_name, a.last_name, a.gender
ORDER BY movie_count DESC
LIMIT 5;

-- 10. Find movies that have the word 'Star' in their title.
SELECT * FROM movies
WHERE name LIKE '%Star%'; 

-- 11. Find all actors who have never acted in a movie directed by 'peter spirer'.
SELECT a.id, a.first_name, a.last_name, a.gender
FROM actors a
WHERE a.id NOT IN (
SELECT r.actor_id
FROM roles r
INNER JOIN movies_directors md
ON r.movie_id = md.movie_id
INNER JOIN directors d
ON md.director_id = d.id
WHERE d.first_name = 'peter'
AND d.last_name = 'spirer');

-- 12. Which movie has the largest cast (most actors)?
SELECT m.name, count(r.actor_id) AS total_actors
FROM movies m
INNER JOIN roles r
ON m.id = r.movie_id
GROUP BY m.name 
ORDER BY total_actors DESC
LIMIT 1;

-- 13. Identify any movies that do not have a single genre associated with them.
SELECT m.id, m.name
FROM movies m
LEFT JOIN movies_genres mg
ON m.id = mg.movie_id
WHERE mg.genre IS NULL; 

-- 14. Find movies that are listed under more than 3 different genres.
SELECT m.id, m.name, count(mg.genre) AS genre_count
FROM movies m
INNER JOIN movies_genres mg
ON m.id = mg.movie_id
GROUP BY m.id, m.name
HAVING count(mg.genre) > 3;

-- 15. List all actors whose names start with a special character or number (to identify data entry errors).
SELECT *
FROM actors a
WHERE first_name REGEXP '^[^A-Za-z]';

-- 16. Use a Window Function to rank movies by their rating within each genre. (Show the top 3 movies for every genre).
WITH ranked_movies AS (
SELECT m.name, mg.genre, m.rankscore,
DENSE_RANK() OVER (PARTITION BY mg.genre ORDER BY m.rankscore DESC) AS rnk
FROM movies m
JOIN movies_genres mg
ON m.id = mg.movie_id)
SELECT *
FROM ranked_movies
WHERE rnk <= 3;

-- 17. For each director, find the difference in years between their first movie and their last movie.
SELECT md.director_id, d.first_name, d.last_name, (max(m.year)-min(m.year)) AS diff
FROM movies m
INNER JOIN movies_directors md
ON m.id = md.movie_id
INNER JOIN directors d
ON md.director_id = d.id
GROUP BY md.director_id, d.first_name, d.last_name
ORDER BY diff desc;

-- 18. Which actor-director pair has worked together the most often?
SELECT d.first_name AS d_name, a.first_name AS a_name, count(*) AS movie_together
FROM actors a
INNER JOIN roles r 
ON r.actor_id = a.id
INNER JOIN movies m
ON r.movie_id = m.id
INNER JOIN movies_directors md 
ON m.id = md.movie_id
INNER JOIN directors AS d 
ON d.id = md.director_id 
GROUP BY d.id, a.id
ORDER BY movie_together DESC
LIMIT 1;

-- 19. Create a CTE to find the average rating of movies for each year, then calculate the overall average of those yearly results.
WITH avg_rating AS (
SELECT m.year, avg(m.rankscore) AS avg_rate FROM movies m
GROUP BY m.year)
SELECT avg(avg_rate) AS overall_avg FROM avg_rating; 

-- 20. Rating Buckets: Use a CASE statement to categorize movies into three groups: 'Blockbuster' (Rank > 8), 'Average' (Rank 5-8), and 'Low' (Rank < 5).
SELECT *, CASE
WHEN rankscore > 8 THEN 'Blockbuster'
WHEN rankscore >= 5 AND rankscore <= 8 THEN 'Average'
ELSE 'Low'
END as rating_recieved
FROM movies;

-- 21. Find actors who have an average movie rating of 8.0 or higher 
SELECT a.id, a.first_name,a.last_name, avg(m.rankscore) AS avg_rating
FROM movies m
INNER JOIN roles r
ON m.id = r.movie_id
INNER JOIN actors a
ON r.actor_id = a.id
GROUP BY a.id, a.first_name,a.last_name
HAVING avg(m.rankscore) >= 8;

-- 22. Find all directors who have a higher average rating than 'osman ali' but have directed at least 5 movies.
WITH higher AS (
SELECT d.id, d.first_name, d.last_name, COUNT(m.id) AS movie_count, AVG(m.rankscore) AS avgrs
FROM movies_directors md
JOIN movies m 
ON m.id = md.movie_id
JOIN directors d 
ON md.director_id = d.id
GROUP BY d.id, d.first_name, d.last_name
HAVING COUNT(m.id) >= 5)
SELECT * FROM higher
WHERE avgrs > (SELECT avgrs FROM higher 
               WHERE first_name = 'Osman' 
			   AND last_name = 'Ali');

-- 23. Which year had the highest variety of unique genres produced?
SELECT m.year, COUNT(DISTINCT mg.genre) AS unique_genres
FROM movies m 
INNER JOIN movies_genres mg
ON m.id = mg.movie_id
GROUP BY m.year
ORDER BY unique_genres DESC
LIMIT 1;

-- 24. Second Best: Find the movie with the second-highest number of roles (cast members)
WITH cast_count AS(
SELECT m.id, m.name, COUNT(*) AS total_cast,
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk
FROM movies m
JOIN roles r
ON m.id = r.movie_id
GROUP BY m.id, m.name)
SELECT id,name,total_cast
FROM cast_count
WHERE rnk = 2;

-- 25. What is the total count of movies, actors, and directors in the database?
SELECT
(SELECT count(*) FROM movies) AS total_movies,
(SELECT count(*) FROM actors) AS total_actors, 
(SELECT count(*) FROM directors) AS total_directors ;

-- 26. Find all movies released before 1930 that have a rankscore higher than 7.0.
SELECT * FROM movies
WHERE year < 1930 AND rankscore > 7;

-- 27. Which first name is the most common among actors? (e.g., How many 'Johns' are there?).
SELECT * FROM (
SELECT first_name, count(*) AS total_count,
DENSE_RANK() OVER(ORDER BY count(*) DESC) AS rnk
FROM actors
GROUP BY first_name)t
WHERE rnk = 1;

-- 28. Find all directors whose last name starts with 'Mc' (e.g., McCarthy, McDonald).
SELECT * FROM directors
WHERE last_name LIKE 'Mc%';

-- 29. List the unique role names that have the word 'Police' or 'Officer' in them.
SELECT DISTINCT role
FROM roles
WHERE role LIKE '%Police%' OR role LIKE '%Officer%';

-- 30. Identify movies that have a title longer than 50 characters.
SELECT id, name FROM movies
WHERE LENGTH(name) > 50;

-- 31. Find actors who played more than one role in a single movie (e.g., playing twins or multiple characters).
SELECT a.first_name, a.last_name, m.name, COUNT(DISTINCT r.role) AS role_count
FROM actors a
JOIN roles r
ON a.id = r.actor_id
JOIN movies m
ON r.movie_id = m.id
GROUP BY a.first_name, a.last_name, m.name
HAVING COUNT(DISTINCT r.role) > 1;

-- 32. Find the top 5 years in history where the most "Action" movies were produced.
SELECT m.year, COUNT(*) AS action_movies
FROM movies m
JOIN movies_genres mg
ON m.id = mg.movie_id
WHERE mg.genre = 'Action'
GROUP BY m.year
ORDER BY action_movies DESC
LIMIT 5;

-- 33. Find the difference between the highest-rated movie and the lowest-rated movie in the 'Comedy' genre.
SELECT max(m.rankscore) - min(m.rankscore) AS Diff
FROM movies m
JOIN movies_genres mg
ON m.id = mg.movie_id
WHERE mg.genre = 'Comedy';

-- 34. Count how many movies were made in the 1990s vs. the 2000s.
SELECT CASE 
WHEN year BETWEEN 1990 AND 1999 THEN '1990s'
WHEN year BETWEEN 2000 AND 2009 THEN '2000s'
END AS decade,
COUNT(*) AS total_movies
FROM movies
WHERE year BETWEEN 1990 AND 2009
GROUP BY decade;

-- 35. Find directors who have directed movies but none of those movies have a genre listed in the movies_genres table.
SELECT DISTINCT d.first_name, d.last_name
FROM directors d
JOIN movies_directors md ON d.id = md.director_id
WHERE md.director_id NOT IN (
SELECT DISTINCT md2.director_id
FROM movies_directors md2
JOIN movies_genres mg ON md2.movie_id = mg.movie_id);
