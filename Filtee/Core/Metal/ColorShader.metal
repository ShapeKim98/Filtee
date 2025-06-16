//
//  ColorShader.metal
//  Filtee
//
//  Created by 김도형 on 5/30/25.
//

#include <metal_stdlib>
using namespace metal;

struct FilterValues {
    float brightness;
    float exposure;
    float contrast;
    float saturation;
    float sharpness;
    float blur;
    float vignette;
    float noiseReduction;
    float highlights;
    float shadows;
    float temperature;
    float blackPoint;
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

float3 linearToSRGB(float3 linear) {
    return pow(linear, float3(2.2/1.0)); // 간단한 감마 보정
}

vertex VertexOut vertexShader(device const float4* vertices [[buffer(0)]],
                              uint vid [[vertex_id]]) {
    VertexOut out;
    out.position = float4(vertices[vid].xy, 0, 1);
    out.texCoord = vertices[vid].zw;
    return out;
}

fragment float4 filterFragment(VertexOut in [[stage_in]],
                               texture2d<float> inputTexture [[texture(0)]],
                               sampler textureSampler [[sampler(0)]],
                               constant FilterValues& filterValues [[buffer(1)]],
                               constant float2& resolution [[buffer(2)]],
                               constant float2& drawableSize [[buffer(3)]],
                               constant bool& isPreview [[buffer(4)]]) {
    float2 texCoord = in.texCoord;
    float2 sampleCoord;
    
    float renderWidth = drawableSize.x;
    float textureAspect = resolution.x / resolution.y;
    float renderHeight = renderWidth / textureAspect;
    
    float offsetX = 0.0;
    float offsetY;
    
    if (renderHeight > drawableSize.y) {
        renderHeight = drawableSize.y;
        renderWidth = renderHeight * textureAspect;
        offsetX = (drawableSize.x - renderWidth) / drawableSize.x / 2.0;
        offsetY = 0.0;
    } else {
        offsetY = (drawableSize.y - renderHeight) / drawableSize.y / 2.0;
    }
    
    float2 renderSize = float2(renderWidth / drawableSize.x, renderHeight / drawableSize.y);
    float2 adjustedTexCoord = (texCoord - float2(offsetX, offsetY)) / renderSize;
    
    if (isPreview) {
        if (adjustedTexCoord.x < 0.0 || adjustedTexCoord.x > 1.0 ||
            adjustedTexCoord.y < 0.0 || adjustedTexCoord.y > 1.0) {
            return float4(0.0, 0.0, 0.0, 0.0);
        }
    }
    
    sampleCoord = adjustedTexCoord;
    
    float2 offsets[9] = {
        float2(-1, -1) / resolution,
        float2(0, -1) / resolution,
        float2(1, -1) / resolution,
        float2(-1, 0) / resolution,
        float2(0, 0) / resolution,
        float2(1, 0) / resolution,
        float2(-1, 1) / resolution,
        float2(0, 1) / resolution,
        float2(1, 1) / resolution
    };
    
    float4 samples[9];
    for (int i = 0; i < 9; i++) {
        float2 sampleCoordOffset = sampleCoord + offsets[i];
        if (sampleCoordOffset.x >= 0.0 && sampleCoordOffset.x <= 1.0 &&
            sampleCoordOffset.y >= 0.0 && sampleCoordOffset.y <= 1.0) {
            samples[i] = inputTexture.sample(textureSampler, sampleCoordOffset);
        } else {
            samples[i] = float4(0.0);
        }
    }
    
    float4 blurredColor = float4(0.0);
    for (int i = 0; i < 9; i++) {
        blurredColor += samples[i];
    }
    blurredColor /= 9.0;
    
    float4 finalColor = samples[4];
    
    if (filterValues.blur > 0.0) {
        finalColor = mix(finalColor, blurredColor, abs(filterValues.blur) * 10.0);
    } else if (filterValues.sharpness > 0.0) {
        float4 detail = finalColor - blurredColor;
        finalColor += detail * abs(filterValues.sharpness) * 2.0;
    }
    
    float4 color = finalColor;
    
    color.rgb += filterValues.brightness;
    color.rgb *= pow(2.0, filterValues.exposure);
    color.rgb = (color.rgb - 0.5) * filterValues.contrast + 0.5;
    float luminance = dot(color.rgb, float3(0.299, 0.587, 0.114));
    color.rgb = mix(float3(luminance), color.rgb, filterValues.saturation);
    float tempScaled = (filterValues.temperature - 6500.0) / 4000.0;
    color.r += tempScaled * 0.1;
    color.b -= tempScaled * 0.1;
    color.rgb = max(color.rgb - filterValues.blackPoint, 0.0);
    luminance = dot(color.rgb, float3(0.299, 0.587, 0.114));
    float shadowFactor = clamp(0.5 - luminance, 0.0, 1.0);
    color.rgb = mix(color.rgb, color.rgb * (1.0 + filterValues.shadows), shadowFactor);
    float highlightFactor = clamp(luminance - 0.5, 0.0, 1.0);
    float highlightsScaled = filterValues.highlights + 1.0;
    color.rgb = mix(color.rgb, color.rgb * highlightsScaled, highlightFactor);
    float2 center = float2(0.5);
    float distance = length(texCoord - center);
    float vignetteAmount = filterValues.vignette * 2.0;
    float vignetteFactor = 1.0 - smoothstep(0.2, 0.8, distance * vignetteAmount);
    color.rgb *= clamp(vignetteFactor, 0.0, 1.0);
    color.rgb = mix(color.rgb, blurredColor.rgb, filterValues.noiseReduction * 0.02);
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    color.rgb = linearToSRGB(color.rgb);
    
    return color;
}
