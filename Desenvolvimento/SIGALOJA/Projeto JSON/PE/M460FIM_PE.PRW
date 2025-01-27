#include "Protheus.ch"

User Function M460FIM(UPAR)
Local aArea     := GetArea()
Local lRet      := .T.
Private _cErro  := ""

If U_VerCfop(SF2->(F2_FILIAL+F2_DOC+F2_SERIE),GetNewPar("ZZ_CFOPT","5152") ) // TES 510

    If !U_GeraJson("2",SF2->(F2_FILIAL+F2_DOC+F2_SERIE),"N","1")
        Alert(_cErro)
    Endif

Endif

RestArea(aArea)
Return lRet

