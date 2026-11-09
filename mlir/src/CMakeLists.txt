add_mlir_dialect_library(MLIRLinda
  Dialect.cpp
  DEPENDS
    LindaIncGen

  LINK_LIBS PUBLIC
    MLIRIR
)

target_include_directories(MLIRLinda
  PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
)
