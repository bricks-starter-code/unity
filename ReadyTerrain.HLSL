Shader "bricksseeds/newSurfaceShader" {
//Updated to work in the normal Unity lighting pipeline
        Properties {
            _Color ("Color", color) = (1,1,1,0)
            _MountainHeight("Mountain Height", Range(.1, 10)) = 1
						_Density("Density", Range(.1, 10)) = 2
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

						#include "ClassicNoise3D.HLSL"

            sampler2D _DispTex;
            float _Displacement;
						float _MountainHeight;
						float _Density;

						float height(float3 xyz) {
							return cnoise(float3(xyz.x * _Density, 0, xyz.z*_Density)) * _MountainHeight;
							//return (sin(xyz.x*5) + cos(xyz.z*5))/2;
						}

            struct Input {
                float2 uv_MainTex;
								float height;
            };

            void disp (inout appdata v, out Input o)
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

								UNITY_INITIALIZE_OUTPUT(Input, o);
								o.height = v.vertex.y/_MountainHeight;
            }


            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed4 _Color;

            void surf (Input IN, inout SurfaceOutput o) {
                if(IN.height > 0)
								{
									o.Albedo = half3(0, 1, 0);
								}
								else{
									o.Albedo = half3(0, 0, 1);
								}

                o.Specular = 0.2;
                o.Gloss = 1.0;
                //o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            }
            ENDCG
        }
        FallBack "Diffuse"
    }
