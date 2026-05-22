


-- ============================================================
-- PART 5: CREATE USERS
-- 1 Admin  + 5 Read-only users
-- ============================================================

-- Admin user (full access)
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hospital_admin')
    CREATE LOGIN hospital_admin WITH PASSWORD = 'Admin@Hospital2024!';
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hospital_admin')
    CREATE USER hospital_admin FOR LOGIN hospital_admin;
GO
ALTER ROLE db_owner ADD MEMBER hospital_admin;
GO

-- Read-only users
DECLARE @i INT = 1;
WHILE @i <= 5
BEGIN
    DECLARE @login NVARCHAR(50) = 'hospital_user0' + CAST(@i AS NVARCHAR);
    DECLARE @pwd   NVARCHAR(50) = 'ReadOnly@' + CAST(@i AS NVARCHAR) + '2024!';

    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @login)
        EXEC('CREATE LOGIN ' + @login + ' WITH PASSWORD = ''' + @pwd + '''');

    IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @login)
        EXEC('CREATE USER ' + @login + ' FOR LOGIN ' + @login);

    EXEC('ALTER ROLE db_datareader ADD MEMBER ' + @login);

    SET @i = @i + 1;
END
GO

-- Confirm users created
SELECT name, type_desc, create_date
FROM sys.database_principals
WHERE name LIKE 'hospital%'
ORDER BY name;
GO
