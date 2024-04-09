-- Login to MariaDB shell as root
mysql -u root -p

-- Create a new user
CREATE USER 'deli'@'localhost' IDENTIFIED BY 'rpass';

-- Grant only SELECT, INSERT, UPDATE, DELETE privileges to the user on a specific database
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'deli'@'localhost';

-- Make sure to reload all the privileges
FLUSH PRIVILEGES;

-- Query the user table in the mysql database
SELECT User, Host FROM mysql.user;
