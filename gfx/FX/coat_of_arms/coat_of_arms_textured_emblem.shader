Includes = {
	"coat_of_arms/coat_of_arms_textured_emblem.fxh"
}

PixelShader =
{
	MainCode PS_Emblem
	{
		Input = "VS_OUTPUT_COA_ATLAS"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				return Emblem( Input );
			}
		]]
	}
}

Effect coa_create_textured_emblem
{
	VertexShader = VertexShaderCOAEmblem
	PixelShader = PS_Emblem
	BlendState = BlendState
}

Effect coa_create_textured_emblem_masked
{
	VertexShader = VertexShaderCOAEmblem
	PixelShader = PS_Emblem
	BlendState = BlendState
	Defines = { "USE_PATTERN_MASK" }
}

Effect coa_create_colored_emblem
{
	VertexShader = VertexShaderCOAEmblem
	PixelShader = PS_Emblem
	BlendState = BlendState
	Defines = { "COLORED_EMBLEM" }
}

Effect coa_create_colored_emblem_pattern_mask
{
	VertexShader = VertexShaderCOAEmblem
	PixelShader = PS_Emblem
	BlendState = BlendState
	Defines = { "USE_PATTERN_MASK" "COLORED_EMBLEM" }
}