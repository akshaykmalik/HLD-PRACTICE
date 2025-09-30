-- ALTER USER 'appuser'@'%' IDENTIFIED WITH mysql_native_password BY 'apppass';

DROP USER IF EXISTS 'repl'@'%';
CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY 'repl_password';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
-- GRANT REPLICATION CLIENT ON *.* TO 'repl'@'%';

FLUSH PRIVILEGES;
