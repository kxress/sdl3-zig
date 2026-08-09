# Rendering and companion modules

The GPU, renderer, TTF, mixer, networking, tray, and shadercross facades are opt-in at build time.
Keep resources in the order required by their ownership graph: destroy pipelines and textures before
the device, fonts before the TTF subsystem, and tracks before the mixer. Shader assets can be loaded
with `shader_assets_api.Directory` and validated before creating a GPU shader.
