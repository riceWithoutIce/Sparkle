#ifndef RICE_SPARKLE_INCLUDED
#define RICE_SPARKLE_INCLUDED

sampler2D _SparkleTex;
half4 _SparkleColor1, _SparkleColor2;
half _SparkleColor01;
half _SparkleScale;
half _SparkleSize;
half _SparkleSizeMin;
half _SparkleOffset;
half _SparkleSpeedU, _SparkleSpeedV;
half _SparkleShine, _SparkleShineColor;
half _SparkleRange;

inline float unity_noise_randomValue(float2 uv)
{
    float randomno = frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
    return randomno;
}

inline half ShineRandom(half f, half random)
{
    half shine = sin(_Time.y * f * (1 - random) + random) * 0.5 + 0.5;
    shine = lerp(1, shine, saturate(ceil(f)));

    return shine;
}

inline half4 Sparkle(half2 coord, half2 coordFloor, half2 coordCenter, half2 uvOffset, half intensity)
{
    half random = unity_noise_randomValue(coordFloor + uvOffset);
    half flg = ceil(intensity - random);

    half2 offset = lerp(0.5, random, _SparkleOffset)+ half2(_Time.y * random * _SparkleSpeedU, _Time.y * random * _SparkleSpeedV);
    offset = frac(offset);

    half fU = saturate(sin(offset.x * UNITY_PI));
    half fV = saturate(sin(offset.y * UNITY_PI));

    // 
    coordCenter += offset * 2 - 1 + uvOffset;

    // scale
    half fScale = ShineRandom(_SparkleShine, random);
    fScale *= fU * fV;

    half sparkleSize = lerp(min(_SparkleSize, _SparkleSizeMin), _SparkleSize, random) * fScale;
    half sparkle = 1 - saturate(length(coord - coordCenter) / sparkleSize);
    sparkle = sparkle * sparkle;// * sparkle * sparkle;

    // color
    half cFlg = ceil(_SparkleColor01 - random);
    half fColor = ShineRandom(_SparkleShineColor, random);
    half3 sparkleColor = lerp(_SparkleColor1, _SparkleColor2, cFlg);

    return half4(sparkleColor, saturate(sparkle * flg * fColor));
}

inline half4 Sparkle(half2 coord, half2 coordFloor, half2 coordCenter, half intensity)
{
    half4 sparkle = Sparkle(coord, coordFloor, coordCenter, half2(0, 0), intensity);

    half xFlg = sign(coord.x - 0.5f);
    half yFlg = sign(coord.y - 0.5f);
    sparkle += Sparkle(coord, coordFloor, coordCenter, half2(xFlg, 0), intensity);
    sparkle += Sparkle(coord, coordFloor, coordCenter, half2(0, yFlg), intensity);
    sparkle += Sparkle(coord, coordFloor, coordCenter, half2(xFlg, yFlg), intensity);

    sparkle.rgb *= 0.25f;

    return sparkle;
}

inline half3 Sparkle(half3 color, half2 uv, half nv)
{
    half4 sparkleTex = tex2D(_SparkleTex, uv);
    half intensity = sparkleTex.a * pow(nv, _SparkleRange);

    half2 coord = half2(uv.x * _SparkleScale, uv.y * _SparkleScale);
    half2 coordFloor = floor(coord);
    coord -= coordFloor;

    half2 coordCenter = 0.5f;
    half4 sparkle = Sparkle(coord, coordFloor, coordCenter, intensity);
    sparkle.rgb *= sparkleTex.rgb;

    color.rgb = lerp(color.rgb, sparkle.rgb, sparkle.a);

    return color.rgb;
}

#endif