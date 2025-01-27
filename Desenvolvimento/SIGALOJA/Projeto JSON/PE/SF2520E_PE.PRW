#Include "Protheus.ch"

User Function SF2520E()
Local _aArea    := GetArea()
Private _cErro  := ""

If U_VerCfop(SF2->(F2_FILIAL+F2_DOC+F2_SERIE),GetNewPar("ZZ_CFOPT","5152"))  

    If !U_GeraJson("5",SF2->(F2_FILIAL+F2_DOC+F2_SERIE),"C","1")
        Alert(_cErro)
    Endif

Endif

RestArea(_aArea)
Return .T.
