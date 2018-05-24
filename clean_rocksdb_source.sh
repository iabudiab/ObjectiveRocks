#!/bin/bash

# Creates a copy of the `rocksdb` submodule dir and cleans it
# of all extraneous files so the actual sources can be easily 
# included and updated in the frameworks.

# Submodule source directory
SRC=rocksdb

# Cleaned container directory
SRC_CLEANED=rocksdb_src

# Cleaned source copy
SRC_COPY=$PWD/$SRC_CLEANED/$SRC

# Return early if already generated
if [ -d $SRC_COPY ]; then
  exit 0
fi

# Clean everything
rm -rf $PWD/$SRC_CLEANED
mkdir $PWD/$SRC_CLEANED

# Make a rocksdb directory within 
# the SRC_COPY directory
cp -R $PWD/$SRC $SRC_COPY

# Delete unused folders
rm -rf $SRC_COPY/.git
rm -rf $SRC_COPY/buckifier
rm -rf $SRC_COPY/cmake
rm -rf $SRC_COPY/docs
rm -rf $SRC_COPY/examples
rm -rf $SRC_COPY/hdfs
rm -rf $SRC_COPY/java
rm -rf $SRC_COPY/port/win
rm -rf $SRC_COPY/third-party/gtest-1.7.0
rm -rf $SRC_COPY/utilities/cassandra

# Delete any files that aren't source files
find $SRC_COPY -not -name '*.cc' -type f -not -name '*.cpp' -type f -not -name '*.c' -type f -not -name '*.h' -type f -delete

# Delete any test files
find $SRC_COPY -name '*test*' -type f -delete
find $SRC_COPY -name '*mock*' -type f -delete

# Delete any additional files we don't need
rm -f $SRC_COPY/db/c.cc
rm -f $SRC_COPY/include/rocksdb/c.h
rm -f $SRC_COPY/port/dirent.h
rm -f $SRC_COPY/env/env_hdfs.cc
find $SRC_COPY/tools -not -name 'sst_dump_tool*' -type f -delete
find $SRC_COPY/util -name '*ppc*' -type f -delete
find $SRC_COPY -name '*bench*' -type f -delete
find $SRC_COPY -name '*rados*' -type f -delete

# Delete any empty folders
find $SRC_COPY -type d -empty -delete

# Create build_version.cc from the original source
ROCKSDB_GIT_DIR=$PWD/$SRC/.git
OUTFILE=$SRC_COPY/util/build_version.cc
GIT_SHA=""
if command -v git >/dev/null 2>&1; then
  GIT_SHA=$(git --git-dir="$ROCKSDB_GIT_DIR" rev-parse HEAD 2>/dev/null)
fi
cat > "${OUTFILE}" <<EOF
  #include "build_version.h"
  const char* rocksdb_build_git_sha = "rocksdb_build_git_sha:${GIT_SHA}";
  const char* rocksdb_build_git_datetime = "rocksdb_build_git_datetime:$(date)";
  const char* rocksdb_build_compile_date = "$(date)"; 
EOF

# Get rid of the original source submodule
rm -rf $PWD/$SRC