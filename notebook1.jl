### A Pluto.jl notebook ###
# v0.14.0

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

# ╔═╡ 980f4910-96f3-11eb-0d4f-b71ad9888d73
begin
	# instantiate environment
    using Pkg; Pkg.activate(@__DIR__); Pkg.instantiate()
	
	# load packages used in this notebook
	using GeoStats, DrillHoles
	using CSV, DataFrames, Query
    using Statistics, StatsBase, Random
	using FileIO, PlutoUI
    using Plots, StatsPlots
	
	# default plot settings
	gr(format=:png)
end;

# ╔═╡ 14ac7b6e-9538-40a0-93d5-0379fa009872
html"""
<p style="background-color:lightgrey" xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">GeoStats.jl at CBMina</span> by <span property="cc:attributionName">Júlio Hoffimann & Franco Naghetini</span> is licensed under <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>
"""

# ╔═╡ 20fff27a-4328-43ac-97df-a35b63a6fdd0
md"""

![geostats-logo](https://github.com/JuliaEarth/GeoStats.jl/blob/master/docs/src/assets/logo-text.svg?raw=true)

# Geoestatística moderna

Instrutores: [Júlio Hoffimann](https://juliohm.github.io) & [Franco Naghetini](https://github.com/fnaghetini)

"""

# ╔═╡ c544614a-3e5c-4d22-9340-592aabf84871
md"""

## Estimativa (tradicional) de recursos

Este módulo objetiva demonstrar um fluxo de trabalho completo de estimativa (tradicional) de recursos por Krigagem realizado com a linguagem [Julia](https://docs.julialang.org/en/v1/) e o pacote [GeoStats.jl](https://juliaearth.github.io/GeoStats.jl/stable/index.html).

Nesse sentido, cobriremos desde a etapa de importação dos dados brutos (tabelas collar, survey e assay) até a estimativa dos recursos num modelo de blocos 3D (Figura 1).

Portanto, o **produto final** é um **modelo de blocos estimado** por Krigagem ordinária.

"""

# ╔═╡ 1a00e8d4-4115-4651-86a7-5237b239307f
html"""

<p align="center">

    <img src="" alt="Figura_01">

</p>

<p align="center">

    <b>Figura 1</b>: Fluxo de trabalho simplificado de estimativa de recursos.

</p>

"""

# ╔═╡ f443543c-c4f4-447b-996d-9ad00c67b1af
md"""

### Agenda

1. Importação e geração de furos
2. Compositagem das amostras
3. Análise exploratória
4. Declusterização
5. Variografia
6. Krigagem
7. Exportação

"""

# ╔═╡ ff01a7d7-d491-4d49-b470-a2af6783c82b
md"""

### 1. Importação e geração de furos

É comum que os dados de sondagem sejam apresentados por meio de um conjunto de três (ou mais) tabelas distintas, relacionadas entre si por um campo-chave (Figura 2).

Esse campo-chave que interliga as três tabelas é o identificador dos furos (comumente chamado de `BHID` ou `HOLEID`).

- A tabela **Collar** traz consigo, obrigatoriamente, informações das coordenadas de boca dos furos e de profundidade final de cada furo e, opcionalmente, a  data de finalização dos furos e o método de aquisição das coordenadas.

- A tabela **Survey** apresenta informações de perfilagem, ou seja, de orientação dos furos (dip direction/dip).

- A tabela **Assay** contém dados de teores, densidade, litologia, zonas mineralizadas e parâmetros geomecânicos agrupados por intervalos amostrais.

Para a importação das tabelas Collar, Survey, Assay e Litho e geração dos furos de sondagem, utilizaremos o pacote [DrillHoles.jl](https://juliahub.com/docs/DrillHoles/XEHc3/0.1.0/#DrillHoles).

"""

# ╔═╡ af1aca7e-bde2-4e14-a664-b7c71ff80ffe
html"""

<p align="center">

    <img src="" alt="Figura_02">

</p>

<p align="center">

    <b>Figura 2</b>: Tabelas Collar, Survey, Assay e Litho. Note que elas se relacionam entre si pelo campo-chave HOLEID.

</p>

"""

# ╔═╡ 65323392-5c7f-40af-9456-d199e90df8c2
md"""
#### Importação das tabelas
"""

# ╔═╡ 444402c6-99a3-4829-9e66-c4962fb83612
begin
	# Importação da tabela Collar
	collar = Collar(file = "data/collar.csv",
					holeid = :HOLEID, x = :X, y = :Y, z = :Z)

	# Importação da tabela Survey
	survey = Survey(file = "data/survey.csv",
					holeid = :HOLEID, at = :AT, azm = :AZM, dip = :DIP)

	# Importação da tabela Assay
	assay = Interval(file = "data/assay.csv",
					 holeid = :HOLEID, from = :FROM, to = :TO)

	# Importação da tabela Litho
	litho  = Interval(file = "data/litho.csv",
					  holeid = :HOLEID, from = :FROM, to = :TO)
end;

# ╔═╡ 0d0d610a-b06c-4c16-878d-8d2d124b8b9e
md"""
#### Geração dos furos
"""

# ╔═╡ 1d7df6f8-f643-4c1e-92b4-52e51c4ccda8
# Geração dos furos a partir das tabelas collar, survey, assay e litho
drillholes = drillhole(collar, survey, [assay, litho])

# ╔═╡ d343401d-61dc-4a45-ab9b-beaff2534886
md"""

Ao final da geração dos furos, são criados quatro objetos:

- `drillholes.table`: tabela dos furos.

- `drillholes.trace`: tabela de perfilagem dos furos.

- `drillholes.pars`: nomes das colunas presentes no arquivo de furos.

- `drillholes.warns`: tabela que contém erros e avisos identificados durante o processo de *desurveying*.

Por exemplo, podemos investigar a tabela de furos:

"""

# ╔═╡ 412cfe3d-f9f1-49a5-9f40-5ab97946df6d
# Armazenando a tabela dos furos na variável "dh"
dh = copy(drillholes.table)

# ╔═╡ 8e2b3339-a65d-4e1b-a9fb-69b6cd4631ea
md"""
#### Dicionário de atributos

O banco de dados consiste em conjunto de furos realizados durante uma campanha de sondagem em um **depósito de Cobre Pórfiro**.

A tabela abaixo apresenta a descrição de cada coluna presente na tabela de furos:
"""

# ╔═╡ 9c653929-dfe2-4506-9eae-03ab6e63ef8d
html"""

<table>

    <tr>

        <th>Atributo</th>

        <th>Unidade</th>

        <th>Descrição</th>

    </tr>

    <tr>

        <td><b>HOLEID</b></td>

        <td style="text-align: center;">-</td>

        <td>

            Identificador do furo

        </td>

    </tr>

    <tr>

        <td><b>FROM</b></td>

        <td style="text-align: center;">m</td>

        <td>

            Início do intervalo amostral

        </td>

    </tr>

	<tr>

        <td><b>TO</b></td>

        <td style="text-align: center;">m</td>

        <td>

            Final do intervalo amostral

        </td>

    </tr>

	<tr>

        <td><b>LENGTH</b></td>

        <td style="text-align: center;">m</td>

        <td>

            Comprimento da amostra

        </td>

    </tr>

	<tr>

        <td><b>CU</b></td>

        <td style="text-align: center;">%</td>

        <td>

            Teor de cobre

        </td>

    </tr>

	<tr>

        <td><b>LITH</b></td>

        <td style="text-align: center;">-</td>

        <td>

            Litologia

        </td>

    </tr>

	<tr>

        <td><b>X</b></td>

        <td style="text-align: center;">m</td>

        <td>

            Coordenada X do centroide da amostra

        </td>

    </tr>

	<tr>

        <td><b>Y</b></td>

        <td style="text-align: center;">m</td>

        <td>

            Coordenada Y do centroide da amostra

        </td>

    </tr>

	<tr>

        <td><b>Z</b></td>

        <td style="text-align: center;">m</td>

        <td>

            Coordenada Z do centroide da amostra

        </td>

    </tr>
    
</table>

"""

# ╔═╡ bedcf585-53ef-4cf6-9dc2-d3fc9cff7755
md"""
#### Sumário estatístico

Uma das primeiras atitudes a se tomar quando se lida com um novo banco de dados é a visualização do **sumário estatístico** de suas colunas. Frequentemente são encontrados valores faltantes e eventuais inconsistências.

"""

# ╔═╡ 15fd1c4d-fbf2-4389-bc1c-eabbbd26817b
# Sumário estatístico da tabela de furos
describe(dh)

# ╔═╡ 39ae0ea7-9659-4c7b-b161-fd9c3495f4e3
md"""

A partir do sumário estatístico acima, nota-se que:

- Existem **307 valores faltantes** das variáveis `CU` e `LITH`.

- As variáveis que deveriam ser numéricas foram reconhecidas como tal.

- Não existem valores anômalos que "saltam aos olhos".

"""

# ╔═╡ f9545a95-57c0-4de6-9ab7-3ac3728b3d27
md"""
#### Remoção dos valores faltantes

Como o objetivo deste módulo é a geração de um modelo de teores de Cu estimado, podemos remover os 307 valores faltantes do banco de dados.

"""

# ╔═╡ 4d5f2467-c7d5-4a82-9968-97f193090bd6
begin
    # Remoção dos valores faltantes de CU e LITH do banco de dados
    dropmissing!(dh, disallowmissing = true)

    # Sumário estatístico do banco de dados após a exclusão dos valores faltantes
    describe(dh)
end

# ╔═╡ f4bd13d4-70d3-4167-84ff-9d3c7200e143
md"""

### 2. Compositagem de amostras

Dados brutos de sondagem normalmente são obtidos em suportes amostrais variados. Nesse sentido, caso não haja um tratamento prévio desses dados, amostras de diferentes suportes amostrais terão mesmo peso na estimativa.

Portanto, um procedimento denominado **compositagem** deve ser conduzido, visando os seguintes objetivos:

- Regularizar o suporte amostral, de modo a reduzir a variância do comprimento das amostras (compositagem ao longo do furo).

- Aumentar o suporte amostral (suporte x variância = k).

- Adequar o comprimento das amostras à escala de trabalho (Figura 3).

Quando a compositagem é realizada, os teores originais são recalculados, a partir de uma média dos teores amostrais ponderada pelo comprimento amostral. Os teores resultantes são denominados **teores compostos (Tc)**:

```math
Tc = \frac{\sum_{i=1}^{n} tᵢ.eᵢ}{\sum_{i=1}^{n} eᵢ}
```

"""

# ╔═╡ 3e5efd3c-3d8a-4bf1-a0f1-b402ea4a6cd3
html"""

<p align="center">

    <img src="" alt="Figura_03">

</p>

<p align="center">

    <b>Figura 3</b>: Exemplo de compositagem por bancadas de 10 m de um furo vertical (Yamamoto, 2001). .

</p>

"""


# ╔═╡ 2a00e08c-5579-4320-b570-3b564d186fec
md"""
#### Descrição estatística pré-compositagem

Uma análise das estatísticas e do histograma da variável suporte amostral é de suma importância para avaliar a necessidade de compositagem das amostras.

"""

# ╔═╡ 79dfd582-1b75-40b0-8feb-4ee92c1b4acc
# Criação do sumário estatístico para a variável LENGTH (dataframe)
stats = DataFrame(Min    = minimum(dh.LENGTH),
                  Max    = maximum(dh.LENGTH), 
                  Mean   = mean(dh.LENGTH),
                  Median = median(dh.LENGTH),
		          Mode   = mode(dh.LENGTH),
                  STD    = std(dh.LENGTH),
                  CV     = variation(dh.LENGTH))

# ╔═╡ 41790d87-ce85-461f-a16d-04821a3624bb
begin
    # Histograma da variável LENGTH
    dh |> @df histogram(:LENGTH,
		                legend = :topleft,
		                label  = false,
		 				color  = :gray90,
						alpha  = 0.75,
	                    xlabel = "Suporte Amostral (m)",
        				ylabel = "Frequência Absoluta",
	                    title  = "Histograma de suporte amostral")

    # Linha vertical contínua vermelha (média)
    vline!([stats.Mean], label = "Média")

    # Linha vertical contínua verde (mediana)
    vline!([stats.Median], label = "Mediana")
end

# ╔═╡ 7ea21049-5edd-4979-9782-8a20d4bb287b
md"""

A partir das estatísticas e do histograma acima podemos chegar a algumas informações:

- Grande parte das amostras apresenta um comprimento igual a $(stats.Mode) m.

- A variável suporte amostral apresenta uma distribuição assimétrica negativa.

- A variável suporte amostral apresenta baixa variabilidade.

"""

# ╔═╡ d8ce39f1-8017-4df3-a55d-648bdd3dbc04
md"""

#### Compositagem das amostras

Primeiramente, vamos supor que o **tamanho da bancada da mina de Cu é de 10 m**.

Embora as amostras já estejam regularizadas para um suporte de $(stats.Mode) m, iremos compositá-las para um tamanho igual a 10 m, com o intuito de **adequar o suporte amostral à escala de trabalho**.

"""

# ╔═╡ 32f75604-b01a-4a0b-a008-33b2a56f4b57
begin
	# Compositagem das amostras para um suporte de 10 m
	composites = composite(drillholes, interval = 10.0, mode = :nodiscard)

	# Armazenando a tabela de furos compositados na variável "comps"
	cp = composites.table

	# Sumário estatístico da tabela de furos compositados
	describe(cp)
end

# ╔═╡ 8a54cc04-7c95-4fd8-a219-7153e7492634
md"""
#### Remoção dos valores faltantes dos furos compositados

Como a compositagem foi realizada sobre os furos originais (com valores faltantes),  os furos compositados apresentam **257 valores faltantes** de Cu.

Nesse sentido, esses valores faltantes devem também ser removidos.

"""

# ╔═╡ 12d3d075-bfad-431e-bbdc-341bb01a89a2
# Remoção dos valores faltantes de CU
dropmissing!(cp, disallowmissing = true);

# ╔═╡ b6712822-7c4d-4936-bcc2-21b48be99a66
md"""

Agora, com os furos compositados, podemos analisar novamente as estatísticas e histograma do suporte amostral:

"""

# ╔═╡ c6051297-bdfe-4783-b0bd-9f89912ac96d
# Criação do sumário estatístico para a variável LENGTH (dataframe)
stats2 = DataFrame(Min    = minimum(cp.LENGTH),
                   Max    = maximum(cp.LENGTH), 
                   Mean   = mean(cp.LENGTH),
                   Median = median(cp.LENGTH),
	               Mode   = mode(cp.LENGTH),
                   STD    = std(cp.LENGTH),
                   CV     = variation(cp.LENGTH))

# ╔═╡ 87808ab0-3bcb-428d-9ebf-71ffefbcb357
begin
    # Histograma da variável LENGTH
    cp |> @df histogram(:LENGTH,
	                    legend = :topleft,
                        label  = false,
                        color  = :gray90,
                        alpha  = 0.75,
	                    xlabel = "Suporte Amostral (m)",
                        ylabel = "Frequência Absoluta",
		                title  = "Histograma de suporte amostral")

    # Linha vertical contínua vermelha (média)
    vline!([stats2.Mean], label = "Média")

    # Linha vertical contínua verde (mediana)
    vline!([stats2.Median], label = "Mediana")
end

# ╔═╡ 893d7d19-878b-4990-80b1-ef030b716048
md"""

Com base no histograma e no sumário estatístico acima, chegamos às seguintes informações acerca do suporte amostral pós-compositagem:

- A média do suporte amostral dos furos compositados encontra-se muito próxima do comprimento pré-estabelecido (10 m).

- Houve uma redução da dispersão do suporte amostral.

- A distribuição da variável suporte amostral, após a compositagem, passou a ser aproximadamente simétrica.

"""

# ╔═╡ b85a7c2f-37e2-48b0-a1db-984e2e719f29
md"""
#### Validação da compositagem

Podemos avaliar o impacto da compositagem a partir de uma comparação entre os sumários estatísticos dos teores originais e teores compostos:

"""

# ╔═╡ 59dfbb66-f188-49f1-87ba-4f7020c4c031
begin	
	# Sumário estatístico do Cu original
	Cu_orig = DataFrame(Variable = "Cu (original)",
						X̄        = mean(dh.CU),
						S²       = var(dh.CU),
						S        = std(dh.CU),
						Cᵥ       = variation(dh.CU),
						P10      = quantile(dh.CU, 0.1),
						P50      = quantile(dh.CU, 0.5),
						P90      = quantile(dh.CU, 0.9),
	                    Skew     = skewness(dh.CU),
					    Kurt     = kurtosis(dh.CU))
	
	# Sumário estatístico do Cu compositado
	Cu_comp = DataFrame(Variable = "Cu (compositado)",
						X̄        = mean(cp.CU),
						S²       = var(cp.CU),
						S        = std(cp.CU),
						Cᵥ       = variation(cp.CU),
						P10      = quantile(cp.CU, 0.1),
						P50      = quantile(cp.CU, 0.5),
						P90      = quantile(cp.CU, 0.9),
		                Skew     = skewness(cp.CU),
					    Kurt     = kurtosis(cp.CU))
	
	# Concatenação vertical dos dois sumários estatísticos
	[Cu_orig
	 Cu_comp]
end

# ╔═╡ 7a021fbd-83ac-4a36-bb8c-98519e6f8acb
md"""

A partir da comparação entre os teores de Cu pré e pós compositagem, chegamos às seguintes conclusões:

- Houve uma redução de menos de 1% na média de Cu.

- A mediana se manteve idêntica após a compositagem.

- Houve uma redução de <8% no desvio padrão.

Como as estatísticas de Cu se mantiveram similares após a compositagem dos furos, pode-se dizer que esta etapa foi realizada com êxito. Nesse sentido, os furos compositados serão utilizados daqui em diante.

"""

# ╔═╡ f2be5f11-1923-4658-93cf-800ce57c32d3
md"""

### 3. Análise exploratória

A análise exploratória dos dados é uma das etapas mais cruciais do fluxo de trabalho. Em essência, ela consiste em sumarizar as principais características do dado através de estatísticas de interesse e visualizações. Veremos esta etapa em mais detalhes no segundo módulo **geociência de dados** hoje.

Aqui apresentaremos o resultado de uma análise simples e visualizações interativas para ilustrar o potencial do modelo de trabalho com notebooks [Pluto](https://github.com/fonsp/Pluto.jl).

"""

# ╔═╡ c0604ed8-766e-4c5d-a628-b156615f8140
md"""

#### Visualização espacial

Como estamos lidando com dados regionalizados, a visualização espacial da variável de interesse sempre deve ser realizada em conjunto com a sua descrição estatística. Devemos ficar atentos a possíveis agrupamentos preferenciais de amostras em regiões "mais ricas" do depósito.

"""

# ╔═╡ 8bb2f630-8234-4f7f-a05c-8206993bdd45
md"""

Rotação em Z: $(@bind α Slider(0:10:90, default=30, show_value=true))°

Rotação em X: $(@bind β Slider(0:10:90, default=30, show_value=true))°

"""

# ╔═╡ 074bff0b-6b41-4bbc-9b5c-77fbf62c4dc6
# Visualização dos furos por teor de Cu
cp |> @df scatter(:X, :Y, :Z,
	              marker_z = :CU,
	              marker   = (:circle, 4),
	              colorbar = true,
	              color    = :berlin,
                  xlabel   = "X",
	              ylabel   = "Y",
	              zlabel   = "Z",
	              label    = "Teor de Cu (%)",
                  camera   = (α, β))

# ╔═╡ 862dd0cf-69ae-48e7-92fb-ff433f62e67c
md"""

Quando não se tem muito conhecimento acerca de um depósito, a seguinte convenção é comumente utilizada para definição dos *low grades* e *high grades*:

- `low grades`: Cu (%) < P10

- `high grades`: Cu (%) > P90

"""

# ╔═╡ 3ae99e49-6996-4b4a-b930-f6073994f25c
begin	
    # Filtragem dos teores lowgrade (< P10)
    lg = cp |> @filter(_.CU ≤ Cu_comp.P10[])
	
	# Filtragem dos teores highgrade (> P90)
    hg = cp |> @filter(_.CU > Cu_comp.P90[])
end;

# ╔═╡ ea0968ca-a997-40c6-a085-34b3aa89807e
begin

    # Visualização de todas as amostras (cinza claro)
    @df cp scatter(:X, :Y, :Z,
		           marker = (:circle, 4, :gray95, 0.5),
		           label  = false,
		           xlabel = "X",
                   ylabel = "Y",
		           zlabel = "Z",
	               camera = (α, β))
	
	# Visualização de lowgrades (azul)
    @df lg scatter!(:X, :Y, :Z,
		            marker = (:circle, 4, :deepskyblue),
		            label  = "Low grade")
    
    # Visualização de highgrades (vermelho)
    @df hg scatter!(:X, :Y, :Z,
		            marker = (:circle, 4, :red),
		            label  = "High grade")

end

# ╔═╡ ccbcf57e-d00b-43df-8555-eee8bf4f9e6f
md"""

A partir da visualização espacial dos _high grades_ e _low grades_, nota-se que:

- As regiões onde ocorrem os _high grades_ apresentam maior densidade amostral.

- Os _low grades_ tendem a se concentrar em porções de densidade amostral baixa.

- As amostras apresentam-se ligeiramente agrupadas na porção sudeste do depósito.

"""

# ╔═╡ cdf51f38-0e3d-47dd-8792-fdb5741db45b
md"""

#### Estatísticas básicas

A partir do sumário estatístico realizado anteriormente e do histograma visualizado abaixo, podemos extrair informações acerca da variabilidade, tendências centrais, forma e simetria da distribuição do teor de Cu:

"""

# ╔═╡ e0bb58df-23d3-4d0f-82f9-bcb39782acd1
Cu_comp[:,2:end]

# ╔═╡ b95a6def-f3e6-4835-b15f-2a48577006f4
begin 

    # Histograma do Cu
    cp |> @df histogram(:CU,
		                bins   = 30,
		 				label  = false,
		                color  = :darkgoldenrod1,
		                alpha  = 0.7,
		                xlabel = "Cu (%)",
            			ylabel = "Frequência Absoluta")

    # Linha vertical contínua vermelha (média)
    vline!([Cu_comp.X̄], color = :blue, label = "X̄")

    # Linha vertical contínua verde (mediana)
    vline!([Cu_comp.P50], color = :green, label = "P50")
	
	# Linha vertical tracejada cinza (P10)
    vline!([Cu_comp.P10, Cu_comp.P90], color = :gray,
		    linestyle = :dashdot, primary = false)

end

# ╔═╡ 0808061f-4856-4b82-8560-46a59e669ac4
md"""

Algumas conclusões obtidas para este banco de dados:

- A média do Cu é igual a $(Cu_comp.X̄) %.

- O coeficiente de variação do Cu é de $(Cu_comp.Cᵥ) %.

- A princípio, os _low grades_ do depósito correspondem a amostras ≤ $(Cu_comp.P10) %.

- A princípio, os _high grades_ do depósito correspondem a amostras > $(Cu_comp.P90) %.

- Como X̅ > P50, Skew > 0 e tem-se cauda alongada à direita, a distribuição da variável Cu é assimétrica positiva. Isso faz sentido, uma vez que o Cu é tipicamente um elemento menor.

- Como Kurt(excessiva) > 0, a distribuição do Cu é leptocúrtica, ou seja, as caudas são mais densas do que as caudas de uma distribuição Gaussiana.

"""

# ╔═╡ 71b45351-7397-46e4-912a-c5e65fb6a1c8
md"""
#### Resumo

- Nota-se um agrupamento preferencial em porções "mais ricas" do depósito. Nesse sentido, há necessidade de se calcular estatísticas declusterizadas para o Cu.

- Rossi & Deutsch (2013) afirmam que substâncias cujo Cᵥ < 50% apresentam baixa variabilidade, ou seja, são "bem comportadas". Como Cᵥ(Cu) < 50%, pode-se dizer que a variável de interesse é pouco errática.

- Cu apresenta uma distribuição assimétrica positiva e é leptocúrtica.

"""

# ╔═╡ 5bfa698a-4e29-47f8-96fe-3c533fbdb761
md"""
### 4. Declusterização

É muito comum, na mineração, que regiões "mais ricas" de um depósito sejam mais amostradas do que suas porções "mais pobres" (Figura 4). Essa situação se justifica pelo fato de a sondagem ser um procedimento de elevado custo e, nesse sentido, é mais coerente que amostremos mais as regiões mais promissoras do depósito.

A **Teoria da Amostragem** deixa claro que a amostragem de um fenômeno (*e.g.* mineralização de Cu) deve ser representativa. Em outras palavras:

> *Uma amostra é representativa, quando qualquer parte do todo (população/depósito) tem iguais chances de ser amostrada. Se alguma parte for favorecida/desfavorecida na amostragem, a amostra não é representativa*.

Nesse sentido, como frequentemente há um agrupamento amostral preferencial nas porções ricas dos depósitos, podemos dizer que a amostragem de depósitos minerais não é representativa. Dessa maneira, como temos uma amostragem sistematicamente não representativa, teremos uma estimativa sistematicamente não fiel à realidade do depósito.

Uma forma de mitigar esse viés amostral intrínseco à indústria da mineração é a utilização de técnicas de **declusterização**.

"""

# ╔═╡ 14beece5-6475-49a0-9f5c-cefb68328e24
html"""

<p align="center">
    <img src="" alt="Figura_04">
</p>

<p align="center">
    <b>Figura 4</b>: Exemplo de agrupamento amostral preferencial nas porções "mais ricas".
</p>

"""

# ╔═╡ 201b805b-7241-441d-b2d9-5698b0da58ab
md"""
#### Georreferenciamento

Antes de realizar a declusterização, é necessário **georreferenciar os furos** compositados.

No pacote [Geostats.jl](https://juliaearth.github.io/GeoStats.jl/stable), georreferenciar os dados consiste em informar quais atributos devem ser tratados como coordenadas geográficas e quais devem ser entendidos com variáveis.

Quando se georreferencia um determinado conjunto de dados, ele passa a ser tratado  como um objeto geoespacial. Um objeto geoespacial apresenta um **domínio (domain)**, ou seja, suas informações geoespaciais (coordenadas) e **valores (values)**, ou seja, suas variáveis.

No caso, iremos georreferenciar o arquivo de furos compositados, de modo que as coordenadas `X`, `Y` e `Z` serão passadas como domínio e a variável `CU` será entendida como variável.

"""

# ╔═╡ 63b75ae2-8dca-40e3-afe0-68c6a639f54e
# Georreferenciamento das amostras compositadas
samples = georef(cp, (:X,:Y,:Z))

# ╔═╡ 5699c563-d6cb-4bc2-8063-e1be00722a41
md"""
Note que as coordenadas `X`, `Y` e `Z` foram agrupadas em uma geometria de ponto.
"""

# ╔═╡ f74b8675-64e4-438d-aa8e-7c5792d25651
md"""
#### Estatísticas declusterizadas

Com os furos georreferenciados, podemos agora calcular **estatísticas declusterizadas** para o Cu. As estatísticas declusterizadas serão utilizadas na etapa de validação da estimativa por Krigagem.

A tabela abaixo mostra uma comparação estatística entre os teores de Cu antes e depois da declusterização das amostras. As estatísticas declusterizadas são função de um tamanho de bloco especificado.

"""

# ╔═╡ 91bbc52e-412f-46eb-b342-0d202e965934
md"""
Tamanho de bloco: $(@bind s Slider(50.:10.:250., show_value=true)) m
"""

# ╔═╡ 68e50bdd-b006-4abc-aeda-c4d67c30babb
begin
	# Sumário estatístico do Cu clusterizado
	Cu_clus = Cu_comp[:,[:Variable,:X̄,:S²,:P10,:P50,:P90]]
	
	# Sumário estatístico do Cu declusterizado
	Cu_decl = DataFrame(Variable = "Cu (declusterizado)",
						X̄        = mean(samples, :CU, s),
						S²       = var(samples, :CU, s),
						P10      = quantile(samples, :CU, 0.1, s),
						P50      = quantile(samples, :CU, 0.5, s),
						P90      = quantile(samples, :CU, 0.9, s))
	
	# Razão das médias (%)
	Xᵣ = (Cu_decl.X̄ / Cu_clus.X̄)[] * 100
	
	# Concatenação dos sumários
	[Cu_clus
     Cu_decl]
end

# ╔═╡ c6710e72-400c-4e90-94e5-fd48b62b088a
begin
	# Cálculo de histogram clusterizado de Cu
	hist_clus = fit(Histogram, samples[:CU], nbins = 30)

    # Cálculo do histograma declusterizado de Cu
    hist_decl = EmpiricalHistogram(samples, :CU, s, nbins = 30)

    # Visualização dos histogramas
    plot(Statistics.normalize(hist_clus),
		 seriestype = :step,
		 normed     = true,
         color      = :darkgoldenrod1,
		 label      = "Clusterizado",
	     xlabel     = "Cu (%)",
	     ylabel     = "PDF")
	
	plot!(hist_decl,
          color  = :green,
		  legend = true,
		  label  = "Declusterizado")
end

# ╔═╡ 32a075ee-e853-4bb3-8eff-44543b6db0d5
md"""

Nota-se que a média declusterizada representa $(round(Xᵣ, digits=2)) % da média original. Ou seja, há uma diferença de $(round((100-Xᵣ), digits=2)) % de Cu entre a média original e a média declusterizada.

"""

# ╔═╡ b02263dc-280a-40b4-be1e-9c3b6873e153
md"""

### 5. Variografia

Na etapa de variografia encontramos uma função que descreve o comportamento espacial da nossa variável de interesse (Cu). É importante ressaltar que, no nosso contexto, essa função é **anisotrópica**, sendo sensível à direção, mas insensível ao sentido. A **função variograma** é a função utilizada na Krigagem:


```math
\gamma(h) = \frac{1}{2n} \sum_{i=1}^{n} [Z(x_i) - Z(x_i + h)]^2

```

onde no nosso caso específico, a variável de interesse $Z$ é o teor de Cu.

Para encontrarmos essa função, devemos realizar duas etapas principais:

- Cálculo de variogramas experimentais

- Modelagem dos variogramas experimentais

Ao final, teremos em mãos um modelo de variograma representativo da continuidade espacial do Cu e que será utilizado como entrada na estimativa por Krigagem.

"""

# ╔═╡ c0dd02dd-9b27-4d10-9ffb-a06ceb4ee1fa
md"""
##### Cálculo de variogramas experimentais

Podemos calcular variogramas experimentais (direcionais) para diversas direções no espaço. Para o cálculo de um variograma experimental direcional, devemos definir alguns parâmetros (Figura 5):

- Direção (azimute/mergulho)

- Tamanho e tolerância do passo

- Largura da banda

"""

# ╔═╡ 23609999-582e-4226-aa54-2d99ca1a931e
html"""

<p align="center">
    <img src="" alt="Figura_05">
</p>

<p align="center">
    <b>Figura 5</b>: Parâmetros para o cálculo de um variograma experimental direcional.

</p>

"""

# ╔═╡ 2e859532-d3d1-4d31-bae6-cb08f3cf40f3
md"""
##### Modelagem de variogramas experimentais

Como os variogramas experimentais só são calculados para distâncias (ou lags) específicos, é necessário o ajuste de um **modelo matemático contínuo** (Figura 6), de modo que saberemos o valor do variograma (γ) para qualquer distância entre pares de amostras (h).

"""

# ╔═╡ afc66878-f1e7-4c76-8eab-51625f2e9a0d
html"""

<p align="center">
    <img src="" alt="Figura_06">
</p>

<p align="center">
    <b>Figura 6</b>: Exemplo de um variograma experimental (esquerda) ajustado por um modelo teórico (direita).


</p>

"""

# ╔═╡ d9c9b259-e09a-4571-85bf-844a881e8251
md"""

Os modelos teóricos mais utilizados na indústria são:

- Modelo Esférico

- Modelo Gaussiano

- Modelo Exponencial

Os modelos teóricos de variograma apresentam basicamente três parâmetros (Figura 7):

- Efeito Pepita ($c_o$)

- Contribuição ($c_i$)

- Alcance ($a_i$)

"""

# ╔═╡ c2af3d54-377f-4d52-98f9-cfae89769950
html"""

<p align="center">
    <img src="" alt="Figura_07">
</p>

<p align="center">
    <b>Figura 7</b>: Propriedades do modelo de variograma.
</p>

"""

# ╔═╡ c3a0dfb3-27e5-4d9a-82e5-f722a513b788
md"""
#### Fluxo da variografia 3D

A Figura 8 ilustra o fluxo de trabalho que realizaremos para a obtenção do modelo de variograma que mapeia a continuidade espacial do Cu.

"""

# ╔═╡ 91700370-f8fe-40c9-88fb-946063ae9084
html"""

<p align="center">
    <img src="" alt="Figura_08">
</p>

<p align="center">
    <b>Figura 8</b>: Fluxo da variografia 3D.
</p>

"""

# ╔═╡ 6d520cfe-aa7b-4083-b2bf-b34f840c0a75
md"""
#### Variograma down hole

Primeiramente, devemos calcular o **variograma experimental down hole**, com o intuito de se obter o **efeito pepita** e o valor da **variância espacial por estrutura**. Esses valores serão utilizados na modelagem dos demais variogramas experimentais.

"""

# ╔═╡ 289865a9-906f-46f4-9faa-f62feebbc92a
md"""
##### Estatísticas de perfilagem

Como o variograma down hole é calculado ao longo da orientação dos furos, devemos avaliar as estatísticas das variáveis `AZM` e `DIP` pertencentes à tabela de perfilagem:

"""

# ╔═╡ 1db51803-8dc4-4db6-80a1-35a489b6fb9e
begin
	
	# Sumário estatístico da variável "AZM"
	azmdf = DataFrame(Variable = :AZM,
                      Mean     = mean(composites.trace.AZM),
					  Median   = median(composites.trace.AZM),
					  Min      = minimum(composites.trace.AZM),
					  Max      = maximum(composites.trace.AZM))
	
	# Sumário estatístico da variável "DIP"
	dipdf = DataFrame(Variable = :DIP,
                      Mean     = mean(composites.trace.DIP),
					  Median   = median(composites.trace.DIP),
					  Min      = minimum(composites.trace.DIP),
					  Max      = maximum(composites.trace.DIP))
	
	# Azimute e Dip médios
	μazi = azmdf.Mean[]
	μdip = dipdf.Mean[]
	
	# Concatenação vertical dos sumários
	[azmdf
	 dipdf]

end

# ╔═╡ a717d5d3-9f4e-4a2d-8e32-f0605bbd742f
md"""

#### Variograma down hole

Agora que sabemos a orientação média dos furos ($(round(μazi,digits=2))°/ $(round(-μdip,digits=2))°), podemos calcular o variograma experimental down hole.

"""

# ╔═╡ 8162f98b-bda1-4475-aa03-e4e379b80b17
md"""
##### Variograma experimental down hole
"""

# ╔═╡ 1465f010-c6a7-4e72-9842-4504c6dda0be
md"""

№ passos: $(@bind nlags_dh Slider(10:1:25, default=12, show_value=true))

Largura da banda: $(@bind bw_dh Slider(10:5:50, default=45, show_value=true)) m

"""

# ╔═╡ ffe3700c-262f-4949-b910-53cbe1dd597b
begin
	# Definição de uma semente aleatória
	Random.seed!(1234)
	
	# Converte coordenadas esféricas para Cartesianas
	function polar2cart(azi, dip)
    	azi_rad = deg2rad(azi)
    	dip_rad = deg2rad(dip)
    	x = sin(azi_rad) * cos(dip_rad)
    	y = cos(azi_rad) * cos(dip_rad)
    	z = -sin(dip_rad)

    	(x, y, z)
	end
	
	# Direcão ao longo dos drillholes
	normal = polar2cart(μazi, -μdip)
	maxlag = 150.0

	# Cálculo variograma down hole para a variável Cu
	γ_dh = DirectionalVariogram(normal, samples, :CU,
								dtol = bw_dh, maxlag = maxlag, nlags = nlags_dh)
	
	# Variância a priori
	σ²_dh = var(samples[:CU])
	
	# Plotagem do variograma experimental downhole
    plot(γ_dh, marker = 5, ylims = (0, σ²_dh+0.05),
		 color = :deepskyblue,
		 title = "$(round(μazi,digits=2))°/$(round(-μdip,digits=2))°")
	
	# Linha horizontal tracejada cinza (variância à priori)
    hline!([σ²_dh], color = :gray, ls = :dash, legend = false)

end

# ╔═╡ 0b46230a-b305-4840-aaad-e985444cf54e
md"""

##### Modelagem do variograma down hole

Agora que o variograma down hole foi calculado, podemos ajustá-lo com um modelo teórico conhecido. Optaremos por  utilizar o **modelo esférico com duas estruturas aninhadas**:

"""

# ╔═╡ 0585add6-1320-4a31-a318-0c40b7a444fa
md"""

Efeito pepita: $(@bind c₀ Slider(0.00:0.005:0.06, default=0.02, show_value=true))

Contribuição 1ª estrutura: $(@bind c₁ Slider(0.045:0.005:0.18, default=0.06, show_value=true))

Contribuição 2ª estrutura: $(@bind c₂ Slider(0.045:0.005:0.18, default=0.075, show_value=true))

Alcance 1ª estrutura: $(@bind a_dh1 Slider(10.0:2.0:80.0, default=80.0, show_value=true)) m

Alcance 2ª estrutura: $(@bind a_dh2 Slider(10.0:2.0:140.0, default=118.0, show_value=true)) m

"""

# ╔═╡ c6d0a87e-a09f-4e78-9672-c858b488fd39
begin

    # Criação da primeira estrutura do modelo de variograma (efeito pepita)
    model_dh0 = NuggetEffect(nugget = c₀)

    # Criação da segunda estrutura do modelo de variograma (1ª contribuição ao sill)
    model_dh1 = SphericalVariogram(sill = Float64(c₁), range = Float64(a_dh1))

    # Criação da terceira estrutura do modelo de variograma (2ª contribuição ao sill)
    model_dh2 = SphericalVariogram(sill = Float64(c₂), range = Float64(a_dh2))

    # Aninhamento das três estruturas
    model_dh = model_dh0 + model_dh1 + model_dh2

    # Plotagem do variograma experimental downhole
    plot(γ_dh, ylims = (0, σ²_dh + 0.05), marker = 5, color = :deepskyblue)

    # Plotagem do modelo de variograma aninhado
    plot!(model_dh, 0, maxlag,
		  lw = 2, color = :red,
		  legend = :right,
          title = "$(round(μazi,digits=2))°/$(round(-μdip,digits=2))°",
          ylims = (0, σ²_dh + 0.05))
    
    # Linha horizontal tracejada cinza (variância à priori)
    hline!([σ²_dh], color="gray", ls=:dash, legend=false)
    
    # Linha vertical tracejada verde (alcance)
    vline!([a_dh2], color="green", ls=:dash, legend=false)

end

# ╔═╡ 09d95ff8-3ba7-4031-946b-8ba768dae5d5
md"""
#### Variograma azimute

O próximo passo é o cálculo do **variograma experimental do azimute de maior continuidade**. Nesta etapa, obteremos a **primeira rotação do variograma**, ou seja, a rotação em torno do **eixo Z**.

"""

# ╔═╡ 52f5b648-cb76-4d87-b31c-42037cf82863
md"""
##### Variograma experimental azimute

Calcularemos diversos variogramas experimentais ortogonais entre si e escolheremos aquele que apresentar **maior continuidade (alcance)**:

"""

# ╔═╡ 17b21a63-9fa6-4975-9302-5465cdd3d2fa
md"""
Azimute: $(@bind azi Slider(0.0:22.5:67.5, default=67.5, show_value=true)) °

№ passos: $(@bind nlags_azi Slider(5:1:12, default=9, show_value=true))

Largura de banda: $(@bind bw_azi Slider(10:10:100, default=70, show_value=true)) m

"""

# ╔═╡ d07a57c3-0a7a-49c2-a840-568e72d50545
begin

    Random.seed!(1234)

    γ_azi_1 = DirectionalVariogram(polar2cart(azi,0.0),
                                   samples, :CU,
                                   dtol = bw_azi, maxlag = 350,
                                   nlags = nlags_azi)

    γ_azi_2 = DirectionalVariogram(polar2cart((azi+90.0),0.0),
                                   samples, :CU, dtol = bw_azi,
                                   maxlag = 350, nlags = nlags_azi)
	
	plot(γ_azi_1, marker=5, ylims=(0, σ²_dh + 0.1), label="$(azi)°", color=:red)

    plot!(γ_azi_2, marker=5, ylims=(0, σ²_dh + 0.1), label="$(azi+90)°",
		  color = :deepskyblue, legend = :topright)

    hline!([σ²_dh], color=:gray, ls=:dash, label=false)

end

# ╔═╡ 9389a6f4-8710-44c3-8a56-804017b6239b
md"""
##### Modelagem do variograma azimute

Agora que o variograma azimute foi calculado, podemos ajustá-lo com um modelo teórico conhecido, considerando os valores de efeito pepita e variância espacial obtidos na etapa anterior:

"""

# ╔═╡ 78b45d90-c850-4a7e-96b8-535dd23bd1a7
md"""

Alcance 1ª estrutura: $(@bind a_azi1 Slider(10.0:2.0:100.0, default=60.0, show_value=true)) m

Alcance 2ª estrutura: $(@bind a_azi2 Slider(10.0:2.0:200.0, default=176.0, show_value=true)) m

"""

# ╔═╡ e3b98c8b-878d-475b-bd4b-823d00c6141b
begin

    model_azi0 = NuggetEffect(nugget=c₀)

    model_azi1 = SphericalVariogram(sill=Float64(c₁),
                                    range=Float64(a_azi1))

    model_azi2 = SphericalVariogram(sill=Float64(c₂),
                                    range=Float64(a_azi2))

    model_azi = model_azi0 + model_azi1 + model_azi2

    plot(γ_azi_1, marker=5, color=:deepskyblue)

    plot!(model_azi, 0, 350, title="$(azi)°",
          ylims=(0, σ²_dh + 0.05), color=:red, lw=2)

    hline!([σ²_dh], color=:gray, ls=:dash, legend=false)

    vline!([a_azi2], color=:green, ls=:dash, legend=false)

end

# ╔═╡ 294ac892-8952-49bc-a063-3d290c375ea5
md"""

#### Variograma primário

Agora, calcularemos o **variograma experimental primário**, ou seja, aquele que representa a direção (azi/dip) de **maior continuidade**.

Nesta etapa, encontraremos o **maior alcance** do modelo de variograma final, além da **segunda rotação do variograma**, ou seja, aquela em torno do **eixo X**.

"""

# ╔═╡ 3859448f-265a-4929-bfa4-1809036da3dd
md"""
##### Variogram experimental primário

Para o cálculo deste variograma experimental, devemos fixar o azimute de maior continuidade já encontrado ($(azi)°) e variar o dip. A orientação (azi/dip) que fornecer o maior alcance, será eleita a **direção de maior continuidade**:

"""

# ╔═╡ 97670210-2c91-4be7-a607-0da83cb16f44
md"""

Dip: $(@bind dip Slider(0.0:22.5:90.0, default=22.5, show_value=true))°

Número de passos: $(@bind nlags_dip Slider(5:1:12, default=10, show_value=true))

Largura de banda: $(@bind bw_dip Slider(10:10:100, default=70, show_value=true)) m

"""

# ╔═╡ 668da8c2-2db6-4812-90ce-86b17b289cc6
begin
	
    Random.seed!(1234)

    γ_dip = DirectionalVariogram(polar2cart(azi,dip), samples,
                                 :CU, dtol=bw_dip, maxlag=350,
                                 nlags=nlags_dip)

	plot(γ_dip, marker=5, ylims=(0, σ²_dh + 0.05), color=:deepskyblue,
         title="$(azi)°/$(dip)°")

    hline!([σ²_dh], color=:gray, ls=:dash, legend=false)
end

# ╔═╡ eb9ebce2-7476-4f44-ad4f-10a1ca522143
md"""
##### Modelagem do variograma primário

Agora que o variograma primário foi calculado, podemos ajustá-lo com um modelo teórico conhecido:

"""

# ╔═╡ 92d11f3b-c8be-4701-8576-704b73d1b619
md"""

Alcance 1ª estrutura: $(@bind a_dip1 Slider(10.0:2.0:120.0, default=84.0, show_value=true)) m

Alcance 2ª estrutura: $(@bind a_dip2 Slider(10.0:2.0:300.0, default=192.0, show_value=true)) m

"""

# ╔═╡ fa93796d-7bc0-4391-89a7-eeb63e1a3838
begin

    model_dip0 = NuggetEffect(nugget=c₀)

    model_dip1 = SphericalVariogram(sill=Float64(c₁),
                                    range=Float64(a_dip1))

    model_dip2 = SphericalVariogram(sill=Float64(c₂),
                                    range=Float64(a_dip2))

    model_dip = model_dip0 + model_dip1 + model_dip2

    plot(γ_dip, marker=5, color=:deepskyblue)

    plot!(model_dip, 0, 350, title="$(azi)°/$(dip)°",
          ylims=(0, 0.3), color=:red, lw=2)
    
    hline!([σ²_dh], color=:gray, ls=:dash, legend=false)

    vline!([a_dip2], color=:green, ls=:dash, legend=false)

end

# ╔═╡ 6c048b83-d12c-4ce8-9e9a-b89bf3ef7638
md"""

#### Variogramas secundário e terciário

Sabe-se que, por definição, os três eixos principais do variograma são ortogonais entre si. Agora que encontramos a **direção de maior continuidade do variograma** (eixo primário), sabemos que os outros dois eixos (secundário e terciário) pertencem a um plano cuja normal é o próprio eixo primário!

Portanto, nesta etapa, encontraremos os **alcances intermediário e menor** do modelo de variograma final, bem como a **terceira rotação do variograma**, ou seja, aquela em torno do **eixo Y**.

Nesse sentido, como o eixo primário do variograma apresenta uma orientação $(azi)° / $(dip)°, com o auxílio de um **estereograma**, podemos encontrar o plano que contém os eixos secundário e terciário. Ressalta-se ainda que **eixos secundário e terciário são ortogonais entre si**.

A Figura 9 mostra um estereograma cujo eixo primário tem orientação 67°/22.5°. O **ponto vermelho** representa o **eixo primário (Y)**, enquanto os **pontos pretos** são candidatos a **eixos secundário e terciário**. O **grande círculo vermelho** representa o **plano XZ**, ou seja, aquele que contém os eixos secundário (X) e terciário (Z).

Portanto, adotaremos a seguinte convenção:

- Eixo primário (maior continuidade) = Y
- Eixo secundário (continuidade intermediária) = X
- Eixo terciário (menor continuidade) = Z

"""

# ╔═╡ 0e431ddb-45c1-4fb6-8469-8c5c10fcf13c
html"""

<p align="center">
    <img src="" alt="Figura_09">
</p>

<p align="center">
    <b>Figura 9</b>: Estereograma com o eixo primário e candidatos para os eixos secundário e terciário.
</p>

"""

# ╔═╡ 512d0792-85fc-4d81-a939-076389a59f19
md"""

##### Cálculo dos variogramas secundário e terciário

Para o cálculo dos variogramas experimentais secundário e terciário, podemos utilizar os pares de direções ortogonais representados pelos pontos pretos da Figura 9. Devemos escolher duas direções para serem eleitas as **direções primária e secundária** do modelo de variograma:

"""

# ╔═╡ 120f4a9c-2ca6-49f1-8abc-999bcc559149
md"""

Ângulo stereonet: $(@bind θ Slider(range(0, stop=180-180/8, step=180/8), show_value=true))°

№ passos: $(@bind nlags_int_min Slider(5:1:15, default=12, show_value=true))

Largura de banda: $(@bind bw_int_min Slider(10:10:100, default=70, show_value=true)) m

"""

# ╔═╡ 0def0326-55ef-45db-855e-a9a683b2a76d
begin

    Random.seed!(1234)

	# Encontra vetores u e v perpendiculares entre si e perpendiculares a normal
    u, v = Variography.planebasis(Vec(normal))
	
	# Giro no plano perpendicular gerado por u e v
	dir1 = cos(deg2rad(θ)) .* u .+ sin(deg2rad(θ)) .* v
	dir2 = cos(deg2rad(θ+90)) .* u .+ sin(deg2rad(θ+90)) .* v
	

    γ_int_min1 = DirectionalVariogram(dir1,
                                      samples, :CU,
                                      dtol=bw_int_min, maxlag=250,
                                      nlags=nlags_int_min)

    γ_int_min2 = DirectionalVariogram(dir2,
                                      samples, :CU,
                                      dtol=bw_int_min, maxlag=250,
                                      nlags=nlags_int_min)
	
	plot(γ_int_min1, marker=5, ylims=(0, 0.4), xlims=(0,250), color=:red)

    plot!(γ_int_min2, marker=5, ylims=(0, 0.4), xlims=(0,250), color=:deepskyblue,
          legend=:topright)

    hline!([σ²_dh], color="gray", ls=:dash, label=false)

end

# ╔═╡ 404622b6-bf67-4b97-9355-2c24592cc364
md"""

##### Modelagem do variograma secundário

Agora que elegemos o variograma experimental representante do eixo secundário, podemos modelá-lo com duas estruturas esféricas:

"""

# ╔═╡ 922d81f3-0836-4b14-aaf2-83be903c8642
md"""

Alcance 1ª estrutura: $(@bind a_interm1 Slider(10.0:2.0:100.0, default=62.0, show_value=true)) m

Alcance 2ª estrutura: $(@bind a_interm2 Slider(10.0:2.0:170.0, default=94.0, show_value=true)) m

"""

# ╔═╡ a74b7c50-4d31-4bd3-a1ef-6869abf73185
begin

    model_interm0 = NuggetEffect(c₀)
	
    model_interm1 = SphericalVariogram(sill=Float64(c₁),
                                       range=Float64(a_interm1))

    model_interm2 = SphericalVariogram(sill=Float64(c₂),
                                       range=Float64(a_interm2))

    model_interm = model_interm0 + model_interm1 + model_interm2

    plot(γ_int_min1, marker=5, color=:deepskyblue)

    plot!(model_interm, 0, 200,
          ylims=(0, 0.4), color=:red, lw=2)

    hline!([σ²_dh], color="gray", ls=:dash, legend=false)

    vline!([a_interm2], color="green", ls=:dash, legend=false)

end

# ╔═╡ 39838426-aeb3-424c-97b8-818b1326b771
md"""

##### Modelagem do variograma terciário

Fazemos o mesmo para o variograma terciário:

"""

# ╔═╡ dacfe446-3c19-430d-8f5f-f276a022791f
md"""

Alcance 1ª Estrutura: $(@bind a_min1 Slider(10.0:2.0:82.0, default=48.0, show_value=true)) m

Alcance 2ª Estrutura: $(@bind a_min2 Slider(10.0:2.0:110.0, default=64.0, show_value=true)) m

"""


# ╔═╡ 0927d78e-9b50-4aaf-a93c-69578608a4f8
begin

    model_min0 = NuggetEffect(c₀)

    model_min1 = SphericalVariogram(sill=Float64(c₁),
                                    range=Float64(a_min1))

    model_min2 = SphericalVariogram(sill=Float64(c₂),
                                    range=Float64(a_min2))

    model_min = model_min0 + model_min1 + model_min2

    plot(γ_int_min2, marker=5, color=:deepskyblue)

    plot!(model_min, 0, 200,
          ylims=(0, 0.4), color=:red, lw=2)

    hline!([σ²_dh], color="gray", ls=:dash)

    vline!([a_min2], color="green", ls=:dash, legend=false)

end

# ╔═╡ c9ac9fb4-5d03-43c9-833e-733e48565946
begin

    range_y = range(model_dip)
    range_x = range(model_interm)
    range_z = range(model_min)

    plot(model_min, lw=2, label="Eixo primário ($(range_z) m)",
         color=:blue, legend=:bottomright)

    plot!(model_interm, lw=2, label="Eixo secundário ($(range_x) m)",
		  color=:green)

    plot!(model_dip, lw=2, label="Eixo terciário ($(range_y) m)",
          color=:red, xlims=(0.0,350.0), ylims=(0.0,0.25))

    vline!([range_y], ls=:dash, label=false, color=:red)
    vline!([range_x], ls=:dash, label=false, color=:green)
    vline!([range_z], ls=:dash, label=false, color=:blue)
	hline!([σ²_dh], ls=:dash, label=false, color=:gray)

end

# ╔═╡ 483487c6-acf8-4551-8357-2e69e6ff44ff
md"""

#### Resumo

Agora que temos as três direções principais do modelo de variograma, podemos sumarizar as informações obtidas nos itens anteriores:

|Estrutura| Modelo | Alcance em X  | Alcance em Y | Alcance em Z | Variância |Efeito Pepita|
|:-------:|:------:|:-------------:|:------------:|:------------:|:---------:|:-----:|
|    0    |   EPP  |     -         | -            |          -   |     -     | $(c₀) |
|    1    |Esférico|$(a_interm1) m | $(a_dip1) m  | $(a_min1) m  |   $(c₁)   | -     |
|    2    |Esférico| $(range_x) m  | $(range_y) m | $(range_z) m |   $(c₂)   |   -   |


"""

# ╔═╡ 38d15817-f3f2-496b-9d83-7dc55f4276dc
begin
	
	# Obtendo rotações do variograma
    rot_z = azi
    rot_x = -dip
	rot_y = -45.0
	
	# Criação dos elipsoides de anisotropia por estrutura
	aniso_elp_1 = aniso2distance([a_dip1, a_interm1, a_min1], 
								 [rot_z, rot_x, rot_y],
								 convention=GSLIB)

    aniso_elp_2 = aniso2distance([range_y, range_x, range_z], 
                            	 [rot_z, rot_x, rot_y],
                            	 convention=GSLIB)
	
	# Criação do modelo de variograma final
	γ₀ = NuggetEffect(nugget=c₀)

    γ₁ = SphericalVariogram(sill=Float64(c₁),
                            distance=aniso_elp_1)

    γ₂ = SphericalVariogram(sill=Float64(c₂),
                            distance=aniso_elp_2)

    γ = γ₀ + γ₁ + γ₂
	
end

# ╔═╡ d700e40b-dd7f-4630-a29f-f27773000597
md"""

#### Criação do modelo de variograma final

Com as informações acima, podemos utilizar uma convenção de rotação, e definir o modelo de variograma teórico 3D que será um parâmetro de entrada no sistema linear de Krigagem.

Nesse sentido, utilizando a **convenção de rotação do GSLIB**, as rotações do modelo de variograma serão:

| Rotação | Eixo | Ângulo   |
|:-------:|:----:|:--------:|
|    1ª   |   Z  |$(rot_z)° |
|    2ª   |   X  |$(rot_x)° |
|    3ª   |   Y  |$(rot_y)° |

"""

# ╔═╡ 9baefd13-4c16-404f-ba34-5982497e8da6
md"""

### 6. Krigagem

Grande parte das estimativas realizadas na indústria são baseadas em estimadores lineares:

```math
\hat{z}(x_o) = \sum_{i=1}^{n} w_i \cdot z(x_i) = w_1 \cdot z(x_1) + w_2 \cdot z(x_2) + \cdots + w_n \cdot z(x_n)
```

Neste módulo, estimaremos os teores de Cu a partir dos estimadores lineares conhecidos como Krigagem Simples e Krigagem Ordinária.

Na **Krigagem Simples (SK)**, a média populacional é assumida como conhecida e constante em todo o domínio de estimativa. Devemos portanto definir esse parâmetro como entrada desse estimador que, no nosso contexto, será a média declusterizada. Diferentemente da Krigagem Ordinária, não há condição de fechamento para os pesos atribuídos às amostras da vizinhança e, nesse sentido, uma parte do peso é atribuída à média especificada.

Por outro lado, a **Krigagem Ordinária (OK)** não assume o conhecimento da média populacional. Nesse caso há condição de fechamento, em que o somatório dos pesos atribuídos às amostras da vizinhança deve resultar na unidade.

"""

# ╔═╡ a7a59395-59ec-442a-b4b6-7db55d150d53
md"""

##### Criação do modelo de blocos

Nesta primeira etapa, definimos o **modelo de blocos**, ou seja, o domínio onde realizaremos as estimativas de teores de Cu. Devemos definir três parâmetros:

- Ponto de origem do modelo de blocos
- Ponto de término do modelo de blocos
- Número de blocos nas direções X, Y e Z

"""

# ╔═╡ 12d79d77-358c-4098-993a-d5be538929a2
md"""

Rotação em Z: $(@bind ψ₁ Slider(0:5:90, default=45, show_value=true))°

Rotação em X: $(@bind ψ₂ Slider(0:5:90, default=45, show_value=true))°

"""

# ╔═╡ f7cee6a3-5ac2-44ff-9d5e-58ede7327c46
begin

	# Caixa delimitadora das amostras
    bbox = boundingbox(samples)
	
	# Tamanho dos blocos em cada direção (metros)
	bsizes  = (20., 20., 10.)
	
	# Número de blocos em cada direção
	nblocks = Tuple(maximum(bbox) - minimum(bbox)) ./ bsizes

	# Modelo de blocos para realização de estimativas
    grid = CartesianGrid(minimum(bbox), maximum(bbox),
		                 dims = ceil.(Int, nblocks))

    plot(grid, camera=(ψ₁,ψ₂), xlabel="X", ylabel="Y", zlabel="Z")

end

# ╔═╡ a8adf478-620d-4744-aae5-99d0891fe6b0
md"""

##### Definição do problema

Para definirmos o problema de estimação, devemos passar como parâmetros:

- Furos georreferenciados
- Modelo de blocos
- Variável de interesse

"""

# ╔═╡ affacc76-18e5-49b2-8e7f-77499d2503b9
problem = EstimationProblem(samples, grid, :CU)

# ╔═╡ 31cd3d10-a1e8-4ad8-958f-51de08d0fa54
md"""

##### Definição do solver

Um **solver** nada mais é do que o estimador que utilizaremos para realizar a estimativa. No nosso contexto, criaremos dois solvers:

- Krigagem Simples (SK)
- Krigagem Ordinária (OK)

"""

# ╔═╡ 9c61271d-4afe-4f7c-a521-8f799b6981ed
md"""

№ mínimo de amostras: $(@bind s_min Slider(2:1:6, default=4, show_value=true))

№ máximo de amostras: $(@bind s_max Slider(6:1:20, default=8, show_value=true))

"""

# ╔═╡ 2a76c2b9-953e-4e4b-a98e-8e992943f60c
begin
	
	# Média desclusterizada
    μ = mean(samples, :CU)

	# Krigagem simples
    SK = Kriging(:CU => (variogram = γ, mean = μ,
			             minneighbors = s_min,
			             maxneighbors = s_max))

	# Krigagem ordinária
    OK = Kriging(:CU => (variogram = γ,
			             minneighbors = s_min,
			             maxneighbors = s_max))

end;

# ╔═╡ 9b3fe534-78fa-48db-a101-e2a43f2478d6
md"""

##### Solução do problema

Para gerar o modelo de teores de Cu, resolvemos o problema definido com qualquer um dos solvers. Como o notebook que estamos trabalhando reage a qualquer alteração dos parâmetros, nós adicionamos um checkbox para apenas executar a Krigagem sob demanda.

Marque o checkbox $(@bind run CheckBox()) para executar a Krigagem.

"""

# ╔═╡ 78117ae8-d77c-4508-9793-3e7e9dfbb913
if run
	sol_SK = solve(problem, SK)
end

# ╔═╡ 5e86ee34-60fe-43e4-851c-2f08072f836e
if run
	sol_OK = solve(problem, OK)
end

# ╔═╡ 50650d2f-350b-446d-8c4b-6aa19e18c148
md"""
Marque o checkbox $(@bind viz CheckBox()) para visualizar o modelo de teores.

**Alerta:** A visualização pode demorar a aparecer por conta da biblioteca Plots.jl utilizada neste notebook. Aconselhamos a biblioteca [Makie.jl](https://github.com/JuliaPlots/Makie.jl) para visualizações 3D.
"""

# ╔═╡ 63d5db73-1073-4b8d-bfab-93577579571f
if viz
	cmin, cmax = coordinates.(extrema(grid))
		
	xm, ym, zm = cmin
	xM, yM, zM = cmax
	
	md"""

	Rotação em Z: $(@bind ϕ₁ Slider(0:5:90, default=45, show_value=true))°

	Rotação em X: $(@bind ϕ₂ Slider(0:5:90, default=45, show_value=true))°

	X: $(@bind x Slider(xm:xM, show_value=true, default=(xm+xM)/2)) m
	
	Y: $(@bind y Slider(ym:yM, show_value=true, default=(ym+yM)/2)) m
	
	Z: $(@bind z Slider(zm:zM, show_value=true, default=(zm+zM)/2)) m
	"""
end

# ╔═╡ b2197d9c-0342-4efe-8c9e-ecf45a07fcf3
if viz
	sol_OK |> @map({CU = _.CU, COORDS = coordinates(centroid(_.geometry))}) |>
	@map({CU = _.CU, X = _.COORDS[1], Y = _.COORDS[2], Z = _.COORDS[3]}) |>
	@filter(_.X < x && _.Y < y && _.Z < z) |>
	@df scatter(:X, :Y, :Z, marker_z = :CU, color = :berlin, marker = (:square, 4),
	            xlabel = "X", ylabel = "Y", zlabel = "Z",
		        xlims = (xm, xM), ylims = (ym, yM), zlims = (zm, zM),
	            label = "Modelo de teores de Cu (%)", camera = (ϕ₁, ϕ₂))
end

# ╔═╡ 4f05c05d-c92a-460d-b3e0-d392111ef57a
md"""

#### Validação da estimativa

Uma etapa crucial do fluxograma de estimativa de recursos é a **validação da estimativa**. Dentre as diversas formas existentes, realizaremos as seguintes validações:

- Validação global da estimativa

- Q-Q Plot entre teores amostrais e teores estimados

"""

# ╔═╡ 64a8cd06-6020-434a-a1e2-115e17c51d29
md"""

##### Validação global da estimativa

Nesta validação, nos atentaremos para a comparação entre os seguintes sumários estatísticos das seguintes variáveis:

- Cu amostral
- Cu declusterizado
- Cu estimado por SK
- Cu estimado por OK

É importante ressaltar dois pontos acerca dos estimadores da família da krigagem:

- Como a krigagem leva em consideração a redundância amostral, é mais conveniente compararmos a média krigada com a a média declusterizada

- Em geral estimativas por krigagem tendem a não honrar a real heterogeneidade do depósito. Em outras palavras, o histograma dos teores estimados por krigagem tende a ser mais suavizado do que o histograma dos teores amostrais

"""

# ╔═╡ c6b0f335-19cb-4fbe-a47b-2ba3fd664832
if run
	
	stats_SK = DataFrame(Variable = "Cu (Krigagem simples)",
                         X̄   = mean(sol_SK[:CU]),
                         S²  = var(sol_SK[:CU]),
                         P10 = quantile(sol_SK[:CU], 0.1),
                         P50 = quantile(sol_SK[:CU], 0.5),
                         P90 = quantile(sol_SK[:CU], 0.9))

	
    stats_OK = DataFrame(Variable = "Cu (Krigagem ordinária)",
                         X̄   = mean(sol_OK[:CU]),
                         S²  = var(sol_OK[:CU]),
                         P10 = quantile(sol_OK[:CU], 0.1),
                         P50 = quantile(sol_OK[:CU], 0.5),
                         P90 = quantile(sol_OK[:CU], 0.9))

    [Cu_clus
	 Cu_decl
	 stats_SK
	 stats_OK]

end

# ╔═╡ ed97c749-30b7-4c72-b790-fef5a8332548
if run
md"""
A partir da comparação entre as estatísticas acima, nota-se que:

- As duas médias estimadas são muito próximas da média declusterizada

- Houve uma redução significativa da dispersão dos teores estimados pelos dois métodos quando comparados com os teores amostrais. OK apresentou estimativas menos suavizadas do que as estimativas de SK.


"""
end

# ╔═╡ 263c1837-7474-462b-bd97-ee805baec458
md"""

##### Q-Q plot

O Q-Q plot entre os teores amostrais (reais) e os teores estimados pode ser utilizado para realizar uma comparação entre as distribuições de Cu amostral e Cu estimado. Podemos analisar visualmente o grau de suavização da estimativa por Krigagem.

Quanto mais distantes forem os pontos do plot da função identidade (X=Y), mais suaves são as estimativas em relação a distribuicão amostral.

"""

# ╔═╡ 193dde9b-1f4a-4313-a3a6-ba3c89600bcb
if run

    qq_SK = qqplot(
				   samples[:CU], sol_SK[:CU],
                   xlabel="Cu(%)", ylabel="Cu-SK(%)",
                   color=:red,legend=:false,
                   title="Amostral x Estimado-SK"
                   )
 
    qq_OK = qqplot(
				   samples[:CU], sol_OK[:CU],
                   xlabel="Cu(%)", ylabel="Cu-OK(%)",
                   color=:green,
                   title="Amostral x Estimado-OK"
				  )

    plot(qq_SK, qq_OK)

end

# ╔═╡ 2181506b-76f5-4a57-adba-e90679b2b21b
md"""

#### Resumo

- A Krigagem ordinária é superior a Krigagem simples como ilustrado no Q-Q plot.

- Métodos de Krigagem são conhecidos por suavizar **inadequadamente** a distribuição de teores.

- Amanhã aprenderemos uma alternativa a Krigagem no módulo **simulação Gaussiana**.
"""

# ╔═╡ 5ad612f4-76e9-4867-b4c8-4c35540a5f47
md"""

### 7. Exportação do modelo de teores

É possível exportar o modelo de teores para diferentes formatos como CSV e GSLIB caso seja necessário continuar o trabalho em outro software. Por exemplo, para exportar no formato GSLIB, o seguinte código pode ser utilizado:

"""

# ╔═╡ b96c4bd5-54ba-4394-b963-5c5ddc06cf3b
if run
	save("output/grademodel.gslib", sol_OK)
end

# ╔═╡ 83b9ba41-4ada-496a-bf0f-32b37fde1027
md"""
E para exportar no formato CSV, a seguinte função pode ser útil:
"""

# ╔═╡ 79bc4b7d-72de-4c9e-94f5-3b5ba6bbff1d
function csvtable(solution, variable)
	center = centroid.(domain(solution))
	
	coords = coordinates.(center)
	
	X = getindex.(coords, 1)
	
	Y = getindex.(coords, 2)
	
	Z = getindex.(coords, 3)
	
	mean = solution[variable]
	
	var  = solution[variable*"-variance"]
	
	DataFrame(MEAN = mean, VARIANCE = var, X = X, Y = Y, Z = Z)
end;

# ╔═╡ 245c7304-1cc0-408a-97ec-867ac0cc81b0
if run
	csvtable(sol_OK, "CU") |> CSV.write("output/grademodel.csv")
end;

# ╔═╡ Cell order:
# ╟─980f4910-96f3-11eb-0d4f-b71ad9888d73
# ╟─14ac7b6e-9538-40a0-93d5-0379fa009872
# ╟─20fff27a-4328-43ac-97df-a35b63a6fdd0
# ╟─c544614a-3e5c-4d22-9340-592aabf84871
# ╟─1a00e8d4-4115-4651-86a7-5237b239307f
# ╟─f443543c-c4f4-447b-996d-9ad00c67b1af
# ╟─ff01a7d7-d491-4d49-b470-a2af6783c82b
# ╟─af1aca7e-bde2-4e14-a664-b7c71ff80ffe
# ╟─65323392-5c7f-40af-9456-d199e90df8c2
# ╠═444402c6-99a3-4829-9e66-c4962fb83612
# ╟─0d0d610a-b06c-4c16-878d-8d2d124b8b9e
# ╠═1d7df6f8-f643-4c1e-92b4-52e51c4ccda8
# ╟─d343401d-61dc-4a45-ab9b-beaff2534886
# ╠═412cfe3d-f9f1-49a5-9f40-5ab97946df6d
# ╟─8e2b3339-a65d-4e1b-a9fb-69b6cd4631ea
# ╟─9c653929-dfe2-4506-9eae-03ab6e63ef8d
# ╟─bedcf585-53ef-4cf6-9dc2-d3fc9cff7755
# ╠═15fd1c4d-fbf2-4389-bc1c-eabbbd26817b
# ╟─39ae0ea7-9659-4c7b-b161-fd9c3495f4e3
# ╟─f9545a95-57c0-4de6-9ab7-3ac3728b3d27
# ╠═4d5f2467-c7d5-4a82-9968-97f193090bd6
# ╟─f4bd13d4-70d3-4167-84ff-9d3c7200e143
# ╟─3e5efd3c-3d8a-4bf1-a0f1-b402ea4a6cd3
# ╟─2a00e08c-5579-4320-b570-3b564d186fec
# ╟─79dfd582-1b75-40b0-8feb-4ee92c1b4acc
# ╟─41790d87-ce85-461f-a16d-04821a3624bb
# ╟─7ea21049-5edd-4979-9782-8a20d4bb287b
# ╟─d8ce39f1-8017-4df3-a55d-648bdd3dbc04
# ╠═32f75604-b01a-4a0b-a008-33b2a56f4b57
# ╟─8a54cc04-7c95-4fd8-a219-7153e7492634
# ╠═12d3d075-bfad-431e-bbdc-341bb01a89a2
# ╟─b6712822-7c4d-4936-bcc2-21b48be99a66
# ╟─c6051297-bdfe-4783-b0bd-9f89912ac96d
# ╟─87808ab0-3bcb-428d-9ebf-71ffefbcb357
# ╟─893d7d19-878b-4990-80b1-ef030b716048
# ╟─b85a7c2f-37e2-48b0-a1db-984e2e719f29
# ╟─59dfbb66-f188-49f1-87ba-4f7020c4c031
# ╟─7a021fbd-83ac-4a36-bb8c-98519e6f8acb
# ╟─f2be5f11-1923-4658-93cf-800ce57c32d3
# ╟─c0604ed8-766e-4c5d-a628-b156615f8140
# ╟─074bff0b-6b41-4bbc-9b5c-77fbf62c4dc6
# ╟─8bb2f630-8234-4f7f-a05c-8206993bdd45
# ╟─862dd0cf-69ae-48e7-92fb-ff433f62e67c
# ╟─ea0968ca-a997-40c6-a085-34b3aa89807e
# ╟─3ae99e49-6996-4b4a-b930-f6073994f25c
# ╟─ccbcf57e-d00b-43df-8555-eee8bf4f9e6f
# ╟─cdf51f38-0e3d-47dd-8792-fdb5741db45b
# ╟─e0bb58df-23d3-4d0f-82f9-bcb39782acd1
# ╟─b95a6def-f3e6-4835-b15f-2a48577006f4
# ╟─0808061f-4856-4b82-8560-46a59e669ac4
# ╟─71b45351-7397-46e4-912a-c5e65fb6a1c8
# ╟─5bfa698a-4e29-47f8-96fe-3c533fbdb761
# ╟─14beece5-6475-49a0-9f5c-cefb68328e24
# ╟─201b805b-7241-441d-b2d9-5698b0da58ab
# ╠═63b75ae2-8dca-40e3-afe0-68c6a639f54e
# ╟─5699c563-d6cb-4bc2-8063-e1be00722a41
# ╟─f74b8675-64e4-438d-aa8e-7c5792d25651
# ╟─91bbc52e-412f-46eb-b342-0d202e965934
# ╟─68e50bdd-b006-4abc-aeda-c4d67c30babb
# ╟─c6710e72-400c-4e90-94e5-fd48b62b088a
# ╟─32a075ee-e853-4bb3-8eff-44543b6db0d5
# ╟─b02263dc-280a-40b4-be1e-9c3b6873e153
# ╟─c0dd02dd-9b27-4d10-9ffb-a06ceb4ee1fa
# ╟─23609999-582e-4226-aa54-2d99ca1a931e
# ╟─2e859532-d3d1-4d31-bae6-cb08f3cf40f3
# ╟─afc66878-f1e7-4c76-8eab-51625f2e9a0d
# ╟─d9c9b259-e09a-4571-85bf-844a881e8251
# ╟─c2af3d54-377f-4d52-98f9-cfae89769950
# ╟─c3a0dfb3-27e5-4d9a-82e5-f722a513b788
# ╟─91700370-f8fe-40c9-88fb-946063ae9084
# ╟─6d520cfe-aa7b-4083-b2bf-b34f840c0a75
# ╟─289865a9-906f-46f4-9faa-f62feebbc92a
# ╟─1db51803-8dc4-4db6-80a1-35a489b6fb9e
# ╟─a717d5d3-9f4e-4a2d-8e32-f0605bbd742f
# ╟─8162f98b-bda1-4475-aa03-e4e379b80b17
# ╟─ffe3700c-262f-4949-b910-53cbe1dd597b
# ╟─1465f010-c6a7-4e72-9842-4504c6dda0be
# ╟─0b46230a-b305-4840-aaad-e985444cf54e
# ╟─c6d0a87e-a09f-4e78-9672-c858b488fd39
# ╟─0585add6-1320-4a31-a318-0c40b7a444fa
# ╟─09d95ff8-3ba7-4031-946b-8ba768dae5d5
# ╟─52f5b648-cb76-4d87-b31c-42037cf82863
# ╟─d07a57c3-0a7a-49c2-a840-568e72d50545
# ╟─17b21a63-9fa6-4975-9302-5465cdd3d2fa
# ╟─9389a6f4-8710-44c3-8a56-804017b6239b
# ╟─e3b98c8b-878d-475b-bd4b-823d00c6141b
# ╟─78b45d90-c850-4a7e-96b8-535dd23bd1a7
# ╟─294ac892-8952-49bc-a063-3d290c375ea5
# ╟─3859448f-265a-4929-bfa4-1809036da3dd
# ╟─668da8c2-2db6-4812-90ce-86b17b289cc6
# ╟─97670210-2c91-4be7-a607-0da83cb16f44
# ╟─eb9ebce2-7476-4f44-ad4f-10a1ca522143
# ╟─fa93796d-7bc0-4391-89a7-eeb63e1a3838
# ╟─92d11f3b-c8be-4701-8576-704b73d1b619
# ╟─6c048b83-d12c-4ce8-9e9a-b89bf3ef7638
# ╟─0e431ddb-45c1-4fb6-8469-8c5c10fcf13c
# ╟─512d0792-85fc-4d81-a939-076389a59f19
# ╟─0def0326-55ef-45db-855e-a9a683b2a76d
# ╟─120f4a9c-2ca6-49f1-8abc-999bcc559149
# ╟─404622b6-bf67-4b97-9355-2c24592cc364
# ╟─a74b7c50-4d31-4bd3-a1ef-6869abf73185
# ╟─922d81f3-0836-4b14-aaf2-83be903c8642
# ╟─39838426-aeb3-424c-97b8-818b1326b771
# ╟─0927d78e-9b50-4aaf-a93c-69578608a4f8
# ╟─dacfe446-3c19-430d-8f5f-f276a022791f
# ╟─483487c6-acf8-4551-8357-2e69e6ff44ff
# ╟─c9ac9fb4-5d03-43c9-833e-733e48565946
# ╟─d700e40b-dd7f-4630-a29f-f27773000597
# ╟─38d15817-f3f2-496b-9d83-7dc55f4276dc
# ╟─9baefd13-4c16-404f-ba34-5982497e8da6
# ╟─a7a59395-59ec-442a-b4b6-7db55d150d53
# ╟─f7cee6a3-5ac2-44ff-9d5e-58ede7327c46
# ╟─12d79d77-358c-4098-993a-d5be538929a2
# ╟─a8adf478-620d-4744-aae5-99d0891fe6b0
# ╠═affacc76-18e5-49b2-8e7f-77499d2503b9
# ╟─31cd3d10-a1e8-4ad8-958f-51de08d0fa54
# ╠═2a76c2b9-953e-4e4b-a98e-8e992943f60c
# ╟─9c61271d-4afe-4f7c-a521-8f799b6981ed
# ╟─9b3fe534-78fa-48db-a101-e2a43f2478d6
# ╠═78117ae8-d77c-4508-9793-3e7e9dfbb913
# ╠═5e86ee34-60fe-43e4-851c-2f08072f836e
# ╟─50650d2f-350b-446d-8c4b-6aa19e18c148
# ╟─b2197d9c-0342-4efe-8c9e-ecf45a07fcf3
# ╟─63d5db73-1073-4b8d-bfab-93577579571f
# ╟─4f05c05d-c92a-460d-b3e0-d392111ef57a
# ╟─64a8cd06-6020-434a-a1e2-115e17c51d29
# ╟─c6b0f335-19cb-4fbe-a47b-2ba3fd664832
# ╟─ed97c749-30b7-4c72-b790-fef5a8332548
# ╟─263c1837-7474-462b-bd97-ee805baec458
# ╟─193dde9b-1f4a-4313-a3a6-ba3c89600bcb
# ╟─2181506b-76f5-4a57-adba-e90679b2b21b
# ╟─5ad612f4-76e9-4867-b4c8-4c35540a5f47
# ╠═b96c4bd5-54ba-4394-b963-5c5ddc06cf3b
# ╟─83b9ba41-4ada-496a-bf0f-32b37fde1027
# ╠═245c7304-1cc0-408a-97ec-867ac0cc81b0
# ╟─79bc4b7d-72de-4c9e-94f5-3b5ba6bbff1d
