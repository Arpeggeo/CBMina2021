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
	using GeoStats, MLJ
	using CSV, DataFrames
	using LossFunctions
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

Existem questões teóricas muito interessantes que não cobriremos neste minicurso, e que estão sendo desenvolvidas ativamente no projeto. Nos concentraremos aqui em **exemplos práticos** para que você possa adaptar este notebook aos seus próprios desafios na mineração. Para mais detalhes teóricos, assista o vídeo abaixo:
"""

# ╔═╡ 4a3fb559-73dd-41e0-8a11-993e5bf286bf
html"""
<iframe width="560" height="315" src="https://www.youtube.com/embed/6S_9GLMv3xI" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
"""

# ╔═╡ f3ff120d-940c-40c9-b9f6-24d4a0b3aec1
md"""
Ao final deste módulo você será capaz de:

- Identificar os **elementos do aprendizado geoestatístico**
- Definir de forma clara **problemas de aprendizado na sua área**
- Resolver o problema com **modelos geoespaciais do GeoStats.jl**

### Agenda

1. O que é aprendizado de máquina?
2. A nova área de **aprendizado geoestatístico**
3. Os elementos do aprendizado geoestatístico
4. Solução do problema (exemplo *Nova Zelândia*)
5. Métodos de validação (seleção de modelos)
"""

# ╔═╡ 1856e01b-2d55-448d-8bdf-e59825934193
md"""
### 1. O que é o aprendizado de máquina?

Antes de podermos entender o problema de aprendizado **geo**estatístico, isto é, o problema de aprendizado com dados **geoespacias**, precisamos entender o problema genérico de **aprendizado de máquina** introduzido na ciência da computação na área de **inteligência artificial**.

Nessa área, buscam-se criar tecnologias capazes de "imitar" a inteligência humana. Ao invés de tentarmos definir inteligência, vamos nos concentrar em duas habilidades que nós humanos exercermos todo dia:

- A habilidade de **raciocinar sobre fatos**
- A habilidade **aprender com experiência**

#### Raciocínio

A habilidade de **raciocínio** é o que nos permite gerar conclusões sobre fatos, segundo alguma lógica pré-estabelecida. Essa habilidade pode ser entendida informalmente como um sistema dedutivo da forma:

$\text{premissa}_1 + \text{premissa}_2 + \cdots + \text{premissa}_n \longrightarrow \text{conclusão}$

onde um conjunto de **premissas** sobre o funcionamento do mundo leva a uma **conclusão** lógica. Como exemplo, podemos considerar a habilidade de um geólogo de deduzir condições marítimas ao ver o fóssil da Figura 2. O raciocínio se dá da seguinte forma:

- *Premissa 1:* Trilobitas são seres marinhos
- *Premissa 2:* Fóssil de trilobita encontrado na região
- *Conclusão:* Região foi mar num passado distante
"""

# ╔═╡ 615e4ed2-f77f-4f38-a6c1-7f0c0f985d49
html"""

<p align="center">

    <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLZzO7ZIjwJzgTPHk6EootRI5usLZCcuDJ-f0Vdz6aYq2rPpNFpaFM8FBPgny42fGfYQQ&usqp=CAU">

</p>

<p align="center">

    <b>Figura 1</b>: Fóssil de trilobita, um antrópode do paleozóico de ambientes marinhos.

</p>

"""

# ╔═╡ b89139a7-57da-4d9d-a791-c06edd5ab99d
md"""
Devemos observar que:

- Sistemas de raciocínio determinísticos como o exemplo acima tendem a falhar em áreas da ciência que apresentam alta complexidade e interação entre as entidades envolvidas no raciocínio, especialmente quando esses sistemas são construídos por [seres humanos e seus vários traços de irracionalidade](https://en.wikipedia.org/wiki/Predictably_Irrational).

- Sistemas de raciocínio probabilísticos, isto é, sistemas que utilizam de teorias de probabilidade para representar incertezas no raciocínio, tem sido mais bem sucedidos na indústria. Um exemplo deste tipo de sistema está descrito em [Hoffimann et al 2021. Probabilistic Knowledge-based Characterization of Conceptual Geological Models](https://www.sciencedirect.com/science/article/pii/S2590197421000033), onde um modelo conhecido como rede Bayesiana é utilizado para auxiliar geocientistas na identificação de cenários geológicos de um sistema petrolífero (Figura 2).
"""

# ╔═╡ 8301bda7-e4a1-442e-bdd4-ad5c7c9e0b46
html"""

<p align="center">

    <img src="https://ars.els-cdn.com/content/image/1-s2.0-S2590197421000033-gr1.jpg">

</p>

<p align="center">

    <b>Figura 2</b>: Modelo geológico conceitual e possíveis cenários geológicos para o sistema deposicional: Braided Rivers, Fluvial Delta, Continental Slope, Inner Shelf.

</p>

"""

# ╔═╡ 301d2074-a2d7-44dc-aeb6-29e69ca5348f
md"""
> **Nota:** Métodos de raciocínio funcionam bem em problemas onde há um enorme acervo de conhecimento. São ótimos quando (1) poucos dados estão disponíveis sobre um determinado objeto de estudo, e (2) a literatura é irrefutável.
"""

# ╔═╡ a0b00451-7418-4d60-812f-5c2a9b32cd4d
md"""
#### Aprendizado

A habilidade de **aprendizado**, por outro lado, é o que nos permite **gerar novas regras** sobre o ambiente em que operamos baseado em novas experiências vividas. É com essa habilidade que evoluimos o nosso entendimento de mundo.

De forma mais precisa, podemos definir aprendizado em termos de experiência $\mathcal{E}$, tarefa $\mathcal{T}$ a ser executada e medida de performance $\mathcal{P}$ nessa tarefa. Adotaremos a definição do [Mitchell 1997](http://www.cs.cmu.edu/~tom/mlbook.html):

**Definição (Aprendizado).** *Dizemos que um agente (e.g. programa de computador) aprende com a experiência $\mathcal{E}$ em relacão à tarefa $\mathcal{T}$ e à medida de performance $\mathcal{P}$ se a performance, medida por $\mathcal{P}$, melhora com a experiência $\mathcal{E}$.*

Por exemplo, um programa de computador pode aprender a jogar xadrez jogando partidas contra si mesmo. A medida de performance pode ser o número de partidas ganhas em um série de 10 partidas, e nesse caso cada partida é uma experiência nova adquirida.

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
Quanto mais complexa é a função $f$, mais exemplos são necessários para aprendê-la segundo alguma medida de performance (e.g. erro quadrático). Por exemplo, se o período de oscilação $T / 2\pi$ da função acima for baixo, mais densa terá que ser a amostragem do eixo $x$ para um aprendizado bem sucedido.

Observamos que:

- O eixo $x$ no aprendizado clássico representa uma **propriedade ou característica** do exemplo. Por exemplo, o módulo de Young ou o teor de um certo minério numa amostra.
- O eixo $y$ representa uma **propriedade que se quer prever**, e que está relacionada de alguma forma com a propriedade $x$.
"""

# ╔═╡ a280a283-59c3-4728-9110-b91d5ea63568
md"""
> **Nota:** Métodos de aprendizado estatístico funcionam bem em problemas onde há uma grande quantidade de dados (os exemplos), preferencialmente anotados por especialistas.
"""

# ╔═╡ bfdbec36-069d-422d-8f88-fd97f8d85455
md"""
### 2. Aprendizado geoestatístico

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
#### Falsificação da hipótese 1

Por simplicidade, eliminaremos as linhas da tabela com dados faltantes para os logs `GR`, `SP`, `DENS`, `NEUT` e `DTC`, e manteremos apenas as linhas com formações `Manganui` e `Urenui`.

Para facilitar a interpretação dos dados e o posterior treinamento de modelos de aprendizado, nós normalizaremos os logs para que tenham média zero e desvio padrão unitário.
"""

# ╔═╡ b106e967-13c3-483d-bc53-9772c25947be
begin
	# Dados utilizados no experimento
	LOGS  = [:GR,:SP,:DENS,:NEUT,:DTC]
	CATEG = [:FORMATION, :ONSHORE]
	COORD = [:X, :Y, :Z]
	FORMS = ["Manganui", "Urenui"]
	
	# Operações de pré-processamento
	f1(table) = select(table, [LOGS; CATEG; COORD])
	
	f2(table) = dropmissing(table)
	
	f3(table) = filter(row -> row.FORMATION ∈ FORMS, table)
	
	function f4(table)
		result = copy(table)
		for LOG in LOGS
			x = table[!, LOG]
			
			μ = mean(x)
			σ = std(x, mean = μ)
	
			result[!, LOG] = (x .- μ) ./ σ
		end
		result
	end
	
	# Execução das operações em sequência
	samples = table |> f1 |> f2 |> f3 |> f4
end

# ╔═╡ e912de0f-cab2-4e11-b0bd-6a9603a9e966
describe(samples)

# ╔═╡ ce132078-cfd3-4455-98b4-3297b1be405f
md"""
Como a tarefa de aprendizado que definimos consiste em prever a formação em poços `OFFSHORE` baseado em anotações em poços `ONSHORE`, nós visualizaremos os dados agrupados dessa forma. Em particular, nós queremos investigar a **distribuição bivariada** entre o logs $(@bind X1 Select(string.(LOGS))) e $(@bind X2 Select(string.(LOGS), default="SP")) nesse agrupamento:
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
Da visualização concluimos que a hipótese (1) da teoria clássica não é válida neste caso. Isto é, a **distribuição das propriedades dos exemplos varia drasticamente** de um domínio geoespacial para outro, mesmo quando consideramos um subconjunto pequeno dos dados para duas formações localizadas em uma única bacia.
"""

# ╔═╡ 3855a6d5-7b8a-487b-abad-288f9fc0152d
md"""
#### Falsificação da hipótese 2

Vejamos agora a hipótese (2) da teoria clássica que assume que exemplos utilizados no treinamento de um modelo de aprendizado são amostrados de forma independente no espaço de propriedades.

Para avaliarmos essa hipótese, utilizaremos a **análise variográfica**. O GeoStats.jl possui estimadores de variogramas de alta performance que conseguem lidar com **centenas de milhares** de amostras em poucos segundos. [Hoffimann & Zadrozny. 2019. Efficient variography with partition variograms.](https://www.sciencedirect.com/science/article/pii/S0098300419302936).

Para utilizar esses estimadores, nós precisaremos **georreferenciar a tabela** de amostras em um dado geoespacial do GeoStats.jl que chamamos de `GeoData`. Esse dado se comporta como uma tabela comum, mas adicionalmente armazena informações necessárias para análises geoespaciais.

Além de georreferenciar as amostras, nós iremos aproveitar esta etapa de processamento para especificar o **tipo científico** de cada coluna da tabela. Por padrão esses tipos são inferidos pela linguagem como:
"""

# ╔═╡ eb9d3014-65b2-44f7-8d33-445826e6974b
schema(samples)

# ╔═╡ 4b41d46e-ccf0-4232-8ce8-f9520a90efea
md"""
Nós iremos converter os tipos científicos `Textual` e `Count` das colunas `FORMATION` e `ONSHORE` pelo tipo `Multiclass` que representa uma propriedade categórica.

Por fim, nós iremos agregar todas as amostras com coordenadas repetidas em uma única amostra já que procedimentos de variografia requerem unicidade de coordenadas no conjunto de dados.

Em resumo, nós utilizaremos:

1. A função `coerce` para especificar o tipo científico das colunas `FORMATION` e `ONSHORE`.
2. A função `georef` para georreferenciar as amostras utilizando as coordenadas `X`, `Y` e `Z`.
3. A função `uniquecoords` para eliminar amostras com coordenadas repetidas.
"""

# ╔═╡ a1c4fc51-1878-4c13-8d01-3642d23ee670
begin
	# Operações de pré-processamento
	g1(table) = coerce(table, :FORMATION => Multiclass, :ONSHORE => Multiclass)
	
	g2(table) = georef(table, (:X, :Y, :Z))
	
	g3(table) = uniquecoords(table)
	
	# Execução das operações em sequência
	𝒮 = samples |> g1 |> g2 |> g3 |> GeoData
end

# ╔═╡ c10c7845-61ec-4275-b9a0-4934a7848e9b
md"""
Para avaliar a dependência das amostras, calculamos o variograma direcional (vertical) ao longo da direção dos poços para qualquer uma das variáveis:
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
r = range(γₜ)

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

**Definição (GL).** *Dado um domínio geoespacial de origem $\mathcal{D}_s$ (ou "source") e uma tarefa de aprendizado $\mathcal{T}_s$, e um domínio de destino $\mathcal{D}_t$ (ou "target") e uma tarefa de aprendizado $\mathcal{T}_t$. O aprendizado geoestatístico consiste em aprender a tarefa $\mathcal{T}_t$ no domínio $\mathcal{D}_t$ utilizando o conhecimento adquirido no aprendizado da tarefa $\mathcal{T}_s$ no domínio $\mathcal{D}_s$. Assumindo que as propriedades em $\mathcal{D}_s$ e $\mathcal{D}_t$ são uma única realização dos processos envolvidos.*
"""

# ╔═╡ 0e168bfe-902b-4732-8ecb-a9a75b330bbb
md"""
### 3. Elementos do aprendizado geoestatístico

Para esclarecer a definição de GL, continuaremos explorando os dados da Nova Zelândia.

#### Domínio geoespacial

O primeiro elemento da definição é o **domínio geoespacial** onde os dados estão georreferenciados:

- O **domínio de origem** $\mathcal{D}_s$ representa as trajetórias dos poços `ONSHORE`. Nesse domínio estão disponíveis os logs, assim como as anotações do tipo de formação feitas por especialistas.
- O **domínio de destino** $\mathcal{D}_t$ representa as trajetórias dos poços `OFFSHORE`. Nesse domínio estão disponíveis apenas os logs que serão utilizados pelo modelo de aprendizao para previsão do tipo de formação.
"""

# ╔═╡ bfbb10f9-364f-441a-872a-96753c3d2231
html"""

<p align="center">

    <img src="https://i.postimg.cc/d3BpsStQ/domains.png">

</p>

<p align="center">

    <b>Figura 3</b>: Domínio geoespacial de origem e de destino.

</p>

"""

# ╔═╡ 89e8f272-8812-4e1e-8ab6-1cb7700c0fde
md"""
Vemos que os nossos dados geoespaciais estão definidos em um domínio do tipo `PointSet`:
"""

# ╔═╡ 8ee75575-d2f2-409f-9016-dac048fc6ff6
domain(𝒮)

# ╔═╡ a21d65cb-d369-4e9b-a1a6-53b06b09dc22
md"""
E que a tabela de valores associada a esse domínio contém as seguintes variáveis:
"""

# ╔═╡ cb8d9a31-d415-45b7-a743-15c715dfd2a5
values(𝒮) |> DataFrame

# ╔═╡ 8712e1ec-0b84-4fc4-a44e-6f5a91180b8b
md"""
Queremos particionar os dados em poços `ONSHORE` e `OFFSHORE` de acordo com a informação já presente na tabela de valores. Utilizaremos a função `groupby` do GeoStats.jl para **particionar os dados preservando as informações geoespaciais**. O resultado da partição possui um campo de metadados associados a cada subconjunto que podemos utilizar para definir os dois domínios de interesse:
"""

# ╔═╡ 59c355a1-34d5-415b-9e29-afcab5103576
function onandoff(𝒮)
	Π = GeoStats.groupby(𝒮, :ONSHORE)
	
	ON₁, ON₂ = metadata(Π)[:values]
	
	if ON₁ == true
		𝒮ₛ, 𝒮ₜ = Π
	else
		𝒮ₜ, 𝒮ₛ = Π
	end
end

# ╔═╡ 340c939a-2a9b-475d-91ef-62effb2a8da3
𝒮ₛ, 𝒮ₜ = onandoff(𝒮)

# ╔═╡ 2c7442fa-5b8c-411d-b3f8-f0ed2ed00dc8
md"""
Para evitar viés no processo de aprendizado, nós balancearemos os dados utilizando uma simples técnica de **subamostragem**. Essa técnica reduz a presença da formação majoritária no treinamento de modelos estatísticos, e é adequada para grandes conjuntos de dados.

Ao aplicar a subamostragem nos poços `ONSHORE` e `OFFSHORE` obtemos um novo conjunto de dados balanceado com 50% dos exemplos na formação `Manganui` e 50% na formação `Urenui`:
"""

# ╔═╡ a7b23e9e-b3f3-4a8b-a5a7-dae05fd73bf1
function balance(𝒮)
	# Coluna com anotações
	y  = 𝒮[:FORMATION]
	
	# Localizações na formação Manganui
	y₁ = isequal.(y, "Manganui")
	
	# Contagem de exemplos nas duas formações
	n  = length(y)
	n₁ = count(y₁)
	n₂ = n - n₁
	
	# Subamostragem dos dados
	if n₁ > n₂
		inds₁ = sample(findall(y₁), n₂, replace = false)
		inds₂ = findall(!, y₁)
	else
		inds₁ = findall(y₁)
		inds₂ = sample(findall(!, y₁), n₁, replace = false)
	end
	
	view(𝒮, [inds₁; inds₂])
end

# ╔═╡ 777f4131-2cbb-4ba5-b786-d6175e3036a5
Ωₛ, Ωₜ = balance(𝒮ₛ), balance(𝒮ₜ)

# ╔═╡ fbd3a1ec-214f-450f-9c2e-547df22157d3
md"""
#### Tarefa de aprendizado

O segundo elemento da definição é a **tarefa de apendizado**. Neste caso, definimos uma única tarefa de previsão de formação a partir de logs, ou seja $\mathcal{T}_s = \mathcal{T}_t$. No jargão de aprendizado essa tarefa é uma tarefa de classificação:
"""

# ╔═╡ 55151073-083b-433c-96e0-5e51978e888f
𝒯 = ClassificationTask(LOGS, :FORMATION)

# ╔═╡ 0250f930-ac62-4fdf-8e36-b79769974a25
md"""
Com isso podemos definir o nosso problema de aprendizado geoestatístico:
"""

# ╔═╡ a012ef03-64a4-44cb-95c2-a5f734a3f75d
problem = LearningProblem(Ωₛ, Ωₜ, 𝒯)

# ╔═╡ 12112daa-17f1-445a-93e8-131c35cfb53d
md"""
Como veremos em seguida, nós podemos resolver o problema com mais de **150** modelos de aprendizado disponíveis no projeto [MLJ.jl](https://github.com/alan-turing-institute/MLJ.jl), incluindo todos os modelos do [scikit-learn](https://scikit-learn.org) e outros modelos de alta performance implementados em Julia:
"""

# ╔═╡ 10ab0262-00ef-4b77-8b6b-a43cf236a29d
models() |> DataFrame

# ╔═╡ 427d35b8-daf0-4d16-87e5-f8eb33e265fe
md"""
> **Nota:** É extremamente importante separar a **definição do problema** de aprendizado geostatístico da **estratégia de solução** para uma comparação justa de modelos. A maioria dos frameworks clássicos de aprendizado (e.g. scikit-learn) **não** permite essa separação.
"""

# ╔═╡ 1ec6e447-fe94-4288-9996-0ba42c8d6cb0
md"""
### 4. Solução do problema

#### Modelos de aprendizado

Com o problema de aprendizado geoestatístico bem definido, nós podemos investigar diferentes estratégias de solução e realizar validações avançadas que só estão disponíveis no GeoStats.jl.

Primeiro nós precisamos definir uma lista de modelos de aprendizado para resolver o problema. Estamos interessados em modelos:

1. **Implementados em Julia** por terem uma maior performance computacional.
2. Adequados para a tarefa de **classificação de formação** definida no problema:
    - Modelos **supervisionados** (que aprendem de exemplos de entrada e saída)
    - Com **variável alvo binária** (que produzem previsões `Manganui` ou `Urenui`)
3. Sob licença **MIT** por ser uma licença de código aberto permissível.

Podemos encontrar esses modelos utilizando filtros na função `models`:
"""

# ╔═╡ 34f48c18-d452-4df4-a8f8-882bfc1db056
models(m -> m.is_pure_julia && m.is_supervised &&
	        m.target_scitype >: AbstractVector{<:Multiclass{2}} &&
	        m.package_license == "MIT") |> DataFrame

# ╔═╡ 2daa903b-af18-40ad-b9ce-0caf93b507c6
md"""
Utilizaremos os seguintes modelos:
"""

# ╔═╡ afa08349-eab0-4ed6-a0aa-cc3cb39a619d
begin
	ℳ₁ = @load DecisionTreeClassifier pkg = DecisionTree
	ℳ₂ = @load KNNClassifier          pkg = NearestNeighborModels
	ℳ₃ = @load LogisticClassifier     pkg = MLJLinearModels
	ℳ₄ = @load ConstantClassifier     pkg = MLJModels
	
	ℳs = [ℳ₁(), ℳ₂(), ℳ₃(), ℳ₄()]
end

# ╔═╡ b0843d5b-69eb-4a53-bff7-2d3bbd8b0057
md"""
#### Estratégia de solução

Para que os modelos de aprendizado possam ser utilizados com dados geoespaciais no GeoStats.jl, nós precisamos definir uma **estratégia de solução**. A estratégia de solução mais comum na literatura geoespacial é o que denominamos aprendizado ponto-a-ponto (em inglês "pointwise learning"):
"""

# ╔═╡ 9dd85a75-c1e3-418a-bb3e-7c8875e9c5dd
solvers = [PointwiseLearn(ℳ) for ℳ in ℳs];

# ╔═╡ bd82b213-99b2-4ba7-997c-9ddbac69579c
md"""
Essa estratégia simplesmente **ignora as coordenadas** dos exemplos e trata o dado geoespacial como uma **tabela comum**. Apesar de ser uma estratégia simplista, ela pode demandar bastante tempo do usuário final que fica responsável pelo pré- e pós-processamento dos dados em formatos tabulares.

O GeoStats.jl **automatiza esse processo de conversão** e salva tempo do geocientista interessado em testar diferentes modelos. Em particular, o framework se encarrega de:

1. Treinar o modelo encapsulado no domínio geoespacial de origem
2. Aplicar o modelo treinado no domínio geoespacial de destino

onde os domínios geoespaciais podem ser **qualquer tipo de malha** do projeto [Meshes.jl](https://github.com/JuliaGeometry/Meshes.jl).
"""

# ╔═╡ 3ba896bd-e569-40c3-9fa1-3e79db50bf45
solutions = [solve(problem, solver) for solver in solvers]

# ╔═╡ f66e960b-e38f-4414-be79-09658eb5cf74
md"""
#### Avaliação qualitativa

Podemos facilmente visualizar qualquer uma das soluções obtidas. Como o número de amostras é considerável neste caso, e não estamos utilizando o [Makie.jl](https://github.com/JuliaPlots/Makie.jl) para visualizações 3D, visualizaremos apenas um subconjunto da solucão i = $(@bind i Scrubbable(1:length(solvers), default=1)):
"""

# ╔═╡ b70f5ab7-9790-4daf-a881-d75c602aaa67
solutionᵢ = sample(solutions[i], 10000, replace = false);

# ╔═╡ 5ec99dcc-58b4-4290-8f05-884ef11e464d
plot(solutionᵢ, marker = (:BrBG_3, 4), colorbar = false,
	 xlabel = "X", ylabel = "Y", zlabel = "Z",
	 title = "PREVISÃO DE FORMAÇÃO\n(Manganui = Laranja, Urenui = Verde)")

# ╔═╡ 78d9f9ba-1947-4bec-bc74-b895d084365e
md"""
#### Avaliação quantitativa

Como neste **caso sintético** nós temos acesso ao tipo de formação nos poços `OFFSHORE`, nós podemos quantificar o erro de cada modelo utilizado.

Em problemas de classificação, é comum reportar a **matriz de confusão** para cada modelo. Essa matriz informa o número de vezes que uma formação (coluna da matriz) foi classificada pelo modelo como uma certa outra formação (linha da matriz):
"""

# ╔═╡ e6e84f8b-e132-42a7-a0e4-1acd9006dbbb
map(solutions) do Ω̂ᵢ
	# Previsão da formação
	ŷ = Ω̂ᵢ[:FORMATION]
	
	# Valor real da formação
	y = Ωₜ[:FORMATION]
	
	# Matriz de confusão
    confmat(ŷ, y)
end

# ╔═╡ 653ed159-838c-47d6-878e-0b2530cf7c52
md"""
Observamos que:

- O **modelo mais simples** (logistic) apresenta os **melhores resultados** nos poços `OFFSHORE`.
- Os **modelos mais complexos** (e.g. decision tree, knn) ficam **"superfitados"** aos poços `ONSHORE` devido principalmente a diferença de distribuição `ONSHORE` e `OFFSHORE`.
- O modelo constante apresenta o pior resultado como esperado.

Podemos sumarizar a informação da matriz de confusão com diferentes medidas, como por exemplo a medida $F_1$-score. A medida é bastante utilizada na área médica, e é calculada como

$F_1 = \frac{tp}{tp + \frac{fp + fn}{2}}$

onde $tp$ é o número de verdadeiros positivos, $fp$ é o número de falsos positivos, e $fn$ é o número de falsos negativos. Em geral quanto maior é o $F_1$-score, maior é a performance do modelo:
"""

# ╔═╡ da350067-a8fb-47bc-b9b8-b069e742383b
html"""

<p align="center">

    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Precisionrecall.svg/350px-Precisionrecall.svg.png">

</p>

<p align="center">

    <b>Figura 4</b>: Ilustração da medida F1-score como combinação de precisão e recall.

</p>

"""

# ╔═╡ ab970650-8dbd-442b-9a25-4cd871ecd336
map(solutions) do Ω̂ᵢ
	# Previsão da formação
	ŷ = Ω̂ᵢ[:FORMATION]
	
	# Valor real da formação
	y = Ωₜ[:FORMATION]
	
	# Matriz de confusão
	f1score(ŷ, y)
end

# ╔═╡ 3e469cb8-745d-4f11-a6e7-814f29e1ccef
md"""
Dessa forma, se soubéssemos o valor real da formação nos poços `OFFSHORE`, nós poderíamos escolher o modelo logistic como o melhor modelo segundo o $F_1$-score. Na prática, porém, **não temos as anotações no domínio geoespacial de destino**, e precisamos de outras métodos para a seleção de modelos.

Antes de investigarmos esses métodos em detalhe na próxima seção, observamos que existem mais de **50** medidas disponíveis para avaliar modelos de aprendizado quando as anotações são conhecidas em um caso sintético. Podemos utilizar a função `measures` para descobrir as medidas válidas para as soluções encontradas:
"""

# ╔═╡ 5b54c097-07b2-4c26-85b1-c7716cd98145
measures(s -> s.target_scitype >: AbstractVector{<:Multiclass{2}} &&
	          s.prediction_type == :deterministic) |> DataFrame

# ╔═╡ 7d6597a0-ae24-483a-a67f-dd6235acb25e
md"""
### 5. Validação cruzada

Nas seções anteriores, aprendemos a definir um problema de aprendizado geoestatístico e a resolver esse problema com diferentes modelos. Nesta seção aprenderemos a selecionar modelos mesmo quando as anotações dos especialistas não estão disponíveis no domínio geoespacial de destino.

Dentre os vários métodos de seleção, os métodos de **validação cruzada** são os que apresentam os resultados mais satisfatórios em problemas reais. Esses métodos se baseiam nas seguintes observações:

1. Anotações de especialistas só estão disponíveis no domínio geoespacial de origem $\mathcal{D}_s$.
2. Subconjuntos de dados em $\mathcal{D}_s$ podem apresentar a mesma distribuição dos dados originais.
3. É possível treinar um modelo em um subdomínio $\mathcal{B}_s \subset \mathcal{D}_s$ e avaliar em $\mathcal{D}_s - \mathcal{B}_s$.

A Figure 4 ilustra um processo de subdivisão do domínio de origem em subdomínios aleatórios marcados em cores distintas. Esse subdomínios são chamados de **folds**.
"""

# ╔═╡ d10b3695-0f6d-406f-813d-17e76d47ba76
html"""

<p align="center">

    <img src="https://i.postimg.cc/wj642dcw/cv.png">

</p>

<p align="center">

    <b>Figura 5</b>: Folds aleatórios no domínio geoespacial de origem representados em diferentes cores.

</p>

"""

# ╔═╡ f96d976f-f40c-4ad2-8bbe-e45da5a3ae3d
md"""
O processo de validação cruzada consiste em **omitir** um dos $k$ folds do conjunto de dados, **treinar** o modelo nos $k-1$ folds restantes, e **avaliar** quantitativamente o erro do modelo no fold que foi omitido. Esse processo é repitido para todos os folds ou cores do domínio, e os resultados são agregados em um erro esperado:

$\epsilon(m) = \frac{1}{k} \sum_{i=1}^k \sum_{j=1}^{n_k} w^{(i)}_j \cdot \mathcal{L}(\hat{y}^{(i)}_j, y^{(i)}_j)$

onde $m$ é o modelo sendo avaliado, $\mathcal{L}$ é uma função conhecida como **função de perda**, e $w^{(i)}_j$ é um peso atribuído ao erro do exemplo $j$ no fold $i$.

Revisaremos três métodos de validação cruzada:

1. Validação cruzada clássica (CV)
2. Validação cruzada em blocos (BCV)
4. Validação cruzada com razão de densidade (DRV)
"""

# ╔═╡ 6ccd3492-a71d-4848-97e1-900614df7aa7
md"""
#### Validação cruzada clássica (CV)

A validação cruzada clássica é o método mais simples de validação no qual os **folds são aleatórios** e todos os exemplos recebem o mesmo **peso unitário** (Figura 5). Por ser bastante simples, o método está disponível em qualquer framework de aprendizado (e.g. sckit-learn, MLJ, mlr3).

O maior problema da validação cruzada clássica é que ela não foi desenvolvida para dados geoespaciais. A existência de correlação entre duas localizações do domínio compromete a estimativa do erro que se torna **super otimista**.

Para ilustrar esse problema, tentaremos estimar o erro de qualquer um dos solvers (e.g. poitwise decision tree) utilizando o método CV. Precisamos definir o **número de folds** e a **função de perda**.

##### Número de folds $k$
O número de folds geralmente é escolhido em função da quantidade de dados no domínio de origem e do recurso computacional disponível. Como existem muitos exemplos (>300k) nos poços `ONSHORE`, podemos escolher valores de $k$ em função do custo computacional. Valores muito maiores que $k=20$ são desnecessariamente caros computacionalmente:
"""

# ╔═╡ 7c5beee4-c4bb-40a5-ab3e-c2fb88e363cb
k = 20

# ╔═╡ 7204b07c-7ad3-4384-b41c-f214e040d280
md"""
##### Função de perda $\mathcal{L}$
Uma função de perda pode ser escolhida do pacote [LossFunctions.jl](https://github.com/JuliaML/LossFunctions.jl). Neste caso de classificação binária podemos escolher a função `MissclassLoss()` que assume o valor `1` quando o exemplo é classificado incorretamente pelo modelo e `0` quando a classificação é correta:
"""

# ╔═╡ 10454510-fcff-46d6-8e28-7800cc0bfd4d
ℒ = MisclassLoss()

# ╔═╡ e4d731eb-e8a3-42d2-beae-54f053722503
md"""
Por fim, criamos o método de validação CV especificando o número de folds e a função de perda para cada variável de saída do problema:
"""

# ╔═╡ 74ecd539-73e9-4fdc-ab35-4a58278ef5bf
CV = CrossValidation(20, loss = Dict(:FORMATION => ℒ))

# ╔═╡ 6dd4b8dd-7dd1-44b7-818a-f6461c9b619a
md"""
##### Estimativa CV

Em uma linha de código, o GeoStats.jl se encarrega de particionar o domínio geoespacial, treinar os modelos em paralelo em cada fold, e combinar as estimativas de erro:
"""

# ╔═╡ 56a82bee-08fc-4c17-9437-e105b2a3cb1c
md"""
Solver index: $(@bind index Scrubbable(1:length(solvers), default=1))
"""

# ╔═╡ 7e1896be-7ae8-4b61-8f47-c147ee199bac
error(solvers[index], problem, CV)

# ╔═╡ a183e138-60be-49ad-8b67-f780b46e9bb2
md"""
Podemos comparar a estimativa de erro obtida com o método CV com o erro real neste caso sintético, e constatar o super otimismo da validação cruzada clássica:
"""

# ╔═╡ f0f10827-7753-4f93-ba63-9b717e1e6ac9
begin
	# Solução geoespacial
	Ω̂ₜ = solutions[index]
	
	# Valor real da formação
	y  = Ωₜ[:FORMATION]
	
	# Previsão da formação
	ŷ  = Ω̂ₜ[:FORMATION]
	
	# Taxa de misclassicação real
	LossFunctions.value(ℒ, y, ŷ, AggMode.Mean())
end

# ╔═╡ 7a790985-6c7d-422d-bcb2-f5ba8caf0322
md"""
#### Validação cruzada em blocos (BCV)
"""

# ╔═╡ 551b332f-3601-472a-b44b-c9b74b199db4
html"""

<p align="center">

    <img src="https://i.postimg.cc/mkRzF40s/bcv.png">

</p>

<p align="center">

    <b>Figura 6</b>: Folds da validação cruzada em blocos.

</p>

"""

# ╔═╡ c867fdb8-9b85-4413-8275-533e773fb466
md"""
#### Validação cruzada com razão de densidade (BCV)
"""

# ╔═╡ 141524ec-9f9d-4950-9881-8b5ddcaa95f8
html"""

<p align="center">

    <img src="https://i.postimg.cc/gJR4Wv92/drv.png">

</p>

<p align="center">

    <b>Figura 7</b>: Folds da validação cruzada com razão de densidade.

</p>

"""

# ╔═╡ Cell order:
# ╟─32f6d41e-3248-4549-9546-53b34d5aa7c6
# ╟─762a6e04-fcb7-4713-859d-fdbfe8ead1bc
# ╟─32429926-f6c3-44b8-b012-d2c67cad0b6d
# ╟─3c79e7aa-b316-4c4b-b44e-e73312085c20
# ╟─4a3fb559-73dd-41e0-8a11-993e5bf286bf
# ╟─f3ff120d-940c-40c9-b9f6-24d4a0b3aec1
# ╟─1856e01b-2d55-448d-8bdf-e59825934193
# ╟─615e4ed2-f77f-4f38-a6c1-7f0c0f985d49
# ╟─b89139a7-57da-4d9d-a791-c06edd5ab99d
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
# ╠═e912de0f-cab2-4e11-b0bd-6a9603a9e966
# ╟─ce132078-cfd3-4455-98b4-3297b1be405f
# ╟─4a3d8d5a-e429-4bc9-91ee-1de5aaa8444b
# ╟─4eadc228-7905-4328-ab01-f21339dd40aa
# ╟─3855a6d5-7b8a-487b-abad-288f9fc0152d
# ╠═eb9d3014-65b2-44f7-8d33-445826e6974b
# ╟─4b41d46e-ccf0-4232-8ce8-f9520a90efea
# ╠═a1c4fc51-1878-4c13-8d01-3642d23ee670
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
# ╟─bfbb10f9-364f-441a-872a-96753c3d2231
# ╟─89e8f272-8812-4e1e-8ab6-1cb7700c0fde
# ╠═8ee75575-d2f2-409f-9016-dac048fc6ff6
# ╟─a21d65cb-d369-4e9b-a1a6-53b06b09dc22
# ╠═cb8d9a31-d415-45b7-a743-15c715dfd2a5
# ╟─8712e1ec-0b84-4fc4-a44e-6f5a91180b8b
# ╠═59c355a1-34d5-415b-9e29-afcab5103576
# ╠═340c939a-2a9b-475d-91ef-62effb2a8da3
# ╟─2c7442fa-5b8c-411d-b3f8-f0ed2ed00dc8
# ╠═a7b23e9e-b3f3-4a8b-a5a7-dae05fd73bf1
# ╠═777f4131-2cbb-4ba5-b786-d6175e3036a5
# ╟─fbd3a1ec-214f-450f-9c2e-547df22157d3
# ╠═55151073-083b-433c-96e0-5e51978e888f
# ╟─0250f930-ac62-4fdf-8e36-b79769974a25
# ╠═a012ef03-64a4-44cb-95c2-a5f734a3f75d
# ╟─12112daa-17f1-445a-93e8-131c35cfb53d
# ╠═10ab0262-00ef-4b77-8b6b-a43cf236a29d
# ╟─427d35b8-daf0-4d16-87e5-f8eb33e265fe
# ╟─1ec6e447-fe94-4288-9996-0ba42c8d6cb0
# ╠═34f48c18-d452-4df4-a8f8-882bfc1db056
# ╟─2daa903b-af18-40ad-b9ce-0caf93b507c6
# ╠═afa08349-eab0-4ed6-a0aa-cc3cb39a619d
# ╟─b0843d5b-69eb-4a53-bff7-2d3bbd8b0057
# ╠═9dd85a75-c1e3-418a-bb3e-7c8875e9c5dd
# ╟─bd82b213-99b2-4ba7-997c-9ddbac69579c
# ╠═3ba896bd-e569-40c3-9fa1-3e79db50bf45
# ╟─f66e960b-e38f-4414-be79-09658eb5cf74
# ╠═b70f5ab7-9790-4daf-a881-d75c602aaa67
# ╠═5ec99dcc-58b4-4290-8f05-884ef11e464d
# ╟─78d9f9ba-1947-4bec-bc74-b895d084365e
# ╠═e6e84f8b-e132-42a7-a0e4-1acd9006dbbb
# ╟─653ed159-838c-47d6-878e-0b2530cf7c52
# ╟─da350067-a8fb-47bc-b9b8-b069e742383b
# ╠═ab970650-8dbd-442b-9a25-4cd871ecd336
# ╟─3e469cb8-745d-4f11-a6e7-814f29e1ccef
# ╠═5b54c097-07b2-4c26-85b1-c7716cd98145
# ╟─7d6597a0-ae24-483a-a67f-dd6235acb25e
# ╟─d10b3695-0f6d-406f-813d-17e76d47ba76
# ╟─f96d976f-f40c-4ad2-8bbe-e45da5a3ae3d
# ╟─6ccd3492-a71d-4848-97e1-900614df7aa7
# ╠═7c5beee4-c4bb-40a5-ab3e-c2fb88e363cb
# ╟─7204b07c-7ad3-4384-b41c-f214e040d280
# ╠═10454510-fcff-46d6-8e28-7800cc0bfd4d
# ╟─e4d731eb-e8a3-42d2-beae-54f053722503
# ╠═74ecd539-73e9-4fdc-ab35-4a58278ef5bf
# ╟─6dd4b8dd-7dd1-44b7-818a-f6461c9b619a
# ╟─56a82bee-08fc-4c17-9437-e105b2a3cb1c
# ╠═7e1896be-7ae8-4b61-8f47-c147ee199bac
# ╟─a183e138-60be-49ad-8b67-f780b46e9bb2
# ╠═f0f10827-7753-4f93-ba63-9b717e1e6ac9
# ╟─7a790985-6c7d-422d-bcb2-f5ba8caf0322
# ╟─551b332f-3601-472a-b44b-c9b74b199db4
# ╟─c867fdb8-9b85-4413-8275-533e773fb466
# ╟─141524ec-9f9d-4950-9881-8b5ddcaa95f8
