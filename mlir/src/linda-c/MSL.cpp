#include "linda/MSL.h"
#include "linda-c/MSL.h"

#include "mlir/CAPI/IR.h"
#include "mlir/CAPI/Support.h"

#include <cstdlib>
#include <cstring>
#include <string>

using namespace mlir;

char *mlirTranslateModuleToMSL(MlirModule module) {
  std::string buffer;
  llvm::raw_string_ostream os(buffer);

  if (failed(linda::translateToMSL(unwrap(module), os)))
    return nullptr;

  os.flush();
  char *result = static_cast<char*>(std::malloc(buffer.size() + 1));
  if (!result) return nullptr;
  std::memcpy(result, buffer.c_str(), buffer.size() + 1);
  return result;
}
