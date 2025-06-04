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
                               constant float2& drawableSize [[buffer(3)]]) {
    float2 texCoord = in.texCoord;
        
        // 텍스처 크기와 뷰 크기를 포인트 단위로 조정
    float renderWidth = drawableSize.x; // 뷰 가로 (402.0 포인트)
    float textureAspect = resolution.x / resolution.y; // 463 / 694 ≈ 0.667
    float renderHeight = renderWidth / textureAspect; // 402.0 / 0.667 ≈ 602.4 포인트
    
    float offsetX = 0.0;
    float offsetY;
    
    if (renderHeight > drawableSize.y) {
        // 텍스처가 뷰보다 높을 경우: 세로 기준 조정
        renderHeight = drawableSize.y; // 뷰 세로 (770.0 포인트)
        renderWidth = renderHeight * textureAspect; // 770.0 * 0.667 ≈ 513.9 포인트
        offsetX = (drawableSize.x - renderWidth) / drawableSize.x / 2.0; // (402.0 - 513.9) / 402.0 / 2
        offsetY = 0.0;
    } else {
        // 가로 기준 조정: 세로 중앙 배치
        offsetY = (drawableSize.y - renderHeight) / drawableSize.y / 2.0; // (770.0 - 602.4) / 770.0 / 2 ≈ 0.1085
    }
    
    // 텍스처 좌표 정규화
    float2 renderSize = float2(renderWidth / drawableSize.x, renderHeight / drawableSize.y);
    float2 adjustedTexCoord = (texCoord - float2(offsetX, offsetY)) / renderSize;
    
    if (adjustedTexCoord.x < 0.0 || adjustedTexCoord.x > 1.0 ||
        adjustedTexCoord.y < 0.0 || adjustedTexCoord.y > 1.0) {
        return float4(0.0, 0.0, 0.0, 0.0);
    }
    
    // 3x3 커널 샘플링
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
        float2 sampleCoord = adjustedTexCoord + offsets[i];
        if (sampleCoord.x >= 0.0 && sampleCoord.x <= 1.0 && sampleCoord.y >= 0.0 && sampleCoord.y <= 1.0) {
            samples[i] = inputTexture.sample(textureSampler, sampleCoord);
        } else {
            samples[i] = float4(0.0);
        }
    }
    
    // 블러 색상 계산
    float4 blurredColor = float4(0.0);
    for (int i = 0; i < 9; i++) {
        blurredColor += samples[i];
    }
    blurredColor /= 9.0;
    
    // 기본 색상 선택
    float4 finalColor = samples[4]; // 중앙 샘플
    
    // 블러 또는 선명도 적용
    if (filterValues.blur > 0.0) {
        finalColor = mix(finalColor, blurredColor, abs(filterValues.blur) * 10.0);
    } else if (filterValues.sharpness > 0.0) {
        float4 detail = finalColor - blurredColor;
        finalColor += detail * abs(filterValues.sharpness) * 2.0;
    }
    
    // 나머지 필터 적용
    float4 color = finalColor;
    
    // 밝기
    color.rgb += filterValues.brightness;
    
    // 노출
    color.rgb *= pow(2.0, filterValues.exposure);
    
    // 대비
    color.rgb = (color.rgb - 0.5) * filterValues.contrast + 0.5;
    
    // 채도
    float luminance = dot(color.rgb, float3(0.299, 0.587, 0.114));
    color.rgb = mix(float3(luminance), color.rgb, filterValues.saturation);
    
    // 색온도
    float tempScaled = (filterValues.temperature - 6500.0) / 4000.0;
    color.r += tempScaled * 0.1;
    color.b -= tempScaled * 0.1;
    
    // 블랙 포인트
    color.rgb = max(color.rgb - filterValues.blackPoint, 0.0);
    
    // 하이라이트와 섀도우
    luminance = dot(color.rgb, float3(0.299, 0.587, 0.114));
    float shadowFactor = clamp(0.5 - luminance, 0.0, 1.0);
    color.rgb = mix(color.rgb, color.rgb * (1.0 + filterValues.shadows), shadowFactor);
    
    float highlightFactor = clamp(luminance - 0.5, 0.0, 1.0);
    float highlightsScaled = filterValues.highlights + 1.0;
    color.rgb = mix(color.rgb, color.rgb * highlightsScaled, highlightFactor);
    
    // 비네트
    float2 center = float2(0.5);
    float distance = length(texCoord - center); // 비네트는 원본 좌표 사용
    float vignetteAmount = filterValues.vignette * 2.0;
    float vignetteFactor = 1.0 - smoothstep(0.2, 0.8, distance * vignetteAmount);
    color.rgb *= clamp(vignetteFactor, 0.0, 1.0);
    
    // 노이즈 감소
    color.rgb = mix(color.rgb, blurredColor.rgb, filterValues.noiseReduction * 0.02);
    
    // 색상 클램핑
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    return color;
}
