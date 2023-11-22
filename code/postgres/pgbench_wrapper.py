#!/usr/bin/env python3

import argparse
import logging
import os
import sys
import subprocess
from pprint import pprint

parser = argparse.ArgumentParser(description="pgbench wrapper")
parser.add_argument("--init", "-i", action="store_true", help="Initialize database")
parser.add_argument("--host", "-H", help="Database host")
parser.add_argument("--port", "-p", default=5432, help="Database port")
parser.add_argument("--user", "-U", help="Database user")
parser.add_argument("--password", "-P", help="Database password")
parser.add_argument("--database", "-d", help="Database name")


if __name__ == "__main__":
    logging.info("Started pgbench wrapper")
    args = parser.parse_args()
    os.environ["PGHOST"] = args.host
    os.environ["PGPORT"] = str(args.port)
    os.environ["PGUSER"] = args.user
    os.environ["PGPASSWORD"] = args.password
    os.environ["PGDATABASE"] = args.database
    if args.init:
        logging.info("Initializing database")
        process = subprocess.Popen(["pgbench", "-i", "-s 10"])
        (out, err) = process.communicate()
        pprint(out)
        pprint(err)
        sys.exit(0)

    logging.info("Running pgbench")
    proc = subprocess.Popen(["pgbench", "-c 10", "-j 2", "-T 60"])
    (out, err) = proc.communicate()
    pprint(out)
