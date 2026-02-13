what each CSV represents

which SQL file generated it

how to regenerate it (00_run_all.sql)


sqlite3 tx_school_funding.db '.read sql/00_run_all.sql'
sqlite3 tx_school_funding.db '.read sql/00_export_outputs.sql'
# outputs saved to outputs/tables/
