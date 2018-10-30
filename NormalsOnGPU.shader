Shader "bricksseeds/normalsOnGPU" {
//Updated to work in the normal Unity lighting pipeline
        Properties {
            _MainTex ("Base (RGB)", 2D) = "white" {}
            _DispTex ("Disp Texture", 2D) = "gray" {}
            _NormalMap ("Normalmap", 2D) = "bump" {}
            _Displacement ("Displacement", Range(0, 1.0)) = 0.3
            _Color ("Color", color) = (1,1,1,0)
            _SpecColor ("Spec color", color) = (0.5,0.5,0.5,0.5)
        }
        SubShader {
            Tags { "RenderType"="Opaque" }
            LOD 300
            
            CGPROGRAM
            #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp nolightmap
            #pragma target 4.6

            struct appdata {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

						//#include "ClassicNoise3D.HLSL"

            sampler2D _DispTex;
            float _Displacement;

						float height(float3 xyz) {
							//return cnoise(xyz);
							return (sin(xyz.x*5) + cos(xyz.z*5))/2;
						}

            void disp (inout appdata v)
            {
                float3 start = v.vertex.xyz;
                v.vertex.y = height(v.vertex);
								float3 altered = v.vertex.xyz;

								float3 offset1 = float3(1,0,0) * .01;
								float3 offset2 = float3(0,0,1) * .01;
								float3 ms1 = start + offset1;
								float3 ms2 = start + offset2;
								float height1 = height(ms1);
								float height2 = height(ms2);
								float3 P1 = float3(ms1.x, height1, ms1.z);
								float3 P2 = float3(ms2.x, height2, ms2.z);
								float3 tangent1 = normalize(P1 - altered);
								float3 tangent2 = normalize(P2 - altered);
								float3 newNormal = cross(tangent2, tangent1);
								v.normal = normalize(newNormal);
            }

            struct Input {
                float2 uv_MainTex;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed4 _Color;

            void surf (Input IN, inout SurfaceOutput o) {
                half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                o.Specular = 0.2;
                o.Gloss = 1.0;
                o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            }
            ENDCG
        }
        FallBack "Diffuse"
    }
