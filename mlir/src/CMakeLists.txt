add_mlir_public_c_api_library(MLIRLindaCAPI
  linda-c/Passes.cpp
  linda-c/Dialect.cpp

  DEPENDS
    LindaIncGen

  LINK_LIBS PUBLIC
    MLIRLinda
    MLIRLindaPasses
    MLIRCAPIIR
)


add_mlir_dialect_library(MLIRLinda
  linda/Dialect.cpp

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
  linda/Passes.cpp

  PARTIAL_SOURCES_INTENDED

  DEPENDS
    LindaIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRLinda
    MLIRAffineDialect
    MLIRArithDialect
    MLIRBufferizationDialect
    MLIRMemRefDialect
    MLIRLLVMDialect
    MLIRPass
    MLIRTransformUtils
    MLIRAffineToStandard
    MLIRArithToLLVM
    MLIRSCFToControlFlow
    MLIRMemRefToLLVM
    MLIRControlFlowToLLVM
    MLIRFuncToLLVM
    MLIRLLVMCommonConversion
    MLIRSCFDialect
    MLIRControlFlowDialect
    MLIRFuncDialect
)

target_include_directories(MLIRLindaPasses
  PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
)
