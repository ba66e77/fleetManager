if [ -f '.env' ]; then
    set -a
    source '.env'
    set +a
    echo "Read .env file"
else
    echo "No .env file found"
fi

duckdb -s ".read 'db_setup.sql'"
echo "Pipeline run complete"
