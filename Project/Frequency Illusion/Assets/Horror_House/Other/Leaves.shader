// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AE/Leaves"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.67
		_Color_Tilling("Color_Tilling", Color) = (0.9716981,0.9716981,0.9716981,0)
		_Color("Color", Color) = (0.9716981,0.9716981,0.9716981,0)
		_WindScale("Wind Scale", Range( 0 , 1)) = 0.3622508
		_WindPower("Wind Power", Range( 0 , 0.5)) = 0.2506492
		_WindSpeed("Wind Speed", Range( 0 , 1)) = 0.2327153
		_Wind_Size("Wind_Size", Range( 0 , 1)) = 0.5
		_Ambient_Occlusion("Ambient_Occlusion", Range( 0 , 3)) = 0
		_Smoothness_Power("Smoothness_Power", Range( 0 , 3)) = 0
		_Normal_Power("Normal_Power", Range( 0 , 5)) = 0
		_Tilling_Color("Tilling_Color", Float) = 1.49
		_Base_Color("Base_Color", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		_Noise("Noise", 2D) = "black" {}
		[Normal]_Normal("Normal", 2D) = "bump" {}
		_Tilling("Tilling", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Off
		ColorMask RGB
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _Noise;
		uniform float _WindSpeed;
		uniform float _Wind_Size;
		uniform float _WindScale;
		uniform float _WindPower;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _Normal_Power;
		uniform float4 _Color;
		uniform sampler2D _Base_Color;
		uniform float4 _Base_Color_ST;
		uniform float4 _Color_Tilling;
		uniform float2 _Tilling;
		uniform float _Tilling_Color;
		uniform float _Smoothness_Power;
		uniform float _Ambient_Occlusion;
		uniform float _Cutoff = 0.67;


		inline float4 TriplanarSampling26( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
			yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
			zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 temp_cast_0 = (_WindSpeed).xx;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float4 triplanar26 = TriplanarSampling26( _Noise, ase_worldPos, ase_worldNormal, 1.0, (0.1 + (_Wind_Size - 0.0) * (3.0 - 0.1) / (1.0 - 0.0)), 1.0, 0 );
			float2 temp_cast_1 = (triplanar26.x).xx;
			float2 panner27 = ( 1.0 * _Time.y * temp_cast_0 + temp_cast_1);
			float2 uv_Mask = v.texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 tex2DNode15 = tex2Dlod( _Mask, float4( uv_Mask, 0, 0.0) );
			v.vertex.xyz += ( ( tex2Dlod( _Noise, float4( ( panner27 * _WindScale ), 0, 0.0) ) * _WindPower ) * tex2DNode15.a ).rgb;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _Normal_Power );
			float2 uv_Base_Color = i.uv_texcoord * _Base_Color_ST.xy + _Base_Color_ST.zw;
			float4 tex2DNode89 = tex2D( _Base_Color, uv_Base_Color );
			float2 uv_TexCoord154 = i.uv_texcoord * _Tilling;
			float simplePerlin2D152 = snoise( uv_TexCoord154*_Tilling_Color );
			simplePerlin2D152 = simplePerlin2D152*0.5 + 0.5;
			o.Albedo = ( ( _Color * tex2DNode89 ) + ( _Color_Tilling * tex2DNode89 * simplePerlin2D152 ) ).rgb;
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float4 tex2DNode15 = tex2D( _Mask, uv_Mask );
			o.Smoothness = ( _Smoothness_Power * tex2DNode15.g );
			float lerpResult168 = lerp( 1.0 , i.vertexColor.r , _Ambient_Occlusion);
			o.Occlusion = lerpResult168;
			o.Alpha = 1;
			clip( tex2DNode89.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Unlit/Color"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18909
-1913;61;1920;953;2645.965;1362.419;2.58383;True;False
Node;AmplifyShaderEditor.RangedFloatNode;22;-2009.076,1121.477;Float;False;Property;_Wind_Size;Wind_Size;6;0;Create;True;0;0;0;False;0;False;0.5;0.297;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;24;-1764.239,1318.416;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.1;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;16;-1851.015,769.6559;Float;True;Property;_Noise;Noise;13;0;Create;True;0;0;0;False;0;False;3948ecb3ddda0914ab24867c36c4a45c;3948ecb3ddda0914ab24867c36c4a45c;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;25;-1358.345,1508.736;Float;False;Property;_WindSpeed;Wind Speed;5;0;Create;True;0;0;0;False;0;False;0.2327153;0.364;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;26;-1537.282,1159.2;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;0;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;165;-1266.379,-579.7614;Inherit;False;Property;_Tilling;Tilling;15;0;Create;True;0;0;0;False;0;False;0,0;3,3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;36;-1080.616,1618.328;Float;False;Property;_WindScale;Wind Scale;3;0;Create;True;0;0;0;False;0;False;0.3622508;0.432;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;27;-983.3217,1309.003;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0.3,0.3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;155;-918.6242,-464.6346;Inherit;False;Property;_Tilling_Color;Tilling_Color;10;0;Create;True;0;0;0;False;0;False;1.49;1.49;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;-1069.624,-666.6346;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-712.6582,1492.918;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-446.3139,1537.21;Float;False;Property;_WindPower;Wind Power;4;0;Create;True;0;0;0;False;0;False;0.2506492;0.229;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;28;-629.2512,1258.394;Inherit;True;Property;_TextureSample1;Texture Sample 1;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;144;19.31287,-1171.296;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;0.9716981,0.9716981,0.9716981,0;0.7075471,0.7075471,0.7075471,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;120;-244.1502,-1183.718;Inherit;False;Property;_Color_Tilling;Color_Tilling;1;0;Create;True;0;0;0;False;0;False;0.9716981,0.9716981,0.9716981,0;0.6775098,0.8207547,0.6775098,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;89;-850.294,-1006.769;Inherit;True;Property;_Base_Color;Base_Color;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;152;-540.1752,-638.7546;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-315.5917,-356.7229;Inherit;False;Property;_Normal_Power;Normal_Power;9;0;Create;True;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;166;-720.8078,-137.3416;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;167;-828.0994,109.3791;Inherit;False;Property;_Ambient_Occlusion;Ambient_Occlusion;7;0;Create;True;0;0;0;False;0;False;0;0.58;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-184.2913,1275.195;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-600.381,-216.8072;Inherit;False;Property;_Smoothness_Power;Smoothness_Power;8;0;Create;True;0;0;0;False;0;False;0;0.14;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;222.5828,-897.7246;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;162;222.7994,-672.9164;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;15;-353.4914,300.1608;Inherit;True;Property;_Mask;Mask;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;168;-410.3971,-53.93218;Inherit;True;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;115;-136.8394,-453.9914;Inherit;True;Property;_Normal;Normal;14;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;18.79523,-210.2543;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;87.76736,854.8181;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;163;539.5239,-759.2738;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1461.67,-241.5397;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;AE/Leaves;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.67;True;True;0;True;TransparentCutout;;Geometry;All;16;all;True;True;True;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;4;False;-1;1;False;-1;0;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;Unlit/Color;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;24;0;22;0
WireConnection;26;0;16;0
WireConnection;26;3;24;0
WireConnection;27;0;26;1
WireConnection;27;2;25;0
WireConnection;154;0;165;0
WireConnection;35;0;27;0
WireConnection;35;1;36;0
WireConnection;28;0;16;0
WireConnection;28;1;35;0
WireConnection;152;0;154;0
WireConnection;152;1;155;0
WireConnection;38;0;28;0
WireConnection;38;1;39;0
WireConnection;143;0;144;0
WireConnection;143;1;89;0
WireConnection;162;0;120;0
WireConnection;162;1;89;0
WireConnection;162;2;152;0
WireConnection;168;1;166;1
WireConnection;168;2;167;0
WireConnection;115;5;169;0
WireConnection;130;0;103;0
WireConnection;130;1;15;2
WireConnection;37;0;38;0
WireConnection;37;1;15;4
WireConnection;163;0;143;0
WireConnection;163;1;162;0
WireConnection;0;0;163;0
WireConnection;0;1;115;0
WireConnection;0;4;130;0
WireConnection;0;5;168;0
WireConnection;0;10;89;4
WireConnection;0;11;37;0
ASEEND*/
//CHKSM=97DFCA8BCF5D97EB51CB09AC89D19CB258DC580C