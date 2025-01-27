#INCLUDE "totvs.ch"
/*
* Programa: LJ7030       Autor: Oscar Lira      17/08/2023
* Finalidade: Esse ponto de entrada e chamado na Linok e na TudoOk na getdados da Venda Assistida
*             Usado para validar se foi definido o motivo do desconto caso o usuario tenha informado
*             valor ou percentual de desconto
*/
User Function LJ7030()
Local lRet       := .T.
Local aOpcoes    := ParamIXB
Local nPosVDesc  := Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_VALDESC"})
Local nPosPDesc  := Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_DESC"})
Local nPosMotivo := Ascan(aHeader, {|x| AllTrim(Upper(x[2])) == "LR_ZZMTDSC"})
Local nX

// Chamada pelo LinOK
If aOpcoes[1] = 1
    If !aCols[n,Len(aHeader)+1] .and. (aCols[n,nPosVDesc] > 0 .or. aCols[n,nPosPDesc] > 0) .and. Empty(aCols[n,nPosMotivo])
        FwAlertWarning("Motivo de desconto não informado")
        lRet := .F.
    EndIf 
// Chamada pelo TudoOK
Else
    For nX := 1 to Len(aCols)
        If !aCols[nX,Len(aHeader)+1] .and. (aCols[nX,nPosVDesc] > 0 .or. aCols[nX,nPosPDesc] > 0) .and. Empty(aCols[nX,nPosMotivo])
            FwAlertWarning("Motivo de desconto não informado")
            lRet := .F.
            Exit
        EndIf 
    Next
EndIf

Return lRet
