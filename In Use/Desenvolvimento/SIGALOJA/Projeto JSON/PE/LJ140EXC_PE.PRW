#Include "Protheus.ch"

User Function LJ140EXC()
Local _aArea    := GetArea()
Private _cErro  := ""

If U_VerCfop(SF2->(F2_FILIAL+F2_DOC+F2_SERIE),GetNewPar("ZZ_CFOPV","5102"))  // TES 501

    If !U_GeraJson("4",SF2->(F2_FILIAL+F2_DOC+F2_SERIE),"C","1")
        Alert(_cErro)
    Endif

Endif

RestArea(_aArea)
Return .T.
