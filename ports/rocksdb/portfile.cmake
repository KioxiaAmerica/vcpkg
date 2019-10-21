set(VCPKG_LIBRARY_LINKAGE static)
include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KioxiaAmerica/trocksdb
  REF 5aa30de524fdcf0ace1b0fb357c632eec6b71472
  SHA512 6a9fc1b9d2e3aa74b943bc56bc8cf31c15ba1ef6c7a1113768bb95d384978894052a6217edec58ab33eafde79ca72e45a3ce687f24c74fa21a6f23b8898fd62d
  HEAD_REF master
)

file(REMOVE "${SOURCE_PATH}/cmake/modules/Findzlib.cmake")
file(COPY
  "${CMAKE_CURRENT_LIST_DIR}/Findlz4.cmake"
  "${CMAKE_CURRENT_LIST_DIR}/Findsnappy.cmake"
  "${CMAKE_CURRENT_LIST_DIR}/Findzstd.cmake"
  DESTINATION "${SOURCE_PATH}/cmake/modules"
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" WITH_MD_LIBRARY)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ROCKSDB_DISABLE_INSTALL_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ROCKSDB_DISABLE_INSTALL_STATIC_LIB)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    "lz4"     WITH_LZ4
    "snappy"  WITH_SNAPPY
    "zlib"    WITH_ZLIB
    "zstd"    WITH_ZSTD
    "tbb"     WITH_TBB
  INVERTED_FEATURES
    "tbb"     CMAKE_DISABLE_FIND_PACKAGE_TBB
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
  -DWITH_GFLAGS=0
  -DWITH_TESTS=OFF
  -DUSE_RTTI=1
  -DROCKSDB_INSTALL_ON_WINDOWS=ON
  -DFAIL_ON_WARNINGS=OFF
  -DWITH_MD_LIBRARY=${WITH_MD_LIBRARY}
  -DPORTABLE=ON
  -DCMAKE_DEBUG_POSTFIX=d
  -DROCKSDB_DISABLE_INSTALL_SHARED_LIB=${ROCKSDB_DISABLE_INSTALL_SHARED_LIB}
  -DROCKSDB_DISABLE_INSTALL_STATIC_LIB=${ROCKSDB_DISABLE_INSTALL_STATIC_LIB}
  -DCMAKE_DISABLE_FIND_PACKAGE_NUMA=TRUE
  -DCMAKE_DISABLE_FIND_PACKAGE_gtest=TRUE
  -DCMAKE_DISABLE_FIND_PACKAGE_Git=TRUE
  ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/rocksdb)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.Apache DESTINATION ${CURRENT_PACKAGES_DIR}/share/rocksdb RENAME copyright)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${SOURCE_PATH}/LICENSE.leveldb DESTINATION ${CURRENT_PACKAGES_DIR}/share/rocksdb)

vcpkg_copy_pdbs()
