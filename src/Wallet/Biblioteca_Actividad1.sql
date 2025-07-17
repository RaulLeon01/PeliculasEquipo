--- Eliminar tablas existentes (en orden correcto para evitar problemas de referencias)
DROP TABLE TRANSACCIONES CASCADE CONSTRAINTS PURGE;
DROP TABLE LIBROS CASCADE CONSTRAINTS PURGE;
DROP TABLE MIEMBROS CASCADE CONSTRAINTS PURGE;
DROP TABLE MEMBRESIAS CASCADE CONSTRAINTS PURGE;
DROP TABLE PUBLICACIONES CASCADE CONSTRAINTS PURGE;
DROP TABLE AUTORES CASCADE CONSTRAINTS PURGE;

----------------------------------------------------------------------------------------------------------
--- CREACIONES DE TABLAS ---
-- TABLA DE MEMBRESIAS (debe crearse primero por las referencias)
CREATE TABLE MEMBRESIAS (
  membresia_id INT PRIMARY KEY NOT NULL,
  nombre VARCHAR(30) NOT NULL,
  duracion_meses INT NOT NULL,
  max_prestamos INT NOT NULL,
  descripcion VARCHAR(100)
);

-- TABLA DE PUBLICACIONES
CREATE TABLE PUBLICACIONES (
  publicacion_id varchar(10) PRIMARY KEY not NULL,
  editorial varchar(20) not null,
  fecha_publicacion date not null,
  edicion int,
  pais_publicacion varchar(15),
  idioma varchar(10)
);

-- TABLA DE AUTORES
CREATE TABLE AUTORES (
  autor_id INT PRIMARY KEY NOT NULL,
  nombre_autor varchar(50) not null,
  nacionalidad varchar(20),
  fecha_nacimiento date,
  bibliografia varchar(500)
);

-- TABLA DE MIEMBROS (con referencia a MEMBRESIAS)
CREATE TABLE MIEMBROS (
  matricula_id varchar(10) PRIMARY KEY NOT NULL,
  nombre varchar(50) not null,
  apellidoPaterno varchar(50) not null,
  apellidoMaterno varchar(50) not null,
  estadoEstudiante varchar(20) not null,
  correo varchar(20) not null,
  telefono VARCHAR(10),
  carrera varchar(20) not null,
  membresia_id INT NOT NULL,
  fecha_inicio_membresia DATE NOT NULL,
  FOREIGN KEY (membresia_id) REFERENCES MEMBRESIAS(membresia_id)
);

-- TABLA DE LIBROS
CREATE TABLE LIBROS (
  libro_id INT PRIMARY KEY not NULL,
  titulo VARCHAR(100) NOT NULL,
  estado varchar(10) NOT NULL,
  autor_id int not NULL,
  publicacion_id varchar(10) not NULL,
  isbn VARCHAR(13) not null,
  cantidad int not null,
  fecha_adquisicion date not null,
  ubicacionFisica VARCHAR(100) not null,
  FOREIGN KEY (autor_id) REFERENCES AUTORES(autor_id),
  FOREIGN KEY (publicacion_id) REFERENCES PUBLICACIONES(publicacion_id)
);

-- TABLA DE TRANSACCIONES
CREATE TABLE TRANSACCIONES (
  transaccion_id int PRIMARY KEY NOT NULL,
  libro_id int not null,
  matricula_id VARCHAR(10) not null,
  estado VARCHAR(20) not null,
  fecha_prestamo date not null,
  fecha_devolucion date not null,
  fecha_devolucion_real date not null,
  multa numeric(10),
  FOREIGN KEY (libro_id) REFERENCES LIBROS(libro_id),
  FOREIGN KEY (matricula_id) REFERENCES MIEMBROS(matricula_id)
);

-- TRIGGER PARA VALIDAR MEMBRESÍAS
CREATE OR REPLACE TRIGGER VALIDAR_MEMBRESIA
BEFORE INSERT ON TRANSACCIONES
FOR EACH ROW
DECLARE
  v_fecha_fin DATE;
  v_membresia_id INT;
  v_prestamos_activos INT;
  v_max_prestamos INT;
BEGIN
  -- Obtener fecha de fin de membresía y tipo
  SELECT m.fecha_inicio_membresia + (mem.duracion_meses * INTERVAL '1' MONTH),
         m.membresia_id
  INTO v_fecha_fin, v_membresia_id
  FROM MIEMBROS m
  JOIN MEMBRESIAS mem ON m.membresia_id = mem.membresia_id
  WHERE m.matricula_id = :NEW.matricula_id;
  
  -- Verificar si la membresía está vencida
  IF v_fecha_fin < SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20001, 'No se puede realizar el préstamo. La membresía ha vencido.');
  END IF;
  
  -- Contar préstamos activos del miembro
  SELECT COUNT(*) 
  INTO v_prestamos_activos
  FROM TRANSACCIONES
  WHERE matricula_id = :NEW.matricula_id
  AND estado = 'PRESTADO';
  
  -- Obtener máximo de préstamos permitidos
  SELECT max_prestamos
  INTO v_max_prestamos
  FROM MEMBRESIAS
  WHERE membresia_id = v_membresia_id;
  
  -- Validar límite
  IF v_prestamos_activos >= v_max_prestamos THEN
    RAISE_APPLICATION_ERROR(-20002, 'Límite de préstamos alcanzado para esta membresía.');
  END IF;
END;
/

-- LLENADO DE TABLAS --
-- MEMBRESIAS (debe insertarse primero)
INSERT ALL
  INTO MEMBRESIAS VALUES (1, 'Básica', 6, 2, 'Membresía básica con límite de 2 préstamos simultáneos')
  INTO MEMBRESIAS VALUES (2, 'Estándar', 12, 4, 'Membresía estándar con límite de 4 préstamos simultáneos')
  INTO MEMBRESIAS VALUES (3, 'Premium', 12, 6, 'Membresía premium con límite de 6 préstamos simultáneos')
SELECT * FROM dual;

-- AUTORES
INSERT ALL
  INTO AUTORES VALUES (1, 'Gabriel García Márquez', 'Colombiano', TO_DATE('1927-03-06', 'YYYY-MM-DD'), 'Premio Nobel de Literatura en 1982, autor de "Cien años de soledad"')
  INTO AUTORES VALUES (2, 'Mario Vargas Llosa', 'Peruano', TO_DATE('1936-03-28', 'YYYY-MM-DD'), 'Premio Nobel de Literatura en 2010, autor de "La ciudad y los perros"')
  INTO AUTORES VALUES (3, 'Isabel Allende', 'Chilena', TO_DATE('1942-08-02', 'YYYY-MM-DD'), 'Autora bestseller conocida por "La casa de los espíritus"')
  INTO AUTORES VALUES (4, 'Jorge Luis Borges', 'Argentino', TO_DATE('1899-08-24', 'YYYY-MM-DD'), 'Maestro del cuento corto y la literatura fantástica')
  INTO AUTORES VALUES (5, 'Pablo Neruda', 'Chileno', TO_DATE('1904-07-12', 'YYYY-MM-DD'), 'Premio Nobel de Literatura en 1971, destacado poeta')
  INTO AUTORES VALUES (6, 'Julio Cortázar', 'Argentino', TO_DATE('1914-08-26', 'YYYY-MM-DD'), 'Autor innovador de "Rayuela"')
  INTO AUTORES VALUES (7, 'Carlos Fuentes', 'Mexicano', TO_DATE('1928-11-11', 'YYYY-MM-DD'), 'Figura central de la literatura latinoamericana')
  INTO AUTORES VALUES (8, 'Octavio Paz', 'Mexicano', TO_DATE('1914-03-31', 'YYYY-MM-DD'), 'Premio Nobel de Literatura en 1990')
  INTO AUTORES VALUES (9, 'Elena Poniatowska', 'Mexicana', TO_DATE('1932-05-19', 'YYYY-MM-DD'), 'Premio Cervantes en 2013')
  INTO AUTORES VALUES (10, 'Juan Rulfo', 'Mexicano', TO_DATE('1917-05-16', 'YYYY-MM-DD'), 'Autor de "Pedro Páramo" y "El llano en llamas"')
SELECT * FROM dual;

-- PUBLICACIONES
INSERT ALL
  INTO PUBLICACIONES VALUES ('PUB001', 'Alfaguara', TO_DATE('1967-05-30', 'YYYY-MM-DD'), 1, 'Argentina', 'Español')
  INTO PUBLICACIONES VALUES ('PUB002', 'Planeta', TO_DATE('2000-01-15', 'YYYY-MM-DD'), 3, 'España', 'Español')
  INTO PUBLICACIONES VALUES ('PUB003', 'Penguin', TO_DATE('2015-08-20', 'YYYY-MM-DD'), 2, 'EE.UU.', 'Inglés')
  INTO PUBLICACIONES VALUES ('PUB004', 'FCE', TO_DATE('1944-01-01', 'YYYY-MM-DD'), NULL, 'México', 'Español')
  INTO PUBLICACIONES VALUES ('PUB005', 'Seix Barral', TO_DATE('1974-09-10', 'YYYY-MM-DD'), 5, 'España', 'Español')
  INTO PUBLICACIONES VALUES ('PUB006', 'Sudamericana', TO_DATE('1963-06-28', 'YYYY-MM-DD'), NULL, 'Argentina', 'Español')
  INTO PUBLICACIONES VALUES ('PUB007', 'Tusquets', TO_DATE('1999-11-15', 'YYYY-MM-DD'), 1, 'México', 'Español')
  INTO PUBLICACIONES VALUES ('PUB008', 'Debolsillo', TO_DATE('2012-03-22', 'YYYY-MM-DD'), 10, 'España', 'Español')
  INTO PUBLICACIONES VALUES ('PUB009', 'Anagrama', TO_DATE('1985-07-07', 'YYYY-MM-DD'), NULL, 'España', 'Español')
  INTO PUBLICACIONES VALUES ('PUB010', 'Siglo XXI', TO_DATE('2008-05-18', 'YYYY-MM-DD'), 1, 'México', 'Español')
SELECT * FROM dual;

-- MIEMBROS (con membresías)
INSERT ALL
  INTO MIEMBROS VALUES ('A22010001', 'Ana', 'García', 'López', 'ACTIVO', 'a.garcia@uni.edu', '5512345678', 'LITERATURA', 1, TO_DATE('2023-06-15', 'YYYY-MM-DD'))
  INTO MIEMBROS VALUES ('A22010002', 'Carlos', 'Martínez', 'Sánchez', 'ACTIVO', 'c.martinez@uni.edu', '5523456789', 'DERECHO', 2, TO_DATE('2023-09-01', 'YYYY-MM-DD'))
  INTO MIEMBROS VALUES ('A22010003', 'María', 'Rodríguez', 'Gómez', 'INACTIVO', 'm.rodriguez@uni.edu', '5534567890', 'MEDICINA', 1, TO_DATE('2023-01-10', 'YYYY-MM-DD'))
  INTO MIEMBROS VALUES ('A22010004', 'Juan', 'Hernández', 'Pérez', 'ACTIVO', 'j.hernandez@uni.edu', '5545678901', 'INGENIERIA', 3, TO_DATE('2023-11-05', 'YYYY-MM-DD'))
  INTO MIEMBROS VALUES ('A22010005', 'Lucía', 'Díaz', 'Fernández', 'SUSPENDIDO', 'l.diaz@uni.edu', '5556789012', 'ARQUITECTURA', 1, TO_DATE('2022-12-20', 'YYYY-MM-DD'))
  INTO MIEMBROS VALUES ('A22010006', 'Pedro', 'Moreno', 'Jiménez', 'ACTIVO', 'p.moreno@uni.edu', '5567890123', 'BIOLOGIA', 2, TO_DATE('2023-08-12', 'YYYY-MM-DD'))
  INTO MIEMBROS VALUES ('A22010007', 'Sofía', 'Torres', 'Ruiz', 'ACTIVO', 's.torres@uni.edu', '5578901234', 'PSICOLOGIA', 3, TO_DATE('2023-10-01', 'YYYY-MM-DD'))
  INTO MIEMBROS VALUES ('A22010008', 'Diego', 'Vargas', 'Castro', 'ACTIVO', 'd.vargas@uni.edu', '5589012345', 'ECONOMIA', 2, TO_DATE('2023-07-22', 'YYYY-MM-DD'))
  INTO MIEMBROS VALUES ('A22010009', 'Elena', 'Cruz', 'Mendoza', 'INACTIVO', 'e.cruz@uni.edu', '5590123456', 'HISTORIA', 1, TO_DATE('2023-03-15', 'YYYY-MM-DD'))
  INTO MIEMBROS VALUES ('A22010010', 'Jorge', 'Ortega', 'Silva', 'ACTIVO', 'j.ortega@uni.edu', '5501234567', 'FISICA', 3, TO_DATE('2023-09-30', 'YYYY-MM-DD'))
SELECT * FROM dual;

-- LIBROS
INSERT ALL
  INTO LIBROS VALUES (1, 'Cien años de soledad', 'DISPONIBLE', 1, 'PUB001', '9780307474728', 5, TO_DATE('2020-01-15', 'YYYY-MM-DD'), 'SEC-A-12')
  INTO LIBROS VALUES (2, 'La ciudad y los perros', 'PRESTADO', 2, 'PUB002', '9788420471839', 3, TO_DATE('2021-03-10', 'YYYY-MM-DD'), 'SEC-B-05')
  INTO LIBROS VALUES (3, 'La casa de los espíritus', 'DISPONIBLE', 3, 'PUB003', '9789500714950', 2, TO_DATE('2019-11-22', 'YYYY-MM-DD'), 'SEC-C-08')
  INTO LIBROS VALUES (4, 'Ficciones', 'MANTENIM', 4, 'PUB004', '9788426413116', 1, TO_DATE('2022-05-30', 'YYYY-MM-DD'), 'TALLER-01')
  INTO LIBROS VALUES (5, 'Veinte poemas de amor', 'DISPONIBLE', 5, 'PUB005', '9788437604417', 4, TO_DATE('2021-07-18', 'YYYY-MM-DD'), 'SEC-D-03')
  INTO LIBROS VALUES (6, 'Rayuela', 'PRESTADO', 6, 'PUB006', '9788437604424', 3, TO_DATE('2020-09-12', 'YYYY-MM-DD'), 'SEC-A-15')
  INTO LIBROS VALUES (7, 'Aura', 'DISPONIBLE', 7, 'PUB007', '9789681618123', 2, TO_DATE('2022-02-28', 'YYYY-MM-DD'), 'SEC-E-07')
  INTO LIBROS VALUES (8, 'El laberinto de la soledad', 'DISPONIBLE', 8, 'PUB008', '9789681601170', 1, TO_DATE('2021-10-05', 'YYYY-MM-DD'), 'SEC-B-12')
  INTO LIBROS VALUES (9, 'La noche de Tlatelolco', 'PRESTADO', 9, 'PUB009', '9786071116248', 2, TO_DATE('2022-06-15', 'YYYY-MM-DD'), 'SEC-C-01')
  INTO LIBROS VALUES (10, 'Pedro Páramo', 'DISPONIBLE', 10, 'PUB010', '9786071609805', 3, TO_DATE('2020-12-20', 'YYYY-MM-DD'), 'SEC-D-08')
SELECT * FROM dual;

-- Actualizar fechas de inicio de membresía para que estén vigentes
UPDATE MIEMBROS SET fecha_inicio_membresia = TO_DATE('2023-10-01', 'YYYY-MM-DD') 
WHERE matricula_id IN ('A22010003', 'A22010005', 'A22010009');
ALTER TRIGGER VALIDAR_MEMBRESIA DISABLE;

-- Luego ejecutar nuevamente el INSERT de TRANSACCIONES
-- TRANSACCIONES
INSERT ALL
  INTO TRANSACCIONES VALUES (1, 2, 'A22010001', 'PRESTADO', TO_DATE('2023-09-10', 'YYYY-MM-DD'), TO_DATE('2023-09-24', 'YYYY-MM-DD'), TO_DATE('2023-09-22', 'YYYY-MM-DD'), 0)
  INTO TRANSACCIONES VALUES (2, 6, 'A22010003', 'DEVUELTO', TO_DATE('2023-09-05', 'YYYY-MM-DD'), TO_DATE('2023-09-19', 'YYYY-MM-DD'), TO_DATE('2023-09-25', 'YYYY-MM-DD'), 60)
  INTO TRANSACCIONES VALUES (3, 9, 'A22010005', 'ATRASADO', TO_DATE('2023-08-15', 'YYYY-MM-DD'), TO_DATE('2023-08-29', 'YYYY-MM-DD'), TO_DATE('2023-09-05', 'YYYY-MM-DD'), 150)
  INTO TRANSACCIONES VALUES (4, 2, 'A22010007', 'DEVUELTO', TO_DATE('2023-10-02', 'YYYY-MM-DD'), TO_DATE('2023-10-16', 'YYYY-MM-DD'), TO_DATE('2023-10-15', 'YYYY-MM-DD'), 0)
  INTO TRANSACCIONES VALUES (5, 6, 'A22010002', 'DEVUELTO', TO_DATE('2023-10-10', 'YYYY-MM-DD'), TO_DATE('2023-10-24', 'YYYY-MM-DD'), TO_DATE('2023-10-22', 'YYYY-MM-DD'), 0)
  INTO TRANSACCIONES VALUES (6, 9, 'A22010004', 'DEVUELTO', TO_DATE('2023-09-07', 'YYYY-MM-DD'), TO_DATE('2023-09-21', 'YYYY-MM-DD'), TO_DATE('2023-09-20', 'YYYY-MM-DD'), 0)
  INTO TRANSACCIONES VALUES (7, 3, 'A22010006', 'DEVUELTO', TO_DATE('2023-10-12', 'YYYY-MM-DD'), TO_DATE('2023-10-26', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'), 0)
  INTO TRANSACCIONES VALUES (8, 7, 'A22010008', 'DEVUELTO', TO_DATE('2023-09-18', 'YYYY-MM-DD'), TO_DATE('2023-10-02', 'YYYY-MM-DD'), TO_DATE('2023-10-01', 'YYYY-MM-DD'), 0)
  INTO TRANSACCIONES VALUES (9, 10, 'A22010010', 'DEVUELTO', TO_DATE('2023-10-05', 'YYYY-MM-DD'), TO_DATE('2023-10-19', 'YYYY-MM-DD'), TO_DATE('2023-10-18', 'YYYY-MM-DD'), 0)
  INTO TRANSACCIONES VALUES (10, 1, 'A22010009', 'PRESTADO', TO_DATE('2023-10-20', 'YYYY-MM-DD'), TO_DATE('2023-11-03', 'YYYY-MM-DD'), TO_DATE('2023-11-03', 'YYYY-MM-DD'), 0)
SELECT * FROM dual;



----------------------------------------------------------------------------------------------------------
-- COMIENZA LA ACTIVIDAD DE PELICULAS DE POO
CREATE TABLE peliculas (
    id NUMBER PRIMARY KEY,
    titulo VARCHAR2(255) NOT NULL,
    genero VARCHAR2(100),
    año NUMBER(4)
);
-- PELICULAS LLENADO
INSERT ALL
  INTO peliculas VALUES (1, 'El Padrino', 'Crimen', 1972)
  INTO peliculas VALUES (2, 'Interestelar', 'Ciencia Ficción', 2014)
  INTO peliculas VALUES (3, 'Parásitos', 'Drama', 2019)
  INTO peliculas VALUES (4, 'Spider-Man: Sin Camino a Casa', 'Acción', 2021)
  INTO peliculas VALUES (5, 'Coco', 'Animación', 2017)
SELECT * FROM dual;
SELECT * FROM peliculas;
DROP TABLE peliculas;

----------------------------------------------------------------------------------------------------------
--- CONSULTAS ---
SELECT *from AUTORES;
SELECT *from LIBROS;
SELECT *from MIEMBROS;
SELECT *from PUBLICACIONES;
SELECT *from TRANSACCIONES;
SELECT *FROM MEMBRESIAS;

----------------------------------------------------------------------------------------------------------
--- CONSULTAS EXAMEN ----
/*
 1.- Mostrar el nombre de la editorial, 
 así como la cantidad de libros que más libros provee a la biblioteca.
*/
SELECT 
    p.editorial AS nombre_editorial,
    SUM(l.cantidad) AS total_libros
FROM 
    LIBROS l
JOIN 
    PUBLICACIONES p ON l.publicacion_id = p.publicacion_id
GROUP BY 
    p.editorial
ORDER BY 
    total_libros DESC
FETCH FIRST 1 ROW ONLY;

/*
 2.- Mostrar el nombre del estudiante, 
 el nombre del libro 
 y la cantidad de libros del estudiante que más libros consulta.
*/
WITH prestamos_por_estudiante AS (
    SELECT 
        m.matricula_id,
        m.nombre || ' ' || m.apellidoPaterno || ' ' || m.apellidoMaterno AS nombre_estudiante,
        COUNT(t.transaccion_id) AS total_libros_consultados
    FROM 
        TRANSACCIONES t
    JOIN 
        MIEMBROS m ON t.matricula_id = m.matricula_id
    GROUP BY 
        m.matricula_id, m.nombre, m.apellidoPaterno, m.apellidoMaterno
    ORDER BY 
        total_libros_consultados DESC
),
estudiante_top AS (
    SELECT 
        matricula_id,
        nombre_estudiante,
        total_libros_consultados
    FROM 
        prestamos_por_estudiante
    WHERE 
        ROWNUM = 1
)
SELECT 
    e.nombre_estudiante,
    l.titulo AS nombre_libro,
    e.total_libros_consultados
FROM 
    estudiante_top e
JOIN 
    TRANSACCIONES t ON e.matricula_id = t.matricula_id
JOIN 
    LIBROS l ON t.libro_id = l.libro_id
ORDER BY 
    l.titulo;
    
/*
 3.-Mostrar los nombres de las personas 
 y su estatus (docente,estudiante, administrativo) que tienen penalización.
*/
SELECT 
    m.nombre || ' ' || m.apellidoPaterno || ' ' || m.apellidoMaterno AS nombre_completo,
    CASE 
        WHEN m.carrera IS NOT NULL THEN 'Estudiante'
        ELSE 'Otro (docente/administrativo)' 
    END AS estatus,
    t.multa AS penalizacion
FROM 
    MIEMBROS m
JOIN 
    TRANSACCIONES t ON m.matricula_id = t.matricula_id
WHERE 
    t.multa > 0
ORDER BY 
    nombre_completo;

/*
 4.- Mostrar los nombres de las personas con sus matriculas 
 o números control que han solicitado libros.
*/
SELECT DISTINCT
    m.matricula_id AS numero_control,
    m.nombre || ' ' || m.apellidoPaterno || ' ' || m.apellidoMaterno AS nombre_completo
FROM 
    MIEMBROS m
JOIN 
    TRANSACCIONES t ON m.matricula_id = t.matricula_id
ORDER BY 
    nombre_completo;

/*
 5.- Mostrar la cantidad total de libros que se tienen en la biblioteca.
*/
SELECT 
    SUM(cantidad) AS total_libros
FROM 
    LIBROS;
----------------------------------------------------------------------------------------------------------
--- ACTUALIZACIONES ----
-- Actualizar editoriales existentes (consulta 1)
UPDATE PUBLICACIONES SET editorial = 'Penguin Random House' WHERE publicacion_id = 'PUB001';
UPDATE PUBLICACIONES SET editorial = 'Planeta DeAgostini' WHERE publicacion_id = 'PUB002';
-- Insertar nuevas publicaciones
INSERT INTO PUBLICACIONES VALUES ('PUB011', 'Santillana', TO_DATE('2020-03-15', 'YYYY-MM-DD'), 2, 'España', 'Español');
INSERT INTO PUBLICACIONES VALUES ('PUB012', 'Santillana', TO_DATE('2021-07-22', 'YYYY-MM-DD'), 1, 'México', 'Español');

-- Actualización de Libros (consultas 1, 2, 5)
-- Agregar nuevos libros
INSERT INTO LIBROS VALUES (11, 'El amor en los tiempos del cólera', 'DISPONIBLE', 1, 'PUB001', '9780307350428', 4, TO_DATE('2023-01-10', 'YYYY-MM-DD'), 'SEC-A-14');
INSERT INTO LIBROS VALUES (12, 'Los cachorros', 'DISPONIBLE', 2, 'PUB002', '9788420471846', 3, TO_DATE('2023-02-15', 'YYYY-MM-DD'), 'SEC-B-07');
INSERT INTO LIBROS VALUES (13, 'El cuaderno de Maya', 'DISPONIBLE', 3, 'PUB011', '9788426413123', 2, TO_DATE('2023-03-20', 'YYYY-MM-DD'), 'SEC-C-09');
INSERT INTO LIBROS VALUES (14, 'El Aleph', 'DISPONIBLE', 4, 'PUB012', '9788426413130', 3, TO_DATE('2023-04-25', 'YYYY-MM-DD'), 'SEC-D-04');

-- Actualización de Miembros (consultas 2, 3, 4)
-- Agregar nuevos miembros
INSERT INTO MIEMBROS VALUES ('A22010011', 'Laura', 'Gómez', 'Pérez', 'ACTIVO', 'l.gomez@uni.edu', '5512345679', 'MEDICINA', 2, TO_DATE('2023-06-01', 'YYYY-MM-DD'));
INSERT INTO MIEMBROS VALUES ('A22010012', 'Ricardo', 'López', 'Martínez', 'ACTIVO', 'r.lopez@uni.edu', '5523456790', 'INGENIERIA', 3, TO_DATE('2023-07-15', 'YYYY-MM-DD'));
INSERT INTO MIEMBROS VALUES ('D22010001', 'Prof. Alejandro', 'Ruiz', 'Hernández', 'ACTIVO', 'p.ruiz@uni.edu', '5534567891', 'DOCENTE', 3, TO_DATE('2023-08-20', 'YYYY-MM-DD'));
-- Actualizar carreras para diferenciar estatus
UPDATE MIEMBROS SET carrera = 'DOCENTE' WHERE matricula_id = 'A22010009';
UPDATE MIEMBROS SET carrera = 'ADMINISTRATIVO' WHERE matricula_id = 'A22010005';

-- Actualización de Transacciones (afecta consultas 2, 3, 4)
-- Insertar nuevas transacciones con multas
INSERT INTO TRANSACCIONES VALUES (11, 11, 'A22010011', 'DEVUELTO', TO_DATE('2023-11-05', 'YYYY-MM-DD'), TO_DATE('2023-11-19', 'YYYY-MM-DD'), TO_DATE('2023-11-25', 'YYYY-MM-DD'), 75);
INSERT INTO TRANSACCIONES VALUES (12, 12, 'A22010012', 'DEVUELTO', TO_DATE('2023-11-10', 'YYYY-MM-DD'), TO_DATE('2023-11-24', 'YYYY-MM-DD'), TO_DATE('2023-11-30', 'YYYY-MM-DD'), 90);
INSERT INTO TRANSACCIONES VALUES (13, 13, 'D22010001', 'PRESTADO', TO_DATE('2023-12-01', 'YYYY-MM-DD'), TO_DATE('2023-12-15', 'YYYY-MM-DD'), TO_DATE('2023-12-15', 'YYYY-MM-DD'), 0);
INSERT INTO TRANSACCIONES VALUES (14, 14, 'A22010007', 'ATRASADO', TO_DATE('2023-12-05', 'YYYY-MM-DD'), TO_DATE('2023-12-19', 'YYYY-MM-DD'), TO_DATE('2023-12-22', 'YYYY-MM-DD'), 45);
-- Actualizar algunas multas existentes
UPDATE TRANSACCIONES SET multa = 200 WHERE transaccion_id = 3;
UPDATE TRANSACCIONES SET multa = 120 WHERE transaccion_id = 2;

-- Actualización de Membresías (consultas indirectamente)
-- Agregar nueva membresía
INSERT INTO MEMBRESIAS VALUES (4, 'VIP', 24, 10, 'Membresía VIP con privilegios extendidos');
-- Actualizar membresías de algunos miembros
UPDATE MIEMBROS SET membresia_id = 4 WHERE matricula_id IN ('A22010004', 'D22010001');

