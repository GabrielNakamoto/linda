import Foundation
import Metal

private final class Runtime {
  let device: any MTLDevice
  let queue: any MTL4CommandQueue
  let event: any MTLSharedEvent

  init() throws {
    guard let device = MTLCreateSystemDefaultDevice(),
          let queue = device.makeMTL4CommandQueue(),
          let event = device.makeSharedEvent()
    else {
      throw RuntimeError.initializationFailed;
    }

    self.device = device;
    self.queue = queue;
    self.event = event;
  }
}

private enum RuntimeError: Error {
  case initializationFailed
}

@c(lmrb_runtime_create)
public func runtime_create() -> UnsafeMutableRawPointer? {
  do {
    let runtime = try Runtime();
    return Unmanaged.passRetained(runtime).toOpaque();
  } catch {
    return nil;
  }
}

@c(lmrb_runtime_destroy)
public func runtime_destroy(_ pointer: UnsafeMutableRawPointer?) {
  guard let pointer else { return }
  Unmanaged<Runtime>.fromOpaque(pointer).release()
}

private func runtime(_ pointer: UnsafeMutableRawPointer) -> Runtime {
  Unmanaged<Runtime>.fromOpaque(pointer).takeUnretainedValue()
}
