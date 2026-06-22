IF OBJECT_ID('dbo.INTAKES', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.INTAKES
    (
        intake_id varchar(20) NOT NULL PRIMARY KEY,
        intake_name varchar(60) NOT NULL,
        intake_month date NOT NULL,
        status varchar(20) NULL
    );
END;

IF COL_LENGTH('dbo.ACADEMIC_SESSIONS', 'intake_id') IS NULL
    EXEC('ALTER TABLE dbo.ACADEMIC_SESSIONS ADD intake_id varchar(20) NULL');
IF COL_LENGTH('dbo.ACADEMIC_SESSIONS', 'registration_start') IS NULL
    EXEC('ALTER TABLE dbo.ACADEMIC_SESSIONS ADD registration_start date NULL');
IF COL_LENGTH('dbo.ACADEMIC_SESSIONS', 'registration_end') IS NULL
    EXEC('ALTER TABLE dbo.ACADEMIC_SESSIONS ADD registration_end date NULL');
IF COL_LENGTH('dbo.ACADEMIC_SESSIONS', 'add_drop_end') IS NULL
    EXEC('ALTER TABLE dbo.ACADEMIC_SESSIONS ADD add_drop_end date NULL');
IF COL_LENGTH('dbo.STUDENTS', 'intake_id') IS NULL
    EXEC('ALTER TABLE dbo.STUDENTS ADD intake_id varchar(20) NULL');

INSERT INTO dbo.INTAKES (intake_id, intake_name, intake_month, status)
SELECT DISTINCT
    UPPER(LEFT(DATENAME(MONTH, start_date), 3)) + CONVERT(varchar(4), YEAR(start_date)),
    UPPER(DATENAME(MONTH, start_date)) + ' ' + CONVERT(varchar(4), YEAR(start_date)),
    DATEFROMPARTS(YEAR(start_date), MONTH(start_date), 1),
    'ACTIVE'
FROM dbo.ACADEMIC_SESSIONS s
WHERE start_date IS NOT NULL
AND NOT EXISTS
(
    SELECT 1 FROM dbo.INTAKES i
    WHERE i.intake_id = UPPER(LEFT(DATENAME(MONTH, s.start_date), 3)) + CONVERT(varchar(4), YEAR(s.start_date))
);

EXEC('UPDATE dbo.ACADEMIC_SESSIONS
SET intake_id=UPPER(LEFT(DATENAME(MONTH,start_date),3))+CONVERT(varchar(4),YEAR(start_date))
WHERE intake_id IS NULL AND start_date IS NOT NULL');

EXEC('UPDATE dbo.ACADEMIC_SESSIONS
SET registration_start=DATEADD(day,-28,start_date),
registration_end=DATEADD(day,-1,start_date),
add_drop_end=DATEADD(day,7,start_date)
WHERE registration_start IS NULL OR registration_end IS NULL OR add_drop_end IS NULL');

EXEC('UPDATE s SET intake_id=a.intake_id
FROM dbo.STUDENTS s
OUTER APPLY
(
    SELECT TOP 1 x.intake_id
    FROM dbo.ACADEMIC_SESSIONS x
    WHERE s.session=x.academic_year+'' ''+x.semester
    ORDER BY x.start_date
) a
WHERE s.intake_id IS NULL AND a.intake_id IS NOT NULL');
