-- Definindo o delimitador para suportar o uso de múltiplos statements
DELIMITER $$

-- Especificando o banco de dados
USE minimundouvv$$

-- Trigger para registrar exclusões de alunos
CREATE TRIGGER trg_alunos_delete
AFTER DELETE ON alunos
FOR EACH ROW
BEGIN
    INSERT INTO log_exclusoes_alunos (matricula, nome, data_exclusao)
    VALUES (OLD.matricula_alunos, OLD.nome, NOW());
END$$

-- Trigger para atualizar o número de alunos em cursos após exclusão de aluno
CREATE TRIGGER trg_alunos_delete_update
AFTER DELETE ON alunos
FOR EACH ROW
BEGIN
    UPDATE cursos
    SET numero_de_alunos = numero_de_alunos - 1
    WHERE codigo_cursos = OLD.cursos_codigo_cursos
        AND Coordenadores_matricula_cordenador = OLD.cursos_Coordenadores_matricula_cordenador;
END$$

-- Trigger para atualizar o número de alunos em cursos após inserção de aluno
CREATE TRIGGER trg_alunos_insert
AFTER INSERT ON alunos
FOR EACH ROW
BEGIN
    UPDATE cursos
    SET numero_de_alunos = numero_de_alunos + 1
    WHERE codigo_cursos = NEW.cursos_codigo_cursos
        AND Coordenadores_matricula_cordenador = NEW.cursos_Coordenadores_matricula_cordenador;
END$$

-- Trigger para atualizar a data de última modificação antes de uma atualização de aluno
CREATE TRIGGER trg_alunos_update
BEFORE UPDATE ON alunos
FOR EACH ROW
SET NEW.data_ultima_modificacao = NOW()$$

-- Restaurando o delimitador padrão
DELIMITER ;