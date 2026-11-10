add_mlir_dialect_library(MLIRLinda
  Dialect.cpp

  PARTIAL_SOURCES_INTENDED

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


add_mlir_conversion_library(MLIRLindaPasses
  Passes.cpp

  PARTIAL_SOURCES_INTENDED

  DEPENDS
    LindaIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRLinda
    MLIRAffineDialect
    MLIRArithDialect
    MLIRPass
    MLIRTransformUtils
)

target_include_directories(MLIRLindaPasses
  PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
)
