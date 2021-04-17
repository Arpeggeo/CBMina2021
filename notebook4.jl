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

# ╔═╡ 32f6d41e-3248-4549-9546-53b34d5aa7c6
begin
	# instantiate environment
	using Pkg; Pkg.activate(@__DIR__); Pkg.instantiate()

	# load packages used in this notebook
	using GeoStats, Query
	using CSV, DataFrames
	using Distributions
	using PlutoUI
	using Plots
	using StatsPlots

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

Neste módulo aprenderemos sobre esta nova área denominada **aprendizado geoestatístico** ([Hoffimann et al 2021](https://arxiv.org/abs/2102.08791)). Introduziremos os elementos do problema de aprendizado com **dados geoespaciais**, e veremos como a biblioteca [GeoStats.jl](https://github.com/JuliaEarth/GeoStats.jl) está na vanguarda desta tecnologia.

Existem questões teóricas muito interessantes que não cobriremos neste minicurso, e que estão sendo desenvolvidas ativamente no projeto. Nos concentraremos aqui em **exemplos práticos** para que você possa adaptar este notebook aos seus próprios desafios na mineração.
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

### Agenda

1. Aprendizado **geo**estatístico
    - O que é aprendizado de máquina (a.k.a. ML)?
    - A nova área de aprendizado **geo**estatístico
    - Os elementos do aprendizado **geo**estatístico
2. Exemplos práticos com o GeoStats.jl
    - Exemplo 1
    - Exemplo 2
"""

# ╔═╡ 1856e01b-2d55-448d-8bdf-e59825934193
md"""
### 1. Aprendizado geoestatístico

#### O que é o aprendizado de máquina?

Antes de podermos entender o problema de aprendizado **geo**estatístico, isto é, o problema de aprendizado com dados **geoespacias**, precisamos entender o problema mais simples de **aprendizado de máquina** introduzido na ciência da computação na área de **inteligência artificial**.

Nessa área, buscam-se criar tecnologias capazes de "imitar" a inteligência humana. Ao invés de tentarmos definir inteligência, vamos nos concentrar em duas habilidades que nós humanos exercermos todo dia:

1. A habilidade de **raciocinar sobre fatos**
2. A habilidade **aprender com experiência**

A habilidade de **raciocínio** é o que nos permite gerar conclusões sobre fatos, segundo alguma lógica pré-estabelecida. Por exemplo, geocientistas são capazes de imaginar sistemas deposicionais na subsuperfície a quilômetros de profundidade utilizando regras de probabilidade em cima de conhecimento pré-estabelecido na literatura. [Hoffimann et al 2021. Probabilistic Knowledge-based Characterization of Conceptual Geological Models](https://www.sciencedirect.com/science/article/pii/S2590197421000033).
"""

# ╔═╡ 8301bda7-e4a1-442e-bdd4-ad5c7c9e0b46
html"""

<p align="center">

    <img src="https://ars.els-cdn.com/content/image/1-s2.0-S2590197421000033-gr1.jpg">

</p>

<p align="center">

    <b>Figura 1</b>: Modelo geológico conceitual e possíveis cenários geológicos para o sistema deposicional: Braided Rivers, Fluvial Delta, Continental Slope, Inner Shelf.

</p>

"""

# ╔═╡ 301d2074-a2d7-44dc-aeb6-29e69ca5348f
md"""
> **Nota:**
> Métodos de raciocínio funcionam bem em problemas onde há um enorme acervo de conhecimento. São ótimos quando (1) poucos dados estão disponíveis sobre um determinado objeto de estudo, e (2) a literatura é irrefutável.
"""

# ╔═╡ a0b00451-7418-4d60-812f-5c2a9b32cd4d
md"""
A habilidade de **aprendizado**, por outro lado, é o que nos permite **gerar novas regras** baseadas em experiências presentes. É com essa habilidade que evoluimos o nosso entendimento de mundo e criamos novas conexões sobre o ambiente em que operamos.

De forma mais precisa, podemos definir aprendizado em termos de experiência $E$, tarefa $T$ a ser executada e medida de performance $P$ nessa tarefa. Adotaremos a definição do [Mitchell 1997](http://www.cs.cmu.edu/~tom/mlbook.html):

**Definição (Aprendizado).** *Dizemos que um agente (e.g. programa de computador) aprende com a experiência $E$ em relacão à tarefa $T$ e à medida de performance $P$ se a performance, medida por $P$, melhora com a experiência $E$.*

Por exemplo, um programa de computador pode aprender a jogar xadrez jogando partidas contra si mesmo. A medida de performance pode ser o número de partidas ganhas em um série de 10 partidas, e nesse caso cada é uma experiência nova adquirida.

Aqui estamos interessados no **aprendizado estatístico** que consiste de aprender novas regras utilizando grandes bases de dados como furos de sondagem, dados oriundos da geometalurgia, e imagens de satélite. Em particular, estamos interessados na aplicacão dessa teoria por meio de programas de computador, conhecida como **aprendizado de máquina** (em inglês "machine learning" ou "ML").

A teoria de aprendizado estatístico está por trás de diversas tecnologias atuais, especialmente o **aprendizado estatístico supervisionado** que consiste em aprender uma função *desconhecida* $f\colon x \mapsto y$ por meio de vários exemplos $\left\{(x_1,y_1), (x_2,y_2),\ldots,(x_n,y_n)\right\}$ de entrada e saída da função:
"""

# ╔═╡ 29cf81d4-996e-4283-8d72-63d3ed1f55a7
md"""
T: $(@bind T Slider(0.1:0.1:1, default=0.3, show_value=true))

n: $(@bind n Slider(100:100:500, show_value=true))
"""

# ╔═╡ f4ad710d-f2a0-4110-8e6f-d76f181881ae
f(x) = sin(x / T)

# ╔═╡ fc3aac9b-ff0b-4b9b-a8d1-a073510cb4c1
begin
	xs = rand(Normal(), n)
	ys = f.(xs) .+ rand(Normal(0,0.1), n)
	
	plot(f, -1, 1, color = :green, label = "f(x)",
		 xlims = (-1, 1), ylims = (-1, 1),
		 xlabel = "x", ylabel = "y",
	     title = "Como aprender f(x)?")
	scatter!([(x, -1) for x in xs], label = "x₁, x₂, ..., xₙ",
	         marker = (:spike, 10, :black))
	scatter!(collect(zip(xs, ys)), label = "y₁, y₂, ..., yₙ",
	         marker = (:circle, 3, :black))
end

# ╔═╡ 6f400014-4f12-42ec-8ee8-db181d82f656
md"""
Quanto mais complexa é a função $f$, mais exemplos são necessários para aprendê-la segundo alguma medida de performance (e.g. erro quadrático). Por exemplo, se o período de oscilação $T / 2\pi$ da função for baixo, mais densa terá que ser a amostragem do eixo $x$ para um aprendizado bem sucedido.

Observamos que:

- O eixo $x$ no aprendizado clássico representa uma **propriedade ou característica** do exemplo. Por exemplo, o módulo de Young ou o teor de um certo minério numa amostra.
- O eixo $y$ representa uma **propriedade que se quer prever**, e que está relacionada de alguma forma com a propriedade $x$.
"""

# ╔═╡ a280a283-59c3-4728-9110-b91d5ea63568
md"""
> **Nota:**
> Métodos de aprendizado estatístico funcionam bem em problemas onde há uma grande quantidade de dados (os exemplos), preferencialmente anotados por especialistas.
"""

# ╔═╡ bfdbec36-069d-422d-8f88-fd97f8d85455
md"""
#### Aprendizado geoestatístico

A **teoria de aprendizado clássica** utilizada no desenvolvimento de vários métodos de aprendizado de máquina **não é apropriada para lidar com dados geoespaciais**, principalmente porque a maior parte da literatura assume que:

1. A distribuição das propriedades dos exemplos é fixa.
2. Os exemplos  são independentes e identicamente distribuídos (I.I.D.).
3. Os exemplos tem um suporte amostral (ou volume físico) comum.

Recentemente, nós formalizamos o problema de **aprendizado geoestatístico** (em inglês "geostatistical learning" ou "GL") com o intuito de resolver grandes desafios de aprendizado de máquina com dados geoespaciais. [Hoffimann et al 2021. Geostatistical Learning: Challenges and Opportunities](https://arxiv.org/abs/2102.08791).

Para ilustrar esses desafios, vamos considerar um conjunto de dados de poços de petróleo que construímos de fontes públicas da Nova Zelândia ([Carvalho et al. 2020](https://zenodo.org/record/3832955#.YHmR9EOYU3w)):
"""

# ╔═╡ b6b9f6db-5d69-496b-9862-bf7d6add901b
table = CSV.File("data/taranaki/logs.csv") |> DataFrame

# ╔═╡ 2702b5c2-b0b8-4926-aabb-9e1a34feb1d6
md"""
e uma tarefa de aprendizado que consiste em prever o tipo de formação da rocha ($y$ = `FORMATION`) em poços `OFFSHORE` como função de perfis (ou "logs") eletromagnéticos ($x$ = (`GR`, `SP`, ...)) e com base em anotações $y_i = f(x_i)$ feitas por especialistas em poços `ONSHORE` de mais fácil acesso.
"""

# ╔═╡ c2fbca00-a248-4f9e-9754-08fd47225bed
md"""
##### Falsificação da hipótese 1

Por simplicidade, eliminaremos as linhas da tabela com dados faltantes para os logs `GR`, `SP`, `DENS`, `NEUT` e `DTC`, e manteremos apenas as linhas com formações `Urenui` e `Manganui`:
"""

# ╔═╡ b106e967-13c3-483d-bc53-9772c25947be
begin
	# Dados utilizados
	LOGS  = [:GR,:SP,:DENS,:NEUT,:DTC]
	CATEG = [:FORMATION, :ONSHORE]
	COORD = [:X, :Y, :Z]
	FORMS = ["Urenui", "Manganui"]
	
	# Operações de limpeza dos dados
	f1(table) = select(table, [LOGS; CATEG; COORD])
	f2(table) = dropmissing(table)
	f3(table) = filter(row -> row.FORMATION ∈ FORMS, table)
	
	# Sequenciamento de operações
	samples = table |> f1 |> f2 |> f3
end

# ╔═╡ 9e6849d8-4c4b-4b18-a12e-734b45f9e41f
md"""
Para facilitar a interpretação dos dados e o posterior treinamento de modelos de aprendizado, nós normalizaremos os logs para que tenham média zero e desvio padrão unitário:
"""

# ╔═╡ 48a4fdfb-07d8-4ce9-a489-5f9611ed4c5b
for LOG in LOGS
	# Seleciona coluna com o log
	x = samples[!, LOG]
	
	# Calcula média e desvio padrão
	μ = mean(x)
	σ = std(x, mean = μ)
	
	# Normaliza coluna
	samples[!, LOG] = (x .- μ) ./ σ
end

# ╔═╡ e912de0f-cab2-4e11-b0bd-6a9603a9e966
describe(samples)

# ╔═╡ ce132078-cfd3-4455-98b4-3297b1be405f
md"""
Como a tarefa de aprendizado que definimos consiste em prever a formação em poços `OFFSHORE` baseado em anotações em poços `ONSHORE`, nós visualizaremos os dados agrupados dessa forma. Em particular, nós queremos investigar a distribuição bivariada entre o logs $(@bind X1 Select(string.(LOGS))) e $(@bind X2 Select(string.(LOGS), default="SP")) nesse agrupamento:
"""

# ╔═╡ 4a3d8d5a-e429-4bc9-91ee-1de5aaa8444b
begin
	# Agrupamento em pocos onshore and offshore
	G1, G2 = DataFrames.groupby(samples, :ONSHORE)
	
	T1 = G1.ONSHORE[1] ? "ONSHORE" : "OFFSHORE"
	T2 = G2.ONSHORE[1] ? "ONSHORE" : "OFFSHORE"
	
	p1 = scatter(G1[!,X1], G1[!,X2], marker = (:gray, 1),
		         xlabel = X1, ylabel = X2, legend = false, title = T1)
	p2 = scatter(G2[!,X1], G2[!,X2], marker = (:purple, 1),
		         xlabel = X1, ylabel = X2, legend = false, title = T2)
	
	plot(p1, p2, link = :both, aspect_ratio = :equal, size = (700, 400))
end

# ╔═╡ 4eadc228-7905-4328-ab01-f21339dd40aa
md"""
Da visualização concluimos que a hipótese (1) da teoria clássica não é válida neste caso. Isto é, a **distribuição das propriedades dos exemplos varia drasticamente** de um domínio geológico para outro, mesmo quando consideramos um subconjunto pequeno dos dados para duas formações localizadas em uma única bacia.
"""

# ╔═╡ 3855a6d5-7b8a-487b-abad-288f9fc0152d
md"""
#### Falsificação da hipótese 2

Vejamos agora a hipótese (2) da teoria clássica que assume que exemplos utilizados no treinamento de um modelo de aprendizado são amostrados de forma independente.

Para avaliarmos essa hipótese, utilizaremos a análise variográfica. O GeoStats.jl possui estimadores de variogramas de alta performance que conseguem lidar com **centenas de milhares** de amostras em poucos segundos. [Hoffimann & Zadrozny. 2019. Efficient variography with partition variograms.](https://www.sciencedirect.com/science/article/pii/S0098300419302936).

Primeiro nós georreferenciamos as amostras em um dado geoespacial utilizando a função `georef` e agregamos as amostras que possuem coordenadas repetidas utilizando a função `uniquecoords`:
"""

# ╔═╡ 3a425474-8710-42f7-83b4-6db8b6fc14b9
𝒮 = georef(samples, (:X, :Y, :Z)) |> uniquecoords

# ╔═╡ c10c7845-61ec-4275-b9a0-4934a7848e9b
md"""
Em seguida calculamos o variograma direcional (vertical) ao longo da direção dos poços:
"""

# ╔═╡ d70ac330-0aae-4fae-91a2-159f1c1bc11f
γ = DirectionalVariogram((0.,0.,1.), 𝒮, :GR, maxlag = 100., nlags = 50, dtol = 10.)

# ╔═╡ 44a77b1f-9d34-45f0-989c-ab03d3d2aaa9
plot(γ)

# ╔═╡ 32f8bc26-97e4-4cfa-b064-eebe0403accb
md"""
O comprimento de correlação ou "range" positivo do variograma indica a dependência espacial das amostras, e pode ser estimado por mínimos quadrados ponderados:
"""

# ╔═╡ dcc82e49-af10-4f9c-927d-1cf039a6185a
γₜ = fit(Variogram, γ, h -> exp(-h/20))

# ╔═╡ 86694a19-f5c9-45a7-8f2b-ec63af5b9cdf
range(γₜ)

# ╔═╡ 6d1b48f9-c7c6-461d-9908-f2a36de2694f
plot(γ); plot!(γₜ, 0, 100)

# ╔═╡ 4c76d345-1d77-4f7f-9fbe-2d4707d70b29
md"""
A partir da análise variográfica, concluimos que a hipótese (2) também não é valida neste caso. As amostras são adjacentes no espaço físico, e estão mais próximas entre si do que o comprimento de correlação do processo. Ou seja, as **amostras estão associadas geoespacialmente**.
"""

# ╔═╡ 06e19a21-5a4e-48c0-9030-9c6c43a3afdb
md"""
#### Falsificação da hipótese 3

A hipótese (3) não é valida, pois como discutimos no primeiro dia do minicurso, amostras geofísicas geralmente tem um suporte (ou volume físico) variável. Neste caso, **o espaçamento das amostras ao longo dos poços não é constante**.
"""

# ╔═╡ e3c46f60-b32e-4911-971f-230c87507f37
md"""
#### Resumo

- A **análise bivariada** indicou que as **distribuições das propriedades** em poços `ONSHORE` e `OFFSHORE` **são distintas**. Portanto, não é aconselhável treinar um modelo de aprendizado com anotações em poços `ONSHORE` e aplicá-lo diretamente a poços `OFFSHORE`, e vice versa.

- A **análise variográfica** indicou a **existência de correlação linear** ao longo dos poços. Isso significa que modelos de aprendizado clássicos desenvolvidos assumindo independência de exemplos podem apresentar, e geralmente apresentam, deterioração de performance em aplicações práticas em geociências.

Precisamos de uma nova definição de aprendizado com dados geoespaciais, que chamaremos de **aprendizado geoestatístico** ou GL:

**Definição (GL).** *Dado um domínio geoespacial de origem $D_s$ (ou "source") e uma tarefa de aprendizado $T_s$, e um domínio de destino $D_t$ (ou "target") e uma tarefa de aprendizado $T_t$. O aprendizado geoestatístico consiste em aprender a tarefa $T_t$ no domínio $D_t$ utilizando o conhecimento adquirido no aprendizado da tarefa $T_s$ no domínio $D_s$. Assumindo que as propriedades em $D_s$ e $D_t$ são uma única realização dos processos envolvidos.*
"""

# ╔═╡ 0e168bfe-902b-4732-8ecb-a9a75b330bbb
md"""
### Elementos do aprendizado geoestatístico
"""

# ╔═╡ fbd3a1ec-214f-450f-9c2e-547df22157d3


# ╔═╡ Cell order:
# ╟─32f6d41e-3248-4549-9546-53b34d5aa7c6
# ╟─762a6e04-fcb7-4713-859d-fdbfe8ead1bc
# ╟─32429926-f6c3-44b8-b012-d2c67cad0b6d
# ╟─3c79e7aa-b316-4c4b-b44e-e73312085c20
# ╟─4a3fb559-73dd-41e0-8a11-993e5bf286bf
# ╟─f3ff120d-940c-40c9-b9f6-24d4a0b3aec1
# ╟─1856e01b-2d55-448d-8bdf-e59825934193
# ╟─8301bda7-e4a1-442e-bdd4-ad5c7c9e0b46
# ╟─301d2074-a2d7-44dc-aeb6-29e69ca5348f
# ╟─a0b00451-7418-4d60-812f-5c2a9b32cd4d
# ╠═f4ad710d-f2a0-4110-8e6f-d76f181881ae
# ╟─29cf81d4-996e-4283-8d72-63d3ed1f55a7
# ╟─fc3aac9b-ff0b-4b9b-a8d1-a073510cb4c1
# ╟─6f400014-4f12-42ec-8ee8-db181d82f656
# ╟─a280a283-59c3-4728-9110-b91d5ea63568
# ╟─bfdbec36-069d-422d-8f88-fd97f8d85455
# ╠═b6b9f6db-5d69-496b-9862-bf7d6add901b
# ╟─2702b5c2-b0b8-4926-aabb-9e1a34feb1d6
# ╟─c2fbca00-a248-4f9e-9754-08fd47225bed
# ╠═b106e967-13c3-483d-bc53-9772c25947be
# ╟─9e6849d8-4c4b-4b18-a12e-734b45f9e41f
# ╠═48a4fdfb-07d8-4ce9-a489-5f9611ed4c5b
# ╠═e912de0f-cab2-4e11-b0bd-6a9603a9e966
# ╟─ce132078-cfd3-4455-98b4-3297b1be405f
# ╟─4a3d8d5a-e429-4bc9-91ee-1de5aaa8444b
# ╟─4eadc228-7905-4328-ab01-f21339dd40aa
# ╟─3855a6d5-7b8a-487b-abad-288f9fc0152d
# ╠═3a425474-8710-42f7-83b4-6db8b6fc14b9
# ╟─c10c7845-61ec-4275-b9a0-4934a7848e9b
# ╠═d70ac330-0aae-4fae-91a2-159f1c1bc11f
# ╠═44a77b1f-9d34-45f0-989c-ab03d3d2aaa9
# ╟─32f8bc26-97e4-4cfa-b064-eebe0403accb
# ╠═dcc82e49-af10-4f9c-927d-1cf039a6185a
# ╠═86694a19-f5c9-45a7-8f2b-ec63af5b9cdf
# ╠═6d1b48f9-c7c6-461d-9908-f2a36de2694f
# ╟─4c76d345-1d77-4f7f-9fbe-2d4707d70b29
# ╟─06e19a21-5a4e-48c0-9030-9c6c43a3afdb
# ╟─e3c46f60-b32e-4911-971f-230c87507f37
# ╟─0e168bfe-902b-4732-8ecb-a9a75b330bbb
# ╠═fbd3a1ec-214f-450f-9c2e-547df22157d3
