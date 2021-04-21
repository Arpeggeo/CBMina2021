### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 69f80bcc-bbbf-4d84-b306-4569cf056bc3
begin
	using Pkg
	Pkg.activate(@__DIR__)
	Pkg.instantiate()
end

# ╔═╡ 87198393-764f-41d2-943e-87f649d51d53
md"""

![geostats-logo](https://github.com/JuliaEarth/GeoStats.jl/blob/master/docs/src/assets/logo-text.svg?raw=true)

# Geoestatística moderna

Instrutores: [Júlio Hoffimann](https://juliohm.github.io) & [Franco Naghetini](https://github.com/fnaghetini)

"""

# ╔═╡ cb333354-a28a-11eb-1d52-17d21276ef92
md"""
## Instalação

Este notebook tem a única função de instalar os pacotes utilizados no minicurso.

A célula abaixo está sendo executada automaticamente. Ela está fazendo o download dos pacotes Julia e precompilando esses pacotes nas versões exatas que utilizaremos no minicurso.

**A instalação pode demorar alguns minutos** dependendo da sua velocidade de internet e configurações de computador.
"""

# ╔═╡ 672de16e-6a18-4cbf-8a4a-b64bae64a9ed
md"""
Para confirmar que todos os pacotes do projeto foram instalados corretamente, volte ao terminal Julia de onde lançou este notebook e confira o log de instalação. Caso alguma mensagem de erro apareça em vermelho, favor reportar aos instrutores.

Estamos ansiosos para conhecê-los!

Boa sorte na instalação.

![handshake](https://media.giphy.com/media/xT9DPIlGnuHpr2yObu/giphy.gif)
"""

# ╔═╡ Cell order:
# ╟─87198393-764f-41d2-943e-87f649d51d53
# ╟─cb333354-a28a-11eb-1d52-17d21276ef92
# ╠═69f80bcc-bbbf-4d84-b306-4569cf056bc3
# ╟─672de16e-6a18-4cbf-8a4a-b64bae64a9ed
