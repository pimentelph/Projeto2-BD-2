DELIMITER $$

USE minimundouvv$$

-- Procedure AdicionarIndices
CREATE DEFINER=root@localhost PROCEDURE AdicionarIndices()
BEGIN
    CALL CriarIndex('coordenadores', 'idx_professores_matricula_professores', 'Professores_matricula_professores');
    CALL CriarIndex('cursos', 'idx_coordenadores_matricula_cordenador', 'Coordenadores_matricula_cordenador');
    CALL CriarIndex('alunos', 'idx_cursos_codigo_cursos', 'cursos_codigo_cursos, cursos_Coordenadores_matricula_cordenador');
    CALL CriarIndex('disciplinas', 'idx_materias_codigo_materia', 'Materias_codigo_materia');
    CALL CriarIndex('disciplinas', 'idx_professores_matricula_professores_disciplinas', 'Professores_matricula_professores');
    CALL CriarIndex('alunos_has_disciplinas', 'idx_alunos_matricula_alunos', 'alunos_matricula_alunos');
    CALL CriarIndex('alunos_has_disciplinas', 'idx_disciplinas_codigo_disciplina', 'Disciplinas_codigo_disciplina, Disciplinas_Materias_codigo_materia');
    CALL CriarIndex('alunos_has_disciplinas', 'idx_composto_alunos_disciplinas', 'alunos_matricula_alunos, Disciplinas_codigo_disciplina, Disciplinas_Materias_codigo_materia');
    CALL CriarIndex('email', 'idx_alunos_matricula_alunos_email', 'alunos_matricula_alunos');
    CALL CriarIndex('professores', 'idx_unico_email_professores', 'email');
END$$

-- Procedure CriarIndex
CREATE DEFINER=root@localhost PROCEDURE CriarIndex(p_tableName VARCHAR(255), p_indexName VARCHAR(255), p_indexColumns VARCHAR(255))
BEGIN
    DECLARE indexExists INT;
    SELECT COUNT(*)
    INTO indexExists
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_NAME = p_tableName 
        AND INDEX_NAME = p_indexName 
        AND TABLE_SCHEMA = 'minimundouvv';

    IF indexExists = 0 THEN
        SET @createIndexQuery = CONCAT('CREATE INDEX ', p_indexName, ' ON ', p_tableName, ' (', p_indexColumns, ')');
        PREPARE createIndexStatement FROM @createIndexQuery;
        EXECUTE createIndexStatement;
        DEALLOCATE PREPARE createIndexStatement;
    END IF;
END$$

-- Procedure DeletarIndex
CREATE DEFINER=root@localhost PROCEDURE DeletarIndex(IN p_dbName VARCHAR(255), IN p_tableName VARCHAR(255), IN p_indexName VARCHAR(255))
BEGIN
    DECLARE indexExiste INT;
    SELECT COUNT(*)
    INTO indexExiste
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_NAME = p_tableName 
        AND INDEX_NAME = p_indexName 
        AND TABLE_SCHEMA = p_dbName;

    IF indexExiste > 0 THEN
        SET @dropIndexQuery = CONCAT('ALTER TABLE ', p_dbName, '.', p_tableName, ' DROP INDEX ', p_indexName);
        PREPARE dropIndexStatement FROM @dropIndexQuery;
        EXECUTE dropIndexStatement;
        DEALLOCATE PREPARE dropIndexStatement;
    END IF;
END$$

-- Procedure LimparIndices
CREATE DEFINER=root@localhost PROCEDURE LimparIndices()
BEGIN
    CALL DeletarIndex('minimundouvv', 'coordenadores', 'idx_professores_matricula_professores');
    CALL DeletarIndex('minimundouvv', 'cursos', 'idx_coordenadores_matricula_cordenador');
    CALL DeletarIndex('minimundouvv', 'alunos', 'idx_cursos_codigo_cursos');
    CALL DeletarIndex('minimundouvv', 'disciplinas', 'idx_materias_codigo_materia');
    CALL DeletarIndex('minimundouvv', 'disciplinas', 'idx_professores_matricula_professores');
    CALL DeletarIndex('minimundouvv', 'alunos_has_disciplinas', 'idx_alunos_matricula_alunos');
    CALL DeletarIndex('minimundouvv', 'alunos_has_disciplinas', 'idx_disciplinas_codigo_disciplina');
    CALL DeletarIndex('minimundouvv', 'alunos_has_disciplinas', 'idx_composto_alunos_disciplinas');
    CALL DeletarIndex('minimundouvv', 'email', 'idx_alunos_matricula_alunos');
    CALL DeletarIndex('minimundouvv', 'professores', 'idx_unico_email');
END$$

-- Procedure povoar_alunos
CREATE DEFINER=root@localhost PROCEDURE povoar_alunos(IN num_alunos INT)
BEGIN
    DECLARE Id INT;
    DECLARE idcurso INT;
    DECLARE matriculacoord INT;
    SET Id = 1;
    WHILE Id <= num_alunos DO
        SELECT codigo_cursos, Coordenadores_matricula_cordenador INTO idcurso, matriculacoord
        FROM cursos
        ORDER BY RAND()
        LIMIT 1;
        INSERT INTO alunos(matricula_alunos, nome, Cursos_codigo_cursos, cursos_Coordenadores_matricula_cordenador) VALUES (
            Id + 1000,
            CONCAT('Aluno - ', CAST(Id AS CHAR)),
            idcurso,
            matriculacoord
        );
        SET Id = Id + 1;
    END WHILE;
END$$

-- Procedure povoar_alunos_has_disciplinas
CREATE DEFINER=root@localhost PROCEDURE povoar_alunos_has_disciplinas(IN num_registros INT)
BEGIN
    DECLARE Id INT;
    DECLARE aluno_id INT;
    DECLARE disciplina_id INT;
    DECLARE materia_id INT;
    DECLARE exists_count INT;
    SET Id = 1;
    
    WHILE Id <= num_registros DO
        -- Seleciona um aluno de forma aleatória
        SELECT matricula_alunos INTO aluno_id
        FROM alunos
        ORDER BY RAND()
        LIMIT 1;
        
        -- Seleciona uma disciplina e sua matéria correspondente de forma aleatória
        SELECT codigo_disciplina, Materias_codigo_materia INTO disciplina_id, materia_id
        FROM disciplinas
        ORDER BY RAND()
        LIMIT 1;
        
        -- Verifica se a combinação já existe
        SELECT COUNT(*) INTO exists_count
        FROM alunos_has_disciplinas
        WHERE alunos_matricula_alunos = aluno_id
            AND disciplinas_codigo_disciplina = disciplina_id
            AND disciplinas_Materias_codigo_materia = materia_id;
        
        -- Insere a combinação apenas se ela não existir
        IF exists_count = 0 THEN
            INSERT INTO alunos_has_disciplinas (
                alunos_matricula_alunos,
                disciplinas_codigo_disciplina,
                disciplinas_Materias_codigo_materia
            )
            VALUES (
                aluno_id,
                disciplina_id,
                materia_id
            );
            
            SET Id = Id + 1;
        END IF;
    END WHILE;
END$$

-- Procedure povoar_coordenadores
CREATE DEFINER=root@localhost PROCEDURE povoar_coordenadores(IN num_coord INT)
BEGIN
    DECLARE Id INT; 
    SET Id = 1;
    WHILE Id <= num_coord DO
        INSERT INTO coordenadores(matricula_cordenador, nome, Professores_matricula_professores) VALUES (
            Id + 1000,
            CONCAT('Coordenador - ', CAST(Id AS CHAR)),
            (SELECT matricula_professores FROM professores ORDER BY RAND() LIMIT 1)
        );
        SET Id = Id + 1;
    END WHILE;
END$$

-- Procedure povoar_cursos
CREATE DEFINER=root@localhost PROCEDURE povoar_cursos(IN num_cursos INT)
BEGIN
    DECLARE Id INT;
    SET Id = 1;
    WHILE Id <= num_cursos DO
        INSERT INTO cursos(codigo_cursos, nome, Coordenadores_matricula_cordenador) VALUES (
            CONCAT(Id + 100),
            CONCAT('Curso - ', CAST(Id AS CHAR)),
            (SELECT matricula_cordenador FROM coordenadores ORDER BY RAND() LIMIT 1)
        );
        SET Id = Id + 1;
    END WHILE;
END$$

-- Procedure povoar_disciplinas
CREATE DEFINER=root@localhost PROCEDURE povoar_disciplinas(IN num_dis INT)
BEGIN
    DECLARE Id INT;
    SET Id = 1;
    WHILE Id <= num_dis DO
        INSERT INTO disciplinas(codigo_disciplina, nome, Materias_codigo_materia, Professores_matricula_professores) VALUES (
            CONCAT(Id + 100),
            CONCAT('Disciplina - ', CAST(Id AS CHAR)),
            (SELECT codigo_materia FROM materias ORDER BY RAND() LIMIT 1),
            (SELECT matricula_professores FROM professores ORDER BY RAND() LIMIT 1)
        );
        SET Id = Id + 1;
    END WHILE;
END$$

-- Procedure povoar_email
CREATE DEFINER=root@localhost PROCEDURE povoar_email(IN num_email INT)
BEGIN
    DECLARE Id INT;
    SET Id = 1;
    WHILE Id <= num_email DO
        INSERT INTO email(email, alunos_matricula_alunos) VALUES (
            CONCAT('aluno', CAST(Id AS CHAR), '@exemplo.com'),
            (SELECT matricula_alunos FROM alunos ORDER BY RAND() LIMIT 1)
        );
        SET Id = Id + 1;
    END WHILE;
END$$

-- Procedure povoar_materias
CREATE DEFINER=root@localhost PROCEDURE povoar_materias(IN num_mat INT)
BEGIN
    DECLARE Id INT;
    SET Id = 1;
    WHILE Id <= num_mat DO
        INSERT INTO materias(codigo_materia, nome) VALUES (
            CONCAT(Id + 100),
            CONCAT('Materia - ', CAST(Id AS CHAR))
        );
        SET Id = Id + 1;
    END WHILE;
END$$

-- Procedure povoar_professores
CREATE DEFINER=root@localhost PROCEDURE povoar_professores(IN num_prof INT)
BEGIN
    DECLARE Id INT;
    SET Id = 1;
    WHILE Id <= num_prof DO
        INSERT INTO professores(matricula_professores, nome, email) VALUES (
            Id + 1000,
            CONCAT('Professor - ', CAST(Id AS CHAR)),
            CONCAT('prof', CAST(Id AS CHAR), '@exemplo.com')
        );
        SET Id = Id + 1;
    END WHILE;
END$$

DELIMITER ;