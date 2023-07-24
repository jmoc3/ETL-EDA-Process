USE popular_videogames;

-- Los tipos de datos de las columnas se encuentran bien exceptuando la de 'release_date' que deberia ser de tipo DATE.
ALTER TABLE games
CHANGE release_date release_date DATE NULL;

-- Creamos las tablas dimensionales
CREATE TABLE IF NOT EXISTS teams(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS genres(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

-- Creamos las tablas Intermedias
CREATE TABLE IF NOT EXISTS games_genres(
	id_game INT NOT NULL,
    id_genre INT NOT NULL
);

CREATE TABLE IF NOT EXISTS games_teams(
	id_game INT NOT NULL,
    id_team INT NOT NULL
);

-- Agregamos registros unicos respectivos a las tablas dimensionales
INSERT IGNORE INTO teams(name)
SELECT DISTINCT(teams) FROM games 
WHERE teams IS NOT NULL
ORDER BY teams ASC;

INSERT IGNORE INTO genres(name)
SELECT DISTINCT(genres) FROM games
WHERE genres IS NOT NULL
ORDER BY genres ASC;

-- Actualizamos las columnas que queremos normalizar por numeros que hagan referencia a los id´s de su respectiva tabla
SET SQL_SAFE_UPDATES = 0;

UPDATE games as g
JOIN teams as t ON g.teams = t.name   
SET g.teams = t.id;

ALTER TABLE games
RENAME COLUMN teams TO id_team;

UPDATE games as g
JOIN genres as gen ON g.genres = gen.name   
SET g.genres = gen.id;

ALTER TABLE games
RENAME COLUMN genres TO id_genre;

-- Agregamos registros que concuerden con los mismos de la tabla original
INSERT IGNORE INTO games_teams(id_game, id_team)
SELECT distinct(id),id_team FROM games where id_team is not null;

INSERT IGNORE INTO games_genres(id_game, id_genre)
SELECT distinct(id),id_genre FROM games where id_genre is not null;

-- Eliminamos duplicados
-- DELETE g1 FROM games g1
-- INNER JOIN games g2 
-- WHERE g1.id = g2.id and g1.name=g2.name ; 

SET SQL_SAFE_UPDATES = 1;

-- Eliminamos las columnas que ya no queremos dentro de la tabla games
ALTER TABLE games
DROP COLUMN id_team, DROP COLUMN id_genre;

-- En este punto solo nos falta las relaciones, y necesitamos borrar los datos duplicados, para mayor sencillez eliminaremos los registros desde python 
-- (Seguir con la segunda parte del apartado de 'Exportacion a la base de datos' antes de ejecutar el siguiente codigo)
---------------------------------------------------------------------------
/*
-- Asignamos y configuramos la llave primaria
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';

ALTER TABLE games 
CHANGE id id INT NOT NULL PRIMARY KEY AUTO_INCREMENT;

SET SESSION sql_mode='';

-- Por ultimo pero no menos importante, creamos las restricciones para generar las llaves foraneas

ALTER TABLE games_teams
ADD CONSTRAINT game_team_fk FOREIGN KEY (id_game) REFERENCES games(id),
ADD CONSTRAINT team_game_fk FOREIGN KEY (id_team) REFERENCES teams(id);

ALTER TABLE games_genres
ADD CONSTRAINT game_genre_fk FOREIGN KEY (id_game) REFERENCES games(id),
ADD CONSTRAINT genre_game_fk FOREIGN KEY (id_genre) REFERENCES genres(id); 
*/


