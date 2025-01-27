#Include 'Protheus.ch'

/*/{Protheus.doc}  MT103FIM
Chamada Tela de Endereçamento

@author Eduardo Patriani
@since 16/05/2019
@version 1.0

/*/
User Function MT103FIM
	
	Local nOpcao 		:= PARAMIXB[1]     // Opção Escolhida pelo usuario no aRotina
	Local nConfirma 	:= PARAMIXB[2]  // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO
	Local nTamSF1 		:= 0
	Local cMens 		:= ""
	Local cF1doc 		:= SF1->F1_DOC
	Local cF1serie 	:= SF1->F1_SERIE
	Local cF1forne 	:= SF1->F1_FORNECE
	Local cF1loja 		:= SF1->F1_LOJA
	Local cF1tipo 		:= SF1->F1_TIPO
	Local cCodObj  := ""
	Local aAreaAnt := GetArea()
	Local aAreaSD1 := SD1->(GetArea())
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaAC9 := AC9->(GetArea())
	Static oDlg
	Static oBot
	
	IF nOpcao == 5 .AND. nConfirma == 1
		DBSELECTAREA("PC2")
		IF DBSEEK(xFilial("PC2")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			while PC2->(!Eof()) .AND. ALLTRIM(PC2->PC2_DOC) == ALLTRIM(SF1->F1_DOC) .AND. ALLTRIM(PC2->PC2_SERIE) == ALLTRIM(SF1->F1_SERIE) .AND. ALLTRIM(PC2->PC2_FORNEC) == ALLTRIM(SF1->F1_FORNECE) .AND. ALLTRIM(PC2->PC2_LOJA) == ALLTRIM(SF1->F1_LOJA) .AND. PC2->PC2_FILIAL == xFilial("PC2")
				RECLOCK("PC2", .F.) // INCLUSÃO(.T.) ALTERAÇÃO(.F.)
				PC2->(DBDelete())
				MSUNLOCK()
				lRet := .T.
				PC2->(DBSKIP())
			ENDDO
		ENDIF
	endif
	
	//************************************************************************************************* 
	//* Função : MT103FIM
	//* Objetivo : Ponto de entrada para gerar mensagem adicional na DANFE quando for importacoes.
	//* Autor    : Patrick Araujo - 17/06/2017
	//************************************************************************************************* 
	DbSelectArea("SA2")
	DbSetOrder(1)
	if Dbseek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA)

		If SA2->A2_EST == "EX" .And. nOpcao == 4 .and. nConfirma == 1
	
			nTamSF1 	:= TamSX3("F1_MENNOTA")[1]
			cMens 		:= space(nTamSF1)
	
			DEFINE MSDIALOG oDlg TITLE "Mensagem Adicional a DANFE" FROM 0,0 TO 100,600 PIXEL

			@ 010, 024 MSGET cMens SIZE 234, 010 OF oDlg PIXEL
			@ 031, 117 BUTTON oBot PROMPT "OK" SIZE 015, 015 PIXEL OF oDlg Action(Gravar(oDlg,cMens,cF1doc,cF1serie,cF1forne,cF1loja,cF1tipo)) PIXEL
      
			ACTIVATE MSDIALOG oDlg CENTERED

		Endif
	
	endif

	// Relacionar os objetos vinculados aos pedidos de compras as notas de entrada e aos titulos a pagar  07/11/2023  Oscar Lira - TOTVS IP
	If nConfirma = 1 .and. (nOpcao = 3 .or. nOpcao = 4)
		SD1->(dBSetOrder(1))  // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		SE2->(dBSetOrder(6))  // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		AC9->(dBSetOrder(2))  // AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ

		// Chave unica SC7: C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN+C7_ITEMGRD
		// Chave unica SF1: F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL
		// Chave unica SE2: E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

		SD1->(MsSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
		While SD1->(!Eof() .and. D1_FILIAL = xFilial("SD1") .and. D1_DOC = SF1->F1_DOC .and. D1_SERIE = SF1->F1_SERIE .and. D1_FORNECE = SF1->F1_FORNECE .and. D1_LOJA = SF1->F1_LOJA)
			If !Empty(SD1->D1_PEDIDO) .and. ;
				AC9->(MsSeek(xFilial("AC9")+"SC7"+xFilial("SC7")+xFilial("SC7")+SD1->(D1_PEDIDO+D1_ITEMPC)))
				
				cCodObj := AC9->AC9_CODOBJ
				If AC9->(!MsSeek(xFilial("AC9")+"SF1"+xFilial("SF1")+SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL)+cCodObj))
					// Criar o relacionamento do objeto com a nota de entrada
					RecLock("AC9",.T.)
					AC9->AC9_FILIAL := xFilial("AC9")
					AC9->AC9_ENTIDA := "SF1"
					AC9->AC9_FILENT := xFilial("SF1")
					AC9->AC9_CODENT := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL)
					AC9->AC9_CODOBJ := cCodObj
					AC9->(MsUnlock())
				EndIf

				SE2->(MsSeek(xFilial("SE2")+SF1->(F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC)))
				While SE2->(!Eof() .and. E2_FILIAL = xFilial("SE2") .and. E2_FORNECE = SF1->F1_FORNECE .and. E2_LOJA = SF1->F1_LOJA .and. E2_PREFIXO = SF1->F1_SERIE .and. E2_NUM = SF1->F1_DOC)
					If AC9->(!MsSeek(xFilial("AC9")+"SE2"+xFilial("SE2")+SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+cCodObj))
						// Criar o relacionamento do objeto com o titutlo a pagar
						RecLock("AC9",.T.)
						AC9->AC9_FILIAL := xFilial("AC9")
						AC9->AC9_ENTIDA := "SE2"
						AC9->AC9_FILENT := xFilial("SE2")
						AC9->AC9_CODENT := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
						AC9->AC9_CODOBJ := cCodObj
						AC9->(MsUnlock())
					EndIf

                    // Gravar o numero do pedido de compra
                    RecLock("SE2",.F.)
                    SE2->E2_ZZPEDC := SD1->D1_PEDIDO
                    SE2->(MsUnlock())

					SE2->(dBSkip())
				Enddo
			EndIf

			SD1->(dBSkip())
		Enddo

		RestArea(aAreaAC9)
		RestArea(aAreaSE2)
		RestArea(aAreaSD1)
		RestArea(aAreaAnt)
	EndIf

return(nil)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 05/06/2019
@Hora: 16:49:25
@Versão: 1.0
@Uso: 
@Descrição: 
---------------------------------------------
Change:
--------------------------------------------*/
Static Function Gravar(oDlg,cMens,cF1doc,cF1serie,cF1forne,cF1loja,cF1tipo)

	If MsgYesNo("Deseja confirmar o texto digitado ?"+chr(13)+chr(10)+cMens)

		DbSelectArea("SF1")
		DbSetOrder(1)
		if Dbseek(xFilial("SF1") + cF1doc + cF1serie + cF1forne + cF1loja + cF1tipo)
			RECLOCK("SF1", .F.)
			SF1->F1_MENNOTA := cMens
			SF1->(MSUNLOCK())
			MsgAlert("OK PROCESSADO!")
			Retorno := oDlg:End()
		endif
	Else
		MsgAlert("Favor ajustar o texto digitado !")
	EndIf

Return(Retorno)
