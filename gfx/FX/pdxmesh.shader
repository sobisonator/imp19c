Includes = {
	"cw/pdxmesh.fxh"
	"cw/utility.fxh"
	"cw/shadow.fxh"
	"cw/camera.fxh"
	"jomini/jomini_fog.fxh"
	"jomini/jomini_lighting.fxh"
	"fog_of_war.fxh"
	"jomini/jomini_water.fxh"
	"jomini/jomini_mapobject.fxh"
	"constants.fxh"
	"standardfuncsgfx.fxh"
	"winter.fxh"
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
	TextureSampler PropertiesMap
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
	#TextureSampler LightIndexMap
	#{
	#	Index = 3
	#	MagFilter = "Point"
	#	MinFilter = "Point"
	#	MipFilter = "Point"
	#	SampleModeU = "Clamp"
	#	SampleModeV = "Clamp"
	#}
	#TextureSampler LightDataMap
	#{
	#	Index = 4
	#	MagFilter = "Point"
	#	MinFilter = "Point"
	#	MipFilter = "Point"
	#	SampleModeU = "Clamp"
	#	SampleModeV = "Clamp"
	#}
	TextureSampler UniqueMap
    {
		Index = 5
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
	TextureSampler WinterMap
	{
		Ref = WinterMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler TerrainDiffuseArray
	{
		Ref = PdxTerrainTextures0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}
	TextureSampler TerrainNormalsArray
	{
		Ref = PdxTerrainTextures1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}
	TextureSampler TerrainMaterialArray
	{
		Ref = PdxTerrainTextures2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}
	TextureSampler TerrainColorMapTexture
	{
		Ref = PdxTerrainColorMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler FlagTexture
	{
		Ref = PdxMeshCustomTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	# MOD(map-skybox)
	TextureSampler SkyboxSample
	{
		Index = 12
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		Type = "Cube"
		File = "gfx/map/environment/SkyBox.dds"
		srgb = yes
		Border_Color = { 1 1 1 1 }
	}
	# END MOD
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
				return Out;
			}
		]]
	}

	MainCode VS_mapobject
	{
		Input = "VS_INPUT_PDXMESH_MAPOBJECT"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				float4x4 WorldMatrix = UnpackAndGetMapObjectWorldMatrix( Input.InstanceIndex24_Opacity8 );
				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShader( PdxMeshConvertInput( Input ), 0/*bone offset not supported*/, WorldMatrix ) );
				Out.InstanceIndex = Input.InstanceIndex24_Opacity8;
				return Out;
			}
		]]
	}
}

PixelShader =
{
	Code

	[[

	// This is passed on through SUnitConstants
	#if defined( USER_COLOR )
		static const int USER_DATA_PRIMARY_COLOR = 0;
		static const int USER_DATA_SECONDARY_COLOR = 1;
		static const int COLOR_OFFSET = 2;
	#else
		static const int COLOR_OFFSET = 0;
	#endif
	#if defined( FLAG )
			static const int USER_DATA_ATLAS_SLOT = 2;
	#endif
	// END of SUnitConstants

	#if defined( ANIMATE_UV )
		static const int USER_DATA_UV_ANIMATION = COLOR_OFFSET;
		static const int ANIMATE_UV_OFFSET = 1;
	#else
		static const int ANIMATE_UV_OFFSET = 0;
	#endif

	#if defined( ATLAS )
		static const int USER_DATA_ATLAS_UV_OFFSET = COLOR_OFFSET + ANIMATE_UV_OFFSET;
	#endif

		float2 MirrorOutsideUV(float2 UV)
		{
			if ( UV.x < 0.0 ) UV.x = -UV.x;
			else if ( UV.x > 1.0 ) UV.x = 2.0 - UV.x;
			if ( UV.y < 0.0 ) UV.y = -UV.y;
			else if ( UV.y > 1.0 ) UV.y = 2.0 - UV.y;
			return UV;
		}

		float4 GetUserData( uint InstanceIndex, int DataOffset )
		{
			return Data[ InstanceIndex + PDXMESH_USER_DATA_OFFSET + DataOffset ];
		}

		float GetOpacity( uint InstanceIndex )
		{
			#ifdef JOMINI_MAP_OBJECT
				return UnpackAndGetMapObjectOpacity( InstanceIndex );
			#else
				return PdxMeshGetOpacity( InstanceIndex );
			#endif
		}
	]]

	# MOD(map-skybox)
	MainCode SKYX_PS_sky
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float3 FromCameraDir = normalize(Input.WorldSpacePos - CameraPosition);
				FromCameraDir.y *= 2;
				FromCameraDir.y += 0.07;
				//float3 FromCameraDir = normalize(Input.WorldSpacePos - CameraPosition) + 0.07;
				//TODO: Figure out a way to have this number adjust so the clouds look like they "move"
				//FromCameraDir.x *= 2;
				float4 CubemapSample = PdxTexCube(SkyboxSample, FromCameraDir);

				#ifdef eveningLight
					CubemapSample.r *= 5.00;
					CubemapSample.g *= 0.7;
					CubemapSample.b *= 0.31;
				#endif
				#ifdef morningLight
					CubemapSample.r *= 2.00;
					CubemapSample.g *= 0.93;
					CubemapSample.b *= 0.89;
				#endif
				#ifdef nightLight
					CubemapSample *= 0.015;
				#endif

				return CubemapSample;
			}
		]]
	}
	# END MOD

	MainCode PS_standard
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			#if defined( ATLAS )
				#ifndef DIFFUSE_UV_SET
					#define DIFFUSE_UV_SET Input.UV1 + GetUserData(Input.InstanceIndex, USER_DATA_ATLAS_UV_OFFSET).rg
				#endif

				#ifndef NORMAL_UV_SET
					#define NORMAL_UV_SET Input.UV1 + GetUserData(Input.InstanceIndex, USER_DATA_ATLAS_UV_OFFSET).rg
				#endif

				#ifndef PROPERTIES_UV_SET
					#define PROPERTIES_UV_SET Input.UV1 + GetUserData(Input.InstanceIndex, USER_DATA_ATLAS_UV_OFFSET).rg
				#endif

				#ifndef UNIQUE_UV_SET
					#define UNIQUE_UV_SET Input.UV0
				#endif
			#else
				#ifndef DIFFUSE_UV_SET
					#define DIFFUSE_UV_SET Input.UV0
				#endif

				#ifndef NORMAL_UV_SET
					#define NORMAL_UV_SET Input.UV0
				#endif

				#ifndef PROPERTIES_UV_SET
					#define PROPERTIES_UV_SET Input.UV0
				#endif
			#endif

			PDX_MAIN
			{
				#ifdef ANIMATE_UV
					float2 UvAnimation = GetUserData( Input.InstanceIndex, USER_DATA_UV_ANIMATION ).rg;
					float2 UvAnimationAdd = UvAnimation * GlobalTime;
				#else
					float2 UvAnimationAdd = vec2( 0.0f );
				#endif



				float4 Diffuse = PdxTex2D( DiffuseMap, DIFFUSE_UV_SET + UvAnimationAdd );

				#ifdef ANIMATE_UV
					Diffuse.a = PdxTex2D( DiffuseMap, DIFFUSE_UV_SET ).a;
				#endif

				#ifdef UNDERWATER
					Diffuse.rgb *= 0.25;
				#endif

				Diffuse.a = PdxMeshApplyOpacity( Diffuse.a, Input.Position.xy, GetOpacity( Input.InstanceIndex ) );

				float4 Properties = PdxTex2D( PropertiesMap, PROPERTIES_UV_SET + UvAnimationAdd );

				float4 NormalPacked = PdxTex2D( NormalMap, NORMAL_UV_SET + UvAnimationAdd );
				float3 NormalSample = UnpackRRxGNormal( NormalPacked );

				float3x3 TBN = Create3x3( normalize( Input.Tangent ), normalize( Input.Bitangent ), normalize( Input.Normal ) );
				float3 Normal = mul( NormalSample, TBN );

				float3 UserColor = float3( 1.0f, 1.0f, 1.0f );
				#if defined( USER_COLOR )
					UserColor = lerp( UserColor, GetUserData( Input.InstanceIndex, USER_DATA_PRIMARY_COLOR ).rgb, Properties.r );
					UserColor = lerp( UserColor, GetUserData( Input.InstanceIndex, USER_DATA_SECONDARY_COLOR ).rgb, NormalPacked.b );
				#endif
				#ifdef FLAG
					float4 CoAAtlasSlot = GetUserData( Input.InstanceIndex, USER_DATA_ATLAS_SLOT );
					float2 FlagCoords = CoAAtlasSlot.xy + ( MirrorOutsideUV( Input.UV1 ) * CoAAtlasSlot.zw );
					UserColor = lerp( UserColor, PdxTex2D( FlagTexture, FlagCoords ).rgb, Properties.r );
				#endif

				Diffuse.rgb *= UserColor;

				#if defined( ATLAS )
					float4 Unique = PdxTex2D( UniqueMap, UNIQUE_UV_SET );

					// blend normals
					float3 UniqueNormalSample = UnpackRRxGNormal( Unique );
					NormalSample = ReorientNormal( UniqueNormalSample, NormalSample );

					// multiply AO
					Diffuse.rgb *= Unique.bbb;
				#endif


				#if defined( ENABLE_SNOW )
					ApplySnowMesh( Diffuse.rgb, Normal, Properties, Input.WorldSpacePos, TerrainColorMapTexture, WinterMap, TerrainDiffuseArray, TerrainNormalsArray, TerrainMaterialArray );
				#endif


				SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Properties.a, Properties.g, Properties.b );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTexture );

				float3 Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );

				#if !defined( UNDERWATER ) && !defined( DISABLE_FOG_OF_WAR )
					Color = ApplyFogOfWar( Color, Input.WorldSpacePos, FogOfWarAlpha );
					float vFogFactor = min(CalculateDistanceFogFactor( Input.WorldSpacePos ),0.6);
					#if defined(nightLight)
						vFogFactor *= 0.05;
					#endif
					Color = ApplyDistanceFog( Color, vFogFactor );
				#endif

				float Alpha = Diffuse.a;
				#ifdef UNDERWATER
					clip( WaterHeight - Input.WorldSpacePos.y + 0.1 ); // +0.1 to avoid gap between water and mesh

					Alpha = CompressWorldSpace( Input.WorldSpacePos );
				#endif

				DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );
				return float4( Color, Alpha );
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = no
}

BlendState alpha_blend
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}

BlendState alpha_additive
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "ONE"
	WriteMask = "RED|GREEN|BLUE|ALPHA"
}

BlendState alpha_to_coverage
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	AlphaToCoverage = yes
}

DepthStencilState DepthStencilState
{
	StencilEnable = yes
	FrontStencilPassOp = replace
	StencilRef = 1
}

DepthStencilState depth_no_write
{
	DepthEnable = yes
	DepthWriteEnable = no
}


RasterizerState ShadowRasterizerState
{
	DepthBias = 40000
	SlopeScaleDepthBias = 2
}


Effect standard
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
}
Effect standardShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"

	RasterizerState = ShadowRasterizerState
}
Effect standard_atlas
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" }
}
Effect standard_atlasShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}
Effect standard_atlas_disable_fow
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" "DISABLE_FOG_OF_WAR" }
}
Effect standard_atlas_disable_fowShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}
Effect standard_snow
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "ENABLE_SNOW" }
}
Effect standard_snowShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"

	RasterizerState = ShadowRasterizerState
}
Effect standard_usercolor
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "USER_COLOR" }
}
Effect standard_usercolorShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"

	RasterizerState = ShadowRasterizerState
	Defines = { "USER_COLOR" }
}
Effect standard_flag
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "FLAG" }
}
Effect standard_flagShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"

	RasterizerState = ShadowRasterizerState
	Defines = { "FLAG" }
}
Effect standard_usercolor_flag
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "USER_COLOR" "FLAG" }
}
Effect standard_usercolor_flagShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"

	RasterizerState = ShadowRasterizerState
	Defines = { "USER_COLOR" "FLAG" }
}



Effect standard_alpha_blend
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_no_write"
}
Effect standard_alpha_blendShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"

	RasterizerState = ShadowRasterizerState
}

Effect standard_alpha_to_coverage
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
}

Effect standard_animate_uv
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "ANIMATE_UV" }
}

Effect standard_animate_uv_alpha_blend
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_no_write"
	Defines = { "ANIMATE_UV" }
}

Effect standard_animate_uv_alpha_additive
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_additive"
	DepthStencilState = "depth_no_write"
	Defines = { "ANIMATE_UV" }
}

Effect material_test
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "NORMAL_UV_SET Input.UV1" "DIFFUSE_UV_SET Input.UV1" }
}

#Clausewitz shaders!
Effect DebugNormal
{
	VertexShader = "VertexDebugNormal"
	PixelShader = "PixelDebugNormal"
}

# Map object shaders
Effect standard_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
}
Effect standardShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"

	RasterizerState = ShadowRasterizerState
}

Effect standard_snow_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "ENABLE_SNOW" }
}
Effect standard_snowShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"

	RasterizerState = ShadowRasterizerState
}


Effect standard_alpha_blend_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"

	BlendState = "alpha_blend"
	Defines = { "IS_ALPHA_BLEND" }
}
Effect standard_alpha_blendShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"

	RasterizerState = ShadowRasterizerState
	Defines = { "IS_ALPHA_BLEND" }
}

Effect standard_atlas_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" }
}
Effect standard_atlasShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}


# MOD(map-skybox)
Effect SKYX_sky
{
	VertexShader = "VS_standard"
	PixelShader = "SKYX_PS_sky"
}

Effect SKYX_sky_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "SKYX_PS_sky"
}

Effect SKYX_sky_selection_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "SKYX_PS_sky"
}
# END MOD