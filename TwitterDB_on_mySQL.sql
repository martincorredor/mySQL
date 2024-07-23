DROP DATABASE IF EXISTS twitter_db;

CREATE DATABASE twitter_db;

USE twitter_db;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
	user_id INT NOT NULL AUTO_INCREMENT,
    user_handle VARCHAR(50) NOT NULL UNIQUE,
    email_address VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phonenumber CHAR(10) UNIQUE,
    follower_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT (NOW()),
    PRIMARY KEY(user_id)
);

INSERT INTO users(user_handle, email_address, first_name, last_name, phonenumber)
VALUES
('Martin', 'dev.martincorredor@gmail.com', 'Martin', 'Corredor', '3224682353'),
('Laura', 'laura@gmail.com', 'Laura', 'Carvajal', '111111'),
('Pilar', 'pilar@gmail.com', 'Pilar', 'Corredor', '22222222'),
('Luis', 'dev.luismesa@gmail.com', 'Luis', 'Mesa', '333333'),
('Maria', 'maria@gmail.com', 'María', 'Corredor', '44444');

DROP TABLE IF EXISTS followers;

CREATE TABLE followers (
	follower_id INT NOT NULL,
    following_id INT NOT NULL,
    FOREIGN KEY(follower_id) REFERENCES users(user_id),
    FOREIGN KEY(following_id) REFERENCES users(user_id),
    PRIMARY KEY(follower_id, following_id)
);

ALTER TABLE followers
ADD CONSTRAINT check_follower_id
CHECK (follower_id <> following_id);



/*
SELECT follower_id, following_id FROM followers;
SELECT follower_id FROM followers WHERE following_id = 1;
SELECT COUNT(follower_id) AS followersNumber FROM followers WHERE following_id = 1;


-- Top 3 usuarios con mayor numero de seguidores
SELECT following_id, COUNT(follower_id) AS followers
FROM followers
GROUP BY following_id
ORDER BY followers DESC
LIMIT 3;

-- Top 3 usuarios con mayor numero de seguidores pero haciendo JOIN
SELECT users.user_id, users.user_handle, users.first_name, following_id, COUNT(follower_id) AS followers
FROM followers
JOIN users ON users.user_id = followers.following_id
GROUP BY following_id
ORDER BY followers DESC
LIMIT 3;

*/

DROP TABLE IF EXISTS tweets;

CREATE TABLE tweets(
	tweet_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    tweet_text VARCHAR(280) NOT NULL,
    nume_likes INT DEFAULT 0,
    num_retweets INT DEFAULT 0,
    num_comments INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT (NOW()),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    PRIMARY KEY (tweet_id)
);

INSERT INTO tweets(user_id, tweet_text)
VALUES
(1, 'Hola, soy Martin! ¿que tal?'),
(2, 'Entrando a tweeter'),
(3, 'HTML es un lenguaje de programación'),
(4, 'Aprendiendo mySQL'),
(5, 'Me encanta React'),
(1, 'Este trabajo ya es mío'),
(1, 'sígueme en todas mis redes');

/*
-- Cuantos tweets ha hecho un usuario?
SELECT user_id, COUNT(*) AS tweet_count
FROM tweets
GROUP BY user_id;
*/


-- Sub consultas
-- Obtener los teews de los usuarios que tienen mas de 2 seguidores
/*
SELECT tweet_id, tweet_text, user_id
FROM tweets
WHERE user_id IN (
	SELECT following_id
	FROM followers
	GROUP BY following_id
	HAVING COUNT(*) > 2
);
*/



-- DELETE
-- Quitar el safe mode
-- SET SQL_SAFE_UPDATES = 0;
-- DELETE FROM tweets WHERE tweet_id = 1
-- DELETE FROM tweets WHERE tweet_text LIKE '%redes%';

-- UPDATE
UPDATE tweets SET num_comments = num_comments + 1 WHERE tweet_id = 1;
/*
UPDATE tweets SET tweet_text = REPLACE(tweet_text, 'Hola', 'Helloooow')
WHERE tweet_text LIKE '%Hola%';
*/


DROP TABLE IF EXISTS tweet_likes;

CREATE TABLE tweet_likes (
	user_id INT NOT NULL,
    tweet_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (tweet_id) REFERENCES tweets(tweet_id),
    PRIMARY KEY (user_id, tweet_id)
);

INSERT INTO tweet_likes (user_id, tweet_id)
VALUES
(1, 3), (1, 5), (3, 4), (4, 3), (2, 1), (3, 1);

-- Obtener el numero de likes por cada tweet
/*
SELECT tweet_id, COUNT(*) AS like_count
FROM tweet_likes
GROUP BY tweet_id;
*/

-- TRIGGERS!!!!

DROP TRIGGER IF EXISTS increase_folloer_count;
DELIMITER $$

CREATE TRIGGER increase_follower_count
AFTER INSERT ON followers
FOR EACH ROW
BEGIN
	UPDATE users SET follower_count = follower_count + 1
    WHERE user_id = NEW.following_id;
END $$

DELIMITER ;

DELIMITER $$
CREATE TRIGGER decrease_follower_count
AFTER DELETE ON followers
FOR EACH ROW
BEGIN
	UPDATE users SET follower_count = follower_count - 1
    WHERE user_id = NEW.following_id;
END $$
DELIMITER ;


INSERT INTO followers(follower_id, following_id)
VALUES
(1, 2),
(2, 1),
(3, 1),
(4, 1),
(4, 5),
(5, 4);


