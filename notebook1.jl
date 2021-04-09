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
    using Pkg; Pkg.activate(@__DIR__); Pkg.instantiate()
    using CSV, DataFrames, Query
    using PlutoUI, Random
    using Statistics, StatsBase
    using GeoStats, DrillHoles, GslibIO, FileIO
    using StatsPlots, Plots; gr(format="png")
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

1. Importação e geração dos furos
2. Compositagem das amostras
3. Análise exploratória
4. Declusterização
5. Variografia
6. Krigagem

"""

# ╔═╡ ff01a7d7-d491-4d49-b470-a2af6783c82b
md"""

### 1. Importação e geração dos furos

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

# ╔═╡ ea0968ca-a997-40c6-a085-34b3aa89807e
begin
	
    # Filtragem dos teores lowgrade (< P10)
    lg = cp |> @filter(_.CU ≤ Cu_comp.P10[])
	
	# Filtragem dos teores highgrade (> P90)
    hg = cp |> @filter(_.CU > Cu_comp.P90[])

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
#### Georeferenciamento

Antes de realizar a declusterização, é necessário **georeferenciar os furos** compositados.

No pacote [Geostats.jl](https://juliaearth.github.io/GeoStats.jl/stable), georreferenciar os dados consiste em informar quais atributos devem ser tratados como coordenadas geográficas e quais devem ser entendidos com variáveis.

Quando se georeferencia um determinado conjunto de dados, ele passa a ser tratado  como um objeto geoespacial. Um objeto geoespacial apresenta um **domínio (domain)**, ou seja, suas informações geoespaciais (coordenadas) e **valores (values)**, ou seja, suas variáveis.

No caso, iremos georreferenciar o arquivo de furos compositados, de modo que as coordenadas `X`, `Y` e `Z` serão passadas como domínio e a variável `CU` será entendida como variável.

"""

# ╔═╡ 63b75ae2-8dca-40e3-afe0-68c6a639f54e
# Georeferenciamento das amostras compositadas
samples = georef(cp, (:X,:Y,:Z))

# ╔═╡ 5699c563-d6cb-4bc2-8063-e1be00722a41
md"""
Note que as coordenadas `X`, `Y` e `Z` foram agrupadas em uma geometria de ponto.
"""

# ╔═╡ f74b8675-64e4-438d-aa8e-7c5792d25651
md"""
#### Estatísticas declusterizadas

Com os furos georeferenciados, podemos agora calcular **estatísticas declusterizadas** para o Cu. As estatísticas declusterizadas serão utilizadas na etapa de validação da estimativa por Krigagem.

A tabela abaixo mostra uma comparação estatística entre os teores de Cu antes e depois da declusterização das amostras:

"""

# ╔═╡ 68e50bdd-b006-4abc-aeda-c4d67c30babb
begin
	# Sumário estatístico do Cu clusterizado
	Cu_clus = Cu_comp[:,[:Variable,:X̄,:S²,:P10,:P50,:P90]]
	
	# Sumário estatístico do Cu declusterizado
	Cu_decl = DataFrame(Variable = "Cu (declusterizado)",
						X̄        = mean(samples, :CU),
						S²       = var(samples, :CU),
						P10      = quantile(samples, :CU, 0.1),
						P50      = quantile(samples, :CU, 0.5),
						P90      = quantile(samples, :CU, 0.9))
	
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
    hist_decl = EmpiricalHistogram(samples, :CU, nbins = 30)

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

#### Função variograma/semivariograma

A **função variograma** é uma função matemática que mapeia o comportamento espacial de uma variável regionalizada. No nosso caso, essa variável é o Cu.

```math
γ(h) = \frac{1}{2n} \sum_{i=1}^{n} [Z(xᵢ) - Z(xᵢ + h)]^2

```

Nesse sentido, o objetivo desta etapa consiste em encontrar uma função matemática que descreve o comportamento espacial da nossa variável de interesse (Cu). É importante ressaltar que, no nosso contexto, essa função é **anisotrópica**, sendo sensível à direção, mas insensível ao sentido.

Para encontrarmos essa função, devemos realizar duas etapas principais:

- Cálculo de variogramas experimentais

- Modelagem dos variogramas experimentais

Ao final, teremos em mãos um modelo de variograma representativo da continuidade espacial do Cu e que será utilizado como entrada na estimativa por krigagem.

"""

# ╔═╡ c0dd02dd-9b27-4d10-9ffb-a06ceb4ee1fa
md"""
##### Cálculo de variogramas experimentais

O **variograma experimental** é uma função discreta que, quando anisotrópica, varia de acordo com a direção que é calculada. Nesse sentido, podemos calcular variogramas experimentais (direcionais) para diversas direções no espaço.

Para o cálculo de um variograma experimental direcional, devemos definir alguns parâmetros, como (Figura 5):

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

Como os variogramas experimentais são funções **discretas**, é necessário o ajuste de um **modelo matemático contínuo** (Figura 6), de modo que saberemos o valor do variograma (γ) para qualquer distância entre pares de amostras (h).

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

É importante ressaltar que apenas funções contínuas e monotônicas crescentes podem ser utilizadas como ajustes teóricos de variograma. Os modelos teóricos mais utilizados na indústria são:

- Modelo Esférico

- Modelo Gaussiano

- Modelo Exponencial

Os modelos teóricos de variograma apresentam basicamente quatro propriedades (Figura 7):

- Efeito Pepita (C₀)

- Variância Espacial (Cᵢ)

- Patamar (C₀+Cᵢ)

- Alcance (aᵢ)

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

# ╔═╡ 0c0ee038-7c0e-4fc4-9ff7-b05d3b7e4c30
md"""

##### Função polar2cart()

Inicialmente, definiremos a função `polar2cart()` para converter uma medida do tipo `(azi/dip)` para `(xᵢ, yᵢ, zᵢ)`, uma vez que a direção do variograma experimental deve ser informada em coordenadas cartesianas.

"""

# ╔═╡ bba932bc-959e-4552-93d2-17cbf25b31fa
function polar2cart(azi, dip)
    azi_rad = deg2rad(azi)
    dip_rad = deg2rad(dip)
    x = sin(azi_rad) * cos(dip_rad)
    y = cos(azi_rad) * cos(dip_rad)
    z = (sin(dip_rad)) * -1

    return (x, y, z)
end

# ╔═╡ 6d520cfe-aa7b-4083-b2bf-b34f840c0a75
md"""
#### 1 - Variograma down hole

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
	sum_azm = DataFrame(
							Variável = :AZM,
							X̅ = round(mean(composites.trace.AZM), digits=2),
							P50 = round(median(composites.trace.AZM), digits=2),
							Min = round(minimum(composites.trace.AZM), digits=2),
							Max = round(maximum(composites.trace.AZM), digits=2)
						)
	
	# Sumário estatístico da variável "DIP"
	sum_dip = DataFrame(
							Variável = :DIP,
							X̅ = round(mean(composites.trace.DIP), digits=2),
							P50 = round(median(composites.trace.DIP), digits=2),
							Min = round(minimum(composites.trace.DIP), digits=2),
							Max = round(maximum(composites.trace.DIP), digits=2)
						)
	
	# Concatenação vertical dos sumários
	vcat(sum_azm, sum_dip)
	
end

# ╔═╡ a717d5d3-9f4e-4a2d-8e32-f0605bbd742f
md"""
**Orientação média dos furos = 150°/55°**

Agora que sabemos a orientação média dos furos, podemos calcular o variograma experimental down hole:

"""

# ╔═╡ 8162f98b-bda1-4475-aa03-e4e379b80b17
md"""
##### Cálculo do variograma down hole
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

	# Cálculo variograma down hole para a variável Cu
	γ_dh = DirectionalVariogram(polar2cart(150,55),
								comps_georef,
								:CU,
								dtol=bw_dh,
								maxlag=150,
								nlags=nlags_dh)
	
	# Plotagem do variograma experimental downhole
    plot(γ_dh, marker=5, ylims=(0, 0.3), color=:deepskyblue, title="150°/55°")
	
	# Linha horizontal tracejada cinza (variância à priori)
    hline!([var(comps.CU)], color=:gray, ls=:dash, legend=false)

end

# ╔═╡ 0b46230a-b305-4840-aaad-e985444cf54e
md"""
##### Modelagem do variograma down hole

Agora que o variograma down hole foi calculado, podemos ajustá-lo com um modelo teórico conhecido.

Nesse sentido, optaremos por  utilizar o **modelo esférico com duas estruturas aninhadas**:
"""

# ╔═╡ 0585add6-1320-4a31-a318-0c40b7a444fa
md"""

Efeito Pepita: $(@bind c₀ Slider(0.00:0.005:0.06, default=0.02, show_value=true))

Variância Espacial 1ª Estrutura: $(@bind c₁ Slider(0.045:0.005:0.18, default=0.06, show_value=true))

Variância Espacial 2ª Estrutura: $(@bind c₂ Slider(0.045:0.005:0.18, default=0.075, show_value=true))

Alcance 1ª Estrutura: $(@bind a_dh1 Slider(10.0:2.0:80.0, default=80.0, show_value=true)) m

Alcance 2ª Estrutura: $(@bind a_dh2 Slider(10.0:2.0:140.0, default=118.0, show_value=true)) m

"""

# ╔═╡ c6d0a87e-a09f-4e78-9672-c858b488fd39
begin

    # Criação da primeira estrutura do modelo de variograma (efeito pepita)
    model_dh0 = NuggetEffect(nugget=c₀)

    # Criação da segunda estrutura do modelo de variograma (1ª contribuição ao sill)
    model_dh1 = SphericalVariogram(sill=Float64(c₁),
                                   range=Float64(a_dh1))

    # Criação da terceira estrutura do modelo de variograma (2ª contribuição ao sill)
    model_dh2 = SphericalVariogram(sill=Float64(c₂),
                                   range=Float64(a_dh2))

    # Aninhamento das três estruturas
    model_dh = model_dh0 + model_dh1 + model_dh2

    # Plotagem do variograma experimental downhole
    plot(γ_dh, ylims=(0, 0.3), marker=5, color=:deepskyblue)

    # Plotagem do modelo de variograma aninhado
    plot!(model_dh, 0, 150, legend=:right,
          title="150°/55°",
          ylims=(0, 0.3), color=:red, lw=2)
    
    # Linha horizontal tracejada cinza (variância à priori)
    hline!([var(comps.CU)], color="gray", ls=:dash, legend=false)
    
    # Linha vertical tracejada verde (alcance)
    vline!([a_dh2], color="green", ls=:dash, legend=false)

end

# ╔═╡ 09d95ff8-3ba7-4031-946b-8ba768dae5d5
md"""
#### 2 - Variograma azimute

O próximo passo é o cálculo do **variograma experimental do azimute de maior continuidade**. Nesta etapa, obteremos a **primeira rotação do variograma**, ou seja, a rotação em torno do **eixo Z**.

"""

# ╔═╡ 52f5b648-cb76-4d87-b31c-42037cf82863
md"""
##### Cálculo do variograma azimute

Iremos calcular diversos variogramas experimentais ortogonais entre si e escolheremos aquele que apresentar **maior continuidade (alcance)**:

"""

# ╔═╡ 17b21a63-9fa6-4975-9302-5465cdd3d2fa
md"""
Azimute: $(@bind azi Slider(0.0:22.5:67.5, default=67.5, show_value=true)) °

№ passos: $(@bind nlags_azi Slider(5:1:12, default=9, show_value=true))

Largura de Banda: $(@bind bw_azi Slider(10:10:100, default=70, show_value=true)) m

"""

# ╔═╡ d07a57c3-0a7a-49c2-a840-568e72d50545
begin

    Random.seed!(1234)

    γ_azi_1 = DirectionalVariogram(polar2cart(azi,0.0),
                                   comps_georef, :CU,
                                   dtol=bw_azi, maxlag=350,
                                   nlags=nlags_azi)

    γ_azi_2 = DirectionalVariogram(polar2cart((azi+90.0),0.0),
                                   comps_georef, :CU, dtol=bw_azi,
                                   maxlag=350, nlags=nlags_azi)
	
	plot(γ_azi_1, marker=5, ylims=(0, 0.4), label="0$(azi)°", color=:red)

    plot!(γ_azi_2, marker=5, ylims=(0, 0.4), label="$(azi+90)°",
		  color=:deepskyblue, legend=:topright)

    hline!([var(comps.CU)], color=:gray, ls=:dash, label=false)

end

# ╔═╡ 9389a6f4-8710-44c3-8a56-804017b6239b
md"""
##### Modelagem do variograma azimute

Agora que o variograma azimute foi calculado, podemos ajustá-lo com um modelo teórico conhecido, considerando os valores de efeito pepita e variância espacial obtidos na etapa anterior:

"""

# ╔═╡ 78b45d90-c850-4a7e-96b8-535dd23bd1a7
md"""

Alcance 1ª Estrutura: $(@bind a_azi1 Slider(10.0:2.0:100.0, default=60.0, show_value=true)) m

Alcance 2ª Estrutura: $(@bind a_azi2 Slider(10.0:2.0:200.0, default=176.0, show_value=true)) m

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

    plot!(model_azi, 0, 350, title="0$(azi)°",
          ylims=(0, 0.3), color=:red, lw=2)

    hline!([var(comps.CU)], color=:gray, ls=:dash, legend=false)

    vline!([a_azi2], color=:green, ls=:dash, legend=false)

end

# ╔═╡ 294ac892-8952-49bc-a063-3d290c375ea5
md"""

#### 3 - Variograma primário

Agora, calcularemos o **variograma experimental primário**, ou seja, aquele que representa a direção (azi/dip) de **maior continuidade**.

Nesta etapa, encontraremos o **maior alcance** do modelo de variograma final, além da **segunda rotação do variograma**, ou seja, aquela em torno do **eixo X**.

"""

# ╔═╡ 3859448f-265a-4929-bfa4-1809036da3dd
md"""
##### Cálculo do variograma primário

Para o cálculo deste variograma experimental, devemos fixar o azimute de maior continuidade já encontrado (0$(azi)°) e variar o dip. A orientação (azi/dip) que fornecer o maior alcance, será eleita a **direção de maior continuidade**:

"""

# ╔═╡ 97670210-2c91-4be7-a607-0da83cb16f44
md"""

Dip: $(@bind dip Slider(0.0:22.5:90.0, default=22.5, show_value=true))°

№ passos: $(@bind nlags_dip Slider(5:1:12, default=10, show_value=true))

Largura de Banda: $(@bind bw_dip Slider(10:10:100, default=70, show_value=true)) m

"""

# ╔═╡ 668da8c2-2db6-4812-90ce-86b17b289cc6
begin
	
    Random.seed!(1234)

    γ_dip = DirectionalVariogram(polar2cart(azi,dip), comps_georef,
                                 :CU, dtol=bw_dip, maxlag=350,
                                 nlags=nlags_dip)

	plot(γ_dip, marker=5, ylims=(0, 0.3), color=:deepskyblue,
         title="0$(azi)°/$(dip)°")

    hline!([var(comps.CU)], color=:gray, ls=:dash, legend=false)
end

# ╔═╡ eb9ebce2-7476-4f44-ad4f-10a1ca522143
md"""
##### Modelagem do variograma primário

Agora que o variograma primário foi calculado, podemos ajustá-lo com um modelo teórico conhecido:

"""

# ╔═╡ 92d11f3b-c8be-4701-8576-704b73d1b619
md"""

Alcance 1ª Estrutura: $(@bind a_dip1 Slider(10.0:2.0:120.0, default=84.0, show_value=true)) m

Alcance 2ª Estrutura: $(@bind a_dip2 Slider(10.0:2.0:300.0, default=192.0, show_value=true)) m

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

    plot!(model_dip, 0, 350, title="0$(azi)°/$(dip)°",
          ylims=(0, 0.3), color=:red, lw=2)
    
    hline!([var(comps.CU)], color=:gray, ls=:dash, legend=false)

    vline!([a_dip2], color=:green, ls=:dash, legend=false)

end

# ╔═╡ 6c048b83-d12c-4ce8-9e9a-b89bf3ef7638
md"""
#### 4 - Variogramas secundário e terciário

Sabe-se que, por definição, os três eixos principais do variograma são ortogonais entre si. Agora que encontramos a **direção de maior continuidade do variograma** (eixo primário), sabemos que os outros dois eixos (secundário e terciário) pertencem a um plano cuja normal é o próprio eixo primário!

Portanto, nesta etapa, encontraremos os **alcances intermediário e menor** do modelo de variograma final, bem como a **terceira rotação do variograma**, ou seja, aquela em torno do **eixo Y**.

Nesse sentido, como o eixo primário do variograma apresenta uma orientação **0$(azi)° / $(dip)°**, com o auxílio de um **estereograma**, podemos encontrar o plano que contém os eixos secundário e terciário. Ressalta-se ainda que **eixos secundário e terciário são ortogonais entre si**.

A Figura 9 mostra um estereograma cujo eixo primário tem orientação 067°/22.5°. O **ponto vermelho** representa o **eixo primário (Y)**, enquanto os **pontos pretos** são candidatos a **eixos secundário e terciário**. O **grande círculo vermelho** representa o **plano XZ**, ou seja, aquele que contém os eixos secundário (X) e terciário (Z).

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

Orientações: $(@bind orient Select(["config1" => "177.6°/41.1° e 317.4°/41.1°",
                                    "config2" => "157.5°/00.0° e 247.5°/68.5°",
                                    "config3" => "165.9°/20.4° e 295.3°/59.6°",
                                    "config4" => "198.3°/58.9° e 328.7°/21.3°"]))

№ passos: $(@bind nlags_int_min Slider(5:1:15, default=12, show_value=true))

Largura de Banda: $(@bind bw_int_min Slider(10:10:100, default=70, show_value=true)) m

"""

# ╔═╡ 0def0326-55ef-45db-855e-a9a683b2a76d
begin

    Random.seed!(1234)

    azi1, dip1 = 177.6, 41.1
    azi2, dip2 = 317.4, 41.1

    if orient == "config1"
        azi1, dip1 = 177.6, 41.1
        azi2, dip2 = 317.4, 41.1

    elseif orient == "config2"
        azi1, dip1 = 157.5, 0.0
        azi2, dip2 = 247.5, 68.5

    elseif orient == "config3"
        azi1, dip1 = 165.9, 20.4
        azi2, dip2 = 295.3, 59.6

    elseif orient == "config4"
        azi1, dip1 = 198.3, 58.9
        azi2, dip2 = 328.7, 21.3
    end

    γ_int_min1 = DirectionalVariogram(polar2cart(azi1,dip1),
                                      comps_georef, :CU,
                                      dtol=bw_int_min, maxlag=250,
                                      nlags=nlags_int_min)

    γ_int_min2 = DirectionalVariogram(polar2cart(azi2,dip2),
                                      comps_georef, :CU,
                                      dtol=bw_int_min, maxlag=250,
                                      nlags=nlags_int_min)
	
	plot(γ_int_min1, marker=5, ylims=(0, 0.4), xlims=(0,250),
         label="$(azi1)°/$(dip1)°", color=:red)

    plot!(γ_int_min2, marker=5, ylims=(0, 0.4), xlims=(0,250),
          label="$(azi2)°/$(dip2)°", color=:deepskyblue,
          legend=:topright)

    hline!([var(comps.CU)], color="gray", ls=:dash, label=false)

end

# ╔═╡ 404622b6-bf67-4b97-9355-2c24592cc364
md"""

##### Modelagem do variograma secundário

Agora que elegemos o variograma experimental representante do eixo secundário, podemos modelá-lo:

"""

# ╔═╡ 922d81f3-0836-4b14-aaf2-83be903c8642
md"""

Alcance 1ª Estrutura: $(@bind a_interm1 Slider(10.0:2.0:100.0, default=62.0, show_value=true)) m

Alcance 2ª Estrutura: $(@bind a_interm2 Slider(10.0:2.0:170.0, default=94.0, show_value=true)) m

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

    plot!(model_interm, 0, 200, title="$(azi1)°/$(dip1)°",
          ylims=(0, 0.4), color=:red, lw=2)

    hline!([var(comps.CU)], color="gray", ls=:dash, legend=false)

    vline!([a_interm2], color="green", ls=:dash, legend=false)

end

# ╔═╡ 39838426-aeb3-424c-97b8-818b1326b771
md"""

##### Modelagem do variograma terciário

Agora que elegemos o variograma experimental representante do eixo terciário, podemos modelá-lo:

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

    plot!(model_min, 0, 200, title="$(azi2)°/$(dip2)°",
          ylims=(0, 0.4), color=:red, lw=2)

    hline!([var(comps.CU)], color="gray", ls=:dash)

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
	hline!([var(comps.CU)], ls=:dash, label=false, color=:gray)

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
    if orient == "config1"
        rot_y = -45.0
    elseif orient == "config2"
        rot_y = -0.0
    elseif orient == "config3"
        rot_y = -22.5
    elseif orient == "config4"
        rot_y = -67.5
    end
	
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

Com as informações sumarizadas acima, podemos definir uma convenção de rotação a ser adotada e, finalmente, criar o modelo de variograma final que, por sua vez, será um objeto de entrada no sistema linear de krigagem.

Nesse sentido, utilizando a **convenção de rotação do GSLIB**, as rotações do modelo de variograma serão:

| Rotação | Eixo | Ângulo   |
|:-------:|:----:|:--------:|
|    1ª   |   Z  |$(rot_z)° |
|    2ª   |   X  |$(rot_x)° |
|    3ª   |   Y  |$(rot_y)° |

"""

# ╔═╡ 8ab2cdfe-8bd5-4270-a57e-89456c713b80
html"""

    <div id="estimativa_de_recursos">
        <h2>6. Estimativa de recursos</h2>
    </div>

"""

# ╔═╡ 9baefd13-4c16-404f-ba34-5982497e8da6
md"""

#### Introdução

Grande parte das estimativas realizadas na indústria são baseadas em **estimadores lineares ponderados**:

- Esses estimadores são **lineares**, pelo fato serem construídos a partir de uma combinação linear entre valores de unidades amostrais Z(uᵢ) e seus respectivos pesos wᵢ.

- Esses estimadores são **podenderados**, pelo fato de consistirem em uma média ponderada entre as amostras utilizadas para se estimar um determinado bloco.

Dessa forma, a equação geral dos estimadores lineares ponderados é definida como:

```math
ẑ(uₒ) = \sum_{i=1}^{n} wᵢ.z(uᵢ) = w₁.z(u₁) + w₂.z(u₂) + w₃.z(u₃) + ... + wₙ.z(uₙ)
```

Neste módulo, estimaremos os teores de Cu a partir dos estimadores Krigagem Simples e Krigagem Ordinária.

Na **Krigagem Simples (SK)**, a média populacional (μ) é assumida como conhecida e invariável em todo o domínio de estimativa. Em outras palavras, devemos definir uma média estacionária como entrada desse estimador que, no nosso contexto, será a média declusterizada. Diferentemente da Krigagem Ordinária, não há condição de fechamento para os pesos atribuídos às amostras da vizinhança e, nesse sentido, uma parte do peso é atribuída à média estacionária (μ):

```math
\sum_{i=1}^{n} wᵢ + w(μ) = 1
```

Por outro lado, a **Krigagem Ordinária (OK)** não assume o conhecimento da média populacional e, nesse sentido, a hipótese de estacionariedade para todo o domínio de estimativa não é tão rígida. Nesse caso há condição de fechamento, em que o somatório dos pesos atribuídos às amostras da vizinhança deve resultar em 1. Portanto, não há atribuição de uma parcela do peso de krigagem para a média estacionária.

```math
\sum_{i=1}^{n} wᵢ = 1
```

"""

# ╔═╡ bbe2e767-0601-436c-8b0e-b9dac8ef945b
md"""

#### Fluxograma de Estimativa no GeoStats.jl

Abaixo encontra-se o *workflow* para a realização da estimativa via pacote [GeoStats.jl](https://juliaearth.github.io/GeoStats.jl/stable/index.html): 

**1.**  Definição do domínio de estimativa (modelo de blocos):

> **BM = RegularGrid(origin, finish, dims=blocksizes)**

**2.** Definição do problema de estimativa:

> **problem = EstimationProblem(sample, BM, :variable)**

**3.** Criação do *solver*:

> **solver = Kriging(:variable => (variogram = vg_model))**

**4.** Solução do problema:

> **solution = solve(problem, solver)**

"""

# ╔═╡ a7a59395-59ec-442a-b4b6-7db55d150d53
md"""

##### 1. Criação do modelo de blocos

Nesta primeira etapa, definimos o **domínio de estimativa**, ou seja, o modelo de blocos dentro do qual realizaremos a estimativa.

Para tal, devemos definir três parâmetros:

- Ponto de origem do modelo de blocos
- Ponto de fim do modelo de blocos
- Número de blocos nas direções X, Y e Z

"""

# ╔═╡ 12d79d77-358c-4098-993a-d5be538929a2
md"""

Rotação em Z: $(@bind ψ₁ Slider(0:5:90, default=45, show_value=true))°

Rotação em X: $(@bind ψ₂ Slider(0:5:90, default=45, show_value=true))°

"""

# ╔═╡ f7cee6a3-5ac2-44ff-9d5e-58ede7327c46
begin

    Xmin, Xmax = minimum(comps.X), maximum(comps.X)
    Ymin, Ymax = minimum(comps.Y), maximum(comps.Y)
    Zmin, Zmax = minimum(comps.Z), maximum(comps.Z)
	
	# Tamanho dos blocos em X, Y e Z
	Xsize = Int(ceil((Xmax - Xmin) / 20))
	Ysize = Int(ceil((Ymax - Ymin) / 20))
	Zsize = Int(ceil((Zmax - Zmin) / 10))

    origem = ((Xmin - Xsize), (Ymin - Ysize), (Zmin - Zsize))
    final = ((Xmax + Xsize), (Ymax + Ysize), (Zmax + Zsize))

    BM = CartesianGrid(origem, final, dims=(Xsize, Ysize, Zsize))

    plot(BM, camera=(ψ₁,ψ₂), xlabel="X", ylabel="Y", zlabel="Z")

end

# ╔═╡ a8adf478-620d-4744-aae5-99d0891fe6b0
md"""

##### 2. Definição do problema de estimativa

Para definirmos o problema de estimativa, devemos passar como parâmetros:

- Furos georreferenciados
- Modelo de blocos
- Variável de interesse

"""

# ╔═╡ affacc76-18e5-49b2-8e7f-77499d2503b9
problem = EstimationProblem(comps_georef, BM, :CU)

# ╔═╡ 31cd3d10-a1e8-4ad8-958f-51de08d0fa54
md"""

##### 3. Criação dos solvers

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
	
	# Média estacionária
    μ = mean(comps_georef, :CU)

	# SK
    SK = Kriging(
                 :CU => (variogram=γ,
                         mean=μ,
                         minneighbors=s_min,
                         maxneighbors=s_max)
                )

	# OK
    OK = Kriging(
                 :CU => (variogram=γ,
                         minneighbors=s_min,
                         maxneighbors=s_max)
                )

end

# ╔═╡ 9b3fe534-78fa-48db-a101-e2a43f2478d6
md"""

##### 4. Solução do problema de estimativa

Para finalmente estimarmos os teores de Cu, devemos passar como argumentos de entrada:

- Problema de estimativa
- Solver que será utilizado para resolvê-lo

"""

# ╔═╡ 86ae2f3e-6291-4107-b201-5cbd51fde73b
begin

    estim_SK = solve(problem, SK)

    estim_OK = solve(problem, OK)

end;

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
begin

	# Teores estimados
	estimado_SK = values(estim_SK).CU
    estimado_OK = values(estim_OK).CU
	
	# Quantis dos teores estimados
    q_SK = quantile(estimado_SK, [0.1,0.5,0.9])
    q_OK = quantile(estimado_OK, [0.1,0.5,0.9])

    sum_SK = DataFrame(
                            Variável = :CU_SK,
                            X̅ = round(mean(estimado_SK), digits=2),
                            S² = round(var(estimado_SK), digits=2),
                            S = round(std(estimado_SK), digits=2),
                            P10 = round(q_SK[1], digits=2),
                            P50 = round(q_SK[2], digits=2),
                            P90 = round(q_SK[3], digits=2)
                       )

	
    sum_OK = DataFrame(
                            Variável = :CU_OK,
                            X̅ = round(mean(estimado_OK), digits=2),
                            S² = round(var(estimado_OK), digits=2),
                            S = round(std(estimado_OK), digits=2),
                            P10 = round(q_OK[1], digits=2),
                            P50 = round(q_OK[2], digits=2),
                            P90 = round(q_OK[3], digits=2)
                      )

    vcat(sum_cu_clus, sum_cu_declus, sum_SK, sum_OK)

end

# ╔═╡ ed97c749-30b7-4c72-b790-fef5a8332548
md"""
A partir da comparação entre as estatísticas acima, nota-se que:

- As duas médias estimadas são muito próximas da média declusterizada

- Houve uma redução significativa da dispersão dos teores estimados pelos dois métodos quando comparados com os teores amostrais. OK apresentou estimativas menos suavizadas do que as estimativas de SK.


"""

# ╔═╡ 263c1837-7474-462b-bd97-ee805baec458
md"""

##### Q-Q plot

O Q-Q plot entre os teores amostrais (reais) e os teores estimados pode ser utilizado para realizar uma comparação entre as distribuições de Cu amostral e Cu estimado. Em outras palavras, podemos analisar (qualitativamente) o grau de suavização da estimativa por krigagem.

Nesse sentido, quanto mais os pontos se aproximam da reta X=Y, menor é o efeito de suavização.

Por outro lado, quanto mais os pontos tendem a se horizontalizar, maior é o grau de suavização da estimativa por krigagem.

"""

# ╔═╡ 193dde9b-1f4a-4313-a3a6-ba3c89600bcb
begin

    qq_SK = qqplot(
				   comps.CU, estimado_SK,
                   xlabel="Cu(%)", ylabel="Cu-SK(%)",
                   color=:red,legend=:false,
                   title="Amostral x Estimado-SK"
                   )
 
    qq_OK = qqplot(
				   comps.CU, estimado_OK,
                   xlabel="Cu(%)", ylabel="Cu-OK(%)",
                   color=:green,
                   title="Amostral x Estimado-OK"
				  )

    plot(qq_SK, qq_OK)

end

# ╔═╡ 9aaadedf-2176-4559-ac19-b36c1dbd3984
html"""

    <div id="exportacao">
        <h2>7. Exportação do modelo estimado</h2>
    </div>

"""

# ╔═╡ 50300f8e-7e27-4c4d-9e26-ff4e2e66c291
md"""

Por fim, iremos exportar o modelo estimado para dois formatos distintos: `.gslib` e `.csv`.

"""

# ╔═╡ 5ad612f4-76e9-4867-b4c8-4c35540a5f47
md"""

#### Exportação para .csv

"""

# ╔═╡ 98b7e4bb-0e06-4538-a945-587ae904c965
estim_OK |> DataFrame |> CSV.write("modelo_estimado_ok.csv")

# ╔═╡ faacc571-561a-48ac-8c9f-4ddbaa7a736f
md"""

#### Exportação para .gslib

"""

# ╔═╡ b96c4bd5-54ba-4394-b963-5c5ddc06cf3b
FileIO.save("modelo_estimado_ok.gslib", estim_OK)

# ╔═╡ Cell order:
# ╠═980f4910-96f3-11eb-0d4f-b71ad9888d73
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
# ╟─0c0ee038-7c0e-4fc4-9ff7-b05d3b7e4c30
# ╠═bba932bc-959e-4552-93d2-17cbf25b31fa
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
# ╠═38d15817-f3f2-496b-9d83-7dc55f4276dc
# ╟─8ab2cdfe-8bd5-4270-a57e-89456c713b80
# ╟─9baefd13-4c16-404f-ba34-5982497e8da6
# ╟─bbe2e767-0601-436c-8b0e-b9dac8ef945b
# ╟─a7a59395-59ec-442a-b4b6-7db55d150d53
# ╟─f7cee6a3-5ac2-44ff-9d5e-58ede7327c46
# ╟─12d79d77-358c-4098-993a-d5be538929a2
# ╟─a8adf478-620d-4744-aae5-99d0891fe6b0
# ╠═affacc76-18e5-49b2-8e7f-77499d2503b9
# ╟─31cd3d10-a1e8-4ad8-958f-51de08d0fa54
# ╠═2a76c2b9-953e-4e4b-a98e-8e992943f60c
# ╟─9c61271d-4afe-4f7c-a521-8f799b6981ed
# ╟─9b3fe534-78fa-48db-a101-e2a43f2478d6
# ╠═86ae2f3e-6291-4107-b201-5cbd51fde73b
# ╟─4f05c05d-c92a-460d-b3e0-d392111ef57a
# ╟─64a8cd06-6020-434a-a1e2-115e17c51d29
# ╠═c6b0f335-19cb-4fbe-a47b-2ba3fd664832
# ╟─ed97c749-30b7-4c72-b790-fef5a8332548
# ╟─263c1837-7474-462b-bd97-ee805baec458
# ╟─193dde9b-1f4a-4313-a3a6-ba3c89600bcb
# ╟─9aaadedf-2176-4559-ac19-b36c1dbd3984
# ╟─50300f8e-7e27-4c4d-9e26-ff4e2e66c291
# ╟─5ad612f4-76e9-4867-b4c8-4c35540a5f47
# ╠═98b7e4bb-0e06-4538-a945-587ae904c965
# ╟─faacc571-561a-48ac-8c9f-4ddbaa7a736f
# ╠═b96c4bd5-54ba-4394-b963-5c5ddc06cf3b
