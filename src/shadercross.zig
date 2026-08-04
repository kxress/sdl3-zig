// Generated from SDL3_shadercross/SDL_shadercross.h by sdl-zig-codegen. Do not edit.

const std = @import("std");
const builtin = @import("builtin");
pub const c = @import("sdl3_shadercross_c");
const sdl = @import("sdl");
const root = @This();

/// SDL enumeration `shadercross.IoVarType`.
const IoVarType = enum(c.SDL_ShaderCross_IOVarType) {
    /// Enumeration value `shadercross.IoVarType.unknown`.
    unknown = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_UNKNOWN),
    /// Enumeration value `shadercross.IoVarType.int8`.
    int8 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_INT8),
    /// Enumeration value `shadercross.IoVarType.uint8`.
    uint8 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_UINT8),
    /// Enumeration value `shadercross.IoVarType.int16`.
    int16 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_INT16),
    /// Enumeration value `shadercross.IoVarType.uint16`.
    uint16 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_UINT16),
    /// Enumeration value `shadercross.IoVarType.int32`.
    int32 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_INT32),
    /// Enumeration value `shadercross.IoVarType.uint32`.
    uint32 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_UINT32),
    /// Enumeration value `shadercross.IoVarType.int64`.
    int64 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_INT64),
    /// Enumeration value `shadercross.IoVarType.uint64`.
    uint64 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_UINT64),
    /// Enumeration value `shadercross.IoVarType.float16`.
    float16 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_FLOAT16),
    /// Enumeration value `shadercross.IoVarType.float32`.
    float32 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_FLOAT32),
    /// Enumeration value `shadercross.IoVarType.float64`.
    float64 = @intCast(c.SDL_SHADERCROSS_IOVAR_TYPE_FLOAT64),
    _,
};

/// SDL enumeration `shadercross.ShaderStage`.
const ShaderStage = enum(c.SDL_ShaderCross_ShaderStage) {
    /// Enumeration value `shadercross.ShaderStage.vertex`.
    vertex = @intCast(c.SDL_SHADERCROSS_SHADERSTAGE_VERTEX),
    /// Enumeration value `shadercross.ShaderStage.fragment`.
    fragment = @intCast(c.SDL_SHADERCROSS_SHADERSTAGE_FRAGMENT),
    /// Enumeration value `shadercross.ShaderStage.compute`.
    compute = @intCast(c.SDL_SHADERCROSS_SHADERSTAGE_COMPUTE),
    _,
};

/// SDL record `shadercross.ComputePipelineMetadata`.
const ComputePipelineMetadata = extern struct {
    /// Field `num_samplers`.
    num_samplers: u32,
    /// Field `num_readonly_storage_textures`.
    num_readonly_storage_textures: u32,
    /// Field `num_readonly_storage_buffers`.
    num_readonly_storage_buffers: u32,
    /// Field `num_readwrite_storage_textures`.
    num_readwrite_storage_textures: u32,
    /// Field `num_readwrite_storage_buffers`.
    num_readwrite_storage_buffers: u32,
    /// Field `num_uniform_buffers`.
    num_uniform_buffers: u32,
    /// Field `threadcount_x`.
    threadcount_x: u32,
    /// Field `threadcount_y`.
    threadcount_y: u32,
    /// Field `threadcount_z`.
    threadcount_z: u32,
};

/// SDL record `shadercross.GraphicsShaderMetadata`.
const GraphicsShaderMetadata = extern struct {
    /// Field `resource_info`.
    resource_info: GraphicsShaderResourceInfo,
    /// Field `num_inputs`.
    num_inputs: u32,
    /// Field `inputs`.
    inputs: ?*IoVarMetadata,
    /// Field `num_outputs`.
    num_outputs: u32,
    /// Field `outputs`.
    outputs: ?*IoVarMetadata,
};

/// SDL record `shadercross.GraphicsShaderResourceInfo`.
const GraphicsShaderResourceInfo = extern struct {
    /// Field `num_samplers`.
    num_samplers: u32,
    /// Field `num_storage_textures`.
    num_storage_textures: u32,
    /// Field `num_storage_buffers`.
    num_storage_buffers: u32,
    /// Field `num_uniform_buffers`.
    num_uniform_buffers: u32,
};

/// SDL record `shadercross.HlslDefine`.
const HlslDefine = extern struct {
    /// Field `name`.
    name: ?*u8,
    /// Field `value`.
    value: ?*u8,
};

/// SDL record `shadercross.HlslInfo`.
const HlslInfo = extern struct {
    /// Field `source`.
    source: ?*const u8,
    /// Field `entrypoint`.
    entrypoint: ?*const u8,
    /// Field `include_dir`.
    include_dir: ?*const u8,
    /// Field `defines`.
    defines: ?*HlslDefine,
    /// Field `shader_stage`.
    shader_stage: ShaderStage,
    /// Field `props`.
    props: sdl.properties.Id,
};

/// SDL record `shadercross.IoVarMetadata`.
const IoVarMetadata = extern struct {
    /// Field `name`.
    name: ?*u8,
    /// Field `location`.
    location: u32,
    /// Field `vector_type`.
    vector_type: IoVarType,
    /// Field `vector_size`.
    vector_size: u32,
};

/// SDL record `shadercross.SpirvInfo`.
const SpirvInfo = extern struct {
    /// Field `bytecode`.
    bytecode: ?*const u8,
    /// Field `bytecode_size`.
    bytecode_size: c_ulong,
    /// Field `entrypoint`.
    entrypoint: ?*const u8,
    /// Field `shader_stage`.
    shader_stage: ShaderStage,
    /// Field `props`.
    props: sdl.properties.Id,
};

/// Printable format: "%d.%d.%d", MAJOR, MINOR, MICRO
const major_version = c.SDL_SHADERCROSS_MAJOR_VERSION;
/// SDL constant `shadercross.micro_version`.
const micro_version = c.SDL_SHADERCROSS_MICRO_VERSION;
/// SDL constant `shadercross.minor_version`.
const minor_version = c.SDL_SHADERCROSS_MINOR_VERSION;
/// SDL constant `shadercross.prop_hlsl_skip_spirv_roundtrip_boolean`.
const prop_hlsl_skip_spirv_roundtrip_boolean = c.SDL_SHADERCROSS_PROP_HLSL_SKIP_SPIRV_ROUNDTRIP_BOOLEAN;
/// SDL constant `shadercross.prop_shader_cull_unused_bindings_boolean`.
const prop_shader_cull_unused_bindings_boolean = c.SDL_SHADERCROSS_PROP_SHADER_CULL_UNUSED_BINDINGS_BOOLEAN;
/// SDL constant `shadercross.prop_shader_debug_enable_boolean`.
const prop_shader_debug_enable_boolean = c.SDL_SHADERCROSS_PROP_SHADER_DEBUG_ENABLE_BOOLEAN;
/// SDL constant `shadercross.prop_shader_debug_name_string`.
const prop_shader_debug_name_string = c.SDL_SHADERCROSS_PROP_SHADER_DEBUG_NAME_STRING;
/// SDL constant `shadercross.prop_spirv_msl_version_string`.
const prop_spirv_msl_version_string = c.SDL_SHADERCROSS_PROP_SPIRV_MSL_VERSION_STRING;
/// SDL constant `shadercross.prop_spirv_pssl_compatibility_boolean`.
const prop_spirv_pssl_compatibility_boolean = c.SDL_SHADERCROSS_PROP_SPIRV_PSSL_COMPATIBILITY_BOOLEAN;

/// Compile an SDL GPU compute pipeline from SPIRV code. If your shader source is HLSL, you should obtain SPIR-V bytecode from shadercross.compileSpirvFromHlsl().
///
/// - **Parameters:**
///   - `device`: the SDL GPU device.
///   - `info`: a struct describing the shader to transpile.
///   - `metadata`: a struct describing shader metadata. Can be obtained from shadercross.reflectComputeSpirv().
///   - `props`: a properties object filled in with extra shader metadata.
///
/// - **Returns:** a compiled sdl.gpu.ComputePipeline.
/// - **Thread safety:** It is safe to call this function from any thread.
inline fn compileComputePipelineFromSpirv(device: ?*sdl.gpu.Device, info: ?*const SpirvInfo, metadata: ?*const ComputePipelineMetadata, props: sdl.properties.Id) ?*sdl.gpu.ComputePipeline {
    const result = c.SDL_ShaderCross_CompileComputePipelineFromSPIRV(@ptrCast(device), @ptrCast(info), @ptrCast(metadata), props);
    return if (result == null) null else @ptrCast(result);
}

/// Compile to DXBC bytecode from HLSL code via a SPIRV-Cross round trip.
///
/// You must sdl.stdinc.free the returned buffer once you are done with it.
/// These are the optional properties that can be used:
/// - `shadercross.prop_shader_debug_enable_boolean`: allows debug info to be emitted when relevant. Should only be used with debugging tools like Renderdoc.
/// - `shadercross.prop_shader_debug_name_string`: a UTF-8 name to be used with the shader. Relevant for use with debugging tools like Renderdoc.
/// - `shadercross.prop_shader_cull_unused_bindings_boolean`: When true, indicates that the compiler should cull unused shader resources. This behavior is disabled by default.
/// - `shadercross.prop_hlsl_skip_spirv_roundtrip_boolean`: When true, the SPIRV roundtrip is skipped. This behavior is disabled by default. Do not use this property if your shader uses Structured Buffers.
///
/// - **Parameters:**
///   - `info`: a struct describing the shader to transpile.
///   - `size`: filled in with the bytecode buffer size.
///
/// - **Returns:** an SDL_malloc'd buffer containing DXBC bytecode.
/// - **Thread safety:** It is safe to call this function from any thread.
inline fn compileDxbcFromHlsl(info: ?*const HlslInfo, size: ?*c_ulong) ?*anyopaque {
    const result = c.SDL_ShaderCross_CompileDXBCFromHLSL(@ptrCast(info), @ptrCast(size));
    return if (result == null) null else @ptrCast(result);
}

/// Compile DXBC bytecode from SPIRV code.
///
/// You must sdl.stdinc.free the returned buffer once you are done with it.
///
/// - **Parameters:**
///   - `info`: a struct describing the shader to transpile.
///   - `size`: filled in with the bytecode buffer size.
///
/// - **Returns:** an SDL_malloc'd buffer containing DXBC bytecode.
inline fn compileDxbcFromSpirv(info: ?*const SpirvInfo, size: ?*c_ulong) ?*anyopaque {
    const result = c.SDL_ShaderCross_CompileDXBCFromSPIRV(@ptrCast(info), @ptrCast(size));
    return if (result == null) null else @ptrCast(result);
}

/// Compile to DXIL bytecode from HLSL code via a SPIRV-Cross round trip.
///
/// You must sdl.stdinc.free the returned buffer once you are done with it.
/// These are the optional properties that can be used:
/// - `shadercross.prop_shader_debug_enable_boolean`: allows debug info to be emitted when relevant. Should only be used with debugging tools like Renderdoc.
/// - `shadercross.prop_shader_debug_name_string`: a UTF-8 name to be used with the shader. Relevant for use with debugging tools like Renderdoc.
/// - `shadercross.prop_shader_cull_unused_bindings_boolean`: when true, indicates that the compiler should cull unused shader resources. This behavior is disabled by default.
/// - `shadercross.prop_hlsl_skip_spirv_roundtrip_boolean`: when true, the SPIRV roundtrip is skipped. This behavior is disabled by default. Do not use this property if your shader uses Structured Buffers.
///
/// - **Parameters:**
///   - `info`: a struct describing the shader to transpile.
///   - `size`: filled in with the bytecode buffer size.
///
/// - **Returns:** an SDL_malloc'd buffer containing DXIL bytecode.
/// - **Thread safety:** It is safe to call this function from any thread.
inline fn compileDxilFromHlsl(info: ?*const HlslInfo, size: ?*c_ulong) ?*anyopaque {
    const result = c.SDL_ShaderCross_CompileDXILFromHLSL(@ptrCast(info), @ptrCast(size));
    return if (result == null) null else @ptrCast(result);
}

/// Compile DXIL bytecode from SPIRV code.
///
/// You must sdl.stdinc.free the returned buffer once you are done with it.
///
/// - **Parameters:**
///   - `info`: a struct describing the shader to transpile.
///   - `size`: filled in with the bytecode buffer size.
///
/// - **Returns:** an SDL_malloc'd buffer containing DXIL bytecode.
inline fn compileDxilFromSpirv(info: ?*const SpirvInfo, size: ?*c_ulong) ?*anyopaque {
    const result = c.SDL_ShaderCross_CompileDXILFromSPIRV(@ptrCast(info), @ptrCast(size));
    return if (result == null) null else @ptrCast(result);
}

/// Compile an SDL GPU shader from SPIRV code. If your shader source is HLSL, you should obtain SPIR-V bytecode from shadercross.compileSpirvFromHlsl().
///
/// - **Parameters:**
///   - `device`: the SDL GPU device.
///   - `info`: a struct describing the shader to transpile.
///   - `resource_info`: a struct describing resource info of the shader. Can be obtained from shadercross.reflectGraphicsSpirv().
///   - `props`: a properties object filled in with extra shader metadata.
///
/// - **Returns:** a compiled sdl.gpu.Shader.
/// - **Thread safety:** It is safe to call this function from any thread.
inline fn compileGraphicsShaderFromSpirv(device: ?*sdl.gpu.Device, info: ?*const SpirvInfo, resource_info: ?*const GraphicsShaderResourceInfo, props: sdl.properties.Id) ?*sdl.gpu.Shader {
    const result = c.SDL_ShaderCross_CompileGraphicsShaderFromSPIRV(@ptrCast(device), @ptrCast(info), @ptrCast(resource_info), props);
    return if (result == null) null else @ptrCast(result);
}

/// Compile to SPIRV bytecode from HLSL code.
///
/// You must sdl.stdinc.free the returned buffer once you are done with it.
/// These are the optional properties that can be used:
/// - `shadercross.prop_shader_debug_enable_boolean`: allows debug info to be emitted when relevant. Should only be used with debugging tools like Renderdoc.
/// - `shadercross.prop_shader_debug_name_string`: a UTF-8 name to be used with the shader. Relevant for use with debugging tools like Renderdoc.
/// - `shadercross.prop_shader_cull_unused_bindings_boolean`: when true, indicates that the compiler should cull unused shader resources. This behavior is disabled by default.
///
/// - **Parameters:**
///   - `info`: a struct describing the shader to transpile.
///   - `size`: filled in with the bytecode buffer size.
///
/// - **Returns:** an SDL_malloc'd buffer containing SPIRV bytecode.
/// - **Thread safety:** It is safe to call this function from any thread.
inline fn compileSpirvFromHlsl(info: ?*const HlslInfo, size: ?*c_ulong) ?*anyopaque {
    const result = c.SDL_ShaderCross_CompileSPIRVFromHLSL(@ptrCast(info), @ptrCast(size));
    return if (result == null) null else @ptrCast(result);
}

/// Get the supported shader formats that HLSL cross-compilation can output
///
/// - **Returns:** GPU shader formats supported by HLSL cross-compilation.
/// - **Thread safety:** It is safe to call this function from any thread.
inline fn getHlslShaderFormats() sdl.gpu.ShaderFormat {
    return c.SDL_ShaderCross_GetHLSLShaderFormats();
}

/// Get the supported shader formats that SPIRV cross-compilation can output
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Returns:** GPU shader formats supported by SPIRV cross-compilation.
inline fn getSpirvShaderFormats() sdl.gpu.ShaderFormat {
    return c.SDL_ShaderCross_GetSPIRVShaderFormats();
}

/// Initializes SDL_shadercross
///
/// - **Thread safety:** This should only be called once, from a single thread.
/// - **Returns:** true on success, false otherwise.
inline fn init() bool {
    return c.SDL_ShaderCross_Init();
}

/// De-initializes SDL_shadercross
///
/// - **Thread safety:** This should only be called once, from a single thread.
inline fn quit() void {
    c.SDL_ShaderCross_Quit();
}

/// Reflect compute pipeline info from SPIRV code. If your shader source is HLSL, you should obtain SPIR-V bytecode from shadercross.compileSpirvFromHlsl(). This must be freed with sdl.stdinc.free() when you are done with the metadata.
///
/// - **Parameters:**
///   - `bytecode`: the SPIRV bytecode.
///   - `props`: a properties object filled in with extra shader metadata, provided by the user.
///
/// - **Returns:** A metadata struct on success, NULL otherwise.
/// - **Thread safety:** It is safe to call this function from any thread.
inline fn reflectComputeSpirv(bytecode: []const u8, props: sdl.properties.Id) ?*ComputePipelineMetadata {
    const result = c.SDL_ShaderCross_ReflectComputeSPIRV(@ptrCast(bytecode.ptr), @intCast(bytecode.len), props);
    return if (result == null) null else @ptrCast(result);
}

/// Reflect graphics shader info from SPIRV code. If your shader source is HLSL, you should obtain SPIR-V bytecode from shadercross.compileSpirvFromHlsl(). This must be freed with sdl.stdinc.free() when you are done with the metadata.
///
/// - **Parameters:**
///   - `bytecode`: the SPIRV bytecode.
///   - `props`: a properties object filled in with extra shader metadata, provided by the user.
///
/// - **Returns:** A metadata struct on success, NULL otherwise. The struct must be free'd when it is no longer needed.
/// - **Thread safety:** It is safe to call this function from any thread.
inline fn reflectGraphicsSpirv(bytecode: []const u8, props: sdl.properties.Id) ?*GraphicsShaderMetadata {
    const result = c.SDL_ShaderCross_ReflectGraphicsSPIRV(@ptrCast(bytecode.ptr), @intCast(bytecode.len), props);
    return if (result == null) null else @ptrCast(result);
}

/// Transpile to HLSL code from SPIRV code.
///
/// You must sdl.stdinc.free the returned string once you are done with it.
/// These are the optional properties that can be used:
/// - `shadercross.prop_spirv_pssl_compatibility_boolean`: generates PSSL-compatible shader.
///
/// - **Parameters:**
///   - `info`: a struct describing the shader to transpile.
///
/// - **Returns:** an SDL_malloc'd string containing HLSL code.
inline fn transpileHlslFromSpirv(info: ?*const SpirvInfo) ?*anyopaque {
    const result = c.SDL_ShaderCross_TranspileHLSLFromSPIRV(@ptrCast(info));
    return if (result == null) null else @ptrCast(result);
}

/// Transpile to MSL code from SPIRV code.
///
/// You must sdl.stdinc.free the returned string once you are done with it.
/// These are the optional properties that can be used:
/// - `shadercross.prop_spirv_msl_version_string`: specifies the MSL version that should be emitted. Defaults to 1.2.0.
///
/// - **Parameters:**
///   - `info`: a struct describing the shader to transpile.
///
/// - **Returns:** an SDL_malloc'd string containing MSL code.
inline fn transpileMslFromSpirv(info: ?*const SpirvInfo) ?*anyopaque {
    const result = c.SDL_ShaderCross_TranspileMSLFromSPIRV(@ptrCast(info));
    return if (result == null) null else @ptrCast(result);
}

/// SDL_shadercross APIs for the shadercross subsystem.
pub const shadercross = struct {
    pub const compileComputePipelineFromSpirv = root.compileComputePipelineFromSpirv;
    pub const compileDxbcFromHlsl = root.compileDxbcFromHlsl;
    pub const compileDxbcFromSpirv = root.compileDxbcFromSpirv;
    pub const compileDxilFromHlsl = root.compileDxilFromHlsl;
    pub const compileDxilFromSpirv = root.compileDxilFromSpirv;
    pub const compileGraphicsShaderFromSpirv = root.compileGraphicsShaderFromSpirv;
    pub const compileSpirvFromHlsl = root.compileSpirvFromHlsl;
    pub const ComputePipelineMetadata = root.ComputePipelineMetadata;
    pub const getHlslShaderFormats = root.getHlslShaderFormats;
    pub const getSpirvShaderFormats = root.getSpirvShaderFormats;
    pub const GraphicsShaderMetadata = root.GraphicsShaderMetadata;
    pub const GraphicsShaderResourceInfo = root.GraphicsShaderResourceInfo;
    pub const HlslDefine = root.HlslDefine;
    pub const HlslInfo = root.HlslInfo;
    pub const init = root.init;
    pub const IoVarMetadata = root.IoVarMetadata;
    pub const IoVarType = root.IoVarType;
    pub const major_version = root.major_version;
    pub const micro_version = root.micro_version;
    pub const minor_version = root.minor_version;
    pub const prop_hlsl_skip_spirv_roundtrip_boolean = root.prop_hlsl_skip_spirv_roundtrip_boolean;
    pub const prop_shader_cull_unused_bindings_boolean = root.prop_shader_cull_unused_bindings_boolean;
    pub const prop_shader_debug_enable_boolean = root.prop_shader_debug_enable_boolean;
    pub const prop_shader_debug_name_string = root.prop_shader_debug_name_string;
    pub const prop_spirv_msl_version_string = root.prop_spirv_msl_version_string;
    pub const prop_spirv_pssl_compatibility_boolean = root.prop_spirv_pssl_compatibility_boolean;
    pub const quit = root.quit;
    pub const reflectComputeSpirv = root.reflectComputeSpirv;
    pub const reflectGraphicsSpirv = root.reflectGraphicsSpirv;
    pub const ShaderStage = root.ShaderStage;
    pub const SpirvInfo = root.SpirvInfo;
    pub const transpileHlslFromSpirv = root.transpileHlslFromSpirv;
    pub const transpileMslFromSpirv = root.transpileMslFromSpirv;
};
