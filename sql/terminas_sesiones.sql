SELECT
    pid,
    usename,
    client_addr,
    backend_start,
    state,
    query
FROM
    pg_stat_activity
WHERE
    datname = 'ACME' 
    AND pid <> pg_backend_pid();

SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname = 'ACME'
  AND pid <> pg_backend_pid();