### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 3e0ccac6-3efd-11eb-2949-a9aa855356b2
begin
	# instantiate environment
	using Pkg; Pkg.activate(@__DIR__); Pkg.instantiate()
	
	# load packages used in this notebook
	using GeoStats, Query, PlutoUI, Plots
	
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

Instrutores: [Júlio Hoffimann](https://juliohm.github.io) & [Franco Naghetini]()
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

Hoje vamos dar nossos primeiros passos em [Julia](https://julialang.org), uma linguagem de programação moderna com as características necessárias para geoestatística de alta-performance. A linguagem é *simples de usar* como Python e *rápida* como C. 🚀
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

# ╔═╡ cce1ce0d-002f-4c5a-a753-e89b076f7041
md"""
### Geociência de dados
"""

# ╔═╡ 8254c0c3-2211-4370-8afe-21a556e11f23
# TODO

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
# ╟─cce1ce0d-002f-4c5a-a753-e89b076f7041
# ╠═8254c0c3-2211-4370-8afe-21a556e11f23
# ╟─200257ea-3ef2-11eb-0f63-2fed43dabcaf
