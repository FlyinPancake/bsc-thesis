#!/bin/env python3

import dataclasses
import json
import time
from datetime import datetime
from pprint import pprint

from postgres_benchmark import (
    get_master_node_ip,
    get_password_secret,
    initialize_db,
    pgbench,
)
from kube import get_cluster_name

if __name__ == "__main__":
    # Get the IP and port of the master node
    master_node_ip, master_node_port = get_master_node_ip("test-postgres")
    # Get the credentials for the test user
    creds = get_password_secret("test_user", "test_postgres")
    results = dict()
    # Initialize the database with 10_000 tellers and 10_000_000 accounts
    initialize_result = initialize_db(200, master_node_ip, master_node_port, creds)
    pprint(initialize_result)
    results["initialize"] = dataclasses.asdict(initialize_result)

    # Run pgbench with 10 clients, 1 thread per client, and 1000 transactions per client
    results["read-write"] = {}
    for i in range(10):
        start_time = time.time()
        bench_result = pgbench(10, 1, 1000, master_node_ip, master_node_port, creds)
        # pprint(bench_result)
        results["read-write"][i] = dataclasses.asdict(bench_result)
        results["read-write"][i]["time"] = time.time() - start_time

    results["read-only"] = {}
    replica_node_ip, replica_node_port = get_master_node_ip("test-postgres-repl")
    for i in range(10):
        start_time = time.time()
        bench_result = pgbench(
            10, 1, 1000, master_node_ip, master_node_port, creds, select_only=True
        )
        results["read-only"][i] = dataclasses.asdict(bench_result)
        results["read-only"][i]["time"] = time.time() - start_time

    test_name = f"../test_results/{get_cluster_name()}_postgres_test_{datetime.now().isoformat()}"
    with open(f"{test_name}.json", "w") as f:
        json.dump(results, f, indent=4)
