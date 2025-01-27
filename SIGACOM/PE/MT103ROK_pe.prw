#include "totvs.ch"
/*/{Protheus.doc} MT103ROK
description   Este ponto de entrada pertence ao MATA103X (funções de validação e controle de interface do documento de entrada). 
              É executado pelo rotina de validação do rateio para os itens do documento de entrada por centro de custo, NFERATTOK().
@type user function
@version  1.0
@author Oscar Lira
@since 06/12/2023
@return lRet, valor logico
/*/
User Function MT103ROK()
Local lRet := .T.
Local nPosValor := aScan(aHeader,{|x| AllTrim(x[2]) == "DE_ZZVLR"})
Local i := 0
Local nTotRat := 0

For i := 1 to Len(aCols)
    If !aCols[i,Len(aHeader)+1]
        nTotRat += aCols[i,nPosValor]
    EndIf
Next

If Abs(aOrigaCols[nOrigN,aScan(aOrigHeader,{|x|alltrim(x[2])=="D1_TOTAL"})]-nTotRat) > 0.02
    FwAlertError("O valor total rateado (R$ "+Alltrim(Transform(nTotRat,"@E 999,999,999.99"))+;
                 ") não está igual ao valor do item (R$ "+;
                 Alltrim(Transform(aOrigaCols[nOrigN,aScan(aOrigHeader,{|x|alltrim(x[2])=="D1_TOTAL"})],"@E 999,999,999.99"))+")")
    lRet := .F.
EndIf

Return lRet
