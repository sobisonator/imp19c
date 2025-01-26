Includes = {
	"cw/pdxmesh.fxh"
	"cw/shadow.fxh"
	"cw/camera.fxh"
	"cw/heightmap.fxh"
	"cw/pdxterrain.fxh"
	"jomini/jomini_fog.fxh"
	"jomini/jomini_lighting.fxh"
	"fog_of_war.fxh"
	#"winter.fxh"
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
	TextureSampler NormalMap
	{
		Index = 2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler EnvironmentMap
	{
		Ref = JominiEnvironmentMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		Type = "Cube"
	}
	TextureSampler ShadowTexture
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		CompareFunction = less_equal
		SamplerType = "Compare"
	}
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	#TextureSampler WinterMap
	#{
	#	Ref = WinterMap
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Wrap"
	#	SampleModeV = "Wrap"
	#}
	#TextureSampler TerrainDiffuseArray
	#{
	#	Ref = TerrainTextureArrays0
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Wrap"
	#	SampleModeV = "Wrap"
	#	type = "2darray"
	#}
	#TextureSampler TerrainNormalsArray
	#{
	#	Ref = TerrainTextureArrays1
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Wrap"
	#	SampleModeV = "Wrap"
	#	type = "2darray"
	#}
	#TextureSampler TerrainMaterialArray
	#{
	#	Ref = TerrainTextureArrays2
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Wrap"
	#	SampleModeV = "Wrap"
	#	type = "2darray"
	#}
}

VertexStruct VS_OUTPUT
{
    float4 Position			: PDX_POSITION;
	float2 UV0				: TEXCOORD0;
	float2 UV1				: TEXCOORD1;
	float3 WorldSpacePos	: TEXCOORD2;
	float3 Bitangent		: TEXCOORD3;
	uint InstanceIndex 		: TEXCOORD4;
};


VertexShader =
{
	Code
	[[
		VS_OUTPUT ConvertOutput( VS_OUTPUT_PDXMESH In )
		{
			VS_OUTPUT Out;
			
			Out.Position = In.Position;
			Out.UV0 = In.UV0;
			Out.UV1 = In.UV1;
			Out.WorldSpacePos = In.WorldSpacePos;
			Out.Bitangent = In.Bitangent;
			return Out;
		}
	]]
	
	MainCode VS_standard
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				Out.InstanceIndex = Input.InstanceIndices.y;
				#ifdef NEW_CITY_DECAL
					Out.WorldSpacePos.y = GetHeight( Out.WorldSpacePos.xz ) + 0.18;
				#else
					Out.WorldSpacePos.y = GetHeight( Out.WorldSpacePos.xz ) + 0.05;
				#endif
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Out.WorldSpacePos.xyz, 1.0 ) );

				return Out;
			}
		]]
	}
}

PixelShader =
{
	Code
	[[
		float3 CalcDecal( float2 UV, float3 Bitangent, float3 WorldSpacePos, float3 Diffuse )
		{
			float4 Properties = PdxTex2D( SpecularMap, UV );
			float4 NormalPacked = PdxTex2D( NormalMap, UV );
			float3 NormalSample = UnpackRRxGNormal( NormalPacked );
			
			float3 Normal = CalculateNormal( WorldSpacePos.xz );
			#ifdef TANGENT_SPACE_NORMALS
				float3 Tangent = cross( Bitangent, Normal );
				float3x3 TBN = Create3x3( normalize( Tangent ), normalize( Bitangent ), Normal );
				Normal = normalize( mul( NormalSample, TBN ) );
			#else
				Normal = ReorientNormal( Normal, NormalSample );
			#endif
			
			float2 ColorMapCoords = WorldSpacePos.xz * WorldSpaceToTerrain0To1;
			float3 ColorMap = PdxTex2D( ColorTexture, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;
			Diffuse = GetOverlay( Diffuse, ColorMap, 0.5 );
			
			//#if defined( ENABLE_SNOW )
			//	ApplySnowMesh( Diffuse, Normal, Properties, WorldSpacePos, WinterMap, TerrainDiffuseArray, TerrainNormalsArray, TerrainMaterialArray );
			//#endif
			
			SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse, Normal, Properties.a, Properties.g, Properties.b );
			SLightingProperties LightingProps = GetSunLightingProperties( WorldSpacePos, ShadowTexture );
			
			float3 Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );

			Color = ApplyFogOfWar( Color, WorldSpacePos, FogOfWarAlpha );
			Color = ApplyDistanceFog( Color, WorldSpacePos );
			
			DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );
			return Color;
		}
	]]
	
	MainCode PS_world
	{
		TextureSampler DecalAlphaTexture
		{
			Index = 3
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
		}
		
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			#ifdef NEW_CITY_DECAL
				static const float DECAL_TILING_SCALE = 1.0;
			#else
				static const float DECAL_TILING_SCALE = 0.15;
			#endif
		
			PDX_MAIN
			{
				float Alpha = PdxTex2D( DecalAlphaTexture, Input.UV0 ).r;
				//return float4( vec3( 1 ), Alpha );
				
				Alpha = PdxMeshApplyOpacity( Alpha, Input.Position.xy, PdxMeshGetOpacity( Input.InstanceIndex ) );
				#ifdef NEW_CITY_DECAL
					float2 DetailUV = Input.UV0 * float2( DECAL_TILING_SCALE, -DECAL_TILING_SCALE );
				#else
					float2 DetailUV = Input.WorldSpacePos.xz * float2( DECAL_TILING_SCALE, -DECAL_TILING_SCALE );
				#endif
				
				float4 Diffuse = PdxTex2D( DiffuseMap, DetailUV );
				float3 Color = CalcDecal( DetailUV, Input.Bitangent, Input.WorldSpacePos, Diffuse.rgb );
				#ifdef NEW_CITY_DECAL
					Alpha = CalcHeightBlendFactors( float4( Diffuse.a, 0.5, 0.0, 0.0 ), float4( Alpha, 1.0 - Alpha, 0.0, 0.0 ), 0.25 ).r;
				#else
					Alpha = CalcHeightBlendFactors( float4( Diffuse.a, 0.3, 0.0, 0.0 ), float4( Alpha, 1.0 - Alpha, 0.0, 0.0 ), 0.25 ).r;
				#endif
				return float4( Color, Alpha );
			}
		]]
	}
	
	MainCode PS_local
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( DiffuseMap, Input.UV0 );
				Diffuse.a = PdxMeshApplyOpacity( Diffuse.a, Input.Position.xy, GetOpacity( Input.InstanceIndex ) );
				
				float3 Color = CalcDecal( Input.UV0, Input.Bitangent, Input.WorldSpacePos, Diffuse.rgb );
				
				return float4( Color, Diffuse.a );
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}


RasterizerState RasterizerState
{
	#fillmode = wireframe
	DepthBias = -10000
	SlopeScaleDepthBias = -2
}


DepthStencilState DepthStencilState
{
	#DepthEnable = no
	DepthWriteEnable = no
}


Effect decal_world
{
	VertexShader = "VS_standard"
	PixelShader = "PS_world"
}

Effect new_decal_world
{
	VertexShader = "VS_standard"
	PixelShader = "PS_world"

	Defines = { "NEW_CITY_DECAL" }
}

Effect decal_local
{
	VertexShader = "VS_standard"
	PixelShader = "PS_local"
	
	Defines = { "TANGENT_SPACE_NORMALS" }
}