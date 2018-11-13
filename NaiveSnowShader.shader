Shader "bricksseeds/snowShader" {
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

            struct Input {
                float2 uv_MainTex;
								float3 normal;
								
            };

            void disp (inout appdata v, out Input o)
            {
                float3 startXYZ = v.vertex.xyz;
								float3 normal = v.normal;
								float d = dot(normal, float3(0,1,0));
                if(d > 0)
								{
									v.vertex.y += d * .1;
								}

								UNITY_INITIALIZE_OUTPUT(Input, o);
								o.normal = v.normal;
            }


            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed4 _Color;

            void surf (Input IN, inout SurfaceOutput o) {
                o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
								float d = dot(IN.normal, float3(0,1,0));
								half4 c;
								if(d>0){
									c = tex2D (_MainTex, IN.uv_MainTex) * fixed4(1,1,1,0);
									//c = half4(0,1,0,1);
								}
                else{

								 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
								 //c = half4(1, 0,0,1);
								}
								//c = half4(o.Normal.x, o.Normal.y, o.Normal.z, 1);
                o.Albedo = c.rgb;
                o.Specular = 0.2;
                o.Gloss = 1.0;
            }
            ENDCG
        }
        FallBack "Diffuse"
    }
