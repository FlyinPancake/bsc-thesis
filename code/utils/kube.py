import json
import subprocess
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import Dict


def run_kubectl(cmd: str) -> "Dict":
    command = f"kubectl {cmd} -ojson".split(" ")

    try:
        result = subprocess.run(command, capture_output=True, check=True)

        loaded: Dict = json.loads(result.stdout)
        return loaded

    except subprocess.CalledProcessError as e:
        raise Exception(f"Error running kubectl command: {e}")


def get_cluster_name() -> str:
    try:
        result = subprocess.run(
            "kubectl config current-context".split(" "),
            capture_output=True,
            check=True,
        )
        cluster_name = result.stdout.decode("utf-8").strip()
        if cluster_name.startswith("vcluster_"):
            return "_".join(cluster_name.split("_")[0:1])
        if cluster_name == "default":
            return "host_cluster"
        return cluster_name
    except subprocess.CalledProcessError as e:
        raise Exception(f"Error running kubectl command: {e}")
