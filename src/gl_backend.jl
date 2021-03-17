try
    using GLFW
catch e
    @warn("""
        OpenGL/GLFW wasn't loaded correctly or couldn't be initialized.
        This likely means, you're on a headless server without having OpenGL support setup correctly.
        Have a look at the troubleshooting section in the readme:
        https://github.com/JuliaPlots/GLMakie.jl#troubleshooting-opengl.
    """)
    rethrow(e)
end

include("GLAbstraction/GLAbstraction.jl")

using .GLAbstraction

const atlas_texture_cache = Dict{Any, Tuple{Texture{Float16, 2}, Function}}()

function get_texture!(atlas)
    # clean up dead context!
    filter!(atlas_texture_cache) do (ctx, tex_func)
        if GLAbstraction.context_alive(ctx)
            return true
        else
            AbstractPlotting.remove_font_render_callback!(tex_func[2])
            return false
        end
    end
    tex, func = get!(atlas_texture_cache, GLAbstraction.current_context()) do
        tex = Texture(
                atlas.data,
                minfilter = :linear,
                magfilter = :linear,
                # TODO: Consider alternatives to using the builtin anisotropic
                # samplers for signed distance fields; the anisotropic
                # filtering should happen *after* the SDF thresholding, but
                # with the builtin sampler it happens before.
                anisotropic = 16f0,
                mipmap = true
        )
        # update the texture, whenever a new font is added to the atlas
        function callback(distance_field, rectangle)
            ctx = tex.context
            if GLAbstraction.context_alive(ctx)
                prev_ctx = GLAbstraction.current_context()
                ShaderAbstractions.switch_context!(ctx)
                tex[rectangle] = distance_field
                ShaderAbstractions.switch_context!(prev_ctx)
            end
        end
        AbstractPlotting.font_render_callback!(callback)
        return (tex, callback)
    end
    return tex
end

# TODO
const enable_SSAO = Ref(false)
const enable_FXAA = Ref(true)

include("GLVisualize/GLVisualize.jl")
using .GLVisualize

include("glwindow.jl")
include("postprocessing.jl")
include("screen.jl")
include("rendering.jl")
include("events.jl")
include("drawing_primitives.jl")
include("display.jl")
