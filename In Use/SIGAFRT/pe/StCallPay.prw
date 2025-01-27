#include "totvs.ch"

#define POS_COD     1
#define POS_DESC    2
#define POS_LOCPAD  3
#define POS_QUANT   4
#define POS_TOTAL   5
#define POS_SALDO   6

/*/{Protheus.doc} StCallPay
Utilizado para validação de estoque negativo na venda PDV
@author Matheus Abrão
@since 22/07/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
user function StCallPay()
local cCodCli       := PARAMIXB[1]  //Codigo do cliente
local cCodCliLoj    := PARAMIXB[2]  //Codigo da loja do cliente
local oProdutos     := PARAMIXB[3]  //Produtos registrados na venda
local aProdutos     := {}
local lRet          := .T.
local nX            := 0
local cMsg          := ""
local nOpc          := 0
local lBloqueia     := .F.

aProdutos := retPrdVnd(oProdutos)

if len(aProdutos) > 0
    getSaldos(@aProdutos)

    lBloqueia := validaSaldo(aProdutos,@cMsg)

    if lBloqueia
        lRet := .F.
        geraTXT(cMsg)
        nOpc := Aviso("Saldo insuficiente", "Saldo insuficiente para os produtos abaixo:" + CRLF + cMsg, {"Liberação Superior", "Cancelar"}, 2)

        if nOpc == 1 // Liberação Superior

        endif
    endif
    

endif

return lRet

static function geraTxt(cMsg)
local cFileName := cFilAnt + "_" + STDGPBasket("SL1", "L1_NUM") + "_" + dtos(dDatabase) + "_" + strTran(time(),":","") + ".TXT"
local cDir      := "C:\TEMP\"
local aDir      := {}
local cFile     := alltrim(cDir) + cFileName
Local oFile     := FWFileWriter():new(cFile)
local i 
local j
local cTexto    := ""
local cCabec    := ""

cCabec += "Filial: " + cFilAnt + CRLF
cCabec += "Orçamento: " + STDGPBasket("SL1", "L1_NUM") + CRLF
cCabec += "Dt. Emissão: " + dtoc(STDGPBasket("SL1", "L1_EMISSAO")) + CRLF
cCabec += CRLF 

cTexto += cCabec + cMsg

aDir  := Directory(cDir,"D")
if len(aDir) = 0
	makeDir(cDir)
endIf

if oFile:Exists()
    oFile:Erase()
endIf

if (oFile:Create())
    oFile:Write(cTexto)
    oFile:Close()
endif

return

static function  validaSaldo(aProdutos,cMsg)
local lBloqueia     := .F.
local nQtdVend      := 0
local nSaldo        := 0
local nX            := 0

for nX := 1 to len(aProdutos)
    nQtdVend := aProdutos[nX,POS_QUANT]
    nSaldo   := aProdutos[nX,POS_SALDO]

    if nQtdVend > nSaldo
        lBloqueia := .T.
        cMsg += "Produto: " + alltrim(aProdutos[nX,POS_COD]) + " - " + alltrim(aProdutos[nX,POS_DESC]) + CRLF
        cMsg += "Valor Total: " + alltrim(transform(aProdutos[nX,POS_TOTAL],"@E 999,999,999,999.99")) + CRLF
        cMsg += "Saldo atual: " + alltrim(transform(nSaldo,"@E 999,999,999,999.99")) + CRLF
        cMsg += "Quantidade venda: " + alltrim(transform(nQtdVend,"@E 999,999,999,999.99")) + CRLF
        cMsg += replicate("-",50) + CRLF
    endif
  
next

return lBloqueia

//http://179.111.200.33:28084/rest/api/retail/v1/RetailStockLevel?iteminternalId=8054738000087
static function getSaldos(aProdutos)
/*local   nX          := 0                                                
local   cServer     := "179.111.200.33"  
local   cPort       := "28084" 
local   cUrl        := 'http://' + cServer + ':' + cPort + '/rest' + '/api/retail/v1'
local   cID         := ""
local   cResource   := "/retailStockLevel" 
local   oRestClient := FWRest():New(cUrl)
local   aHeader     := {}
local   cJson       := ''
local   cProduto    := ""
local   cLocPad     := ""

Private oJson

aAdd(aHeader, "Content-Type: application/json; charset=UTF-8" )
aAdd(aHeader, "Accept: application/json" )
aAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

for nX := 1 to len(aProdutos)
    cProduto := aProdutos[nX,1]
    cLocPad  := aProdutos[nX,2]
    cID      := "/companyId=" + cEmpAnt + "&branchId=" + cFilAnt + "&iteminternalId="+ cProduto + "&WarehouseInternalId=" + cLocPad"
    oRestClient:setPath(cResource + cID)

    if oRestClient:Get(aHeader)
        ConOut("GET",oRestClient:GetResult())
    else
        ConOut("GET", oRestClient:GetLastError())
    endIf
next*/
//teste
for nX := 1 to len(aProdutos)
    aProdutos[nX,4] := 1
next

return

static function retPrdVnd(oProdutos)
local aRet      := {}
local nPos      := 0
local cCodPrd   := ""
local cDescr    := ""
local cLocPad   := ""
local nQtd      := 0
local nTotal    := 0
local nX        := 0            //Variavel de loop
local aAreaSB1  := SB1->(getArea())

for nX := 1 to oProdutos:Length()
    oProdutos:GoLine(nX)
    cCodPrd := oProdutos:GetValue("L2_PRODUTO")
    nQtd    := oProdutos:GetValue("L2_QUANT")
    cDescr  := oProdutos:GetValue("L2_DESCRI")
    nTotal  := oProdutos:GetValue("L2_VLRITEM")
    cLocPad := posicione("SB1",1,xFilial("SB1") + cCodPrd,"B1_LOCPAD")

    nPos := aScan(aRet,{|x| x[POS_COD] == cCodPrd} )

    if nPos == 0
        aadd(aRet,{cCodPrd,cDescr,cLocPad,nQtd,nTotal,0}) // posição 6 será o saldo atual
    else
        aRet[nPos,POS_QUANT] += nQtd
        aRet[nPos,POS_TOTAL] += nTotal
    endif

next nX

restArea(aAreaSB1)
return aRet
