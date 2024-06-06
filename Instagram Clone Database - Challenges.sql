/*We want to reward our users who have been around the longest.  
Find the 5 oldest users.*/
SELECT dense_rank() over(ORDER BY created_at) as 'rank', id, username, created_at FROM users
LIMIT 5;

/*What day of the week do most users register on?
We need to figure out when to schedule an ad campgain*/

select dense_rank() over(ORDER BY a.total DESC) as 'rank', a.day, a.total from
(SELECT 
    DAYNAME(created_at) AS 'day',
    COUNT(1) AS 'total'
FROM users
GROUP BY day
ORDER BY total DESC) a;


/*We want to target our inactive users with an email campaign.
Find the users who have never posted a photo*/

SELECT username
FROM users
where not exists (select  1 from photos where photos.user_id=users.id);

/*We're running a new contest to see who can get the most likes on a single photo.
WHO WON??!!*/
SELECT 
    username,
    photos.id,
    photos.image_url, 
    COUNT(1) AS total_likes
FROM photos
INNER JOIN likes
    ON likes.photo_id = photos.id
INNER JOIN users
    ON photos.user_id = users.id
GROUP BY photos.id
ORDER BY total_likes DESC
LIMIT 1;


/*Our Investors want to know...
How many times does the average user post?*/
/*total number of photos/total number of users*/
SELECT ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),2) as 'average_posts';


/*user ranking by postings higher to lower*/
SELECT users.username,COUNT(photos.image_url) as 'total_posts'
FROM users
inner JOIN photos ON users.id = photos.user_id
GROUP BY users.id
ORDER BY total_posts DESC;


/*Total Posts per users */
SELECT users.username,COUNT(photos.image_url) AS total_posts_per_user
		FROM users
		 inner JOIN photos ON users.id = photos.user_id
		GROUP BY users.id
        order by total_posts_per_user desc ;


/*total numbers of users who have posted at least one time */
SELECT COUNT(DISTINCT(users.id)) AS total_number_of_users_with_posts
FROM users
inner JOIN photos ON users.id = photos.user_id;


/*A brand wants to know which hashtags to use in a post
What are the top 5 most commonly used hashtags?*/
SELECT tag_name, COUNT(tag_name) AS total
FROM tags
inner JOIN photo_tags ON tags.id = photo_tags.tag_id
GROUP BY tags.id
ORDER BY total DESC
limit 5;


/*We have a small problem with bots on our site...
Find users who have liked every single photo on the site*/
SELECT users.id,username, COUNT(users.id) As total_likes_by_user
FROM users
inner JOIN likes ON users.id = likes.user_id
GROUP BY users.id
HAVING total_likes_by_user = (SELECT COUNT(1) FROM photos);


/*We also have a problem with celebrities
Find users who have never commented on a photo*/

SELECT username
	FROM users
	left JOIN comments ON users.id = comments.user_id
	where comment_text IS NULL;

/*Mega Challenges
Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on every photo*/

SELECT tableA.celebrity_count AS 'celebrity',
		(tableA.celebrity_count/(SELECT COUNT(*) FROM users))*100 AS 'celebrity %',
		tableB.bot_count AS 'bot',
		(tableB.bot_count/(SELECT COUNT(*) FROM users))*100 AS 'bot %'
FROM
	(
		SELECT COUNT(1) AS 'celebrity_count' FROM
			(SELECT username
	FROM users
	left JOIN comments ON users.id = comments.user_id
	where comment_text IS NULL) a
	) AS tableA,
	(
		SELECT COUNT(1) AS 'bot_count' FROM
			(SELECT users.id,username, COUNT(users.id) As total_likes_by_user
FROM users
inner JOIN likes ON users.id = likes.user_id
GROUP BY users.id
HAVING total_likes_by_user = (SELECT COUNT(1) FROM photos)) b
	)AS tableB;

/*Find users who have commented on a photo*/

SELECT COUNT(*) as 'total_number_users_with_comments' FROM
(SELECT users.id 
	FROM users
	LEFT JOIN comments ON users.id = comments.user_id
    where comments.comment_text IS NOT NULL
	GROUP BY users.id
	) a;
