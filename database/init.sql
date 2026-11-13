-- =====================================================================
-- Base de Datos Legacy: colegio_legacy
-- Motor: MariaDB / MySQL 5.7+
-- Proposito: Repositorio de prueba para testing de migracion Delphi -> Modern Stack
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `colegio_legacy` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `colegio_legacy`;

-- ---------------------------------------------------------------------
-- Tabla 1: Cursos (División y año escolar)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `asistencias`;
DROP TABLE IF EXISTS `calificaciones`;
DROP TABLE IF EXISTS `alumnos`;
DROP TABLE IF EXISTS `materias`;
DROP TABLE IF EXISTS `cursos`;

CREATE TABLE `cursos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre` VARCHAR(50) NOT NULL COMMENT 'Ej: 1er Año A, 2do Año B',
  `division` VARCHAR(10) NOT NULL COMMENT 'A, B, C',
  `anio_escolar` INT NOT NULL COMMENT '1, 2, 3, 4, 5, 6',
  `turno` VARCHAR(20) NOT NULL DEFAULT 'Mañana' COMMENT 'Mañana, Tarde, Noche',
  `activo` TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Tabla 2: Materias
-- ---------------------------------------------------------------------
CREATE TABLE `materias` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `codigo` VARCHAR(15) NOT NULL UNIQUE COMMENT 'Ej: MAT-101, LENG-101',
  `nombre` VARCHAR(100) NOT NULL,
  `anio_escolar` INT NOT NULL,
  `carga_horaria` INT NOT NULL DEFAULT 4,
  `activo` TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Tabla 3: Alumnos (Entidad principal para Pantalla 1)
-- ---------------------------------------------------------------------
CREATE TABLE `alumnos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `legajo` VARCHAR(20) NOT NULL UNIQUE COMMENT 'Ej: LEG-2024-001',
  `apellido` VARCHAR(80) NOT NULL,
  `nombre` VARCHAR(80) NOT NULL,
  `dni` VARCHAR(20) NOT NULL UNIQUE,
  `fecha_nacimiento` DATE DEFAULT NULL,
  `email` VARCHAR(120) DEFAULT NULL,
  `telefono` VARCHAR(40) DEFAULT NULL,
  `curso_id` INT NOT NULL,
  `estado` VARCHAR(20) NOT NULL DEFAULT 'REGULAR' COMMENT 'REGULAR, LIBRE, EGRESADO, SUSPENDIDO',
  `fecha_alta` DATE NOT NULL,
  CONSTRAINT `fk_alumno_curso` FOREIGN KEY (`curso_id`) REFERENCES `cursos` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Tabla 4: Asistencias (Entidad para Pantalla 2)
-- ---------------------------------------------------------------------
CREATE TABLE `asistencias` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `alumno_id` INT NOT NULL,
  `materia_id` INT NOT NULL,
  `fecha` DATE NOT NULL,
  `estado` ENUM('PRESENTE', 'AUSENTE', 'JUSTIFICADO', 'TARDE') NOT NULL DEFAULT 'PRESENTE',
  `observacion` VARCHAR(255) DEFAULT NULL,
  `fecha_registro` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_asistencia_diaria` (`alumno_id`, `materia_id`, `fecha`),
  CONSTRAINT `fk_asistencia_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_asistencia_materia` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Tabla 5: Calificaciones / Notas (Entidad para Pantalla 3)
-- ---------------------------------------------------------------------
CREATE TABLE `calificaciones` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `alumno_id` INT NOT NULL,
  `materia_id` INT NOT NULL,
  `periodo` VARCHAR(30) NOT NULL COMMENT '1er Trimestre, 2do Trimestre, 3er Trimestre, Final Diciembre, Final Febrero',
  `nota` DECIMAL(4,2) NOT NULL COMMENT 'Escala de 1 a 10 con decimales',
  `observacion` VARCHAR(255) DEFAULT NULL,
  `estado_academico` VARCHAR(20) GENERATED ALWAYS AS (IF(`nota` >= 6.00, 'APROBADO', 'DESAPROBADO')) STORED,
  `fecha_carga` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_calificacion_periodo` (`alumno_id`, `materia_id`, `periodo`),
  CONSTRAINT `fk_calif_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_calif_materia` FOREIGN KEY (`materia_id`) REFERENCES `materias` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================================
-- DATOS SEMILLA (SEED DATA)
-- =====================================================================

-- Cursos
INSERT INTO `cursos` (`id`, `nombre`, `division`, `anio_escolar`, `turno`, `activo`) VALUES
(1, '1er Año A', 'A', 1, 'Mañana', 1),
(2, '1er Año B', 'B', 1, 'Tarde', 1),
(3, '2do Año A', 'A', 2, 'Mañana', 1),
(4, '3er Año A', 'A', 3, 'Mañana', 1);

-- Materias
INSERT INTO `materias` (`id`, `codigo`, `nombre`, `anio_escolar`, `carga_horaria`, `activo`) VALUES
(1, 'MAT-101', 'Matemática I', 1, 5, 1),
(2, 'LENG-101', 'Lengua y Literatura I', 1, 4, 1),
(3, 'HIST-101', 'Historia General', 1, 3, 1),
(4, 'FIS-101', 'Física Elemental', 1, 3, 1),
(5, 'ING-101', 'Inglés Técnico', 1, 3, 1);

-- Alumnos (Curso 1 = 1er Año A)
INSERT INTO `alumnos` (`id`, `legajo`, `apellido`, `nombre`, `dni`, `fecha_nacimiento`, `email`, `telefono`, `curso_id`, `estado`, `fecha_alta`) VALUES
(1, 'LEG-2024-001', 'González', 'Martín', '45123890', '2008-03-15', 'mgonzalez@escuela.edu.ar', '11-4567-8901', 1, 'REGULAR', '2024-02-15'),
(2, 'LEG-2024-002', 'Rodríguez', 'Lucía', '45890234', '2008-07-22', 'lrodriguez@escuela.edu.ar', '11-5678-9012', 1, 'REGULAR', '2024-02-15'),
(3, 'LEG-2024-003', 'Fernández', 'Joaquín', '46012456', '2008-11-05', 'jfernandez@escuela.edu.ar', '11-6789-0123', 1, 'REGULAR', '2024-02-16'),
(4, 'LEG-2024-004', 'López', 'Valentina', '45345678', '2008-01-30', 'vlopez@escuela.edu.ar', '11-7890-1234', 1, 'REGULAR', '2024-02-16'),
(5, 'LEG-2024-005', 'Díaz', 'Mateo', '45789123', '2008-09-18', 'mdiaz@escuela.edu.ar', '11-8901-2345', 1, 'REGULAR', '2024-02-18'),
(6, 'LEG-2024-006', 'Pérez', 'Camila', '45234567', '2008-04-12', 'cperez@escuela.edu.ar', '11-9012-3456', 1, 'REGULAR', '2024-02-18'),
(7, 'LEG-2024-007', 'Gómez', 'Santiago', '46123789', '2008-12-01', 'sgomez@escuela.edu.ar', '11-2345-6789', 1, 'LIBRE', '2024-02-20'),
(8, 'LEG-2024-008', 'Álvarez', 'Sofía', '45678901', '2008-06-19', 'salvarez@escuela.edu.ar', '11-3456-7890', 1, 'REGULAR', '2024-02-20'),
(9, 'LEG-2024-009', 'Romero', 'Ignacio', '45901234', '2008-08-25', 'iromero@escuela.edu.ar', '11-4567-8911', 2, 'REGULAR', '2024-02-22'),
(10, 'LEG-2024-010', 'Torres', 'Micaela', '45456789', '2008-02-14', 'mtorres@escuela.edu.ar', '11-5678-9022', 2, 'REGULAR', '2024-02-22');

-- Asistencias de prueba
INSERT INTO `asistencias` (`alumno_id`, `materia_id`, `fecha`, `estado`, `observacion`) VALUES
(1, 1, '2024-04-15', 'PRESENTE', NULL),
(2, 1, '2024-04-15', 'PRESENTE', NULL),
(3, 1, '2024-04-15', 'AUSENTE', 'Fiebre avisada por tutor'),
(4, 1, '2024-04-15', 'PRESENTE', NULL),
(5, 1, '2024-04-15', 'TARDE', 'Llegó 15 min tarde'),
(6, 1, '2024-04-15', 'PRESENTE', NULL),
(7, 1, '2024-04-15', 'AUSENTE', 'Sin justificar'),
(8, 1, '2024-04-15', 'PRESENTE', NULL);

-- Calificaciones de prueba (1er Trimestre - Matemática I)
INSERT INTO `calificaciones` (`alumno_id`, `materia_id`, `periodo`, `nota`, `observacion`) VALUES
(1, 1, '1er Trimestre', 8.50, 'Excelente participación'),
(2, 1, '1er Trimestre', 7.00, 'Buen rendimiento en evaluaciones'),
(3, 1, '1er Trimestre', 4.50, 'Debe reforzar ecuaciones lineales'),
(4, 1, '1er Trimestre', 9.00, 'Destacada'),
(5, 1, '1er Trimestre', 6.00, 'Aprobó con lo justo'),
(6, 1, '1er Trimestre', 5.00, 'Recuperatorio pendiente'),
(7, 1, '1er Trimestre', 3.00, 'Múltiples inasistencias'),
(8, 1, '1er Trimestre', 8.00, 'Muy buen trabajo en clase');
