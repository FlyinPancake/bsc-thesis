#!/bin/env python3

from pprint import pprint
from unittest import result
from postgres_benchmark import (
    get_password_secret,
    initialize_db,
    get_master_node_ip,
    pgbench,
)

if __name__ == "__main__":
    # Get the IP and port of the master node
    master_node_ip, master_node_port = get_master_node_ip("test-postgres")
    # Get the credentials for the test user
    creds = get_password_secret("test_user", "test_postgres")

    # Initialize the database with 10_000 tellers and 10_000_000 accounts
    initialize_result = initialize_db(100, master_node_ip, master_node_port, creds)
    pprint(initialize_result)

    # Run pgbench with 10 clients, 1 thread per client, and 1000 transactions per client
    results = {}
    for i in range(10):
        bench_result = pgbench(10, 1, 1000, master_node_ip, master_node_port, creds)
        # pprint(bench_result)
        results[i] = bench_result.tps
    pprint(results)

    results = {}
    replica_node_ip, replica_node_port = get_master_node_ip("test-postgres-repl")
    for i in range(10):
        bench_result = pgbench(
            10, 1, 1000, master_node_ip, master_node_port, creds, select_only=True
        )
        results[i] = bench_result.tps
    pprint(results)
