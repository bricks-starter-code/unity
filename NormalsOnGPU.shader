Shader "bricksseeds/NormalsOnGPU"
{
	Properties
	{
		
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;				
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal: NORMAL;
				float3 objectSpacePosition : TEXCOORD0;
			};

			
			float height(fixed2 xy) {
				return (sin(xy.x * 8 ) + cos(xy.y * 8) )* .25;
			}

			v2f vert(appdata v)
			{
				v2f o;
				fixed3 modelSpace = v.vertex;
				fixed2 P = fixed2(modelSpace.x, modelSpace.z);
				float newY = height(P);
				fixed3 altered = fixed3(P.x, newY, P.y);
				o.vertex = UnityObjectToClipPos(altered);
				o.objectSpacePosition = altered;			



				//calculate the normal
				fixed2 offset1 = fixed2(1,0) * .01;
				fixed2 offset2 = fixed2(0,1) * .01;
				fixed2 ms1 = P + offset1;
				fixed2 ms2 = P + offset2;
				float height1 = height(ms1);
				float height2 = height(ms2);
				fixed3 P1 = fixed3(ms1.x, height1, ms1.y);
				fixed3 P2 = fixed3(ms2.x, height2, ms2.y);
				fixed3 tangent1 = normalize(P1 - altered);
				fixed3 tangent2 = normalize(P2 - altered);
				fixed3 newNormal = cross(tangent2, tangent1);
				o.normal = normalize(newNormal);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 objectSpaceColor = frac(abs(i.objectSpacePosition));
				fixed3 normalColor = i.normal * .5 + fixed3(.5, .5, .5);

				float d = dot(normalize(half3(0, 1, 0)), i.normal);
				float3 simpleLightingColor = fixed3(1, 0, 0) * d;


				fixed4 final = fixed4(simpleLightingColor, 1);//Or for debugging use normalColor, objectSpaceColor
				return final;
			
			}
			ENDCG
		}
	}
}
