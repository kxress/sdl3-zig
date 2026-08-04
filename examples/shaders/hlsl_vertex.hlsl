struct VertexInput {
    float3 position : TEXCOORD0;
};

struct VertexOutput {
    float4 position : SV_Position;
};

VertexOutput main(VertexInput input) {
    VertexOutput output;
    output.position = float4(input.position, 1.0);
    return output;
}
