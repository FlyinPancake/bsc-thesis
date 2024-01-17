#!/usr/bin/env python3

import json
import logging
from pprint import pprint
import subprocess

from datetime import datetime
from typing import TYPE_CHECKING, Dict

if TYPE_CHECKING:
    from datetime import timedelta


class PodStartupError(Exception):
    def __init__(self, message):
        self.message = message


def run_kubectl(cmd: str) -> Dict:
    command = f"kubectl {cmd}".split(" ")

    try:
        result = subprocess.run(command, capture_output=True, check=True)

        loaded: Dict = json.loads(result.stdout)
        return loaded

    except subprocess.CalledProcessError as e:
        raise PodStartupError(f"Error running kubectl command: {e}")


def get_pod(pod_name: str):
    return run_kubectl(f"get pod {pod_name} -o json")


def parse_kubernetes_time(time: str) -> "datetime":
    return datetime.fromisoformat(time[:-1])


def get_startup_time(pod_data: Dict) -> "timedelta":
    conditions = pod_data["status"]["conditions"]
    scheduled_event = [
        event
        for event in conditions
        if event["type"] == "PodScheduled" and event["status"] == "True"
    ][0]
    scheduled_time = parse_kubernetes_time(scheduled_event["lastTransitionTime"])
    ready_event = [
        event
        for event in conditions
        if event["type"] == "Ready" and event["status"] == "True"
    ][0]
    ready_time = parse_kubernetes_time(ready_event["lastTransitionTime"])
    return ready_time - scheduled_time


def get_postgres_operator_pods() -> Dict:
    return run_kubectl("get pods -l application=spilo -o json")


logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

log = logging.getLogger(__name__)

if __name__ == "__main__":
    postgres_pods = get_postgres_operator_pods()
    print(
        json.dumps(
            {
                pod["metadata"]["name"]: get_startup_time(pod).total_seconds()
                for pod in postgres_pods["items"]
            }
        )
    )
