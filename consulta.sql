/* Adaptación de código realizado por el ingeniero Juan Suárez en https://www.youtube.com/watch?v=jVlR9_qkM8c 
Código original: https://github.com/IngJuanMaSuarez/PostGIS-para-Dummies/blob/main/04%20-%20PostGIS%20-%20Analisis.sql
Archivos originales: https://drive.google.com/drive/folders/1VY90McIrfuLC2WOKxSxiZ9i2ZTaKBT6A

PLANTEAMIENTO: 
Se requiere adquirir una manzana de más de 5000 metros cuadrados para construir un nuevo colegio de primaria, 
asegurando que esté a más de 300 metros de otro colegio, a más de 200 metros de cualquier equipamiento y en una 
zona exclusivamente residencial*/

-- CÓDIGO PARA SER EJECUTADO DESDE PGADMIN
WITH
    manzanas_grandes AS (
        SELECT *
        FROM manzanas m
        WHERE ST_AREA(m.geom) > 5000
    ),
    buffer_colegios AS (
        SELECT ST_UNION(ST_BUFFER(c.geom, 300)) AS geom_buffer
        FROM colegios c
        WHERE c.categoria = 'Primaria'
    ),
    manzanas_sin_colegios AS (
        SELECT m.*
        FROM manzanas_grandes m
        JOIN buffer_colegios bc ON ST_INTERSECTS(m.geom, bc.geom_buffer) = FALSE
    ),
    buffer_equipamientos AS (
        SELECT ST_UNION(ST_BUFFER(e.geom, 200)) AS geom_buffer
        FROM equipamientos e
    ),
    manzanas_sin_equipamientos AS ( 
        SELECT mc.*
        FROM manzanas_sin_colegios mc
        JOIN buffer_equipamientos eq ON ST_INTERSECTS(mc.geom, eq.geom_buffer) = FALSE
    ),
    uso_residencial AS (   
        SELECT ST_UNION(u.geom) AS geom_uso
        FROM usodelsuelo u
        WHERE u.tipo_uso = 'RESIDENCIAL'
    )	
SELECT ST_TRANSFORM(geom,4326)
FROM manzanas_sin_equipamientos mc, uso_residencial u
WHERE ST_CONTAINS(u.geom_uso, mc.geom);


-- CÓDIGO PARA SER EJECUTADO DESDE QGIS (AGREGAR COMO CAPA)
WITH
    manzanas_grandes AS (
        SELECT *
        FROM manzanas m
        WHERE ST_AREA(m.geom) > 5000
    ),
    buffer_colegios AS (
        SELECT ST_UNION(ST_BUFFER(c.geom, 300)) AS geom_buffer
        FROM colegios c
        WHERE c.categoria = 'Primaria'
    ),
    manzanas_sin_colegios AS (
        SELECT m.*
        FROM manzanas_grandes m
        JOIN buffer_colegios bc ON ST_INTERSECTS(m.geom, bc.geom_buffer) = FALSE
    ),
    buffer_equipamientos AS (
        SELECT ST_UNION(ST_BUFFER(e.geom, 200)) AS geom_buffer
        FROM equipamientos e
    ),
    manzanas_sin_equipamientos AS ( 
        SELECT mc.*
        FROM manzanas_sin_colegios mc
        JOIN buffer_equipamientos eq ON ST_INTERSECTS(mc.geom, eq.geom_buffer) = FALSE
    ),
    uso_residencial AS (   
        SELECT ST_UNION(u.geom) AS geom_uso
        FROM usodelsuelo u
        WHERE u.tipo_uso = 'RESIDENCIAL'
    )	
SELECT *
FROM manzanas_sin_equipamientos mc, uso_residencial u
WHERE ST_CONTAINS(u.geom_uso, mc.geom);
