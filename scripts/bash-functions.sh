#!/bin/bash

function hkust::hpc::doc::hash_rename_file() {
  local category file dirname basename ext title hash
  if [ ! $# -eq 2 ]; then
    echo "Usage: hash_rename_file [category] file"
    return 1
  fi
  category=$1
  file=$(realpath $2)
  dirname=$(dirname $file)
  basename=$(basename $file)
  ext="${basename##*.}"
  title="$(head -n1 $file | cut -c1-32 | tr -d '\n' | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '-')"
  hash="$(head $file | md5sum | head -c 32 | xxd -r -p | base64 | tr '+/' '-_' | head -c 4)"
  mv "$file" "$dirname/$category-$title-$hash.$ext"
}

alias hash_rename_file='hkust::hpc::doc::hash_rename_file'
