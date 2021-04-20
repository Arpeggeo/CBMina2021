### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 3e0ccac6-3efd-11eb-2949-a9aa855356b2
begin
	# instantiate environment
	using Pkg; Pkg.activate(@__DIR__); Pkg.instantiate()

	# load packages used in this notebook
	using GeoStats
	using Distributions
	using PlutoUI
	using Plots
	using StatsPlots

	# default plot settings
	gr(format=:png)
end;

# ╔═╡ 51dd001e-41f7-11eb-0f21-6b97ea0d70cb
html"""
<p style="background-color:lightgrey" xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">GeoStats.jl at CBMina</span> by <span property="cc:attributionName">Júlio Hoffimann & Franco Naghetini</span> is licensed under <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>
"""

# ╔═╡ 8066e25c-3fc1-11eb-1d21-89b95a15287f
md"""
![geostats-logo](https://github.com/JuliaEarth/GeoStats.jl/blob/master/docs/src/assets/logo-text.svg?raw=true)

# Geostatística moderna

Instrutores: [Júlio Hoffimann](https://juliohm.github.io) & [Franco Naghetini](https://github.com/fnaghetini)
"""

# ╔═╡ f2a77ee0-3ee1-11eb-1ce3-213bfda427c6
md"""
## Simulação de recursos

Neste curto módulo, aprenderemos sobre **simulação geoestatística** de recursos. Um conceito simples, mas que é muitas vezes explicado de forma misteriosa na indústria.

Como temos muito material para cobrir no último módulo do minicurso (**aprendizado geoestatístico**), não nos aprofundaremos nos diferentes métodos de simulação disponíveis no GeoStats.jl.

O objetivo deste módulo é ilustrar que após a variografia ter sido realizada, é trivial utilizar um solver de **simulação Gaussiana**.

### Agenda

1. Estimação vs. Simulação
2. Simulação com GeoStats.jl
"""

# ╔═╡ 902f52bf-db33-48c7-a626-453856f2da37
md"""
### 1. Estimação vs. Simulação

#### Simulação 1D

Para entendermos o conceito de simulação, vamos considerar uma distribuição 1D:
"""

# ╔═╡ 8cb117c9-b256-46a4-a109-f018096fa14d
d1 = Normal(0, 1)

# ╔═╡ a76c95eb-4949-4ffc-a58e-073abf63908d
plot(d1, func=cdf, label = "CDF")

# ╔═╡ 3e16501d-1c36-4115-9f52-fab7d243036b
md"""
Podemos amostrar **qualquer** distribuição 1D dada a sua funcão de probabilidade acumulada $CDF$ utilizando o método da função inversa:

1. Primeiro nós geramos um número aleatório uniformemente no intervalo $u \sim Uniform(0,1)$.
2. Em seguida avaliamos a função $CDF^{-1}(u)$ para obter uma amostra da distribuição.

Esse método e outros métodos estão disponíveis na função `rand`:
"""

# ╔═╡ 6a20c9f6-aa3a-4a87-a6dd-f727f19d8f94
rand(d1)

# ╔═╡ 30daa327-7154-4678-9dbc-e52438ce6c99
md"""
A função aceita um número n = $(@bind n Scrubbable(1:100, default=50)) de amostras como segundo parâmetro, que podemos visualizar no eixo horizontal do plot junto ao valor médio da distribuição:
"""

# ╔═╡ e435eb7d-3f90-4a1a-a6c7-bc27bf4d0b64
xₛ = rand(d1, n)

# ╔═╡ c469fefc-038b-435a-b3b7-f1dc94f8815d
begin
	plot(d1, fill = true, alpha = 0.5,
		 label = "Distribuição 1D")
	vline!([mean(d1)], label = "Média")
	scatter!([(x, 0) for x in xₛ],
		     marker = :spike, color = :black,
		     label = "Realizações")
end

# ╔═╡ 193188b1-7b41-42c6-84d8-62e4d87c7da1
md"""
Vemos que podemos gerar várias amostras ou **realizações** da distribuição, e que cada amostra representa uma alternativa possível a variável que estamos modelando.

#### Simulação 2D

Queremos agora amostrar uma distribuição 2D. Por simplicidade, vamos nos concentrar no caso **Gaussiano**. Neste caso, basta definir um vetor média $\boldsymbol{\mu}$ e uma matriz de covariância $\boldsymbol{\Sigma}$ para especificar a distribuição.

Um método de simulação simples consiste em gerar a decomposição da matriz de covariância $\boldsymbol{\Sigma} = \boldsymbol{LU}$ em uma matriz triangular inferior $\boldsymbol{L}$ e uma matriz triangular superior $\boldsymbol{U}$, e realizar os seguintes passos:

1. Primeiro geramos amostras 1D independentemente: $x_1 \sim N(0,1)$ e $x_2 \sim N(0,1)$.
2. Em seguida geramos o vetor $\boldsymbol{x} = \boldsymbol{L}\begin{bmatrix}x_1 \\ x_2\end{bmatrix} + \boldsymbol{\mu}$ como uma amostra da distribuição 2D.

Novamente, nós podemos utilizar a função `rand` e um número m = $(@bind m Scrubbable(1:100, default=50)) de amostras:
"""

# ╔═╡ b6c9ffe2-aa49-47a4-841f-667b8b16dc42
μ = [0.0
	 0.0]

# ╔═╡ 62344df1-0908-4775-a4d4-6adf594111f9
Σ = [1.0 0.5
	 0.5 1.0]

# ╔═╡ a616edc2-5f47-490b-8ab9-616bfe7770b2
d2 = MvNormal(μ, Σ)

# ╔═╡ 9a1f16a4-34db-4d6b-ab49-d024bb47a7c1
X = rand(d2, m)

# ╔═╡ 417501f7-46df-44c7-8689-4675c07e6792
begin
	covellipse(μ, Σ, n_std=3, aspect_ratio = :equal, xlabel = "x₁", ylabel = "x₂", label = "Envelope 3σ")
	scatter!([Tuple(μ)], label = "Média")
	scatter!(Tuple.(eachcol(X)), marker = (:cross,:black), label = "Realizações")
end

# ╔═╡ 30f06d24-58ad-40b3-abc7-48d9b05fd578
md"""
#### Simulação N-D

O mesmo método de simulação 2D descrito acima funciona para distribuições em N dimensões. Vamos agora imaginar que **cada dimensão é uma localização no espaço físico**. Tudo que precisamos fazer é construir uma matriz de covariância

$\boldsymbol{\Sigma} = \begin{bmatrix}\sigma_{11} & \sigma_{12} & \cdots & \sigma_{1k}\\ \sigma_{21} & \sigma_{22} & \cdots & \sigma_{2k}\\ \sigma_{31} & \sigma_{32} & \ddots & \sigma_{3k}\\ \sigma_{k1} & \sigma_{k2} & \cdots & \sigma_{kk}\\ \end{bmatrix}$

para todas as localizações $s_1, s_2, \ldots, s_k$, e seguir o mesmo procedimento. Cada entrada da matriz é obtida da função variograma que modelamos no módulo de Krigagem:

$\sigma_{ij} = \gamma(h_{ij})$.

onde $h_{ij} = ||s_i - s_j||$ é a distância geográfica entre as localizações. Para exemplificar esse conceito, vamos considerar uma distribuição Gaussiana definida em 100 localizações:
"""

# ╔═╡ 2da0c405-7ef0-4cb3-b41d-5ae7394854f4
# Domínio 1D com 100 localizações
𝒢 = CartesianGrid(100)

# ╔═╡ 4a9b1c77-e786-43e0-b8df-2ffb47c661ae
md"""
Também vamos considerar que algumas dessas localizações já foram amostradas:
"""

# ╔═╡ 32b6405f-3847-4a1b-b1ea-538c9788ae44
begin
	# Localizações s em um domínio 1D
	s = [(20.,),(40.,),(70.,)]
	
	# Medições x(s) da variável na localização s
	x = [0.0, 1.0, -0.5]
	
	# Dado geoespacial com medições
	𝒮 = georef((X=x,), s)
end

# ╔═╡ 9603c203-9431-4709-ae79-b3f35900ecd1
md"""
Para compararmos os resultados com a Krigagem, vamos definir dois problemas geoestatísticos, um de estimação e um de simulação, e vamos resolver os dois problemas com os solvers `Kriging` e `LUGS`:
"""

# ╔═╡ d114ce29-fc89-461a-8d4c-6927a6eebd21
# Problema de estimação a ser resolvido por Krigagem
problem₁ = EstimationProblem(𝒮, 𝒢, :X)

# ╔═╡ a6383d1b-0a41-45aa-a237-1c891a164f76
# Problema de simulação a ser resolvido por Simulação Gaussiana
problem₂ = SimulationProblem(𝒮, 𝒢, :X=>Float64, 3)

# ╔═╡ fcc9e8c9-0f8a-4c82-93db-74795a73faa7
begin
	# Variograma obtido da variografia
	γ = ExponentialVariogram(range=25.)
	
	# Krigagem para resolver o problema de estimação
	solver₁ = Kriging(:X => (variogram = γ,))
	
	# Simulação LU para resolver o problema de simulação
	solver₂ = LUGS(:X => (variogram = γ,))
end;

# ╔═╡ b69fd4db-f7e4-4c63-a2da-12f9a639ce26
sol₁ = solve(problem₁, solver₁)

# ╔═╡ 322cc143-8475-42bd-9f43-68d62045cf34
sol₂ = solve(problem₂, solver₂)

# ╔═╡ b8ed44f2-24d1-4bd2-be6c-1c0371c95ffa
begin
	p = plot(xlabel = "s", ylabel = "x(s)", size = (800,400))
	plot!(sol₁[:X], ribbon = 3*sol₁["X-variance"],
		  ls = :dash, lc=:black, c=:gray90, label = "Média (Kriging)")
	for (i, real) in enumerate(sol₂)
		plot!(real[:X], label = "Realização $i (LUGS)")
	end
	plot!(𝒮, color = :black, legend = true,
		  label = "Medições", title = "Estimação vs. Simulação")
	p
end

# ╔═╡ b00c2db6-b588-4652-bd7a-df2823583537
md"""
Notamos que as **realizações são muito diferente da média**. Enquanto as realizações parecem capturar o variograma especificado, a média é um valor suavizado calculado de "infinitas" realizações.

Portanto, a variável que está sendo modelada na mina com o auxílio de variogramas nunca irá se parecer visualmente com o resultado da Krigagem a menos que a densidade de furos seja muito alta.

A **Krigagem** é amplamente difundida por diversos motivos:

1. Fornece uma estimativa estatisticamente "segura".
2. Não assume nenhuma distribuição nos dados.
2. Softwares comerciais oferecem essa opção há anos.
3. Falta de treinamento na indústria.

As **simulação Gaussiana** tem algumas vantagens:

1. Oferece estimativa de incerteza ponto a ponto.
2. Reproduz a variável espacial visualmente.

A **principal diferença** entre os dois métodos **na prática** está no fato de que a simulação Gaussiana requer **pré- e pós-processamento dos dados** para que a distribuição se aproxime de uma distribuição Gaussiana.
"""

# ╔═╡ 1b17b6c6-6001-4861-b8da-839cb561a92b
md"""
### 2. Simulação com GeoStats.jl

A literatura de simulação geoestatística é bastante rica, no entanto poucos softwares comerciais oferecem implementações desses métodos. O GeoStats.jl oferece vários métodos de simulação com excelente performance computacional.

#### LUGS

O solver `LUGS` é o solver baseado na decomposição LU da covariância, com detalhes adicionais para performance e condicionamento. É recomendado quando o número de blocos no modelo de blocos está em torno de alguns milhares de blocos como no exemplo abaixo.

Parâmetros do variograma:

range = $(@bind range Slider(1:25, default=10, show_value=true))

sill = $(@bind sill Slider(0.5:0.1:1, default=0.7, show_value=true))

nugget = $(@bind nugget Slider(0:0.05:0.2, default=0.1, show_value=true))

model = $(@bind gamma Select(["Gaussian","Spherical","Exponential"]))
"""

# ╔═╡ 81e0f6d5-9edd-4a22-b2e9-d53ee4949429
begin
	xs = rand(0.0:1.0:99.0, 100)
	ys = rand(0.0:1.0:24.0, 100)
	zs = randn(100)
		
	data = georef((X=zs,), collect(zip(xs,ys)))
end;

# ╔═╡ 230dcfb9-da92-4266-8363-0754c71b612f
begin
	model = Dict("Spherical"=>SphericalVariogram,
		         "Gaussian"=>GaussianVariogram,
		         "Exponential"=>ExponentialVariogram)
	
	g = model[gamma](sill=Float64(sill), range=Float64(range), nugget=Float64(nugget))
	
	gplot = plot(g, 0, 25, c=:black, ylim=(0,1),
		         legend=:topright, size=(650,300))
	vline!([range], c=:grey, ls=:dash, primary=false)
	annotate!(range-2, 1, "range")
	hline!([sill], c=:brown, ls=:dash, primary=false)
	annotate!(23, sill+0.05, "sill")
	if n > 0
		hline!([nugget], c=:orange, ls=:dash, primary=false)
		annotate!(23, n+0.05, "nugget")
	end
	gplot
end

# ╔═╡ 0ad94903-c4de-45d7-a025-39b5fb2f3723
begin
	P   = SimulationProblem(data, CartesianGrid(100,25), :X, 1)
	
	LU  = LUGS(:X => (variogram=g,))
	
	sol = solve(P, LU)
	
	plot(sol, clim=(-3,3), size=(700,200))
	plot!(data, markersize=2, markershape=:square,
		  markerstrokecolor=:white, markerstrokewidth=3)
end

# ╔═╡ ef7871ae-9476-4255-9957-44a619316a2c
md"""
#### FFTGS

O solver `FFTGS` é baseado na transformada de Fourier e portanto só pode ser utilizado em domínios Cartesianos com amostragem regular. Ele é extremamente rápido podendo gerar modelos 3D com **centenas de milhões** de blocos em poucos segundos.
"""

# ╔═╡ eb1fa2e8-79e8-48cf-8d23-32e3491bfaab
blocks = (1000,1000)

# ╔═╡ 6c003049-d590-4425-a72b-ebaa2309d4d0
problem = SimulationProblem(CartesianGrid(blocks...), :X=>Float64, 1)

# ╔═╡ 7799b274-de86-4c73-afeb-cbab5ee1b15f
fftgs = FFTGS(:X => (variogram = GaussianVariogram(range=30.),));

# ╔═╡ 0d274d47-541f-4903-9cf0-1d784a81682a
fftsol = solve(problem, fftgs)

# ╔═╡ b7cd766e-0fd5-453b-bd3b-751371e51072
plot(fftsol)

# ╔═╡ 247bd77b-630f-4229-8d5b-e834cf10565a
md"""
#### SGS

O solver `SGS` é baseado na simulação sequencial de blocos. É o solver mais popular na mineração por permitir elipsóides de busca, parâmetros de vizinhança, etc.

>**Aviso**: Alguns detalhes de condicionamento numérico ainda estão sendo resolvidos no `SGS`. Simulações com variogramas Gaussianos podem apresentar artefatos indesejados.
"""

# ╔═╡ caa6ae71-3ab0-4369-84ec-9c98525d0104
prob = SimulationProblem(CartesianGrid(500,500), :X=>Float64, 1)

# ╔═╡ 273f4ed4-07c1-4825-8777-b4bdd7b29f39
sgs = SGS(:X => (
		variogram    = SphericalVariogram(range=30.),
		neighborhood = Ellipsoid([10.,10.], [0.]),
		path         = RandomPath()
	)
);

# ╔═╡ 41dd3c9b-a717-41be-b403-728bb2f1b5ff
sgssol = solve(prob, sgs)

# ╔═╡ 76e910ce-ff67-47fc-b218-48293369ad73
plot(sgssol)

# ╔═╡ 6c98983f-3efd-40c5-a7ca-48f8bb3a241a
md"""
#### Outros solvers

Além de simulação Gaussiana, o GeoStats oferece vários outros solvers bastante utilizados na área de óleo e gás como o [ImageQuilting.jl](https://github.com/JuliaEarth/ImageQuilting.jl) para simulação geostatística multi-ponto.
"""

# ╔═╡ 9ce06a3e-0c74-47de-9c4b-ec861b0af535
md"""
### Resumo

Este módulo teve como principal objetivo **ilustrar as ferramentas de simulação disponíveis** no projeto. Observamos que:

- Simulação Gaussiana é uma alternativa direta à Krigagem.
- Vários solvers de simulação estão disponíveis no GeoStats.jl.
- Referências bibliográficas se encontram disponíveis na documentação.

No próximo módulo sobre **aprendizado geoestatístico** teremos mais tempo para entrar em detalhes dos métodos, e utilizaremos um caso prático para aprender sobre esta nova área de grande potencial tecnológico.
"""

# ╔═╡ Cell order:
# ╟─3e0ccac6-3efd-11eb-2949-a9aa855356b2
# ╟─51dd001e-41f7-11eb-0f21-6b97ea0d70cb
# ╟─8066e25c-3fc1-11eb-1d21-89b95a15287f
# ╟─f2a77ee0-3ee1-11eb-1ce3-213bfda427c6
# ╟─902f52bf-db33-48c7-a626-453856f2da37
# ╠═8cb117c9-b256-46a4-a109-f018096fa14d
# ╠═a76c95eb-4949-4ffc-a58e-073abf63908d
# ╟─3e16501d-1c36-4115-9f52-fab7d243036b
# ╠═6a20c9f6-aa3a-4a87-a6dd-f727f19d8f94
# ╟─30daa327-7154-4678-9dbc-e52438ce6c99
# ╠═e435eb7d-3f90-4a1a-a6c7-bc27bf4d0b64
# ╟─c469fefc-038b-435a-b3b7-f1dc94f8815d
# ╟─193188b1-7b41-42c6-84d8-62e4d87c7da1
# ╠═b6c9ffe2-aa49-47a4-841f-667b8b16dc42
# ╠═62344df1-0908-4775-a4d4-6adf594111f9
# ╠═a616edc2-5f47-490b-8ab9-616bfe7770b2
# ╠═9a1f16a4-34db-4d6b-ab49-d024bb47a7c1
# ╟─417501f7-46df-44c7-8689-4675c07e6792
# ╟─30f06d24-58ad-40b3-abc7-48d9b05fd578
# ╠═2da0c405-7ef0-4cb3-b41d-5ae7394854f4
# ╟─4a9b1c77-e786-43e0-b8df-2ffb47c661ae
# ╠═32b6405f-3847-4a1b-b1ea-538c9788ae44
# ╟─9603c203-9431-4709-ae79-b3f35900ecd1
# ╠═d114ce29-fc89-461a-8d4c-6927a6eebd21
# ╠═a6383d1b-0a41-45aa-a237-1c891a164f76
# ╠═fcc9e8c9-0f8a-4c82-93db-74795a73faa7
# ╠═b69fd4db-f7e4-4c63-a2da-12f9a639ce26
# ╠═322cc143-8475-42bd-9f43-68d62045cf34
# ╟─b8ed44f2-24d1-4bd2-be6c-1c0371c95ffa
# ╟─b00c2db6-b588-4652-bd7a-df2823583537
# ╟─1b17b6c6-6001-4861-b8da-839cb561a92b
# ╟─81e0f6d5-9edd-4a22-b2e9-d53ee4949429
# ╟─230dcfb9-da92-4266-8363-0754c71b612f
# ╟─0ad94903-c4de-45d7-a025-39b5fb2f3723
# ╟─ef7871ae-9476-4255-9957-44a619316a2c
# ╠═eb1fa2e8-79e8-48cf-8d23-32e3491bfaab
# ╠═6c003049-d590-4425-a72b-ebaa2309d4d0
# ╠═7799b274-de86-4c73-afeb-cbab5ee1b15f
# ╠═0d274d47-541f-4903-9cf0-1d784a81682a
# ╠═b7cd766e-0fd5-453b-bd3b-751371e51072
# ╟─247bd77b-630f-4229-8d5b-e834cf10565a
# ╠═caa6ae71-3ab0-4369-84ec-9c98525d0104
# ╠═273f4ed4-07c1-4825-8777-b4bdd7b29f39
# ╠═41dd3c9b-a717-41be-b403-728bb2f1b5ff
# ╠═76e910ce-ff67-47fc-b218-48293369ad73
# ╟─6c98983f-3efd-40c5-a7ca-48f8bb3a241a
# ╟─9ce06a3e-0c74-47de-9c4b-ec861b0af535
