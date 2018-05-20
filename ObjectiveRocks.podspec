Pod::Spec.new do |s|
  s.name              = 'ObjectiveRocks'
  s.version           = '0.8.0'
  s.summary           = 'Objective-C wrapper of RocksDB - A Persistent Key-Value Store for Flash and RAM Storage.'
  s.license           = 'MIT'
  s.homepage          = 'https://github.com/iabudiab/ObjectiveRocks'
  s.author            = 'iabudiab'
  s.social_media_url  = 'https://twitter.com/_iabudiab'
  s.source            = { :git => 'https://github.com/iabudiab/ObjectiveRocks.git', :tag => s.version, :submodules => true }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'

  s.requires_arc = true
  s.preserve_paths = 'rocksdb/**'

  s.prepare_command = <<-CMD
    ROCKSDB_DIR="$PWD/rocksdb/.git"
    OUTFILE="$PWD/rocksdb/util/build_version.cc"
    GIT_SHA=""

    if command -v git >/dev/null 2>&1; then
      GIT_SHA=$(git --git-dir="$ROCKSDB_DIR" rev-parse HEAD 2>/dev/null)
    fi

    cat > "${OUTFILE}" <<EOF
      #include "build_version.h"
      const char* rocksdb_build_git_sha = "rocksdb_build_git_sha:${GIT_SHA}";
      const char* rocksdb_build_git_datetime = "rocksdb_build_git_datetime:$(date)";
      const char* rocksdb_build_compile_date = "$(date)"; 
    EOF
  CMD

  s.source_files =
    'rocksdb/cache/*.{h,cc}',
    'rocksdb/db/*.{h,cc}',
    'rocksdb/env/*.{h,cc}',
    'rocksdb/include/**/*.h',
    'rocksdb/memtable/*.{h,cc}',
    'rocksdb/monitoring/*.{h,cc}',
    'rocksdb/options/*.{h,cc}',
    'rocksdb/port/*.{h,cc}',
    'rocksdb/table/*.{h,cc}',
    'rocksdb/third-party/fbson/*.{h,cc}',
    'rocksdb/third-party/flashcache/*.{h,cc}',
    'rocksdb/util/*.{h,cc}',
    'rocksdb/utilities/**/*.{h,cc}',
    'Code/*.{h,mm,cpp}'

  s.exclude_files = 
    'rocksdb/port/dirent.h',
    'rocksdb/port/win/**',
    'rocksdb/examples/**',
    'rocksdb/hdfs/**',
    'rocksdb/java/**',
    'rocksdb/tools/**',
    'rocksdb/**/*rados*',
    'rocksdb/**/*bench*',
    'rocksdb/**/*mock*',
    'rocksdb/**/*test*'

  s.ios.exclude_files = 
    'Code/RocksDBBackupEngine*.{h,mm}',
    'Code/RocksDBBackupInfo*.{h,mm}',
    'Code/RocksDBCheckpoint*.{h,mm}',
    'Code/RocksDBColumnFamilyMetadata*.{h,mm}',
    'Code/RocksDBCuckooTableOptions*.{h,mm}',
    'Code/RocksDBIndexedWriteBatch*.{h,mm}',
    'Code/RocksDBPlainTableOptions*.{h,mm}',
    'Code/RocksDBProperties*.{h,mm}',
    'Code/RocksDBThreadStatus*.{h,mm}',
    'Code/RocksDBWriteBatchIterator*.{h,mm}'

  s.public_header_files = 'Code/*.h'

  s.private_header_files =
    'rocksdb/cache/*.h',
    'rocksdb/db/*.h',
    'rocksdb/env/*.h',
    'rocksdb/include/**/*.h',
    'rocksdb/memtable/*.h',
    'rocksdb/monitoring/*.h',
    'rocksdb/options/*.h',
    'rocksdb/port/*.h',
    'rocksdb/table/*.h',
    'rocksdb/third-party/fbson/*.h',
    'rocksdb/third-party/flashcache/*.h',
    'rocksdb/util/*.h',
    'rocksdb/utilities/**/*.h',
    'Code/*Callback*.h',
    'Code/*Private*.h',
    'Code/RocksDBError.h',
    'Code/RocksDBSlice.h'

  s.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'NDEBUG=1 OS_MACOSX=1 ROCKSDB_PLATFORM_POSIX=1 ROCKSDB_LIB_IO_POSIX=1',
    'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/ObjectiveRocks/rocksdb" "${PODS_ROOT}/ObjectiveRocks/rocksdb/include"',
    'GCC_INPUT_FILETYPE' => 'sourcecode.cpp.objcpp'
  }

  s.osx.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'ROCKSDB_USING_THREAD_STATUS=1'
  }

  s.ios.pod_target_xcconfig = { 
    'GCC_PREPROCESSOR_DEFINITIONS' => 'ROCKSDB_LITE=1 IOS_CROSS_COMPILE=1 NROCKSDB_THREAD_STATUS=1'
  }

end
