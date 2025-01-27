#include "totvs.ch"
/*/{Protheus.doc} MT120RAT
description   Alteração de informações na tabela Rateio Pedido de Compra (SCH)
@type user function
@version  1.0
@author Oscar Lira
@since 06/12/2023
@return aColsSCH
/*/
User Function MT120RAT()

Local aColsSCH := ParamIXB[1] //contém as informações da replicação do rateio por centro de custo
Local aHeadSCH := ParamIXB[2] //contém as informações dos campos do array anterior
Local nItemRat := ParamIXB[3] //item a partir do qual será replicado o rateio por centro de custo.
Local nPosVLR  := aScan(aHeadSCH,{|x| Alltrim(x[2]) = "CH_ZZVLR"})
Local nPosPerc := aScan(aHeadSCH,{|x| Alltrim(x[2]) = "CH_PERC"})
Local nX,nY

For nX := 1 to Len(aColsSCH)
    For nY := 1 to Len(aColsSCH[nX,2])
	    If !aColsSCH[nX,2,nY,Len(aHeadSCH)+1]
            aColsSCH[nX,2,nY,nPosVLR] := aOrigaCols[nX,aScan(aOrigHeader,{|x|alltrim(x[2])=="C7_TOTAL"})]*aColsSCH[nX,2,nY,nPosPerc]/100
        EndIf
    Next
Next

Return aColsSCH
