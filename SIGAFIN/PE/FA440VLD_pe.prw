#INCLUDE "totvs.ch"
/*
* Programa: SF1TTS       Autor: Oscar Lira      04/07/2023
* Finalidade: Ponto de entrada para atualizacoes na SF1 apos finalizacao da gravacao da SF1
*             Usado para verificar se a nota de devolucao deve descontar a comissao
*/
User Function FA440VLD()
Local aAreaAnt := GetArea()
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSE3 := SE3->(GetArea())
Local aParamBox	:= {}
Local aRet      := {}
Local lRet      := .T.
Local aCampos   := FWSX3Util():GetListFieldsStruct("SE3",.F.)
Local nI

aAdd(aParamBox,{2,"Desconta comissão",1,{"1=Sim","2=Não"},50,"Pertence('12')",.F.})

If !IsBlind() .and. FWIsInCallStack("MATA103") .and. SF1->F1_TIPO = "D"
    If INCLUI .and. Empty(SF1->F1_ZZCMDEV) .and. ParamBox(aParamBox,"Tratamento de comissões",@aRet,,,.T.,,,,,.F.,.F.)
        RecLock("SF1",.F.)
        If (Valtype(aRet[1])="N" .and. aRet[1]=1) .or. (Valtype(aRet[1])="C" .and. aRet[1]="1")

            SF1->F1_ZZCMDEV := "1"
            SF1->(MsUnlock())

            lRet := .T.
        Else
            SF1->F1_ZZCMDEV := "2"
            SF1->(MsUnlock())

            lRet := .F.

            // Se for troca ou devolucao pelo LOJA, salvo os dados da comissao e retorno no P.E. LJ720FIM
            If FWIsInCallStack("LOJA720")
                Public oComisTable := FWTemporaryTable():New("COMIS_LOJA_TRB")
                aadd(aCampos,{"E3_BASEORI","N",TamSX3("E3_BASE")[1],TamSX3("E3_BASE")[2]})
                aadd(aCampos,{"E3_COMIORI","N",TamSX3("E3_COMIS")[1],TamSX3("E3_COMIS")[2]})
                oComisTable:SetFields(aCampos)
                oComisTable:AddIndex("indice1", {"E3_FILIAL","E3_PREFIXO","E3_NUM","E3_PARCELA","E3_SEQ","E3_VEND"})
                oComisTable:Create()

                SD1->(dBSetOrder(1))  // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
                SE3->(dBSetOrder(1))  // E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND

                SD1->(MsSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
                While SD1->(!Eof() .and. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA = SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
                    SE3->(MsSeek(xFilial("SE3")+SD1->(D1_SERIORI+D1_NFORI)))
                    While SE3->(!Eof() .and. E3_FILIAL = xFilial("SE3") .and. E3_PREFIXO = SD1->D1_SERIORI .and. E3_NUM = SD1->D1_NFORI)
                        RecLock("COMIS_LOJA_TRB",.T.)
                        For nI := 1 to SE3->(fCount())
                            cCampo := SE3->(FieldName(nI))
                            COMIS_LOJA_TRB->&cCampo. := SE3->&cCampo.
                        Next
                        COMIS_LOJA_TRB->E3_BASEORI := SE3->E3_BASE
                        COMIS_LOJA_TRB->E3_COMIORI := SE3->E3_COMIS
                        COMIS_LOJA_TRB->(MsUnlock())

                        SE3->(dBSkip())
                    Enddo

                    SD1->(dBSkip())
                Enddo

                RestArea(aAreaSD1)
                RestArea(aAreaSE3)
            EndIf
        EndIf

        RestArea(aAreaAnt)
    ElseIf !INCLUI .and. !ALTERA
        If SF1->F1_ZZCMDEV = "1"
            lRet := .T.
        Else
            lRet := .F.
        EndIf
    EndIf
EndIf

Return lRet
