### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 32f6d41e-3248-4549-9546-53b34d5aa7c6
begin
	# instantiate environment
	using Pkg; Pkg.activate(@__DIR__); Pkg.instantiate()

	# load packages used in this notebook
	using GeoStats, Plots

	# default plot settings
	gr(format=:png)
end;

# ╔═╡ 762a6e04-fcb7-4713-859d-fdbfe8ead1bc
html"""
<p style="background-color:lightgrey" xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">GeoStats.jl at CBMina</span> by <span property="cc:attributionName">Júlio Hoffimann & Franco Naghetini</span> is licensed under <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>
"""

# ╔═╡ 32429926-f6c3-44b8-b012-d2c67cad0b6d
md"""
![geostats-logo](https://github.com/JuliaEarth/GeoStats.jl/blob/master/docs/src/assets/logo-text.svg?raw=true)

# Geostatística moderna

Instrutores: [Júlio Hoffimann](https://juliohm.github.io) & [Franco Naghetini](https://github.com/fnaghetini)
"""

# ╔═╡ 3c79e7aa-b316-4c4b-b44e-e73312085c20
md"""
## Aprendizado geoestatístico

Neste módulo aprenderemos sobre esta nova área de **aprendizado geoestatístico** ([Hoffimann 2021](https://arxiv.org/abs/2102.08791)). Introduziremos os elementos do problema de aprendizado com dados geoespaciais, e veremos como a biblioteca [GeoStats.jl](https://github.com/JuliaEarth/GeoStats.jl) está na vanguarda dessa tecnologia.

Existem questões teóricas muito interessantes que não cobriremos neste minicurso, e que estão sendo desenvolvidas ativamente no projeto. Nos concentraremos em **exemplos práticos** para que você possa adaptar este notebook aos seus próprios desafios na mineração.
"""

# ╔═╡ 4a3fb559-73dd-41e0-8a11-993e5bf286bf
html"""
<iframe width="560" height="315" src="https://www.youtube.com/embed/6S_9GLMv3xI" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
"""

# ╔═╡ f3ff120d-940c-40c9-b9f6-24d4a0b3aec1
md"""
Ao final deste módulo você será capaz de:

- Identificar os **elementos do aprendizado geoestatístico** na mineração
- Definir o **problema de aprendizado** de forma clara com o GeoStats.jl
- Resolver o problema com vários **modelos de aprendizado** disponíveis
"""

# ╔═╡ 1856e01b-2d55-448d-8bdf-e59825934193
md"""
### Elementos do aprendizado
"""

# ╔═╡ 06a5a386-5595-483a-9ce7-a3433486c0c3


# ╔═╡ 661a2b3f-469c-45ef-a024-99daf491e363
md"""
### Definição do problema
"""

# ╔═╡ cc2332d4-44b9-4459-8609-7a5edbc1c2a6


# ╔═╡ 71a5ad94-83df-48de-869c-ec23bd7ab1d9
md"""
### Solução e validação
"""

# ╔═╡ f3f34906-84d2-40b4-b198-2330a171ba06


# ╔═╡ Cell order:
# ╟─32f6d41e-3248-4549-9546-53b34d5aa7c6
# ╟─762a6e04-fcb7-4713-859d-fdbfe8ead1bc
# ╟─32429926-f6c3-44b8-b012-d2c67cad0b6d
# ╟─3c79e7aa-b316-4c4b-b44e-e73312085c20
# ╟─4a3fb559-73dd-41e0-8a11-993e5bf286bf
# ╟─f3ff120d-940c-40c9-b9f6-24d4a0b3aec1
# ╟─1856e01b-2d55-448d-8bdf-e59825934193
# ╠═06a5a386-5595-483a-9ce7-a3433486c0c3
# ╟─661a2b3f-469c-45ef-a024-99daf491e363
# ╠═cc2332d4-44b9-4459-8609-7a5edbc1c2a6
# ╟─71a5ad94-83df-48de-869c-ec23bd7ab1d9
# ╠═f3f34906-84d2-40b4-b198-2330a171ba06
