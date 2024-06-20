SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema minimundouvv
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS minimundouvv DEFAULT CHARACTER SET utf8mb3 ;
USE minimundouvv ;

-- -----------------------------------------------------
-- Table minimundouvv.professores
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS minimundouvv.professores (
  matricula_professores INT UNSIGNED NOT NULL,
  nome VARCHAR(45) NOT NULL,
  email VARCHAR(95) NOT NULL,
  PRIMARY KEY (matricula_professores),
  UNIQUE INDEX idx_unico_email_professores (email ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table minimundouvv.coordenadores
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS minimundouvv.coordenadores (
  matricula_cordenador INT UNSIGNED NOT NULL,
  nome VARCHAR(45) NOT NULL,
  Professores_matricula_professores INT UNSIGNED NOT NULL,
  PRIMARY KEY (matricula_cordenador),
  INDEX fk_Coordenadores_Professores1_idx (Professores_matricula_professores ASC) VISIBLE,
  INDEX idx_professores_matricula_professores (Professores_matricula_professores ASC) VISIBLE,
  CONSTRAINT fk_Coordenadores_Professores1
    FOREIGN KEY (Professores_matricula_professores)
    REFERENCES minimundouvv.professores (matricula_professores))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table minimundouvv.cursos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS minimundouvv.cursos (
  codigo_cursos INT UNSIGNED NOT NULL,
  nome VARCHAR(45) NOT NULL,
  carga_horaria INT UNSIGNED NOT NULL DEFAULT '3600',
  Coordenadores_matricula_cordenador INT UNSIGNED NOT NULL,
  numero_de_alunos INT NULL DEFAULT '0',
  PRIMARY KEY (codigo_cursos, Coordenadores_matricula_cordenador),
  INDEX fk_Cursos_Coordenadores1_idx (Coordenadores_matricula_cordenador ASC) VISIBLE,
  INDEX idx_coordenadores_matricula_cordenador (Coordenadores_matricula_cordenador ASC) VISIBLE,
  CONSTRAINT fk_Cursos_Coordenadores1
    FOREIGN KEY (Coordenadores_matricula_cordenador)
    REFERENCES minimundouvv.coordenadores (matricula_cordenador))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table minimundouvv.alunos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS minimundouvv.alunos (
  matricula_alunos INT UNSIGNED NOT NULL,
  nome VARCHAR(45) NOT NULL,
  cursos_codigo_cursos INT UNSIGNED NOT NULL,
  cursos_Coordenadores_matricula_cordenador INT UNSIGNED NOT NULL,
  data_ultima_modificacao TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (matricula_alunos, cursos_codigo_cursos, cursos_Coordenadores_matricula_cordenador),
  INDEX fk_alunos_cursos1_idx (cursos_codigo_cursos ASC, cursos_Coordenadores_matricula_cordenador ASC) VISIBLE,
  INDEX idx_cursos_codigo_cursos (cursos_codigo_cursos ASC, cursos_Coordenadores_matricula_cordenador ASC) VISIBLE,
  CONSTRAINT fk_alunos_cursos1
    FOREIGN KEY (cursos_codigo_cursos , cursos_Coordenadores_matricula_cordenador)
    REFERENCES minimundouvv.cursos (codigo_cursos , Coordenadores_matricula_cordenador))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table minimundouvv.materias
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS minimundouvv.materias (
  codigo_materia INT UNSIGNED NOT NULL,
  nome VARCHAR(45) NOT NULL,
  carga_horaria INT NOT NULL COMMENT 'minima de 40 horas',
  PRIMARY KEY (codigo_materia))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table minimundouvv.disciplinas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS minimundouvv.disciplinas (
  codigo_disciplina INT UNSIGNED NOT NULL,
  nome VARCHAR(45) NOT NULL,
  vagas INT NOT NULL COMMENT 'maximo de 60',
  Materias_codigo_materia INT UNSIGNED NOT NULL,
  professores_matricula_professores INT UNSIGNED NOT NULL,
  PRIMARY KEY (codigo_disciplina, Materias_codigo_materia, professores_matricula_professores),
  INDEX fk_Disciplinas_Materias1_idx (Materias_codigo_materia ASC) VISIBLE,
  INDEX fk_disciplinas_professores1_idx (professores_matricula_professores ASC) VISIBLE,
  INDEX idx_professores_matricula_professores_disciplinas (professores_matricula_professores ASC) VISIBLE,
  INDEX idx_materias_codigo_materia (Materias_codigo_materia ASC) VISIBLE,
  CONSTRAINT fk_Disciplinas_Materias1
    FOREIGN KEY (Materias_codigo_materia)
    REFERENCES minimundouvv.materias (codigo_materia),
  CONSTRAINT fk_disciplinas_professores1
    FOREIGN KEY (professores_matricula_professores)
    REFERENCES minimundouvv.professores (matricula_professores))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table minimundouvv.alunos_has_disciplinas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS minimundouvv.alunos_has_disciplinas (
  alunos_matricula_alunos INT UNSIGNED NOT NULL,
  Disciplinas_codigo_disciplina INT UNSIGNED NOT NULL,
  Disciplinas_Materias_codigo_materia INT UNSIGNED NOT NULL,
  PRIMARY KEY (alunos_matricula_alunos, Disciplinas_codigo_disciplina, Disciplinas_Materias_codigo_materia),
  INDEX fk_alunos_has_Disciplinas_Disciplinas1_idx (Disciplinas_codigo_disciplina ASC, Disciplinas_Materias_codigo_materia ASC) VISIBLE,
  INDEX fk_alunos_has_Disciplinas_alunos1_idx (alunos_matricula_alunos ASC) VISIBLE,
  INDEX idx_alunos_matricula_alunos (alunos_matricula_alunos ASC) VISIBLE,
  INDEX idx_disciplinas_codigo_disciplina (Disciplinas_codigo_disciplina ASC, Disciplinas_Materias_codigo_materia ASC) VISIBLE,
  INDEX idx_composto_alunos_disciplinas (alunos_matricula_alunos ASC, Disciplinas_codigo_disciplina ASC, Disciplinas_Materias_codigo_materia ASC) VISIBLE,
  CONSTRAINT fk_alunos_has_Disciplinas_alunos1
    FOREIGN KEY (alunos_matricula_alunos)
    REFERENCES minimundouvv.alunos (matricula_alunos),
  CONSTRAINT fk_alunos_has_Disciplinas_Disciplinas1
    FOREIGN KEY (Disciplinas_codigo_disciplina , Disciplinas_Materias_codigo_materia)
    REFERENCES minimundouvv.disciplinas (codigo_disciplina , Materias_codigo_materia))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table minimundouvv.email
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS minimundouvv.email (
  email VARCHAR(45) NOT NULL,
  alunos_matricula_alunos INT UNSIGNED NOT NULL,
  PRIMARY KEY (email, alunos_matricula_alunos),
  INDEX fk_email_alunos1_idx (alunos_matricula_alunos ASC) VISIBLE,
  INDEX idx_alunos_matricula_alunos_email (alunos_matricula_alunos ASC) VISIBLE,
  CONSTRAINT fk_email_alunos1
    FOREIGN KEY (alunos_matricula_alunos)
    REFERENCES minimundouvv.alunos (matricula_alunos))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table minimundouvv.log_exclusoes_alunos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS minimundouvv.log_exclusoes_alunos (
  id INT NOT NULL AUTO_INCREMENT,
  matricula INT NULL DEFAULT NULL,
  nome VARCHAR(255) NULL DEFAULT NULL,
  data_exclusao TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
