Shader "Rice/Sparkle"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Sparkle)]
        _SparkleTex ("Sparkle texture (rgb: color, a: mask)", 2D) = "black" {}
        [HDR]_SparkleColor ("Sparkle color", Color) = (1, 1, 1, 1)
        _SparkleScale ("Sparkle intensity", Range(0, 1000)) = 1
        _SparkleSize ("Sparkle max size", Range(0, 0.5)) = 0.5
        _SparkleSizeMin ("Sparkle min size", Range(0, 0.5)) = 0.2
        _SparkleSpeedU ("Sparkle speed u", Range(-5, 5)) = 0
        _SparkleSpeedV ("Sparkle speed v", Range(-5, 5)) = 0
        _SparkleShine ("Sparkle shine", Range(0, 20)) = 0
        _SparkleRange ("Sparkle range", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"
                #include "Sparkle.cginc"

                half4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    half3 normal : NORMAL;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    half3 wsNormal : TEXCOORD1;
                    half3 viewDir : TEXCOORD2;
                };

                v2f vert (appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.wsNormal = normalize(UnityObjectToWorldNormal(v.normal));
                    o.viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                    return o;
                }

                fixed4 frag (v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                    half2 uv = i.uv;
                    half4 sparkleTex = tex2D(_SparkleTex, uv);
                    half nv = abs(dot(i.wsNormal, i.viewDir));
                    half intensity = sparkleTex.a * pow(nv, _SparkleRange);

                    half2 coord = half2(uv.x * _SparkleScale, uv.y * _SparkleScale);
                    half2 coordFloor = floor(coord);
                    coord -= coordFloor;
                    half2 coordCenter = 0.5f;
                    half3 sparkle = Sparkle(coord, coordFloor, coordCenter, intensity).xxx * _SparkleColor.rgb * sparkleTex.rgb;
                    
                    col.rgb += sparkle;

                    return col;
                }
            ENDCG
        }
    }
}
