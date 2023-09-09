#if canImport(Glibc)
@_exported import Glibc
#elseif canImport(Darwin)
@_exported import Darwin.C
#elseif canImport(WASILibc)
@_exported import WASILibc
#elseif canImport(ucrt)
@_exported import ucrt
#else
#error("Unsupported platform: Cannot find C stdlib")
#endif
