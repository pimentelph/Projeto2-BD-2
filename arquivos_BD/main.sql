-- Limpando os dados das tabelas

set foreign_key_checks=0;
TRUNCATE TABLE minimundouvv.alunos_has_disciplinas;
TRUNCATE TABLE minimundouvv.email;
TRUNCATE TABLE minimundouvv.disciplinas;
TRUNCATE TABLE minimundouvv.materias;
TRUNCATE TABLE minimundouvv.alunos;
TRUNCATE TABLE minimundouvv.cursos;
TRUNCATE TABLE minimundouvv.coordenadores;
TRUNCATE TABLE minimundouvv.professores;
set foreign_key_checks=1;

-- Limpando os indices e realocando os mesmos

CALL Limparindices();
CALL AdicionarIndices();

-- Procedures para povoar as tabelas
CALL povoar_professores(20);
CALL povoar_materias(30);
CALL povoar_coordenadores(5);
CALL povoar_cursos(5);
CALL povoar_alunos(140);
CALL povoar_disciplinas(15);
CALL povoar_alunos_has_disciplinas(140);
CALL povoar_email(160);