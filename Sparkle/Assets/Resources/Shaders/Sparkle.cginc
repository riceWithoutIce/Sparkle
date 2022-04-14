#ifndef RICE_SPARKLE_INCLUDED
#define RICE_SPARKLE_INCLUDED

sampler2D _SparkleTex;
half4 _SparkleColor;
half _SparkleScale;
half _SparkleSize;
half _SparkleSizeMin;
half _SparkleSpeedU, _SparkleSpeedV;
half _SparkleShine;
half _SparkleRange;

inline float unity_noise_randomValue(float2 uv)
{
    float randomno = frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
    return randomno;
}

inline half Sparkle(half2 coord, half2 coordFloor, half2 coordCenter, half2 uvOffset, half intensity)
{
    half random = unity_noise_randomValue(coordFloor + uvOffset);
    half flg = ceil(intensity - random);

    half2 offset = half2(_Time.y * random * _SparkleSpeedU, _Time.y * random * _SparkleSpeedV);
    offset = frac(offset);

    half scaleU = lerp(1, saturate(sin(offset.x * UNITY_PI)), saturate(ceil(abs(_SparkleSpeedU))));
    half scaleV = lerp(1, saturate(sin(offset.y * UNITY_PI)), saturate(ceil(abs(_SparkleSpeedV))));

    coordCenter += offset * 1.5 - 0.5 + uvOffset;
    half scale = sin(_Time.y * _SparkleShine * (1 - random)) * 0.5 + 0.5;
    scale *= scaleU * scaleV;

    half sparkleSize = lerp(_SparkleSizeMin, max(_SparkleSizeMin, _SparkleSize), random) * scale;
    half sparkle = 1 - saturate(length(coord - coordCenter) / sparkleSize);

    return sparkle * flg;
}

inline half Sparkle(half2 coord, half2 coordFloor, half2 coordCenter, half intensity)
{
    half sparkle = Sparkle(coord, coordFloor, coordCenter, half2(0, 0), intensity);

    half xFlg = sign(coord.x - 0.5f);
    half yFlg = sign(coord.y - 0.5f);
    sparkle += Sparkle(coord, coordFloor, coordCenter, half2(xFlg, 0), intensity);
    sparkle += Sparkle(coord, coordFloor, coordCenter, half2(0, yFlg), intensity);
    sparkle += Sparkle(coord, coordFloor, coordCenter, half2(xFlg, yFlg), intensity);

    return sparkle;
}

#endif