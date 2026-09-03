$ErrorActionPreference = "Continue"

# ============================================================
# CONFIGURACAO
# ============================================================

$BASE_URL = "http://localhost:3000/api/produtos"

$Total = 0
$Passou = 0
$Falhou = 0
$ProdutoId = $null

# ============================================================
# FUNCAO PARA EXECUTAR HTTP
# ============================================================

function Request {
    param(
        [string]$Method,
        [string]$Url,
        $Body = $null
    )

    try {

        $params = @{
            Uri         = $Url
            Method      = $Method
            UseBasicParsing = $true
            ErrorAction = "Stop"
        }

        if ($null -ne $Body) {
            $params.ContentType = "application/json"
            $params.Body = ($Body | ConvertTo-Json -Depth 10 -Compress)
        }

        $response = Invoke-WebRequest @params

        return @{
            Status = [int]$response.StatusCode
            Body   = $response.Content
            Json   = if ($response.Content) {
                try {
                    $response.Content | ConvertFrom-Json
                }
                catch {
                    $null
                }
            } else {
                $null
            }
        }

    }
    catch {

        $status = 0
        $body = ""

        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode

            try {
                $reader = New-Object System.IO.StreamReader(
                    $_.Exception.Response.GetResponseStream()
                )

                $body = $reader.ReadToEnd()
                $reader.Close()
            }
            catch {
                $body = ""
            }
        }

        return @{
            Status = $status
            Body   = $body
            Json   = if ($body) {
                try {
                    $body | ConvertFrom-Json
                }
                catch {
                    $null
                }
            } else {
                $null
            }
        }
    }
}

# ============================================================
# FUNCAO DE TESTE
# ============================================================

function Test {
    param(
        [string]$Nome,
        [bool]$Resultado,
        [string]$Detalhe = ""
    )

    $script:Total++

    if ($Resultado) {

        $script:Passou++

        Write-Host "[PASSOU] $Nome" -ForegroundColor Green

        if ($Detalhe) {
            Write-Host "         $Detalhe" -ForegroundColor Gray
        }

    }
    else {

        $script:Falhou++

        Write-Host "[FALHOU] $Nome" -ForegroundColor Red

        if ($Detalhe) {
            Write-Host "         $Detalhe" -ForegroundColor Yellow
        }
    }
}

# ============================================================
# CABECALHO
# ============================================================

Clear-Host

Write-Host ""
Write-Host "============================================================"
Write-Host "      TESTES AUTOMATIZADOS - API E-COMMERCE"
Write-Host "============================================================"
Write-Host ""

# ============================================================
# VERIFICACAO DA API
# ============================================================

Write-Host "Verificando API..."

$api = Request -Method "GET" -Url $BASE_URL

if ($api.Status -ne 200) {

    Write-Host "[ERRO] API nao esta funcionando." -ForegroundColor Red
    Write-Host "Status recebido: $($api.Status)"
    Write-Host ""
    Write-Host "Execute primeiro:"
    Write-Host "npm run dev"
    Write-Host ""

    exit 1
}

Write-Host "[OK] API funcionando." -ForegroundColor Green
Write-Host ""

# ============================================================
# RF01 - CADASTRO DE PRODUTOS
# ============================================================

Write-Host "============================================================"
Write-Host "RF01 - CADASTRO DE PRODUTOS"
Write-Host "============================================================"
Write-Host ""

Write-Host "[Teste 1] Cadastro com especificacoes dinamicas..."

$produto = @{
    nome = "Produto Teste Automatizado"
    preco = 123.45
    categoria = "Testes"
    estoque = 50
    descricao = "Produto criado pelo teste automatizado"

    especificacoes = @{
        cor = "Azul"
        tamanho = "M"
        material = "Algodao"
    }
}

$r = Request `
    -Method "POST" `
    -Url $BASE_URL `
    -Body $produto

$ok = (
    $r.Status -eq 201 -and
    $null -ne $r.Json -and
    $null -ne $r.Json._id
)

Test `
    "RF01 - Cadastro de produto" `
    $ok `
    "HTTP $($r.Status)"

if ($ok) {

    $ProdutoId = [string]$r.Json._id

    Write-Host "         ID criado: $ProdutoId" -ForegroundColor Gray
}

Write-Host ""

# ------------------------------------------------------------

Write-Host "[Teste 2] Cadastro com outro tipo de especificacao..."

$produto2 = @{
    nome = "Eletrodomestico Teste"
    preco = 599.90
    categoria = "Eletrodomesticos"
    estoque = 15
    descricao = "Produto de teste"

    especificacoes = @{
        voltagem = "220V"
        potencia = "1500W"
        capacidade = "30L"
    }
}

$r = Request `
    -Method "POST" `
    -Url $BASE_URL `
    -Body $produto2

$ok = (
    $r.Status -eq 201 -and
    $null -ne $r.Json -and
    $null -ne $r.Json._id
)

Test `
    "RF01 - Esquema dinamico" `
    $ok `
    "HTTP $($r.Status)"

Write-Host ""

# ============================================================
# RF02 - FILTROS COMPOSTOS
# ============================================================

Write-Host "============================================================"
Write-Host "RF02 - FILTROS COMPOSTOS"
Write-Host "============================================================"
Write-Host ""

Write-Host "[Teste 1] Filtro por categoria..."

$url = "$BASE_URL`?categoria=Testes"

$r = Request `
    -Method "GET" `
    -Url $url

$ok = (
    $r.Status -eq 200 -and
    $null -ne $r.Json
)

Test `
    "RF02 - Filtro por categoria" `
    $ok `
    "HTTP $($r.Status)"

Write-Host ""

# ------------------------------------------------------------

Write-Host "[Teste 2] Categoria + preco minimo + preco maximo..."

$url = "$BASE_URL`?categoria=Testes&precoMin=50&precoMax=200"

$r = Request `
    -Method "GET" `
    -Url $url

$ok = (
    $r.Status -eq 200 -and
    $null -ne $r.Json
)

Test `
    "RF02 - Categoria + faixa de preco" `
    $ok `
    "HTTP $($r.Status)"

Write-Host ""

# ============================================================
# RF03 - BUSCA TEXTUAL
# ============================================================

Write-Host "============================================================"
Write-Host "RF03 - BUSCA TEXTUAL"
Write-Host "============================================================"
Write-Host ""

Write-Host '[Teste 1] Busca por "Produto"...'

$url = "$BASE_URL`?q=Produto"

$r = Request `
    -Method "GET" `
    -Url $url

$ok = (
    $r.Status -eq 200 -and
    $null -ne $r.Json
)

Test `
    "RF03 - Busca por nome" `
    $ok `
    "HTTP $($r.Status)"

Write-Host ""

# ------------------------------------------------------------

Write-Host '[Teste 2] Busca por "Automatizado"...'

$url = "$BASE_URL`?q=Automatizado"

$r = Request `
    -Method "GET" `
    -Url $url

$ok = (
    $r.Status -eq 200 -and
    $null -ne $r.Json
)

Test `
    "RF03 - Busca textual" `
    $ok `
    "HTTP $($r.Status)"

Write-Host ""

# ============================================================
# RF04 - PAGINACAO E ORDENACAO
# ============================================================

Write-Host "============================================================"
Write-Host "RF04 - PAGINACAO E ORDENACAO"
Write-Host "============================================================"
Write-Host ""

Write-Host "[Teste 1] Paginacao limit=2 skip=0..."

$url = "$BASE_URL`?limit=2&skip=0"

$r = Request `
    -Method "GET" `
    -Url $url

$items = @()

if ($r.Json -is [System.Array]) {
    $items = @($r.Json)
}
elseif ($null -ne $r.Json.produtos) {
    $items = @($r.Json.produtos)
}
elseif ($null -ne $r.Json.data) {
    $items = @($r.Json.data)
}

$ok = (
    $r.Status -eq 200 -and
    $items.Count -le 2
)

Test `
    "RF04 - Paginacao limit=2" `
    $ok `
    "HTTP $($r.Status) | Itens retornados: $($items.Count)"

Write-Host ""

# ------------------------------------------------------------

Write-Host "[Teste 2] Ordenacao por preco decrescente..."

$url = "$BASE_URL`?ordem=desc"

$r = Request `
    -Method "GET" `
    -Url $url

$items = @()

if ($r.Json -is [System.Array]) {
    $items = @($r.Json)
}
elseif ($null -ne $r.Json.produtos) {
    $items = @($r.Json.produtos)
}
elseif ($null -ne $r.Json.data) {
    $items = @($r.Json.data)
}

$ordenado = $true

for ($i = 0; $i -lt ($items.Count - 1); $i++) {

    $precoAtual = [double]$items[$i].preco
    $proximoPreco = [double]$items[$i + 1].preco

    if ($precoAtual -lt $proximoPreco) {
        $ordenado = $false
        break
    }
}

$ok = (
    $r.Status -eq 200 -and
    $ordenado
)

Test `
    "RF04 - Ordenacao decrescente" `
    $ok `
    "HTTP $($r.Status)"

Write-Host ""

# ============================================================
# RF05 - ATUALIZACAO
# ============================================================

Write-Host "============================================================"
Write-Host "RF05 - ATUALIZACAO DE DADOS E ESTOQUE"
Write-Host "============================================================"
Write-Host ""

if ($ProdutoId) {

    Write-Host "[Teste 1] Atualizando dados..."

    $atualizacao = @{
        nome = "Produto Automatizado Atualizado"
        preco = 199.90
        descricao = "Dados atualizados automaticamente"
    }

    $r = Request `
        -Method "PUT" `
        -Url "$BASE_URL/$ProdutoId" `
        -Body $atualizacao

    $ok = ($r.Status -eq 200)

    Test `
        "RF05 - Atualizacao de dados" `
        $ok `
        "HTTP $($r.Status)"

    Write-Host ""

    # --------------------------------------------------------
    # INCREMENTO
    # --------------------------------------------------------

    Write-Host "[Teste 2] Incrementando estoque +5..."

    $incremento = @{
        quantidade = 5
    }

    $r = Request `
        -Method "PATCH" `
        -Url "$BASE_URL/$ProdutoId/estoque" `
        -Body $incremento

    $ok = ($r.Status -eq 200)

    Test `
        "RF05 - Incremento de estoque com `$inc" `
        $ok `
        "HTTP $($r.Status)"

    Write-Host ""

    # --------------------------------------------------------
    # DECREMENTO
    # --------------------------------------------------------

    Write-Host "[Teste 3] Decrementando estoque -2..."

    $decremento = @{
        quantidade = -2
    }

    $r = Request `
        -Method "PATCH" `
        -Url "$BASE_URL/$ProdutoId/estoque" `
        -Body $decremento

    $ok = ($r.Status -eq 200)

    Test `
        "RF05 - Decremento de estoque com `$inc" `
        $ok `
        "HTTP $($r.Status)"

}
else {

    Test "RF05 - Atualizacao de dados" $false "ID do produto nao foi criado"
    Test "RF05 - Incremento de estoque" $false "ID do produto nao foi criado"
    Test "RF05 - Decremento de estoque" $false "ID do produto nao foi criado"
}

Write-Host ""

# ============================================================
# RF06 - REMOCAO
# ============================================================

Write-Host "============================================================"
Write-Host "RF06 - REMOCAO DE PRODUTOS"
Write-Host "============================================================"
Write-Host ""

if ($ProdutoId) {

    Write-Host "[Teste 1] Removendo produto..."

    $r = Request `
        -Method "DELETE" `
        -Url "$BASE_URL/$ProdutoId"

    $ok = ($r.Status -eq 200)

    Test `
        "RF06 - Remocao do produto" `
        $ok `
        "HTTP $($r.Status)"

    Write-Host ""

    # --------------------------------------------------------

    Write-Host "[Teste 2] Buscando produto removido..."

    $r = Request `
        -Method "GET" `
        -Url "$BASE_URL/$ProdutoId"

    $ok = ($r.Status -eq 404)

    Test `
        "RF06 - Produto nao encontrado apos remocao" `
        $ok `
        "HTTP $($r.Status) | Esperado: 404"
}
else {

    Test "RF06 - Remocao do produto" $false "ID do produto nao foi criado"
    Test "RF06 - Produto nao encontrado apos remocao" $false "ID do produto nao foi criado"
}

# ============================================================
# RESULTADO FINAL
# ============================================================

Write-Host ""
Write-Host ""
Write-Host "============================================================"
Write-Host "                   RESULTADO FINAL"
Write-Host "============================================================"
Write-Host ""

Write-Host "Total de testes : $Total"
Write-Host "Testes passaram : $Passou" -ForegroundColor Green
Write-Host "Testes falharam : $Falhou" -ForegroundColor Red

if ($Total -gt 0) {

    $taxa = [math]::Round(($Passou / $Total) * 100)

    Write-Host "Taxa de sucesso : $taxa%"
}

Write-Host ""

if ($Falhou -eq 0) {

    Write-Host "============================================================"
    Write-Host "              TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    Write-Host "============================================================"

}
else {

    Write-Host "============================================================"
    Write-Host "              EXISTEM TESTES COM FALHA!" -ForegroundColor Red
    Write-Host "============================================================"
}

Write-Host ""
