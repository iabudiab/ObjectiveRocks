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
  s.preserve_paths = 'rocksdb_src/rocksdb/**/*'
  
  #### CLEAN SOURCE
  
  # After downloading the pod, This generates 
  # a rocksdb_src directory from the original 
  # source submodule, purges all extraneaous 
  # files, and then deletes the original source.
  
  s.prepare_command = 'sh clean_rocksdb_source.sh'
  
  #### SHARED SOURCE FILES

  s.source_files =
    'rocksdb_src/rocksdb/**/*',
    'Code/*.{h,mm,cpp}'
  
  # All headers not specifically scoped to `public` or `private`
  # will default to being in the `project_header_files` section.
   
  s.private_header_files = 
    'Code/*Callback*.h',
    'Code/*Private*.h',
    'Code/RocksDBError.h',
    'Code/RocksDBSlice.h'
    
  #### macOS HEADERS
  
  s.osx.public_header_files = 
    'Code/RocksDB.h',
    'Code/RocksDBBackupEngine.h',
    'Code/RocksDBBackupInfo.h',
    'Code/RocksDBBlockBasedTableOptions.h',
    'Code/RocksDBCache.h',
    'Code/RocksDBCheckpoint.h',
    'Code/RocksDBColumnFamily.h',
    'Code/RocksDBColumnFamilyDescriptor.h',
    'Code/RocksDBColumnFamilyMetadata.h',
    'Code/RocksDBColumnFamilyOptions.h',
    'Code/RocksDBCompactRangeOptions.h',
    'Code/RocksDBComparator.h',
    'Code/RocksDBCuckooTableOptions.h',
    'Code/RocksDBDatabaseOptions.h',
    'Code/RocksDBEnv.h',
    'Code/RocksDBFilterPolicy.h',
    'Code/RocksDBIndexedWriteBatch.h',
    'Code/RocksDBIterator.h',
    'Code/RocksDBMemTableRepFactory.h',
    'Code/RocksDBMergeOperator.h',
    'Code/RocksDBOptions.h',
    'Code/RocksDBPlainTableOptions.h',
    'Code/RocksDBPrefixExtractor.h',
    'Code/RocksDBProperties.h',
    'Code/RocksDBRange.h',
    'Code/RocksDBReadOptions.h',
    'Code/RocksDBSnapshot.h',
    'Code/RocksDBSnapshotUnavailable.h',
    'Code/RocksDBStatistics.h',
    'Code/RocksDBStatisticsHistogram.h',
    'Code/RocksDBTableFactory.h',
    'Code/RocksDBThreadStatus.h',
    'Code/RocksDBWriteBatch.h',
    'Code/RocksDBWriteBatchIterator.h',
    'Code/RocksDBWriteOptions.h'
    
  s.osx.exclude_files = 
    'rocksdb_src/rocksdb/tools/sst_dump_tool*'
    
  #### iOS SOURCE & HEADERS
    
  s.ios.exclude_files = 
    'Code/RocksDBColumnFamilyMetadata*.{h,mm}',
    'Code/RocksDBIndexedWriteBatch*.{h,mm}',
    'Code/RocksDBWriteBatchIterator*.{h,mm}',
    'Code/RocksDBThreadStatus*.{h,mm}',
    'Code/RocksDBPlainTableOptions*.{h,mm}',
    'Code/RocksDBCuckooTableOptions*.{h,mm}',
    'Code/RocksDBProperties*.{h,mm}',
    'Code/RocksDBCheckpoint*.{h,mm}',
    'Code/RocksDBStatistics*.{h,mm}',
    'Code/RocksDBStatisticsHistogram*.{h,mm}',
    'Code/RocksDBBackupEngine*.{h,mm}',
    'Code/RocksDBBackupInfo*.{h,mm}'
  
  s.ios.public_header_files = 
    'Code/RocksDB.h',
    'Code/RocksDBBlockBasedTableOptions.h',
    'Code/RocksDBCache.h',
    'Code/RocksDBColumnFamily.h',
    'Code/RocksDBColumnFamilyDescriptor.h',
    'Code/RocksDBColumnFamilyOptions.h',
    'Code/RocksDBCompactRangeOptions.h',
    'Code/RocksDBComparator.h',
    'Code/RocksDBDatabaseOptions.h',
    'Code/RocksDBEnv.h',
    'Code/RocksDBFilterPolicy.h',
    'Code/RocksDBIterator.h',
    'Code/RocksDBMemTableRepFactory.h',
    'Code/RocksDBMergeOperator.h',
    'Code/RocksDBOptions.h',
    'Code/RocksDBPrefixExtractor.h',
    'Code/RocksDBRange.h',
    'Code/RocksDBReadOptions.h',
    'Code/RocksDBSnapshot.h',
    'Code/RocksDBSnapshotUnavailable.h',
    'Code/RocksDBTableFactory.h',
    'Code/RocksDBWriteBatch.h',
    'Code/RocksDBWriteOptions.h'
  
  #### CONFIGS

  shared_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'NDEBUG=1 OS_MACOSX=1 ROCKSDB_PLATFORM_POSIX=1 ROCKSDB_LIB_IO_POSIX=1' }
  framework_shared_xconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/rocksdb_src/rocksdb" "${PODS_TARGET_SRCROOT}/rocksdb_src/rocksdb/include"',
    'LIBRARY_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/rocksdb_src/rocksdb"',
    'GCC_INPUT_FILETYPE' => 'sourcecode.cpp.objcpp',
    'GCC_C_LANGUAGE_STANDARD' => 'gnu99',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++11'
  }
  s.pod_target_xcconfig = shared_xcconfig.merge(framework_shared_xconfig)
  s.user_target_xcconfig = shared_xcconfig

  shared_osx_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'ROCKSDB_USING_THREAD_STATUS=1' }
  s.osx.pod_target_xcconfig = shared_osx_xcconfig
  s.osx.user_target_xcconfig = shared_osx_xcconfig

  shared_ios_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'ROCKSDB_LITE=1 IOS_CROSS_COMPILE=1 NROCKSDB_THREAD_STATUS=1' }
  s.ios.pod_target_xcconfig = shared_ios_xcconfig
  s.ios.user_target_xcconfig = shared_ios_xcconfig

end
