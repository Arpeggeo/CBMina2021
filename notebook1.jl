### A Pluto.jl notebook ###
# v0.14.1

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
    using GeoStats, DrillHoles
    using StatsPlots, Plots; gr(format="png")
end;

# ╔═╡ 14ac7b6e-9538-40a0-93d5-0379fa009872
html"""
<p style="background-color:lightgrey" xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><span property="dct:title">GeoStats.jl at CBMina</span> by <span property="cc:attributionName">Júlio Hoffimann & Franco Naghetini</span> is licensed under <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>
"""

# ╔═╡ 20fff27a-4328-43ac-97df-a35b63a6fdd0
md"""

![geostats-logo](https://github.com/JuliaEarth/GeoStats.jl/blob/master/docs/src/assets/logo-text.svg?raw=true)

# Estimativa de recursos em 3D

Instrutores: [Júlio Hoffimann](https://juliohm.github.io) & [Franco Naghetini](https://github.com/fnaghetini)

"""

# ╔═╡ c544614a-3e5c-4d22-9340-592aabf84871
md"""

## Introdução

Este notebook objetiva demonstrar um fluxo de trabalho completo de estimativa de recursos realizado com a linguagem [Julia](https://docs.julialang.org/en/v1/) e o pacote [GeoStats.jl](https://juliaearth.github.io/GeoStats.jl/stable/index.html).

Nesse sentido, cobriremos desde a etapa de importação dos dados brutos (tabelas collar, survey e assay) até a validação de uma estimativa geoestatística de recursos (Figura 1).

Portanto, o **produto final** é um **modelo de blocos estimado** por krigagem ordinária.

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

# ╔═╡ c66d36e2-d6be-4d70-a3c3-a691d0b1064e
html"""

    <h2>Agenda</h2>

    <a href="#importacao_dos_dados">

        <big>1. Importação dos dados e geração dos furos</big>

    </a><br><br>

	<a href="#compositagem">

        <big>2. Compositagem de amostras</big>
	</a><br><br>

    <a href="#AED">

        <big>3. Análise exploratória dos dados</big>

    </a><br><br>

	<a href="#declus">

        <big>4. Declusterização</big>

    </a><br><br>

    <a href="#vg_exp_model_vg">

        <big>5. Cálculo e modelagem de variogramas experimentais</big>

    </a><br><br>

    <a href="#estimativa_de_recursos">

        <big>6. Estimativa de recursos</big>

    </a><br><br>

    <a href="#exportacao">

        <big>7. Exportação dos dados estimados</big>

    </a><br><br>

"""

# ╔═╡ ff01a7d7-d491-4d49-b470-a2af6783c82b
html"""

    <div id="importacao_dos_dados">

        <h2>1. Importação dos dados e geração dos furos</h2>

    </div>

"""

# ╔═╡ ca724400-26a6-4332-bf19-2eb8ffe7d817
md"""

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
	collar = Collar(file="data/collar.csv",
					holeid=:HOLEID, x=:X, y=:Y, z=:Z)

	# Importação da tabela Survey
	survey = Survey(file="data/survey.csv",
					holeid=:HOLEID, at=:AT, azm=:AZM, dip=:DIP)

	# Importação da tabela Assay
	assay = Interval(file="data/assay.csv",
					 holeid=:HOLEID, from=:FROM, to=:TO)

	# Importação da tabela Litho
	litho  = Interval(file="data/litho.csv",
					  holeid=:HOLEID, from=:FROM, to=:TO)
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

"""

# ╔═╡ 412cfe3d-f9f1-49a5-9f40-5ab97946df6d
begin
	# Armazenando a tabela dos furos na variável "dh"
	dh = deepcopy(drillholes.table)

	# Visualização das 5 primeiras linhas da tabela de furos
	first(dh, 5)
end

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

Como o objetivo deste notebook é a geração de um modelo de teores de Cu estimado, podemos remover os 307 valores faltantes do banco de dados.

"""

# ╔═╡ 4d5f2467-c7d5-4a82-9968-97f193090bd6
begin
    # Remoção dos valores faltantes de CU e LITH do banco de dados
    dropmissing!(dh, disallowmissing=true)

    # Sumário estatístico do banco de dados após a exclusão dos valores faltantes
    describe(dh)
end

# ╔═╡ f4bd13d4-70d3-4167-84ff-9d3c7200e143
html"""
    <div id="compositagem">

        <h2>2. Compositagem de amostras</h2>

    </div>
"""

# ╔═╡ 7a2899ab-496e-4919-a02e-e6ad8dd2b676
md"""
#### Introdução

Dados brutos de sondagem normalmente são obtidos em suportes amostrais variados. Nesse sentido, caso não houver um tratamento prévio desses dados, amostras de diferentes suportes amostrais terão mesmo peso na estimativa.

Portanto, um procedimento denominado **compositagem** deve ser conduzido, visando os seguintes objetivos:

- Regularizar o suporte amostral, de modo a reduzir a variância do comprimento das amostras (compositagem ao longo do furo).

- Aumentar o suporte amostral (suporte x variância = k).

- Adequar o comprimento das amostras à escala de trabalho (**Figura 3**).

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

# ╔═╡ 1f07ba56-2ebd-4b4b-b0e8-cabcfe102e0f
# Criação do sumário estatístico para a variável LENGTH (dataframe)
sum_sup = DataFrame(Min = minimum(dh.LENGTH),
                    Max = maximum(dh.LENGTH), 
                    X̅ = round(mean(dh.LENGTH), digits=2),
                    P50 = median(dh.LENGTH),
                    S = round(std(dh.LENGTH), digits=2),
                    CV = round(variation(dh.LENGTH), digits=2))

# ╔═╡ 41790d87-ce85-461f-a16d-04821a3624bb
begin
    # Histograma da variável LENGTH
    dh |> @df histogram(:LENGTH, xlabel="Suporte Amostral (m)",
        				ylabel="Frequência Absoluta", color="gray90",
        				legend=:topleft, label=false, alpha=0.75)

    # Linha vertical contínua vermelha (média)
    vline!([sum_sup.X̅], c="red", ls=:solid, label="X̅")

    # Linha vertical contínua verde (mediana)
    vline!([sum_sup.P50], c="green", ls=:solid, label="P50")
end

# ╔═╡ 7ea21049-5edd-4979-9782-8a20d4bb287b
md"""

A partir das estatísticas e do histograma acima podemos chegar a algumas informações:

- Grande parte das amostras apresenta um comprimento igual a 5 m.

- A variável suporte amostral apresenta uma distribuição assimétrica negativa.

- A variável suporte amostral apresenta baixa variabilidade.

"""

# ╔═╡ d8ce39f1-8017-4df3-a55d-648bdd3dbc04
md"""
#### Compositagem das amostras

Primeiramente, vamos supor que o **tamanho da bancada da mina de Cu é de 10 m**.

Embora as amostras já estejam regularizadas para um suporte de 5 metros, iremos compositá-las para um tamanho igual a 10 m, com o intuito de **adequar o suporte amostral à escala de trabalho**.

"""

# ╔═╡ 32f75604-b01a-4a0b-a008-33b2a56f4b57
begin
	# Compositagem das amostras para um suporte de 10 m
	composites = composite(drillholes, interval=10.0, mode=:nodiscard)

	# Armazenando a tabela de furos compositados na variável "comps"
	comps = composites.table

	# Sumário estatístico da tabela de furos compositados
	describe(comps)
end

# ╔═╡ 8a54cc04-7c95-4fd8-a219-7153e7492634
md"""
#### Remoção dos valores faltantes dos furos compositados

Como a compositagem foi realizada sobre os furos originais (com valores faltantes),  os furos compositados apresentam **257 valores faltantes** de Cu.

Nesse sentido, esses valores faltantes devem também ser removidos.

"""

# ╔═╡ 12d3d075-bfad-431e-bbdc-341bb01a89a2
# Remoção dos valores faltantes de CU
dropmissing!(comps, disallowmissing=true);

# ╔═╡ b6712822-7c4d-4936-bcc2-21b48be99a66
md"""
###### Descrição estatística pós-compositagem

Agora, com os furos compositados, podemos analisar novamente as estatísticas e histograma do suporte amostral:

"""

# ╔═╡ c6051297-bdfe-4783-b0bd-9f89912ac96d
# Criação do sumário estatístico para a variável LENGTH (dataframe)
sum_comp = DataFrame(Min = minimum(comps.LENGTH),
                    Max = maximum(comps.LENGTH), 
                    X̅ = round(mean(comps.LENGTH), digits=2),
                    P50 = median(comps.LENGTH),
                    S = round(std(comps.LENGTH), digits=2),
                    CV = round(variation(comps.LENGTH), digits=2))

# ╔═╡ 87808ab0-3bcb-428d-9ebf-71ffefbcb357
begin
    # Histograma da variável LENGTH compositada
    comps |> @df histogram(:LENGTH, xlabel="Suporte Amostral Compositado (m)",
        				ylabel="Frequência Absoluta", color="gray90",
        				legend=:topleft, label=false, alpha=0.75)

    # Linha vertical contínua vermelha (média)
    vline!([sum_comp.X̅], c="red", ls=:solid, label="X̅")

    # Linha vertical contínua verde (mediana)
    vline!([sum_comp.P50], c="green", ls=:solid, label="P50")
end

# ╔═╡ 893d7d19-878b-4990-80b1-ef030b716048
md"""

Com base no histograma e no sumário estatístico acima, chegamos às seguintes informações acerca do suporte amostral pós-compositagem:

- A média do suporte amostral dos furos compositados encontra-se muito próxima do comprimento pré-estabelecido (10 metros).

- Houve uma redução da dispersão do suporte amostral.

- A distribuição da variável suporte amostral, após a compositagem, passou a ser praticamente simétrica.

"""

# ╔═╡ b85a7c2f-37e2-48b0-a1db-984e2e719f29
md"""
#### Validação da compositagem

Podemos avaliar o impacto da compositagem a partir de uma comparação entre os sumários estatísticos dos teores originais e teores compostos:

"""

# ╔═╡ 59dfbb66-f188-49f1-87ba-4f7020c4c031
begin
	# P10, P50 e P90 do Cu original
	q_cu_orig = quantile(dh.CU, [0.1, 0.5, 0.9])
	# P10, P50 e P90 do Cu compositado
	q_cu_comp = quantile(comps.CU, [0.1, 0.5, 0.9])
	
	# Sumário estatístico do Cu original
	sum_cu_orig = DataFrame(
								Variável=:Cu_Original,
								X̅=round(mean(dh.CU),digits=2),
								S²=round(var(dh.CU),digits=2),
								S=round(std(dh.CU),digits=2),
								Cᵥ=round(variation(dh.CU),digits=2),
								P10=round(q_cu_orig[1],digits=2),
								P50=round(q_cu_orig[2],digits=2),
								P90=round(q_cu_orig[3],digits=2)
							)
	
	# Sumário estatístico do Cu compositado
	sum_cu_comp = DataFrame(
								Variável=:Cu_Compositado,
								X̅=round(mean(comps.CU),digits=2),
								S²=round(var(comps.CU),digits=2),
								S=round(std(comps.CU),digits=2),
								Cᵥ=round(variation(comps.CU),digits=2),
								P10=round(q_cu_comp[1],digits=2),
								P50=round(q_cu_comp[2],digits=2),
								P90=round(q_cu_comp[3],digits=2)
							)
	
	# Concatenação vertical dos dois sumários estatísticos
	vcat(sum_cu_orig, sum_cu_comp)
end

# ╔═╡ 7a021fbd-83ac-4a36-bb8c-98519e6f8acb
md"""

A partir da comparação entre os teores de Cu pré e pós compositagem, chegamos às seguintes conclusões:

- Houve uma redução de menos de 1% na média de Cu.

- A mediana se manteve idêntica após a compositagem.

- Houve uma redução de <8% no desvio padrão.

Como as estatísticas de Cu se mantiveram similares após a compositagem dos furos, pode-se dizer que esta etapa foi realizada com êxito. Nesse sentido, os furos compositados serão utilizados daqui em diante.

"""

# ╔═╡ 439837bf-941d-4300-ba96-6f372b7e514f
html"""
    <div id="AED">

        <h2>3. Análise exploratória dos dados</h2>

    </div>
"""

# ╔═╡ f2be5f11-1923-4658-93cf-800ce57c32d3
md"""

A **Análise exploratória dos dados (AED)** é uma das etapas mais cruciais do fluxo de trabalho. Em essência, ela consiste em sumarizar, descrever e obter insights a partir do banco de dados.

A AED antecede a análise de continuidade espacial (e a estimativa) e objetiva transformar dados em informações. Esta etapa pode ser definida como:

              "A arte de torturar os dados até que eles confessem informações"

Neste notebook a AED será dividida em duas subetapas:

- **Visualização espacial**

- **Descrição univariada**

Ao final, sumarizaremos as informações e insights obtidos a partir dos dados.

"""

# ╔═╡ c0604ed8-766e-4c5d-a628-b156615f8140
md"""

### 3.1. Visualização espacial

Nesta etapa, visualizaremos a distribuição dos teores de Cu (%) na malha de sondagem.

Como estamos lidando com dados regionalizados, a visualização espacial da variável de interesse sempre deve ser realizada em conjunto com a sua descrição estatística.

Devemos ficar atentos a possíveis agrupamentos preferenciais de amostras em regiões "mais ricas" do depósito.

"""

# ╔═╡ f855019a-27b0-42b5-a867-82fc25ef9e82
md"""
#### Visualização espacial dos teores de Cu (%)
"""

# ╔═╡ 8bb2f630-8234-4f7f-a05c-8206993bdd45
md"""

Rotação em Z: $(@bind αₜ Slider(0:10:90, default=30, show_value=true))°

Rotação em X: $(@bind βₜ Slider(0:10:90, default=30, show_value=true))°

"""

# ╔═╡ 074bff0b-6b41-4bbc-9b5c-77fbf62c4dc6
# Visualização dos furos por teor de Cu
comps |> @df scatter(:X, :Y, :Z, marker_z=:CU, marker=:circle,
                  markersize=4, camera=(αₜ,βₜ),
                  xlabel="X", ylabel="Y", zlabel="Z",
                  legend=false, colorbar=true, c=:jet)

# ╔═╡ 862dd0cf-69ae-48e7-92fb-ff433f62e67c
md"""

#### Visualização espacial dos *high grades* e *low grades* de Cu

Uma etapa muito importante é a visualização da posição espacial dos _low grades_ e _high grades_ de um depósito.

Quando não se tem muito conhecimento acerca de um depósito, a seguinte convenção é comumente utilizada:

- **Low grades < P10**

- **High grades > P90**

"""

# ╔═╡ 36fad6e9-038c-4ba2-a49c-badeda404356
md"""
Rotação em Z: $(@bind α₂ Slider(0:10:90, default=30, show_value=true))°

Rotação em X: $(@bind β₂ Slider(0:10:90, default=30, show_value=true))°
"""

# ╔═╡ ea0968ca-a997-40c6-a085-34b3aa89807e
begin

	# P10
	P10 = quantile(comps.CU, [0.1])[1]
	# P90
	P90 = quantile(comps.CU, [0.9])[1]
	
    # Filtragem dos teores highgrade (> P90)
    hg = comps |> @filter(_.CU > P90)
    # Filtragem dos teores lowgrade (< P10)
    lg = comps |> @filter(_.CU ≤ P10)

    # Visualização de todas as amostras (cinza claro)
    @df comps scatter(:X, :Y, :Z, marker=:circle, markersize=4,
                    color="gray95",xlabel="X", markeralpha=0.5,
                    ylabel="Y", zlabel="Z", label=false)
    
    # Visualização de highgrades (vermelho)
    @df hg scatter!(:X, :Y, :Z, marker=:circle, markersize=4,
                    camera=(α₂,β₂),color="red", label="High grade")

    # Visualização de lowgrades (azul)
    @df lg scatter!(:X, :Y, :Z, marker=:circle, markersize=4,
                    legend=:topright, color="deepskyblue", label="Low grade")

end

# ╔═╡ ccbcf57e-d00b-43df-8555-eee8bf4f9e6f
md"""

A partir da visualização espacial dos _high grades_ e _low grades_, nota-se que:

- As regiões onde ocorrem os _high grades_ apresentam maior densidade amostral.

- Os _low grades_ tendem a se concentrar em porções de densidade amostral baixa.

- As amostras apresentam-se ligeiramente agrupadas preferencialmente na porção SE do depósito.

"""

# ╔═╡ 7f3f9c03-097d-4dd1-a122-53cceef56cbd
md"""
### 3.2. Descrição Univariada
"""

# ╔═╡ 462264f1-cad2-4ae6-abc2-5273f175569b
md"""
#### Descrição da variável cobre

A partir do sumário estatístico e do histograma do Cu, podemos extrair informações acerca de sua variabilidade, tendências centrais, além da forma e simetria de sua distribuição:

"""

# ╔═╡ 2e94b106-56cd-4034-b5d4-00dae5c02c57
# Sumário estatístico do Cu
sum_cu = DataFrame(
					Variável=:Cu,
					X̅=round(mean(comps.CU),digits=2),
					S²=round(var(comps.CU),digits=2),
					S=round(std(comps.CU),digits=2),
					Cᵥ=round(variation(comps.CU),digits=2),
					P10=round(q_cu_comp[1],digits=2),
					P50=round(q_cu_comp[2],digits=2),
					P90=round(q_cu_comp[3],digits=2),
					Skew=round(skewness(comps.CU),digits=2),
					Kurt=round(kurtosis(comps.CU),digits=2)
				  )

# ╔═╡ b95a6def-f3e6-4835-b15f-2a48577006f4
begin 

    # Histograma do Cu
    comps |> @df histogram(:CU, xlabel="Cu (%)",
            			   ylabel="Frequência Absoluta", color="darkgoldenrod1",
                           label=false, bins=30, alpha=0.55)

    # Linha vertical contínua vermelha (média)
    vline!([sum_cu.X̅], c="red", ls=:solid, label="X̅")

    # Linha vertical contínua verde (mediana)
    vline!([sum_cu.P50], c="green", ls=:solid, label="P50")
	
	# Linha vertical tracejada cinza (P10)
    vline!([sum_cu.P10], c="gray", ls=:dashdot, label="P10")
	
	# Linha vertical tracejada cinza (P90)
    vline!([sum_cu.P90], c="gray", ls=:dashdot, label="P90")

end

# ╔═╡ 0808061f-4856-4b82-8560-46a59e669ac4
md"""

Algumas informações obtidas sobre o Cu:

- A média do Cu é igual a 0.85%.

- O coeficiente de variação do Cu é de 46%.

- A princípio, os _low grades_ do depósito correspondem a amostras ≤ 0.47%.

- A princípio, os _high grades_ do depósito correspondem a amostras > 1.31%.

- Como X̅ > P50, Skew > 0 e tem-se cauda alongada à direita, a distribuição da variável Cu é assimétrica positiva. Isso faz sentido, uma vez que o Cu é tipicamente um elemento menor.

- Como Kurt(excessiva) > 0, a distribuição do Cu é leptocúrtica, ou seja, as caudas são mais densas do que as caudas de uma Distribuição Gaussiana.

"""

# ╔═╡ e752b573-9652-4d13-ab16-fde4137828ed
md"""
#### Descrição da variável litologia

O banco de dados é composto por **três litotipos** distintos:

- Tonalito Pórfiro (TnP)
- Granodiorito Pórfiro (GnP)
- Monzonito Pórfiro (MzP)

"""

# ╔═╡ b635a9ad-90ab-4a28-8cc4-ad2285fe2f0e
# Criação de uma tabela com o número de amostras por litologia
lito = dh |>
    @groupby(_.LITH) |>
    @map({Litologia=key(_), Contagem=length(_)}) |>
    DataFrame

# ╔═╡ 1e7c1b35-980c-4bd5-8287-1c93bc82d80f
# Gráfico de barras de contagem de litotipos
bar(lito[:,:Litologia], lito[:,:Contagem], legend=false,
        ylabel="Contagem", color=:pink1, alpha=0.65)

# ╔═╡ 20e2519a-041a-4790-8160-fdddf86e1801
md"""

As três litologias apresentam número de ocorrências muito semelhantes. Em outras palavras, encontram-se balanceadas.

"""

# ╔═╡ 71b45351-7397-46e4-912a-c5e65fb6a1c8
md"""
#### Resumo

- Nota-se um agrupamento preferencial em porções "mais ricas" do depósito. Nesse sentido, há necessidade de se calcular estatísticas declusterizadas para o Cu.

- Rossi & Deutsch (2013) afirmam que substâncias cujo Cᵥ < 50% apresentam baixa variabilidade, ou seja, são "bem comportadas". Como Cᵥ(Cu) < 50%, pode-se dizer que a variável de interesse é pouco errática.

- Cu apresenta uma distribuição assimétrica positiva e é leptocúrtica.

- Existem três litotipos distintos no conjunto de dados (TnP, MzP e GnP) distribuídos de forma balanceada.
"""

# ╔═╡ 85d1bce5-6d24-4b2a-83e3-d76c29677751
html"""
    <div id="declus">
        <h2>4. Declusterização</h2>
    </div>
"""

# ╔═╡ 5bfa698a-4e29-47f8-96fe-3c533fbdb761
md"""
#### Introdução

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

No pacote [Geostats.jl](https://juliaearth.github.io/GeoStats.jl/stable/index.html), georreferenciar os dados consiste em informar quais atributos devem ser tratados como coordenadas e quais devem ser entendidos com variáveis.

Quando se georreferencia um determinado conjunto de dados, ele passa a ser tratado  como um objeto espacial.

Um objeto espacial apresenta um **domínio (domain)**, ou seja, suas informações espaciais (coordenadas) e **valores (values)**, ou seja, suas variáveis.

No caso, iremos georreferenciar o arquivo de furos compositados, de modo que as coordenadas `X`, `Y` e `Z` serão passadas como domínio e a variável `CU` será entendida como valor.

"""

# ╔═╡ 63b75ae2-8dca-40e3-afe0-68c6a639f54e
begin

    # Criando uma subtabela a partir dos furos apenas com as coordenadas e Cu
    comps_sub = comps[:,[:X,:Y,:Z,:CU]]

    # Georreferenciando da nova tabela criada acima
    comps_georef = georef(comps_sub, (:X,:Y,:Z))

end

# ╔═╡ f74b8675-64e4-438d-aa8e-7c5792d25651
md"""
#### Estatísticas declusterizadas

Com os furos georreferenciados, podemos agora calcular **estatísticas declusterizadas** para o Cu.

As estatísticas declusterizadas serão utilizadas na etapa de validação da estimativa por krigagem.

A tabela abaixo mostra uma comparação estatística entre os teores de Cu originais e declusterizados:

"""

# ╔═╡ 68e50bdd-b006-4abc-aeda-c4d67c30babb
begin
	# Sumário estatístico do Cu clusterizado (original)
	sum_cu_clus = sum_cu[:,[:Variável, :X̅, :S², :S, :P10, :P50, :P90]]
	
	# P10, P50 e P90 do Cu declusterizado
	q_dec = quantile(comps_georef, :CU, [0.1, 0.5, 0.9])
	
	# Sumário estatístico do Cu declusterizado
	sum_cu_declus = DataFrame(
								Variável = :CU_Declus,
								X̅ = round(mean(comps_georef, :CU), digits=2),
								S² = round(var(comps_georef, :CU), digits=2),
								S = round(sqrt(var(comps_georef, :CU)), digits=2),
								P10 = round(q_dec[1], digits=2),
								P50 = round(q_dec[2], digits=2),
								P90 = round(q_dec[3], digits=2)
                          )
	
	# Concatenação vertical dos sumários clusterizado e declusterizado
	vcat(sum_cu_clus, sum_cu_declus)
end

# ╔═╡ c6710e72-400c-4e90-94e5-fd48b62b088a
begin

    # Cálculo do histograma declusterizado de Cu
    hist_dec = EmpiricalHistogram(comps_georef, :CU, nbins=30)

    # Visualização do histograma declusterizado de Cu
    plot(hist_dec, label=false, xlabel="Cu Declusterizado (%)",
         color=:darkgoldenrod1, legend=true)

    # Linha vertical tracejada vermelha (média original)
    vline!([sum_cu_clus[:,:X̅]], label="X̅ Original",
           color=:red, ls=:dashdot, linewidth=1.5)

    # Linha vertical contínua vermelha (média declusterizada)
    vline!([sum_cu_declus[:,:X̅]], label="X̅ Declusterizada",
           color=:red, ls=:solid, linewidth=1.5)

end

# ╔═╡ 32a075ee-e853-4bb3-8eff-44543b6db0d5
md"""

Nota-se que a média declusterizada representa **$(round(Int,((sum_cu_declus[:,:X̅] / sum_cu_clus[:,:X̅]) * 100)[1]))%** da média original. Ou seja, há uma diferença de **$(round((sum_cu_clus[:,:X̅] - sum_cu_declus[:,:X̅])[1], digits=2))%** de Cu entre a média original e a média declusterizada.

Houve uma redução de **$(round((100.00 - ((sum_cu_declus[:,:S] / sum_cu_clus[:,:S]) *100)[1]),digits=2))%** do desvio padrão. Isso é curioso, já que, quando se aplica alguma técnica de declusterização, a tendência é haver um aumento na dispersão.

"""

# ╔═╡ d3b6724c-bc28-4d21-93e9-4f63508b0c2b
html"""

    <div id="vg_exp_model_vg">
        <h2>5. Cálculo e modelagem de variogramas experimentais</h2>
    </div>

"""

# ╔═╡ 162ce197-8d60-45dc-812f-91aa2f80fb95
md"""
#### Introdução
"""

# ╔═╡ b02263dc-280a-40b4-be1e-9c3b6873e153
md"""

##### Função variograma/semivariograma

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
    
    hline!([var(dh.CU)], color=:gray, ls=:dash, legend=false)

    vline!([a_dip2], color=:green, ls=:dash, legend=false)

end

# ╔═╡ Cell order:
# ╠═980f4910-96f3-11eb-0d4f-b71ad9888d73
# ╟─14ac7b6e-9538-40a0-93d5-0379fa009872
# ╟─20fff27a-4328-43ac-97df-a35b63a6fdd0
# ╟─c544614a-3e5c-4d22-9340-592aabf84871
# ╟─1a00e8d4-4115-4651-86a7-5237b239307f
# ╟─c66d36e2-d6be-4d70-a3c3-a691d0b1064e
# ╟─ff01a7d7-d491-4d49-b470-a2af6783c82b
# ╟─ca724400-26a6-4332-bf19-2eb8ffe7d817
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
# ╟─7a2899ab-496e-4919-a02e-e6ad8dd2b676
# ╟─3e5efd3c-3d8a-4bf1-a0f1-b402ea4a6cd3
# ╟─2a00e08c-5579-4320-b570-3b564d186fec
# ╟─1f07ba56-2ebd-4b4b-b0e8-cabcfe102e0f
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
# ╟─439837bf-941d-4300-ba96-6f372b7e514f
# ╟─f2be5f11-1923-4658-93cf-800ce57c32d3
# ╟─c0604ed8-766e-4c5d-a628-b156615f8140
# ╟─f855019a-27b0-42b5-a867-82fc25ef9e82
# ╟─074bff0b-6b41-4bbc-9b5c-77fbf62c4dc6
# ╟─8bb2f630-8234-4f7f-a05c-8206993bdd45
# ╟─862dd0cf-69ae-48e7-92fb-ff433f62e67c
# ╟─ea0968ca-a997-40c6-a085-34b3aa89807e
# ╟─36fad6e9-038c-4ba2-a49c-badeda404356
# ╟─ccbcf57e-d00b-43df-8555-eee8bf4f9e6f
# ╟─7f3f9c03-097d-4dd1-a122-53cceef56cbd
# ╟─462264f1-cad2-4ae6-abc2-5273f175569b
# ╟─2e94b106-56cd-4034-b5d4-00dae5c02c57
# ╟─b95a6def-f3e6-4835-b15f-2a48577006f4
# ╟─0808061f-4856-4b82-8560-46a59e669ac4
# ╟─e752b573-9652-4d13-ab16-fde4137828ed
# ╠═b635a9ad-90ab-4a28-8cc4-ad2285fe2f0e
# ╟─1e7c1b35-980c-4bd5-8287-1c93bc82d80f
# ╟─20e2519a-041a-4790-8160-fdddf86e1801
# ╟─71b45351-7397-46e4-912a-c5e65fb6a1c8
# ╟─85d1bce5-6d24-4b2a-83e3-d76c29677751
# ╟─5bfa698a-4e29-47f8-96fe-3c533fbdb761
# ╟─14beece5-6475-49a0-9f5c-cefb68328e24
# ╟─201b805b-7241-441d-b2d9-5698b0da58ab
# ╠═63b75ae2-8dca-40e3-afe0-68c6a639f54e
# ╟─f74b8675-64e4-438d-aa8e-7c5792d25651
# ╟─68e50bdd-b006-4abc-aeda-c4d67c30babb
# ╠═c6710e72-400c-4e90-94e5-fd48b62b088a
# ╟─32a075ee-e853-4bb3-8eff-44543b6db0d5
# ╟─d3b6724c-bc28-4d21-93e9-4f63508b0c2b
# ╟─162ce197-8d60-45dc-812f-91aa2f80fb95
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
