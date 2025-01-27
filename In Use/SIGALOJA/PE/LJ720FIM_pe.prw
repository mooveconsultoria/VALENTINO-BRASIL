#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
/*
* Programa: SF1TTS       Autor: Oscar Lira      04/07/2023
* Finalidade: Ponto de entrada para atualizacoes na SF1 apos finalizacao da gravacao da SF1
*             Usado para verificar se a nota de devolucao deve descontar a comissao
*/
User Function LJ720FIM()
Local aAreaAnt  := GetArea()
Local aAreaSE3  := SE3->(GetArea())
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSF1  := SF1->(GetArea())
Local nX
Private aDevDocs  := ParamIXB[1]

SE3->(dBSetOrder(1))  // E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND
SD1->(dBSetOrder(1))  // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
SF1->(dBSetOrder(1))  // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
/*
FWAlertInfo("Tipo: "+Type("aDevDocs"))
FWAlertInfo("Tipo: 1-"+Type("aDevDocs[1]")+If(!Type("aDevDocs[1]") $ "UA",aDevDocs[1],""))
FWAlertInfo("Tipo: 2-"+Type("aDevDocs[2]")+If(!Type("aDevDocs[2]") $ "UA",aDevDocs[2],""))
FWAlertInfo("Tipo: 3-"+Type("aDevDocs[3]")+If(!Type("aDevDocs[3]") $ "UA",aDevDocs[3],""))
FWAlertInfo("Tipo: 4-"+Type("aDevDocs[4]")+If(!Type("aDevDocs[4]") $ "UA",aDevDocs[4],""))
*/
// Caso a nota nao deva descontar a comissao, restaurar a SE3 original que foi salva no P.E. FA440VLD
If SF1->(MsSeek(xFilial("SF1")+aDevDocs[2]+aDevDocs[1]+aDevDocs[3]+aDevDocs[4]) .AND. F1_TIPO = "D" .AND. F1_ZZCMDEV = "2")
    COMIS_LOJA_TRB->(dBGotop())
    While COMIS_LOJA_TRB->(!Eof())
        If COMIS_LOJA_TRB->E3_BASE <> 0
            RecLock("SE3",SE3->(!MsSeek(COMIS_LOJA_TRB->(E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND))))
            For nX := 1 to COMIS_LOJA_TRB->(fCount())
                cCampo := COMIS_LOJA_TRB->(FieldName(nX))
                SE3->&cCampo. := COMIS_LOJA_TRB->&cCampo.
            Next
            SE3->(MsUnlock())
        EndIf

        COMIS_LOJA_TRB->(dBSkip())
    Enddo

    COMIS_LOJA_TRB->(dBCloseArea())
    oComisTable:Delete()
EndIf

/*
    For nX := 1 to Len(aDevDocs)
        SD1->(MsSeek(xFilial("SD1")+aDevDocs[nX,2]+aDevDocs[nX,1]+aDevDocs[nX,3]+aDevDocs[nX,4]))
        While SD1->(!Eof() .and. D1_FILIAL = xFilial("SD1") .and. D1_DOC = aDevDocs[nX,2] .and. D1_SERIE = aDevDocs[nX,1] .and. ;
                    D1_FORNECE = aDevDocs[nX,3] .and. D1_LOJA = aDevDocs[nX,4])
            If SF1->(MsSeek(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA))) .and. ;
                COMIS_LOJA_TRB->(MsSeek(xFilial("SE3")+SD1->(D1_SERIORI+D1_NFORI)))

                While COMIS_LOJA_TRB->(!Eof() .and. E3_FILIAL = xFilial("SE3") .and. E3_PREFIXO = SD1->D1_SERIORI .and. E3_NUM = SD1->D1_NFORI)
                    If SF1->F1_ZZCMDEV = "1"
                        RecLock("COMIS_LOJA_TRB",.F.)
                        COMIS_LOJA_TRB->E3_BASE  -= If(SD1->D1_TOTAL > COMIS_LOJA_TRB->E3_BASE, COMIS_LOJA_TRB->E3_BASE, SD1->D1_TOTAL)
                        COMIS_LOJA_TRB->E3_COMIS := COMIS_LOJA_TRB->E3_BASE*COMIS_LOJA_TRB->E3_PORC/100
                        COMIS_LOJA_TRB->(MsUnlock())
                    EndIf

                    COMIS_LOJA_TRB->(dBSkip())
                EndDo
            EndIf
            SD1->(dBSkip())
        EndDo
    Next

COMIS_LOJA_TRB->(dBGotop())
While COMIS_LOJA_TRB->(!Eof())
    If SE3->(MsSeek(COMIS_LOJA_TRB->(E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND)))
        // Verificar se a comissao ainda nao foi paga
        If Empty(SE3->E3_DATA)
            RecLock("SE3",.F.)
            If COMIS_LOJA_TRB->E3_COMIS = 0
                SE3->(dBDelete())
            Else
                For nX := 1 to SE3->(fCount())
                    cCampo := SE3->(FieldName(nX))
                    SE3->&cCampo. := COMIS_LOJA_TRB->&cCampo.
                Next
            EndIf
            SE3->(MsUnlock())
        Else
            // Se a comissao foi paga, criar uma comissao negativa
            RecLock("SE3",.T.)
            For nX := 1 to SE3->(fCount())
                cCampo := SE3->(FieldName(nX))
                If Alltrim(cCampo) = "E3_BASE"
                    SE3->E3_BASE := -COMIS_LOJA_TRB->E3_BASEORI
                ElseIf Alltrim(cCampo) = "E3_COMIS"
                    SE3->E3_COMIS := -COMIS_LOJA_TRB->E3_COMIORI
                ElseIf Alltrim(cCampo) = "E3_SEQ"
                    SE3->E3_SEQ := RetSeqSE3(COMIS_LOJA_TRB->E3_FILIAL,COMIS_LOJA_TRB->E3_PREFIXO,COMIS_LOJA_TRB->E3_NUM,COMIS_LOJA_TRB->E3_PARCELA,COMIS_LOJA_TRB->E3_VEND)
                Else
                    SE3->&cCampo. := COMIS_LOJA_TRB->&cCampo.
                EndIf
            Next
            SE3->(MsUnlock())
        EndIf
    EndIf

    COMIS_LOJA_TRB->(dBSkip())
Enddo

COMIS_LOJA_TRB->(dBCloseArea())
oComisTable:Delete()

    cQuery := "SELECT SE3.R_E_C_N_O_ NUMREG,D1_SERIORI "
    cQuery += "FROM "+RetSqlName("SD1")+" SD1 INNER JOIN "+RetSqlName("SE3")+" SE3 ON "
    cQuery += "E3_FILIAL = '"+xFilial("SE3")+"' AND E3_NUM = D1_NFORI AND E3_ZZSRORI = D1_SERIORI AND SE3.D_E_L_E_T_ = ' ' "
    cQuery += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND D1_DOC = '"+aDevDocs[nX,2]+"' AND D1_SERIE = '"+aDevDocs[nX,1]+"' AND "
    cQuery += "D1_FORNECE = '"+aDevDocs[nX,3]+"' AND D1_LOJA = '"+aDevDocs[nX,4]+"' AND SD1.D_E_L_E_T_ = ' ' "
    TcQuery cQuery Alias (cNewAlias) New

    (cNewAlias)->(dBGotop())
    While (cNewAlias)->(!Eof())
        SE3->(dBGoto((cNewAlias)->NUMREG))
        If SE3->(!Eof())
            RecLock("SE3",.F.)
            SE3->E3_PREFIXO := (cNewAlias)->D1_SERIORI
            SE3->E3_ZZSRORI := Space(TamSX3("E3_ZZSRORI")[1])
            SE3->(MsUnlock())
        EndIf

        (cNewAlias)->(dBSkip())
    Enddo
    (cNewAlias)->(dBCloseArea())
Next
*/
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aAreaSE3)
RestArea(aAreaAnt)

Return Nil
/*---------------------------------------------------------------------------*/
Static Function RetSeqSE3(cCodFil,cPrefixo,cNum,cParcela,cVend)
Local cQuery := ""
Local cNewAlias := GetNextAlias()
Local cRetSeq := ""

cQuery := "SELECT MAX(E3_SEQ) E3_SEQ FROM "+RetSqlName("SE3")+" WHERE "
cQuery += "E3_FILIAL = '"+cCodFil+"' AND E3_PREFIXO = '"+cPrefixo+"' AND E3_NUM = '"+cNum+"' AND "
cQuery += "E3_PARCELA = '"+cParcela+"' AND E3_VEND = '"+cVend+"' AND D_E_L_E_T_ = ' '"
TcQuery cQuery Alias (cNewAlias) New

cRetSeq := Soma1((cNewAlias)->E3_SEQ)
(cNewAlias)->(dBCloseArea())

Return cRetSeq
