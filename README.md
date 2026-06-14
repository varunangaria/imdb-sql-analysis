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
├── ER_Diagram.png 
├── IMDB Analysis MySQL.sql                 
├── README.md             
└── schema.sql
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

## Key Insights

Movie Trends
•	The database contains 3,88,269 movies spanning from 1888 to 2008. 
•	Movie production peaked in 2002, with 12,056 movies released. 

Ratings Analysis
•	The highest-rated movie is ‘Atunci i-am condamnat pe toti la moarte’ with a rating of 9.9. 
•	The average movie rating across all films is 5.8. 
•	‘Film-Noir’ genre has the highest average rating among all genres. i.e. rating = 6.7
 
Actor Insights
•	The most active actor is 'Mel Blanc'. 
•	‘John’ is the most common first name among actors.
•	Several actors played multiple roles within the same movie, indicating complex character portrayals. 
•	‘Around the world in 80 days’ movie had the maximum cast. i.e 1,274 actors

Director Insights
•	'Eleni Alexandrakis' is the only director who maintained long career, with over 98 years between their first and last movies. 
•	Directors with at least five movies generally achieved higher average ratings than the overall director average.

Data Quality Findings 
•	A few actors have names beginning with numbers or special characters, indicating potential data-entry issues. 
•	Some movies do not have genre information associated with them and may require data cleansing. 
•	Long movie titles and missing genre assignments highlight opportunities for improving data quality. 

## Conclusion

This project demonstrates the use of SQL joins, aggregations, subqueries, CTEs, window functions, and analytical queries to explore relationships between movies, actors, directors, ratings, and genres. The analysis revealed patterns in movie production, genre popularity, actor-director collaborations, and data quality issues while showcasing practical SQL skills commonly used in real-world analytics projects.

## Tools Used

- **MySQL 8.0**
- **MySQL Workbench** (query editor + ER diagram)

## Author

**Varun Angaria**
Data Analyst
[LinkedIn](https://www.linkedin.com/in/varun-angaria1998/) • [GitHub](https://github.com/varunangaria)

