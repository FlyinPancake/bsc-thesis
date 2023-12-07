#!/bin/env python3

import dataclasses
import json
from pathlib import Path
import time
from datetime import datetime
from pprint import pprint
from typing import TYPE_CHECKING

from kube import get_cluster_name
from postgres_benchmark import (
    get_master_node_ip,
    get_master_node_lb_ip,
    get_password_secret,
    initialize_db,
    pgbench,
)

from alive_progress import alive_bar, alive_it

if TYPE_CHECKING:
    from postgres_benchmark import PostgresCredentials


def do_test(
    scale: int,
    master_node_ip: str,
    master_node_port: int,
    replica_node_ip: str,
    replica_node_port: int,
    creds: "PostgresCredentials",
):
    results = dict()

    # Initialize the database with 10_000 tellers and 10_000_000 accounts
    with alive_bar() as bar:
        initialize_result = initialize_db(
            scale, master_node_ip, master_node_port, creds
        )
        bar()

    results["initialize"] = dataclasses.asdict(initialize_result)

    # Run pgbench with 10 clients, 1 thread per client, and 1000 transactions per client
    results["read-write"] = {}
    for i in alive_it(range(10)):
        start_time = time.time()
        bench_result = pgbench(
            int(scale / 10), 1, 1000, master_node_ip, master_node_port, creds
        )
        results["read-write"][i] = dataclasses.asdict(bench_result)
        results["read-write"][i]["time"] = time.time() - start_time

    results["read-only"] = {}
    for i in alive_it(range(10)):
        start_time = time.time()
        bench_result = pgbench(
            int(scale / 2),
            1,
            1000,
            replica_node_ip,
            replica_node_port,
            creds,
            select_only=True,
        )
        results["read-only"][i] = dataclasses.asdict(bench_result)
        results["read-only"][i]["time"] = time.time() - start_time
    file = Path(__file__)
    test_name = (
        f"{get_cluster_name()}_postgres_test_{scale}_{datetime.now().isoformat()}.json"
    )
    # file / ".." / "test_results" / test_name
    with open(test_name, "w") as f:
        json.dump(results, f, indent=4)


if __name__ == "__main__":
    # Get the IP and port of the master node and the replica node
    master_node_ip, master_node_port = get_master_node_ip("test-postgres-main")
    master_node_ip = "localhost"
    replica_node_ip, replica_node_port = get_master_node_ip("test-postgres-replica")
    replica_node_ip = "localhost"
    # Get the credentials for the test user
    creds = get_password_secret("test_user", "test_postgres")
    # master_node_ip = "10.1.65.102"
    test_scales = [10, 20, 50, 100, 200]
    for scale in test_scales:
        print(f"🧪 Running test with scale {scale}")
        do_test(
            master_node_ip=master_node_ip,
            master_node_port=master_node_port,
            creds=creds,
            replica_node_port=replica_node_port,
            replica_node_ip=replica_node_ip,
            scale=scale,
        )
