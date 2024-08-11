Includes = {
	"cw/pdxmesh.fxh"
	"standardfuncsgfx.fxh"
}

PixelShader =
{
	TextureSampler DiffuseMap
	{
		Index = 0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler SpecularMap
	{
		Index = 1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	#TextureSampler NormalMap
	#{
	#	Index = 2
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Wrap"
	#	SampleModeV = "Wrap"
	#}	
	TextureSampler FlagTexture
	{
		Ref = PdxMeshCustomTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
}

VertexStruct VS_OUTPUT
{
    float4 Position			: PDX_POSITION;
	float3 Normal			: TEXCOORD0;
	float3 Tangent			: TEXCOORD1;
	float3 Bitangent		: TEXCOORD2;
	float2 UV0				: TEXCOORD3;
	float2 UV1				: TEXCOORD4;
	float3 WorldSpacePos	: TEXCOORD5;
	uint InstanceIndex 	: TEXCOORD6;
};


VertexShader =
{
	Code
	[[
		VS_OUTPUT ConvertOutput( VS_OUTPUT_PDXMESH In )
		{
			VS_OUTPUT Out;
			
			Out.Position = In.Position;
			Out.Normal = In.Normal;
			Out.Tangent = In.Tangent;
			Out.Bitangent = In.Bitangent;
			Out.UV0 = In.UV0;
			Out.UV1 = In.UV1;
			Out.WorldSpacePos = In.WorldSpacePos;
			return Out;
		}
		void CalculateSineAnimation( float2 UV, inout float3 Position, inout float3 Normal, inout float4 Tangent )
		{

			// CONSTANT BUFFER VALUES
			float SmallWaveScale = 1.5;
			float WaveScale = 0.5;
			float AnimationSpeed = 1.4;

			float AnimSeed = UV.x;
			
			float Time = GlobalTime * AnimationSpeed;
			
			float SmallWaveV = Time - AnimSeed * SmallWaveScale;
			float SmallWaveD = -( AnimSeed * SmallWaveScale );
			float SmallWave = sin( SmallWaveV );
			float CombinedWave = SmallWave;
			
			// Wave
			float3 AnimationDir = float3( 0, 0.08, -1 );
			float Wave = WaveScale * smoothstep( 0.0, 0.12, AnimSeed ) * CombinedWave;
			float Derivative = ( WaveScale * 1.0f) * AnimSeed * -( SmallWave + cos( SmallWaveV ) * SmallWaveD );

			// Vertex position
			Position += AnimationDir * Wave;
			
			// Normals
			float2 WaveTangent = normalize( float2( 1.0f, Derivative ) );
			float3 WaveNormal = normalize( float3( WaveTangent.y, 0.0f, -WaveTangent.x ));
			
			float WaveNormalStrength = 1.0f;

			Normal = normalize( lerp( Normal, WaveNormal, 0.65f ) ); // Wave normal strength
		}
	]]
	MainCode VS_animated
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				#ifndef FLAG_WAVES_DISABLED
					float2 AnimUV = saturate( Input.Position.xy / float2( 9.0f, 6.0f ) + vec2( 0.5f ) );
					CalculateSineAnimation( AnimUV, Input.Position, Input.Normal, Input.Tangent );
				#endif
				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				Out.InstanceIndex = Input.InstanceIndices.y;
				return Out;
			}
		]]
	}
}

PixelShader =
{	
	MainCode PS_standard
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[		
			float4 GetUserColor( uint InstanceIndex )
			{
				// assuming that the mesh user data only contains a color
				return Data[ InstanceIndex + PDXMESH_USER_DATA_OFFSET ];
			}	
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( DiffuseMap, Input.UV0 );
				float4 Properties = PdxTex2D( SpecularMap, Input.UV0 );
				
				#ifdef COLOR
					Diffuse.rgb = lerp( Diffuse.rgb, Diffuse.rgb * GetUserColor( Input.InstanceIndex ).rgb, Properties.r );
				#endif
				#ifdef FLAG
					Diffuse.rgb *= PdxTex2D( FlagTexture, Input.UV1 ).rgb;
				#endif
				return Diffuse;
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	SourceAlpha = "ONE"
	DestAlpha = "INV_SRC_ALPHA"
}

Effect gui_banner_flag
{
	VertexShader = "VS_animated"
	PixelShader = "PS_standard"
	Defines = { "FLAG" }
}
Effect gui_banner_color
{
	VertexShader = "VS_animated"
	PixelShader = "PS_standard"
	Defines = { "COLOR" }
}