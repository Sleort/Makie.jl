# This file was generated, do not modify it. # hide
__result = begin # hide
  
using CairoMakie
CairoMakie.activate!()

f = Figure()
ax = Axis(f[1, 1])

lines!(ax, 0..20, sin)
vspan!(ax, [0, 2pi, 4pi], [pi, 3pi, 5pi], color = (:red, 0.2))
hspan!(ax, -1.1, -0.9, color = (:blue, 0.2))

f

  end # hide
  save(joinpath(@OUTPUT, "example_17064304980503968551.png"), __result) # hide
  
  nothing # hide