#!/bin/bash

dest_dir="/mnt/f/notes/terraform/ziptool-backups/"
tar_name="terraform"

set -e
tar -czf ${tar_name}-$(date +%Y-%M-%H%M).tar.gz *
echo "created tar.gz"
ls | grep tar.gz | xargs -I {} cp {} ${dest_dir}
echo "copied tar.gz to notes"
echo "deleting tar.gz after copy finished"
ls | grep tar.gz | xargs rm -rf

