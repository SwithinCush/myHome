#!/usr/bin/env python

import yaml
import argparse
import os

def parse_compose_file(file_path, base_dir):
    """Parses a docker-compose file, handling includes."""
    with open(file_path, 'r') as f:
        compose_data = yaml.safe_load(f)

    if 'include' in compose_data:
        for include_path in compose_data['include']:
            include_file = os.path.join(base_dir, include_path)
            included_data = parse_compose_file(include_file, base_dir)
            compose_data.update(included_data)
        del compose_data['include']

    return compose_data

def merge_compose_files(files, base_dir):
    """Merges multiple docker-compose files into one."""
    merged_data = {}

    for file_path in files:
        compose_data = parse_compose_file(file_path, base_dir)
        merged_data.update(compose_data)

    return merged_data

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Merge docker-compose files with includes.')
    parser.add_argument('files', metavar='FILE', nargs='+', help='Compose files to merge.')
    parser.add_argument('-o', '--output', help='Output file', default='merged_compose.yml')

    args = parser.parse_args()
    base_dir = os.path.dirname(args.files[0])
    merged_data = merge_compose_files(args.files, base_dir)

    with open(args.output, 'w') as f:
        yaml.dump(merged_data, f)
