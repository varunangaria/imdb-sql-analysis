-- (IMDB movie analysis using SQL)

USE imdb;

-- 1. List all movies released in the year 1998.
SELECT *
FROM movies
WHERE year = 1998;

-- 2. Count the total number of movies in the dataset.
SELECT count(*) AS total_movies
FROM movies;

-- 3. Find the top 10 highest-rated movies.
SELECT name, rankscore
FROM movies
ORDER BY rankscore DESC
LIMIT 10;

-- 4. How many movies were released each year?
SELECT year, count(*) AS total_movies
FROM movies
GROUP BY year
ORDER BY year DESC;

-- 5. What is the average rank (rating) of movies for each genre?
SELECT mg.genre ,avg(m.rankscore) AS avg_rating 
FROM movies m
LEFT JOIN movies_genres mg
ON m.id = mg.movie_id
GROUP BY mg.genre
ORDER BY avg_rating DESC;

-- 6. Find directors who have directed more than 5 movies.
SELECT d.id, d.first_name, d.last_name, count(md.movie_id) AS total_movies
FROM directors d
INNER JOIN movies_directors md
ON d.id = md.director_id
GROUP BY d.id, d.first_name, d.last_name
HAVING count(md.movie_id) > 5;

-- 7. List all actors who acted in the movie 'Dosti'.
SELECT a.id, a.first_name, a.last_name, m.name
FROM actors a
INNER JOIN roles r
ON a.id = r.actor_id
INNER JOIN movies m
ON r.movie_id = m.id
WHERE m.name = 'Dosti';

-- 8. Find the names of directors and the movies they directed in the 'Sci-Fi' genre.
SELECT d.id, d.first_name, d.last_name, m.name
FROM directors d
INNER JOIN movies_directors md
ON d.id = md.director_id
INNER JOIN movies m
ON md.movie_id = m.id
INNER JOIN movies_genres mg
ON m.id = mg.movie_id
WHERE mg.genre = 'Sci-Fi';

-- 9. List the top 5 actors who have appeared in the maximum number of movies.
SELECT a.id, a.first_name, a.last_name, count(DISTINCT r.movie_id) AS movie_count
FROM actors a
INNER JOIN roles r
ON a.id = r.actor_id
GROUP BY a.id, a.first_name, a.last_name 
ORDER BY movie_count DESC
LIMIT 5;

-- 10. Find movies that have the word 'Star' in their title.
SELECT *  
FROM movies
WHERE name LIKE '%Star%';

-- 11. Find all actors who have never acted in a movie directed by 'peter spirer'.
SELECT Distinct a.id, a.first_name, a.last_name 
FROM actors a
WHERE a.id NOT IN(
SELECT r.actor_id 
FROM roles r
INNER JOIN movies_directors md
ON r.movie_id = md.movie_id
INNER JOIN directors d
ON md.director_id = d.id
WHERE LOWER(CONCAT(d.first_name,' ',d.last_name)) = 'peter spirer'); 

-- 12. Which movie has the largest cast (most actors)?
SELECT m.id, m.name, count(r.actor_id) AS total_cast
FROM movies m
INNER JOIN roles r
ON m.id = r.movie_id
GROUP BY m.id, m.name
ORDER BY total_cast DESC
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
FROM actors 
WHERE first_name REGEXP '^[^A-Za-z]'
OR last_name REGEXP '^[^A-Za-z]';

-- 16. Use a Window Function to rank movies by their rating within each genre. (Show the top 3 movies for every genre).
WITH movie_rank AS (
SELECT mg.genre, m.name, m.rankscore,
DENSE_RANK() OVER(PARTITION BY mg.genre ORDER BY m.rankscore DESC) AS rnk
FROM movies m
INNER JOIN movies_genres mg
ON m.id = mg.movie_id)
SELECT *
FROM movie_rank
WHERE rnk <=3;

-- 17. For each director, find the difference in years between their first movie and their last movie.
SELECT d.id, d.first_name, d.last_name, min(m.year), max(m.year), max(m.year) - min(m.year) AS total_gap
FROM directors d
INNER JOIN movies_directors md
ON d.id = md.director_id
INNER JOIN movies m
ON md.movie_id = m.id
GROUP BY d.id, d.first_name, d.last_name
ORDER BY total_gap DESC;

-- 18. Which actor-director pair has worked together the most often?
SELECT a.id, a.first_name AS actor_name, d.id, d.first_name AS director_name, count(*) AS worked_together
FROM actors a
INNER JOIN roles r
ON a.id = r.actor_id
INNER JOIN movies_directors md
ON r.movie_id = md.movie_id
INNER JOIN directors d
ON md.director_id = d.id
GROUP BY a.id, d.id
ORDER BY worked_together DESC
LIMIT 1;

-- 19. Create a CTE to find the average rating of movies for each year, then calculate the overall average of those yearly results.
WITH year_avg AS (
SELECT year, avg(rankscore) AS avg_rating
FROM movies
GROUP BY year )
SELECT avg(avg_rating) AS overall_avg
FROM year_avg;

-- 20. Rating Buckets: Use a CASE statement to categorize movies into three groups:'Blockbuster' (Rank > 8), 'Average' (Rank 5-8), and 'Low' (Rank < 5).
SELECT name, rankscore,
CASE
WHEN rankscore > 8 THEN 'Blockbuster'
WHEN rankscore BETWEEN 5 AND 8 THEN 'Average'
ELSE 'Low'
END AS category
FROM movies;

-- 21. Find actors who have an average movie rating of 8.0 or higher 
SELECT a.id, a.first_name, a.last_name, avg(m.rankscore) AS avg_rating
FROM actors a
INNER JOIN roles r
ON a.id = r.actor_id
INNER JOIN movies m
ON r.movie_id = m.id
GROUP BY a.id, a.first_name, a.last_name
HAVING avg(m.rankscore) >= 8;

-- 22. Find all directors who have a higher average rating than 'osman ali' but have directed at least 5 movies.
WITH osman_avg AS(
SELECT avg(m.rankscore) AS avg_rating
FROM directors d
INNER JOIN movies_directors md
ON d.id = md.director_id
INNER JOIN movies m
ON md.movie_id = m.id
WHERE LOWER(CONCAT(d.first_name,' ',d.last_name))= 'osman ali')
SELECT d.first_name, d.last_name, avg(m.rankscore) AS avg_rating, count(*) AS movie_count
FROM directors d
INNER JOIN movies_directors md
ON d.id = md.director_id
INNER JOIN movies m
ON md.movie_id = m.id
GROUP BY d.id,d.first_name,d.last_name
HAVING COUNT(*) >= 5
AND AVG(m.rankscore) >(SELECT avg_rating
					   FROM osman_avg);

-- 23. Which year had the highest variety of unique genres produced?
SELECT m.year, count(DISTINCT mg.genre) AS total_genres
FROM movies m
INNER JOIN movies_genres mg
ON m.id = mg.movie_id
GROUP BY m.year
ORDER BY total_genres DESC
LIMIT 1;

-- 24. Second Best: Find the movie with the second-highest number of roles (cast members)
WITH cast_count AS (
SELECT m.id, m.name, count(r.actor_id) AS cast_size,
DENSE_RANK() OVER(ORDER BY count(r.actor_id) DESC) AS rnk
FROM movies m
INNER JOIN roles r
ON m.id = r.movie_id
GROUP BY m.id, m.name)
SELECT * FROM cast_count
WHERE rnk = 2;

-- 25. What is the total count of movies, actors, and directors in the database?
SELECT (
SELECT count(*) FROM movies) AS total_movies,
(SELECT count(*) FROM actors) AS total_actors,
(SELECT count(*) FROM directors) AS total_directors;

-- 26. Find all movies released before 1930 that have a rankscore higher than 7.0.
SELECT *
FROM movies
WHERE year < 1930 AND rankscore > 7;

-- 27. Which first name is the most common among actors? (e.g., How many 'Johns' are there?).
SELECT first_name, count(*) AS frequency
FROM actors
GROUP BY first_name
ORDER BY frequency DESC
LIMIT 1;

-- 28. Find all directors whose last name starts with 'Mc' (e.g., McCarthy, McDonald).
SELECT first_name, last_name
FROM directors
WHERE last_name LIKE 'Mc%';

-- 29. List the unique role names that have the word 'Police' or 'Officer' in them.
SELECT DISTINCT role 
FROM roles
WHERE role LIKE '%Police%' OR role LIKE '%Officer%';

-- 30. Identify movies that have a title longer than 50 characters.
SELECT name, LENGTH(name) AS total_length
FROM movies
WHERE LENGTH(name) > 50;

-- 31. Find actors who played more than one role in a single movie (e.g., playing twins or multiple characters).
SELECT a.id, a.first_name, a.last_name, m.name, count(DISTINCT r.role) AS role_count
FROM actors a
INNER JOIN roles r
ON a.id = r.actor_id
INNER JOIN movies m
ON r.movie_id = m.id
GROUP BY a.id, m.id
HAVING count(DISTINCT r.role) > 1;

-- 32. Find the top 5 years in history where the most "Action" movies were produced.
SELECT m.year, count(*) AS action_movies
FROM movies m
INNER JOIN movies_genres mg
ON m.id = mg.movie_id
WHERE mg.genre = 'Action'
GROUP BY m.year
ORDER BY action_movies DESC
LIMIT 5;

-- 33. Find the difference between the highest-rated movie and the lowest-rated movie in the 'Comedy' genre.
SELECT max(m.rankscore) - min(m.rankscore) AS rating_diff
FROM movies m
INNER JOIN movies_genres mg
ON m.id = mg.movie_id
WHERE mg.genre = 'Comedy';

-- 34. Count how many movies were made in the 1990s vs. the 2000s.
SELECT 
CASE
WHEN year BETWEEN 1990 AND 1999 THEN '1990s'
WHEN year BETWEEN 2000 AND 2009 THEN '2000s'
END AS decade,
count(*) AS movie_count
FROM movies
WHERE year BETWEEN 1990 AND 2009
GROUP BY decade;

-- 35. Find directors who have directed movies but none of those movies have a genre listed in the movies_genres table.
SELECT DISTINCT d.id, d.first_name, d.last_name
FROM directors d
INNER JOIN movies_directors md 
ON d.id = md.director_id
WHERE NOT EXISTS (
SELECT 1
FROM movies_directors md2
INNER JOIN movies_genres mg 
ON md2.movie_id = mg.movie_id
WHERE md2.director_id = d.id
);