act:
    #!/bin/bash
    cd {{ justfile_directory() }}
    gh act -s GITHUB_TOKEN=$(op read 'op://Personal/GitHub Personal Access Token/token') -e .act_event.json
    cd {{ invocation_directory() }}