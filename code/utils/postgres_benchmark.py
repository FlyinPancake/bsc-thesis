#!/usr/bin/env python3
from dataclasses import dataclass
import json
import os
import re
import subprocess
from base64 import b64decode
from pprint import pprint
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import Dict, List, Tuple


def run_kubectl(cmd: str) -> "Dict":
    command = f"kubectl {cmd} -ojson".split(" ")

    try:
        result = subprocess.run(command, capture_output=True, check=True)

        loaded: Dict = json.loads(result.stdout)
        return loaded

    except subprocess.CalledProcessError as e:
        raise Exception(f"Error running kubectl command: {e}")


class PostgresCredentials:
    def __init__(self, user: str, password: str):
        self.user = user
        self.password = password

    def __repr__(self):
        return f"PostgresCredentials(user={self.user}, password={self.password})"


def run_pgbench(args: "List[str]", creds: PostgresCredentials):
    command = ["pgbench", *args]
    try:
        # os.environ["PGHOST"] = "localhost"
        # os.environ["PGPORT"] = "5432"
        os.environ["PGUSER"] = creds.user
        os.environ["PGPASSWORD"] = creds.password
        os.environ["PGSSLMODE"] = "require"
        # os.environ["PGDATABASE"] = creds.user
        result = subprocess.run(command, capture_output=True, check=True)
        print(result.stderr.decode("utf-8"))
        return result
    except subprocess.CalledProcessError as e:
        print(e.stderr.decode("utf-8"))
        raise Exception(f"Error running pgbench command: {e}")


def get_password_secret(user: str, operator: str) -> PostgresCredentials:
    secret = run_kubectl(
        f"get secret {user.replace('_', '-')}.{operator.replace('_', '-')}.credentials.postgresql.acid.zalan.do"
    )
    password = b64decode(secret["data"]["password"]).decode("utf-8")
    secret_username = b64decode(secret["data"]["username"]).decode("utf-8")
    if user != secret_username:
        print(f"Username does not match: {user} != {secret_username}")
        raise Exception("Username does not match")
    return PostgresCredentials(user, password)


def get_master_node_ip(postgres_cluster_name: str) -> "Tuple[str, int]":
    # kubectl get pods -o jsonpath={.items..metadata.name} -l application=spilo,cluster-name=acid-minimal-cluster,spilo-role=master -n default
    pod = run_kubectl(f"get svc/{postgres_cluster_name}")
    return (
        "localhost",
        pod["spec"]["ports"][0]["nodePort"],
    )


def get_master_node_lb_ip(postgres_cluster_name: str) -> "Tuple[str, int]":
    # kubectl get pods -o jsonpath={.items..metadata.name} -l application=spilo,cluster-name=acid-minimal-cluster,spilo-role=master -n default
    pod = run_kubectl(f"get svc/{postgres_cluster_name}")
    return (
        pod["status"]["loadBalancer"]["ingress"][0]["ip"],
        pod["spec"]["ports"][0]["nodePort"],
    )


@dataclass
class InitializeDbResult:
    done_in: float
    drop_tables: float
    create_tables: float
    client_side_generate: float
    vacuum: float
    primary_keys: float


def initialize_db(
    scaling: int, ip: str, port: int, creds: PostgresCredentials
) -> InitializeDbResult:
    result = run_pgbench(["-i", "-h", ip, "-p", str(port), "-s", str(scaling)], creds)

    performance_data = result.stderr.decode("utf-8").split("\n")[-2]
    # print(performance_data)
    matches = re.findall(r"(\d+\.\d+) s", performance_data)
    result = InitializeDbResult(
        done_in=float(matches[0]),
        drop_tables=float(matches[1]),
        create_tables=float(matches[2]),
        client_side_generate=float(matches[3]),
        vacuum=float(matches[4]),
        primary_keys=float(matches[5]),
    )
    return result


@dataclass
class PgBenchResult:
    scaling_factor: int
    number_of_clients: int
    number_of_threads: int
    number_of_transactions_per_client: int
    latency_average: float
    initial_connection_time: float
    tps: float


def pgbench(
    clients: int,
    therads_per_client: int,
    transactions: int,
    ip: str,
    port: int,
    creds: PostgresCredentials,
    select_only: bool = False,
) -> PgBenchResult:
    pgbench_args = [
        "-h",
        ip,
        "-p",
        str(port),
        f"--transactions={transactions}",
        f"--jobs={therads_per_client}",
        f"--client={clients}",
    ]
    if select_only:
        pgbench_args.append("--select-only")

    result = (
        run_pgbench(
            pgbench_args,
            creds,
        )
        .stdout.decode("utf-8")
        .split("\n")
    )

    scaling_factor = int(result[2][result[2].find(":") + 1 :])
    number_of_clients = int(result[4][result[4].find(":") + 1 :])
    number_of_threads = int(result[5][result[5].find(":") + 1 :])
    number_of_transactions_per_client = int(result[6][result[6].find(":") + 1 :])
    latency_average = float(result[8][result[8].find("=") + 1 : -2])
    initital_connection_time = float(result[9][result[9].find("=") + 1 : -2])
    tps = float(result[10][result[10].find("=") + 1 : result[10].find("(")])
    return PgBenchResult(
        scaling_factor,
        number_of_clients,
        number_of_threads,
        number_of_transactions_per_client,
        latency_average,
        initital_connection_time,
        tps,
    )


if __name__ == "__main__":
    creds = get_password_secret("test_user", "test_postgres")

    ip, port = get_master_node_ip("test-postgres")
    # result = initialize_db(10, ip, port, creds)
    # pprint(result)
    result = pgbench(10, 2, 10000, ip, port, creds)
    pprint(result)
