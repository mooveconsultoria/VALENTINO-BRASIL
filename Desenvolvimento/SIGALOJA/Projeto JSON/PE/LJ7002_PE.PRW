#Include "Protheus.ch"

User Function LJ7002()
	Local _aArea    := GetArea()
	Local cCliente	:= SL1->L1_CLIENTE
	Local cLoja		:= SL1->L1_LOJA
	Local cDoc		:= SL1->L1_DOC
	Local cSerie    := SL1->L1_SERIE
    
    Private nTipo		:= paramixb[1] // 1 - orçamento   2 - cupom  3-nota
	Private _cErro  := ""
    
	dbselectArea("SF2")
	dbSetOrder(1)
	if SF2->(dbSeek(xFilial("SF2")+cDoc+cSerie+cCliente+cloja))
		RecLock("SF2", .F.)
		    SF2->F2_ZZPEDCL := SL1->L1_ZZPEDCL
		    dbCommit()
		MsUnlock()
	endif


If U_VerCfop(SF2->(F2_FILIAL+F2_DOC+F2_SERIE),GetNewPar("ZZ_CFOPV","5102"))  // TES 501
    If !U_GeraJson("1",SF2->(F2_FILIAL+F2_DOC+F2_SERIE),"N","1")
        Alert(_cErro)
    Endif
Endif

RestArea(_aArea)
Return .T.

User Function VerCfop(cChave,cPar)
Local _aArea    := GetArea()
Local _lRet     := .F.

DbSelectArea("SD2")
DbSetOrder(3)
DbGoTop()

DbSeek(cChave)

Do While SD2->(D2_FILIAL+D2_DOC+D2_SERIE) = cChave .And. !Eof()

    If Substr(SD2->D2_CF,2,3) $ Substr(cPar,2,3)
        _lRet := .T.
        EXIT
    ENDIF

    DbSkip()

Enddo

RestArea(_aArea)
Return _lRet
