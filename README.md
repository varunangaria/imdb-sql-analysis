## IMDB SQL Analysis Project

A structured SQL project built on the IMDB relational database, covering 35 analytical queries ranging from basic data retrieval to advanced techniques like Window Functions, CTEs, and correlated subqueries.

## Project Overview

| Detail | Info |
|---|---|
| **Database** | MySQL |
| **Dataset** | IMDB (Movies, Actors, Directors, Genres, Roles) |
| **Total Queries** | 35 |

## Database Schema

The project uses the following tables:

| Table | Description |
|---|---|
| `movies` | Movie ID, name, year, rankscore |
| `actors` | Actor ID, first name, last name, gender |
| `directors` | Director ID, first name, last name |
| `roles` | Movie ID, Actor ID, Role |
| `movies_directors` | Director ID, Movie ID |
| `movies_genres` | Movie ID, Genre |
| `directors_genres` | Director ID, Genre, Prob |

## Files

```
├── IMDB Analysis MySQL.sql     # All 35 queries with comments
├── imdbERdiagram.mwb          # MySQL Workbench ER Diagram
└── README.md
```

## Sample Queries

**Top 3 movies per genre using Window Function:**
```sql
WITH movie_rank AS (
SELECT mg.genre, m.name, m.rankscore,
DENSE_RANK() OVER(PARTITION BY mg.genre ORDER BY m.rankscore DESC) AS rnk
FROM movies m
INNER JOIN movies_genres mg
ON m.id = mg.movie_id)
SELECT *
FROM movie_rank
WHERE rnk <=3;
```

**Directors with higher avg rating than 'Osman Ali' (min 5 movies):**
```sql
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
```

## Conclusion

This project demonstrates the use of SQL joins, aggregations, subqueries, CTEs, window functions, and analytical queries to explore relationships between movies, actors, directors, ratings, and genres. The analysis revealed patterns in movie production, genre popularity, actor-director collaborations, and data quality issues while showcasing practical SQL skills commonly used in real-world analytics projects.

## Tools Used

- **MySQL 8.0**
- **MySQL Workbench** (query editor + ER diagram)

## Author

**Varun Angaria**
Data Analyst
[LinkedIn](https://www.linkedin.com/in/varun-angaria1998/) • [GitHub](https://github.com/varunangaria)

