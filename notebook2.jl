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
	using CSV, DataFrames, Query
	using Statistics, PlutoUI
	using Plots, StatsPlots

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
## Geociência de dados 🔥

Neste módulo aprenderemos sobre esta nova área que está pegando fogo em geociências, a **geociência de dados**. Vamos aprender técnicas de manipulação de grandes bases de dados na mineração, assim como visualizações avançadas que podem ser customizadas para necessidades específicas de projetos.

Ao final deste módulo, você será capaz de:

1. Responder perguntas não-triviais sobre dados de mineracão
2. Calcular estatísticas de interesse, incluindo **estatísticas geoespaciais**
2. Produzir **visualizações avançadas** com poucas linhas de código

A demanda por profissionais com essas habilidades só tende a crescer na indústria de mineração. Torcemos que este material seja útil na sua formação e gere inovação no seu ambiente de trabalho.
"""

# ╔═╡ 25ddd894-3f2c-11eb-327f-ad0031d2e7a7
md"""
### Primeiros passos em Julia

Hoje vamos dar nossos primeiros passos em [Julia](https://julialang.org), uma linguagem de programação moderna com as características necessárias para geoestatística de **alta-performance** e geociência de dados.

A linguagem é *simples de usar* como Python e *rápida* como C. 🚀
"""

# ╔═╡ 1623916e-41fc-11eb-19ce-91716fd0f8ea
html"""
<img src="https://github.com/JuliaLang/julia-logo-graphics/blob/master/images/animated-logo.gif?raw=true" height=200>
"""

# ╔═╡ 7ff43936-41fc-11eb-3aea-dfaaba545497
md"""
#### Variáveis e funções

Para definir variáveis no notebook, utilizamos a sintaxe `variável = valor`. Existem vários tipos de valores possíveis para variáveis, como por exemplo:
"""

# ╔═╡ 7ff62bce-41fc-11eb-1f51-b9b2b9833df4
name = "Vanessa"

# ╔═╡ 7ff7b6a6-41fc-11eb-0f01-c991a9782cf3
country = "🇧🇷"

# ╔═╡ 7fff28dc-41fc-11eb-328d-8f1499a16a5f
age = 25

# ╔═╡ 7fff8066-41fc-11eb-3392-654640e59658
md"""
Essas variáveis podem ser utilizadas em qualquer outra célula para customizar seu relatório:
"""

# ╔═╡ 80034070-41fc-11eb-00d5-819ce259b506
"Bem-vinda $name $(country)! Me disseram que você tem $age anos!"

# ╔═╡ 80066c5a-41fc-11eb-075a-cd61e67f3adc
md"""
Também podemos utilizar símbolos matemáticos para as nossas variáveis, o que é bastante conveniente. Abaixo criamos três variáveis de uma vez. O resultado da célula é uma tupla:
"""

# ╔═╡ 8006c7c2-41fc-11eb-2ec1-e582eaafc2ab
α, β, τ = 1.5, 2.6, 0.5

# ╔═╡ 800a6ddc-41fc-11eb-0909-dfd4d9e0179b
md"""
Podemos definir funções de várias formas bem simples, principalmente se comparamos com outras linguagens de programação populares:
"""

# ╔═╡ 800cc280-41fc-11eb-193e-f38e4102427c
f(α, β) = 2α + β

# ╔═╡ 800f4fe6-41fc-11eb-387d-a5919143b34e
function g(τ)
	return τ^2
end

# ╔═╡ 80128724-41fc-11eb-29db-d9a9611b203d
h = α -> √α

# ╔═╡ 8012f434-41fc-11eb-0cfe-2b01bf041b7d
f(1, 2) + g(3) + h(4)

# ╔═╡ 8016c1d6-41fc-11eb-2619-112f9669b0e7
md"""
##### Exercício

Escreva uma função `volume` que retorna o volume da esfera com raio `r`:
"""

# ╔═╡ 801961ac-41fc-11eb-2b65-0b14581715e4
volume(r) = missing

# ╔═╡ 8020249c-41fc-11eb-1cef-ebe1819db6f4
md"""
#### Coleções

Vários tipos de coleções estão disponíveis para armazenar um conjunto de valores: tuplas, vetores, matrizes, tensores, dicionários, etc. A linguagem é bastante poderosa para processar essas coleções como veremos nas próximas seções deste módulo.
"""

# ╔═╡ 8026b4c4-41fc-11eb-36d0-41f86c453fb2
tuple = (1, 2, 3)

# ╔═╡ 80270ba4-41fc-11eb-3ced-cbf85a15f3b3
vector = [1, 2, 3]

# ╔═╡ 802b5e32-41fc-11eb-12d4-6b2dc82cf55a
matrix = [
	1 2
	3 4
]

# ╔═╡ 802f779e-41fc-11eb-24e4-a3b5bcfc85c4
tensor = ones(3, 3, 2)

# ╔═╡ 802fe0bc-41fc-11eb-1c57-e942c94b5a71
dict = Dict(:a => 1, :b => 2)

# ╔═╡ 80348f0e-41fc-11eb-0efa-e7fb50fc7504
namedtuple = (a = 1, b = 2)

# ╔═╡ 803883ac-41fc-11eb-02ad-772e3cf848af
md"""
As coleções mais utilizadas m aplicações científicas são os vetores, matrizes, tensores, ou mais geralmente o que chamamos de `Array` em Julia.

Arrays podem ser construídos com notação de lista, o que também é bastante conveniente:
"""

# ╔═╡ 803f7716-41fc-11eb-25df-d9da725053f5
[i for i in 1:5]

# ╔═╡ 803ffb28-41fc-11eb-1be4-27cb0f8e537e
[i for i in 1:5 if isodd(i)]

# ╔═╡ 804217b4-41fc-11eb-1908-fb5e506bdb06
[i+j for i in 1:3, j in 1:4]

# ╔═╡ 8046bee0-41fc-11eb-0464-bd19d7586aef
[i+j for i in 1:3 for j in 1:4]

# ╔═╡ 804b55f4-41fc-11eb-1c23-6b398276e6fe
md"""
##### Exercício

Dado um ângulo `θ` em radianos, escreva uma função `rotation` que retorna a matriz de rotação 2D dada por $R(θ) = \begin{bmatrix}cos(θ) & -sin(θ)\\ sin(θ) & cos(θ)\end{bmatrix}$.
"""

# ╔═╡ 8050228c-41fc-11eb-00b2-a1fd938fe153
function rotation(θ)
	missing
end

# ╔═╡ 80604f04-41fc-11eb-1af3-c9accd6abd14
md"""
Escreva a função `square` que retorna todos os elementos da coleção `xs` ao quadrado:
"""

# ╔═╡ 8064bd5a-41fc-11eb-3f0d-07a6eff7b1ac
square(xs) = missing

# ╔═╡ 807404ea-41fc-11eb-1c0c-83bf90a95a42
md"""
#### Controle de fluxo

Podemos tomar ações diferentes dependendo do valor de variáveis. Por exemplo, podemos dobrar o valor da variável `b` se a variável `a` for positiva, somar o valor `1` a `b` se a variável `a` for negativa ou atribuir um valor aleatório a `b` caso nenhuma das condições anteriores seja satisfeita:

```julia
if a > 0 # caso 1
  b = 2b
elseif a < 0 # caso 2
  b = b + 1
else # outros casos
  b = rand()
end
```
"""

# ╔═╡ 8078e488-41fc-11eb-08a4-e5945a37e3a3
md"""
##### Exercício

Escreva uma função `emoji` que recebe o nome de um emoji e retorna o símbolo do emoji:

- "diamond" --> 💎
- "tool" --> ⛏️
- "tractor" --> 🚜

Você pode copiar e colar o símbolo de um emoji dentro de uma string `"🚜"` usando `Ctrl+C` e `Ctrl+V` dentro da sua função.
"""

# ╔═╡ 80809c78-41fc-11eb-0249-af3de04c3d83
function emoji(name)
	missing
end

# ╔═╡ 47e58082-70ac-4155-a900-54e6184e5d44
md"""
Isso é tudo que precisamos saber de programação básica em Julia para o restante minicurso. Para aprender mais sobre a linguagem, recomendamos a leitura do [manual oficial](https://docs.julialang.org/en/v1/manual/getting-started) e os fóruns de usuários como [Discourse](https://discourse.julialang.org) e [Zulip](https://julialang.zulipchat.com) para tirar dúvidas.
"""

# ╔═╡ cce1ce0d-002f-4c5a-a753-e89b076f7041
md"""
### Geociência de dados

Investigaremos os dados `Bonnie` disponibilizados sob a seguinte licença:

```
The Bonnie Project Example is under copyright of Transmin Metallurgical Consultants, 2019. It is issued under the Creative Commons Attribution-ShareAlike 4.0 International Public License.
```

Os dados estão no formato CSV no arquivo `data/bonnie.csv`. Para carregar o arquivo no notebook, utilizaremos os pacotes [CSV.jl](https://github.com/JuliaData/CSV.jl) e [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl).

Especificamos o caminho do arquivo e redirecionamos o resultado para uma tabela `DataFrame` utilizando o operador `|>`, conhecido como operador "pipe" em Julia:
"""

# ╔═╡ 03422030-504e-47fb-96a1-4a2d35842107
table = CSV.File("data/bonnie.csv") |> DataFrame

# ╔═╡ d84ab2b1-eb39-4432-9899-ef69839d459c
md"""
Podemos obter estatísticas básicas de cada coluna da tabela com a função `describe`:
"""

# ╔═╡ e3581031-38e4-4180-bff6-065c565ecc40
describe(table)

# ╔═╡ 0dca6624-99e1-4e85-b3f5-bda0a3388983
md"""
Notamos que cada coluna tem um tipo de elemento `eltype` e que a coluna `:CODE` tem 70 elementos faltantes. Elementos faltantes neste caso tem o tipo `Union{Missing,String}` que representa a união do tipo `String` com o tipo `Missing`. Ou seja, a coluna `:CODE` tem elementos que são `String` mas algumas linhas tem o elemento `missing`.
"""

# ╔═╡ 68b81f0e-9560-4fbb-8131-84071115bf9b
md"""
#### Limpeza de dados

O primeiro passo na geociência de dados é a limpeza e preparação dos dados. Usaremos o pacote [Query.jl](https://github.com/queryverse/Query.jl) para manipular tabelas de uma forma sucinta e poderosa. O pacote introduz um conjunto de operações que podem ser facilmente concatenadas para produzir novas tabelas:

```julia
table |> @filter(...) |> @select(...)
```

Por exemplo, podemos eliminar as linhas da tabela que contém elementos faltantes usando a operação `@dropna` e em seguida renomear algumas das colunas da tabela resultante para maior legibilidade usando a operação `@rename`:
"""

# ╔═╡ 8afea00a-ede9-435a-9b69-0c3d854a7ca8
samples = table |> @dropna() |> @rename(:EAST=>:X, :NORTH=>:Y, :RL=>:Z,
	                                    :Auppm=>:Au, :Agppm=>:Ag, :Cuppm=>:Cu,
	                                    :Asppm=>:As, :Sper=>:S, :CODE=>:geo,
	                                    :OX=>:litho, :ISBD=>:ρ)

# ╔═╡ 78655ad4-1c53-48c1-b108-c7a6c23cc331
md"""
##### Exercício

Utilizando a [documentação](http://www.queryverse.org/Query.jl/stable/standalonequerycommands/#The-@replacena-command-1) do Query.jl, escreva uma query que troca todos os valores faltantes da tabela `table` pelo valor `0` e salva o resultado na variável `q1`:
"""

# ╔═╡ 741cdeca-45ff-40df-b45b-96ba97cefa83
q1 = missing

# ╔═╡ b20b8d48-c4ad-43ef-a39c-ca983a0323c1
md"""
#### Filtragem de dados

Para poder responder qualquer pergunta sobre os dados, nós precisamos saber filtrar as linhas da tabela que são relevantes para o cálculo da resposta. Para isso, utilizaremos a operação `@filter`.

A operação utiliza o símbolo especial `_` para se referir a linha atual da tabela sendo filtrada. Podemos escrever `_.Au` para nos referirmos ao valor da coluna (ou variável) `Au` na linha atual.

Por exemplo, podemos filtrar todas as amostras onde `Au > 0.5` e `Cu > 0`:
"""

# ╔═╡ 8bba9702-8166-4399-a801-51f67971056d
samples |> @filter(_.Au > 0.5 && _.Cu > 0)

# ╔═╡ e9355bf7-ae22-4a7f-9da3-8e42ccd563e6
md"""
##### Exercício

Encontre todas as amostras onde a soma dos teores de `Au` e `Cu` é inferior a `0.5`. Salve o resultado da query na variável `q2`.
"""

# ╔═╡ 900f4fc6-027a-47a6-b56c-45dd2cd82a2b
q2 = missing

# ╔═╡ 84e1bdab-677c-417a-98ba-6b4506ed47e4
md"""
#### Agrupamento de dados

Para responder perguntas mais avançadas sobre os dados, precisamos saber agrupar informações que estão dispersas na tabela, mas que fazem parte de um mesmo grupo (e.g. litologia). Para isso, utilizaremos as operações `@groupby` e `@map`.

A operação `@map` tem um formato mais difícil de entender:

```julia
@map({col1 = exp1, col2 = exp2, coln = expn})
```

Neste formato, estamos criando novas colunas `col1`, `col2`, ..., `coln` a partir de diferentes expressões `exp1`, `exp2`, ..., `expn` em função de outras colunas.

Para exemplificar o formato, vamos calcular o valor médio e desvio padrão de `Au` dentro de cada geologia `geo`. Para fazer isso, utilizaremos as funções `mean` e `std` da biblioteca padrão `Statistics`.

Vamos criar duas novas colunas chamadas `μAu` e `σ²Au` após agruparmos as amostras por geologia:
"""

# ╔═╡ 62cfb9ee-35f0-46a8-af76-4d2c7a09661c
samples |> @groupby(_.geo) |> @map({geo = key(_), μAu = mean(_.Au), σ²Au = std(_.Au)})

# ╔═╡ 1e8bd0a3-3a4a-4681-a994-53d6185eca97
md"""
A função `key(_)` retorna o valor da variável utilizada no agrupamento. Neste caso, a geologia pode assumir os valores `C1` ou `C2` como ilustrado na tabela.
"""

# ╔═╡ 4cf756d2-98e6-47f0-9952-17c47bab8210
md"""
##### Exercício

Escreva uma query para encontrar as litologias `litho` dentro de cada geologia `geo`.
Utilize os nomes de coluna `geo` e `litho`, nesta ordem, na tabela de resultados.
"""

# ╔═╡ e84dedf5-fdee-49c1-8765-8bc3bb869933
function query3(samples)
	missing
end

# ╔═╡ 6d757d5f-69ec-41ec-b05c-c5731af2c33b
md"""
##### Exemplo mais avançado

Suponha que estamos interessados na massa total de ouro `Au` que será minada de cada litologia `litho`. Vamos assumir que o volume de cada amostra é `1` unidade por simplicidade.

Podemos escrever uma query que:

1. Usa a operação `@mutate` para calcular uma nova coluna `mass` com a massa de `Au`
2. Usa a operação `@groupby` para agrupar as amostras por litologia `litho`
3. Usa a operação `@map` para somar a massa de `Au` dentro de cada litologia `litho`
"""

# ╔═╡ 972939e8-85d1-4754-9c41-fbac682d5245
samples |>
@mutate(mass = _.ρ * 1 * _.Au) |>
@groupby(_.litho) |>
@map({litho = key(_), mass = sum(_.mass)})

# ╔═╡ 5b58bf67-fb11-44f8-9b36-f534b0e66a8e
md"""
#### Visualização de dados

Além de responder perguntas sobre os dados, e ajudar no cálculo de estatísticas de interesse, a geociência de dados abrange metodologias de visualização, super importantes para gerar conhecimento.

Diferentemente da ciência de dados tradicional, existem dois tipos de espaço de visualização na **geo**ciência de dados, são eles:

1. Espaço geográfico
2. Espaço de características

Começaremos investigando o espaço geográfico através de visualizações das amostras em suas localizações no mundo físico. Utilizaremos o pacote [StatsPlots.jl](https://github.com/JuliaPlots/StatsPlots.jl) pela sua boa integração com o pacote Query.jl. O pacote introduz a operação `@df` como demonstrado a seguir:
"""

# ╔═╡ 28b22b40-7b26-48ad-839f-0a7770fd7765
samples |> @df scatter(:X, :Y, :Z, group = :litho, marker = :square,
	                   xlabel = "X", ylabel = "Y", zlabel = "Z")

# ╔═╡ cadf9937-8c09-49d2-b5f5-f745c1a07050
md"""
Essa operação recebe uma tabela e permite criar plots acessando os nomes das colunas. No exemplo acima, utilizamos as colunas `X`, `Y` e `Z` com as coordenadas geográficas e agrupamos as amostras por litologia `litho`.

Em outro exemplo, podemos gerar uma visão de topo do modelo de blocos utilizando apenas as coordenadas `X` e `Y` da tabela:
"""

# ╔═╡ 472eec28-72ed-4e2d-ba1e-36e804298066
samples |> @df scatter(:X, :Y, group = :litho, marker = :square,
	                   xlabel = "X", ylabel = "Y")

# ╔═╡ b0aa83f8-49f4-4e58-983e-7a80da3ea474
md"""
##### Interatividade

Para explorar melhor os dados, podemos adicionar elementos de interatividade. Esses elementos permitem que o usuário manipule paramêtros do notebook, como os ângulos de visualização. Utilizaremos o pacote `PlutoUI.jl` para adicionar elementos de interatividade:
"""

# ╔═╡ 5c628225-ab3c-4f08-afcb-bf78f9c68d7a
@bind θ Slider(0:90, default=30)

# ╔═╡ f8e40e45-31bb-4f52-bab5-850533df0caa
@bind ϕ Slider(0:90, default=30)

# ╔═╡ 5c10f73d-2f10-4c02-b484-1ddbaf565a20
samples |> @df scatter(:X, :Y, :Z, group = :litho,
	                   marker = :square, camera = (θ, ϕ),
	                   xlabel = "X", ylabel = "Y", zlabel = "Z")

# ╔═╡ 007bfdb2-4cd9-46a1-ac0a-41374192fd45
md"""
##### Exercício

Visualize todas as localizações `X`, `Y`, `Z` com amostras tais que `Au > 0.5`. Crie um elemento `Slider` para interagir com o valor de cutoff.
"""

# ╔═╡ 87c0e372-4472-41da-a3ec-716e2d42167a


# ╔═╡ 907a7f9b-b7da-421f-a2b8-91753c0d78ac
md"""
Além de gerar visualizações no espaço geográfico, podemos facilmente gerar visualizações no espaço de características (ou variáveis) das amostras.

Por exemplo, podemos gerar uma visualização dos teores de `Au` versus `Ag` agrupados por `litho`:
"""

# ╔═╡ 309e1817-17a1-4763-abc5-d3bf1ef7f7e7
samples |> @df scatter(:Au, :Ag, group = :litho, xlabel = "Au", ylabel = "Ag")

# ╔═╡ d9639cc5-8bc0-41f8-91e2-031bdcec173b
md"""
Ou gerar histogramas para diferentes variáveis:
"""

# ╔═╡ 61ce0145-cef4-49e3-9e66-418e3440658d
samples |> @df histogram(:Au, group = :litho, xlabel = "Au", ylabel = "Counts")

# ╔═╡ f365b503-29a8-4572-9be0-467d9d208960
md"""
##### Exemplo mais avançado

Suponha que estamos interessados em visualizar a função densidade de probabilidade de `Ag` para cada geologia `geo` considerando apenas amostras na litologia `"TR1"` que estão livres de `S`.

Podemos escrever uma visualização que:

1. Usa a operação `@filter` para eliminar amostras irrelevantes
2. Usa a operação `@df` para gerar o plot de densidade

Escrevemos uma operação por linha para facilitar a leitura:
"""

# ╔═╡ 3339d4f1-5f6d-4d8a-a179-4f77995bf1b3
samples |>
@filter(_.litho == "TR1" && _.S == 0) |>
@df density(:Ag, group = :geo,
	        fill = true, legend = :topleft,
            xlabel = "Ag", ylabel = "PDF")

# ╔═╡ 0cf80a48-a326-4c64-b657-4be2f95e66ea
md"""
#### Outros exemplos

Exemplos mais avançados podem ser facilmente construídos seguindo os mesmos princípios que aprendemos neste módulo. Com tempo, prática e conhecimento de domínio você vai ser capaz de gerar visualizações úteis que são impossíveis de gerar em softwares comerciais.

Violin plot de `Cu` agrupado por geologia `geo`, para diferentes litologias `litho`:
"""

# ╔═╡ 76decafb-0aa9-46df-b3a2-f699ea202406
samples |> @df violin(:litho, :Cu, group = :geo, xlabel = "Lithology", ylabel = "Cu")

# ╔═╡ 056db77f-4187-45cc-b771-5434a08be0e6
md"""
Histograma bivariado entre `Au` and `Cu`:
"""

# ╔═╡ f7055ed8-4ea3-41a5-91f4-3993c5147b15
samples |> @df marginalhist(:Au, :Cu, xlabel="Au", ylabel="Cu")

# ╔═╡ 253b8c06-b045-481a-89ca-9099ba1a1e39
md"""
e muitas outras possibilidades.
"""

# ╔═╡ bc0738b1-aa76-4c36-adc3-12854720dd4e
md"""
### Concluimos por hoje 🎉

Se chegou até aqui, parabéns por esta conquista! 👏🏻 Esperamos que esteja gostando do minicurso! Está muito difícil? Muito fácil? O que podemos fazer para melhorar o material? Compartilhe conosco e tentaremos melhorar numa próxima versão.

#### O que veremos amanhã?

- **Simulacão Gaussiana** como uma alternativa à Krigagem
- A nova área de **Aprendizado Geoestatístico** ([Hoffimann 2021](https://arxiv.org/abs/2102.08791))
"""

# ╔═╡ 200257ea-3ef2-11eb-0f63-2fed43dabcaf
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Dica", [text]))

	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Quase lá!", [text]))

	still_missing(text=md"Troque `missing` pela sua resposta.") = Markdown.MD(Markdown.Admonition("warning", "Aqui vamos nós!", [text]))

	keep_working(text=md"A resposta não está totalmente certa.") = Markdown.MD(Markdown.Admonition("danger", "Continue trabalhando nisto!", [text]))

	yays = [md"Fantástico!", md"Ótimo!", md"Yay ❤", md"Legal! 🎉", md"Muito bem!", md"Bom trabalho!", md"Você conseguiu a resposta certa!", md"Vamos seguir para próxima seção."]

	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

	not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oops!", [md"Tenha certeza que definiu uma variável chamada **$(Markdown.Code(string(variable_name)))**"]))
end;

# ╔═╡ 801c3b32-41fc-11eb-20fd-11deaf47542b
begin
	scored1 = false
	_vol = volume(3)
	if ismissing(_vol)
		still_missing()
	elseif _vol ≈ (4/3)*π*3^3
		scored1 = true
		correct()
	elseif _vol isa Number
		almost(md"A fórmula não está certa...")
	else
		keep_working()
	end
end

# ╔═╡ 801fb322-41fc-11eb-0784-e5053c75e5ff
hint(md"Alguém me disse que a fórmula é $\frac{4}{3}\pi r^3$...")

# ╔═╡ 8055419c-41fc-11eb-2a1e-5bf1d4b9a4b1
begin
	scored2 = false
	_rot = rotation(π)
	if ismissing(_rot)
		still_missing()
	elseif _rot ≈ [cos(π) -sin(π); sin(π) cos(π)]
		scored2 = true
		correct()
	elseif _rot isa Matrix
		almost(md"Trocou `sin` e `cos` talvez?")
	else
		keep_working()
	end
end

# ╔═╡ 805a398c-41fc-11eb-364f-cf4a9c87d864
hint(md"Escreva \theta e pressione TAB para escrever o símbolo θ")

# ╔═╡ 806ab098-41fc-11eb-0102-0d5729033a3e
begin
	scored3 = false
	_sqr = square([1 2; 3 4])
	if ismissing(_sqr)
		still_missing()
	elseif _sqr == [1 4; 9 16]
		scored3 = true
		correct()
	elseif _sqr == [1, 9, 4, 16]
		almost(md"Tente usar a dica")
	else
		keep_working()
	end
end

# ╔═╡ 806e40aa-41fc-11eb-2933-43d9c2c4c194
hint(md"A notação de lista `[f(x) for x in xs]` pode ser bem útil!")

# ╔═╡ 80871a58-41fc-11eb-1820-b1604f6aa881
begin
	scored4 = false
	_emj = emoji.(["diamond","tool","tractor"])
	if all(ismissing.(_emj))
		still_missing()
	elseif all(_emj .== ["💎","⛏️","🚜"])
		scored4 = true
		correct()
	elseif _emj ⊆ ["💎","⛏️","🚜"]
		almost(md"Cheque os emojis novamente...")
	else
		keep_working()
	end
end

# ╔═╡ 808cb788-41fc-11eb-3085-895eec8a68be
hint(md"Basta escrever uma sequência de `if name == \"diamond\" return \"💎\" end`")

# ╔═╡ fed76047-e402-4f6a-b9a2-b998f6d2879d
begin
	scored5 = false
	if ismissing(q1)
		still_missing()
	elseif q1 |> DataFrame == (table |> @replacena(0) |> DataFrame)
		scored5 = true
		correct()
	else
		keep_working()
	end
end

# ╔═╡ cebff47b-9a33-41b6-9757-cc99f89190f8
hint(md"Utilize a operação `@replacena`")

# ╔═╡ cceabfd2-728c-49fa-b944-cfddf3adf2e7
begin
	scored6 = false
	if ismissing(q2)
		still_missing()
	elseif q2 |> DataFrame == (samples |> @filter(_.Au + _.Cu < 0.5) |> DataFrame)
	# elseif DataFrame(q2) == DataFrame(geo=["C1","C2"], litho=[["TR1","OX1","OX2"],["OX1","FR1","TR1","OX2"]])
		scored6 = true
		correct()
	else
		keep_working()
	end
end

# ╔═╡ bd122b99-38b3-4b5c-a18f-8590aeadd4db
hint(md"Use o último exemplo como ponto de partida.")

# ╔═╡ 2a12ec7e-617f-441a-885e-6d21a63acf87
begin
	scored7 = false
	q3 = query3(samples)
	if ismissing(q3)
		still_missing()
	elseif DataFrame(q3) == DataFrame(geo=["C1","C2"], litho=[["TR1","OX1","OX2"],["OX1","FR1","TR1","OX2"]])
		scored7 = true
		correct()
	else
		keep_working()
	end
end

# ╔═╡ 74b9ea7e-5acc-48e1-b7de-468993c50be0
scored7 ? q3 : nothing

# ╔═╡ 0887e587-4857-40ec-a356-7280c7152994
hint(md"Adapte o último exemplo para usar a função `unique` na coluna `litho`.")

# ╔═╡ 4d1bf0ad-9c9c-45d4-9f18-5832b7ee0226
hint(md"Utilize `@filter` para filtrar as amostras antes de utilizar `@df`")

# ╔═╡ Cell order:
# ╟─3e0ccac6-3efd-11eb-2949-a9aa855356b2
# ╟─51dd001e-41f7-11eb-0f21-6b97ea0d70cb
# ╟─8066e25c-3fc1-11eb-1d21-89b95a15287f
# ╟─f2a77ee0-3ee1-11eb-1ce3-213bfda427c6
# ╟─25ddd894-3f2c-11eb-327f-ad0031d2e7a7
# ╟─1623916e-41fc-11eb-19ce-91716fd0f8ea
# ╟─7ff43936-41fc-11eb-3aea-dfaaba545497
# ╠═7ff62bce-41fc-11eb-1f51-b9b2b9833df4
# ╠═7ff7b6a6-41fc-11eb-0f01-c991a9782cf3
# ╠═7fff28dc-41fc-11eb-328d-8f1499a16a5f
# ╟─7fff8066-41fc-11eb-3392-654640e59658
# ╟─80034070-41fc-11eb-00d5-819ce259b506
# ╟─80066c5a-41fc-11eb-075a-cd61e67f3adc
# ╠═8006c7c2-41fc-11eb-2ec1-e582eaafc2ab
# ╟─800a6ddc-41fc-11eb-0909-dfd4d9e0179b
# ╠═800cc280-41fc-11eb-193e-f38e4102427c
# ╠═800f4fe6-41fc-11eb-387d-a5919143b34e
# ╠═80128724-41fc-11eb-29db-d9a9611b203d
# ╠═8012f434-41fc-11eb-0cfe-2b01bf041b7d
# ╟─8016c1d6-41fc-11eb-2619-112f9669b0e7
# ╠═801961ac-41fc-11eb-2b65-0b14581715e4
# ╟─801c3b32-41fc-11eb-20fd-11deaf47542b
# ╟─801fb322-41fc-11eb-0784-e5053c75e5ff
# ╟─8020249c-41fc-11eb-1cef-ebe1819db6f4
# ╠═8026b4c4-41fc-11eb-36d0-41f86c453fb2
# ╠═80270ba4-41fc-11eb-3ced-cbf85a15f3b3
# ╠═802b5e32-41fc-11eb-12d4-6b2dc82cf55a
# ╠═802f779e-41fc-11eb-24e4-a3b5bcfc85c4
# ╠═802fe0bc-41fc-11eb-1c57-e942c94b5a71
# ╠═80348f0e-41fc-11eb-0efa-e7fb50fc7504
# ╟─803883ac-41fc-11eb-02ad-772e3cf848af
# ╠═803f7716-41fc-11eb-25df-d9da725053f5
# ╠═803ffb28-41fc-11eb-1be4-27cb0f8e537e
# ╠═804217b4-41fc-11eb-1908-fb5e506bdb06
# ╠═8046bee0-41fc-11eb-0464-bd19d7586aef
# ╟─804b55f4-41fc-11eb-1c23-6b398276e6fe
# ╠═8050228c-41fc-11eb-00b2-a1fd938fe153
# ╟─8055419c-41fc-11eb-2a1e-5bf1d4b9a4b1
# ╟─805a398c-41fc-11eb-364f-cf4a9c87d864
# ╟─80604f04-41fc-11eb-1af3-c9accd6abd14
# ╠═8064bd5a-41fc-11eb-3f0d-07a6eff7b1ac
# ╟─806ab098-41fc-11eb-0102-0d5729033a3e
# ╟─806e40aa-41fc-11eb-2933-43d9c2c4c194
# ╟─807404ea-41fc-11eb-1c0c-83bf90a95a42
# ╟─8078e488-41fc-11eb-08a4-e5945a37e3a3
# ╠═80809c78-41fc-11eb-0249-af3de04c3d83
# ╟─80871a58-41fc-11eb-1820-b1604f6aa881
# ╟─808cb788-41fc-11eb-3085-895eec8a68be
# ╟─47e58082-70ac-4155-a900-54e6184e5d44
# ╟─cce1ce0d-002f-4c5a-a753-e89b076f7041
# ╠═03422030-504e-47fb-96a1-4a2d35842107
# ╟─d84ab2b1-eb39-4432-9899-ef69839d459c
# ╠═e3581031-38e4-4180-bff6-065c565ecc40
# ╟─0dca6624-99e1-4e85-b3f5-bda0a3388983
# ╟─68b81f0e-9560-4fbb-8131-84071115bf9b
# ╠═8afea00a-ede9-435a-9b69-0c3d854a7ca8
# ╟─78655ad4-1c53-48c1-b108-c7a6c23cc331
# ╠═741cdeca-45ff-40df-b45b-96ba97cefa83
# ╟─fed76047-e402-4f6a-b9a2-b998f6d2879d
# ╟─cebff47b-9a33-41b6-9757-cc99f89190f8
# ╟─b20b8d48-c4ad-43ef-a39c-ca983a0323c1
# ╠═8bba9702-8166-4399-a801-51f67971056d
# ╟─e9355bf7-ae22-4a7f-9da3-8e42ccd563e6
# ╠═900f4fc6-027a-47a6-b56c-45dd2cd82a2b
# ╟─cceabfd2-728c-49fa-b944-cfddf3adf2e7
# ╟─bd122b99-38b3-4b5c-a18f-8590aeadd4db
# ╟─84e1bdab-677c-417a-98ba-6b4506ed47e4
# ╠═62cfb9ee-35f0-46a8-af76-4d2c7a09661c
# ╟─1e8bd0a3-3a4a-4681-a994-53d6185eca97
# ╟─4cf756d2-98e6-47f0-9952-17c47bab8210
# ╠═e84dedf5-fdee-49c1-8765-8bc3bb869933
# ╟─74b9ea7e-5acc-48e1-b7de-468993c50be0
# ╟─2a12ec7e-617f-441a-885e-6d21a63acf87
# ╟─0887e587-4857-40ec-a356-7280c7152994
# ╟─6d757d5f-69ec-41ec-b05c-c5731af2c33b
# ╠═972939e8-85d1-4754-9c41-fbac682d5245
# ╟─5b58bf67-fb11-44f8-9b36-f534b0e66a8e
# ╠═28b22b40-7b26-48ad-839f-0a7770fd7765
# ╟─cadf9937-8c09-49d2-b5f5-f745c1a07050
# ╠═472eec28-72ed-4e2d-ba1e-36e804298066
# ╟─b0aa83f8-49f4-4e58-983e-7a80da3ea474
# ╠═5c628225-ab3c-4f08-afcb-bf78f9c68d7a
# ╠═f8e40e45-31bb-4f52-bab5-850533df0caa
# ╠═5c10f73d-2f10-4c02-b484-1ddbaf565a20
# ╟─007bfdb2-4cd9-46a1-ac0a-41374192fd45
# ╠═87c0e372-4472-41da-a3ec-716e2d42167a
# ╟─4d1bf0ad-9c9c-45d4-9f18-5832b7ee0226
# ╟─907a7f9b-b7da-421f-a2b8-91753c0d78ac
# ╠═309e1817-17a1-4763-abc5-d3bf1ef7f7e7
# ╟─d9639cc5-8bc0-41f8-91e2-031bdcec173b
# ╠═61ce0145-cef4-49e3-9e66-418e3440658d
# ╟─f365b503-29a8-4572-9be0-467d9d208960
# ╠═3339d4f1-5f6d-4d8a-a179-4f77995bf1b3
# ╟─0cf80a48-a326-4c64-b657-4be2f95e66ea
# ╠═76decafb-0aa9-46df-b3a2-f699ea202406
# ╟─056db77f-4187-45cc-b771-5434a08be0e6
# ╠═f7055ed8-4ea3-41a5-91f4-3993c5147b15
# ╟─253b8c06-b045-481a-89ca-9099ba1a1e39
# ╟─bc0738b1-aa76-4c36-adc3-12854720dd4e
# ╟─200257ea-3ef2-11eb-0f63-2fed43dabcaf
