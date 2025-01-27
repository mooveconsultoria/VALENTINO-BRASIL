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
	Local _aArea        := GetArea()

	
	Private _cErro  := ""
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


		// PROJETO JSON 

		If nConfirma = 1
			If nOpcao  = 5 // Exclusão 
				Set Delete Off
			Endif

			If U_VerCfop2(SF1->(F1_FILIAL+F1_DOC+F1_SERIE),GetNewPar("ZZ_CFOPD","1202"))  //Devolução e Retornos
				If !U_GeraJson(If(nOpcao=5,"6","3"),SF1->(F1_FILIAL+F1_DOC+F1_SERIE),If(nOpcao=5,"C","N"),"1")
					Alert(_cErro)
				Endif
			Endif

			If nOpcao  = 5 // Exclusão 
				Set Delete On
			Endif
		Endif

RestArea(_aArea)

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

/*--------------------------------------------
@Autor: 
@Data: 
@Versão: 1.0
@Uso: 
@Descrição: 
---------------------------------------------*/

User Function VerCfop2(cChave,cPar)
Local _aArea    := GetArea()
Local _lRet     := .F.

DbSelectArea("SD1")
DbSetOrder(1)
DbGoTop()

DbSeek(cChave)

Do While SD1->(D1_FILIAL+D1_DOC+D1_SERIE) = cChave .And. !Eof()

    If Substr(SD1->D1_CF,2,3) $ Substr(cPar,2,3)
        _lRet := .T.
        EXIT
    ENDIF

    DbSkip()

Enddo

RestArea(_aArea)
Return _lRet
